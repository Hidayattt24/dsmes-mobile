import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../data/repositories/device_token_repository.dart';
import '../../features/notifications/helpers/notification_copywriter.dart';
import '../../features/notifications/models/notification_item.dart';
import '../../firebase_options.dart';
import '../constants/app_constants.dart';
import '../router/app_router.dart';
import '../router/notification_action_router.dart';
import 'local_notification_service.dart';
import 'notification_deduplicator.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint(
    '[FCM][BACKGROUND] message=${message.messageId} sent_at=${message.data['sent_at']} received_at=${DateTime.now().toUtc().toIso8601String()}',
  );

  // If payload is data-only (no system notification), show notification only if user is logged in
  if (message.notification == null) {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: AppConstants.keyAuthToken);
    if (token != null && token.isNotEmpty) {
      if (message.data['type'] == 'reminder' &&
          (message.data['occurrence_id']?.isEmpty ?? true)) {
        debugPrint('[FCM][BACKGROUND] ignored legacy reminder without occurrence_id');
        return;
      }
      final key = NotificationDeduplicator.resolveKey(
        message.data,
        messageId: message.messageId,
      );

      if (key.isNotEmpty && await NotificationDeduplicator.isDuplicate(key)) {
        NotificationDeduplicator.logDecision(
          source: 'fcm_data',
          occurrenceId: key,
          decision: 'deduplicated',
        );
        return;
      }

      if (key.isNotEmpty) {
        await NotificationDeduplicator.markProcessed(key);
      }
      NotificationDeduplicator.logDecision(
        source: 'fcm_data',
        occurrenceId: key.isNotEmpty ? key : (message.messageId ?? 'unknown'),
        decision: 'displayed',
      );

      final username = await storage.read(
        key: AppConstants.keyNotificationUsername,
      );
      final rawTitle = message.data['title'] ?? 'Pengingat DIBA';
      final rawBody = message.data['body'] ?? '';
      final alreadyPersonalized = rawBody.toLowerCase().startsWith('hai,');
      final notifId =
          key.isNotEmpty
              ? NotificationDeduplicator.resolveNotificationId(key)
              : message.messageId.hashCode.abs();
      final reminderId = message.data['reminder_id'];
      final notifTag = reminderId != null ? 'reminder_$reminderId' : null;

      await LocalNotificationService.instance.showNotification(
        source: 'fcm_data',
        id: notifId,
        tag: notifTag,
        title: rawTitle,
        body:
            username == null || username.trim().isEmpty || alreadyPersonalized
                ? rawBody
                : 'Hai, ${username.trim()}! $rawBody',
        payload: jsonEncode({
          'type': message.data['type'],
          'article_id': message.data['article_id'],
          'reminder_id': message.data['reminder_id'],
          'action_type': message.data['action_type'],
          'occurrence_id': message.data['occurrence_id'],
          'scheduled_at': message.data['scheduled_at'],
          'sent_at': message.data['sent_at'],
        }),
      );
    }
  }
}

class FirebaseMessagingService {
  FirebaseMessagingService._();

  static final instance = FirebaseMessagingService._();
  late final FirebaseMessaging _messaging;
  DeviceTokenRepository? _repository;
  bool _tokenRefreshAttached = false;
  bool _initialized = false;
  RemoteMessage? _pendingMessage;

  Future<void> initialize() async {
    if (_initialized) return;
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    _messaging = FirebaseMessaging.instance;
    _initialized = true;
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    debugPrint('[FCM] authorization=${settings.authorizationStatus}');

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleOpenedMessage);

    // Buffer initial message if available
    try {
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _pendingMessage = initialMessage;
      }
    } catch (e) {
      debugPrint('[FCM] getInitialMessage error: $e');
    }
  }

  /// Checks and processes any pending initial notification that launched the app
  Future<void> checkInitialMessage() async {
    if (!_initialized) return;
    try {
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _pendingMessage = null;
        _handleOpenedMessage(initialMessage);
      } else if (_pendingMessage != null) {
        final pending = _pendingMessage!;
        _pendingMessage = null;
        _handleOpenedMessage(pending);
      }
    } catch (e) {
      debugPrint('[FCM] checkInitialMessage error: $e');
    }
  }

  Future<void> registerCurrentToken(DeviceTokenRepository repository) async {
    if (!_initialized) {
      debugPrint('[FCM] token registration skipped; Firebase is unavailable');
      return;
    }
    _repository = repository;
    final token = await _messaging.getToken();
    if (token != null && token.isNotEmpty) {
      await _registerToken(repository, token);
    }
    if (!_tokenRefreshAttached) {
      _tokenRefreshAttached = true;
      _messaging.onTokenRefresh.listen((newToken) {
        final currentRepository = _repository;
        if (currentRepository != null) {
          _registerToken(currentRepository, newToken);
        }
      });
    }
  }

  Future<void> unregisterCurrentToken(DeviceTokenRepository repository) async {
    if (!_initialized) return;
    final token = await _messaging.getToken();
    if (token != null && token.isNotEmpty) {
      try {
        await repository.delete(token);
      } catch (_) {
        // Rotate locally even if the server cannot be reached. Firebase will
        // invalidate the old installation token and issue a fresh one on login.
      }
    }
    await _messaging.deleteToken();
    _repository = null;
    NotificationActionRouter.clearPending();
  }

  Future<void> _registerToken(
    DeviceTokenRepository repository,
    String token,
  ) async {
    try {
      await repository.register(token);
      debugPrint('[FCM] token registered');
    } catch (error) {
      debugPrint('[FCM][ERROR] token registration failed: $error');
    }
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint(
      '[FCM][FOREGROUND] message=${message.messageId} sent_at=${message.data['sent_at']} received_at=${DateTime.now().toUtc().toIso8601String()}',
    );

    // Guard: only display notifications if user is currently logged in
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: AppConstants.keyAuthToken);
    if (token == null || token.isEmpty) {
      debugPrint(
        '[FCM] Ignoring foreground notification: no active user session.',
      );
      return;
    }

    if (message.data['type'] == 'reminder' &&
        (message.data['occurrence_id']?.isEmpty ?? true)) {
      debugPrint('[FCM][FOREGROUND] ignored legacy reminder without occurrence_id');
      return;
    }

    final key = NotificationDeduplicator.resolveKey(
      message.data,
      messageId: message.messageId,
    );

    if (key.isNotEmpty && await NotificationDeduplicator.isDuplicate(key)) {
      NotificationDeduplicator.logDecision(
        source: 'fcm_foreground',
        occurrenceId: key,
        decision: 'deduplicated',
      );
      return;
    }

    if (key.isNotEmpty) {
      await NotificationDeduplicator.markProcessed(key);
    }
    NotificationDeduplicator.logDecision(
      source: 'fcm_foreground',
      occurrenceId: key.isNotEmpty ? key : (message.messageId ?? 'unknown'),
      decision: 'displayed',
    );

    final rawTitle =
        message.notification?.title ??
        message.data['title'] ??
        'Pengingat DIBA';
    final rawBody = message.notification?.body ?? message.data['body'] ?? '';
    final notifTypeStr = message.data['type'] as String? ?? 'reminder';
    final iconName = message.data['icon_name'] as String?;
    final activityName = message.data['activity_name'] as String?;
    final category = message.data['category'] as String?;
    final username = await storage.read(
      key: AppConstants.keyNotificationUsername,
    );
    final notifType =
        notifTypeStr == 'education'
            ? NotificationType.education
            : NotificationType.medication;

    final backendHasCopy =
        rawBody.isNotEmpty &&
        rawTitle != 'Pengingat DIBA' &&
        rawTitle != 'Pengingat DSMES';

    final (title, body) =
        backendHasCopy
            ? (rawTitle, rawBody)
            : NotificationCopywriter.getInteractiveCopy(
              rawTitle: rawTitle,
              rawDescription: rawBody,
              type: notifType,
              iconName: iconName,
              activityName: activityName,
              category: category,
              username: username,
              actionType: message.data['action_type'] as String?,
            );

    final reminderId = message.data['reminder_id'];
    final notifId =
        key.isNotEmpty
            ? NotificationDeduplicator.resolveNotificationId(key)
            : (reminderId != null
                ? reminderId.hashCode.abs()
                : message.messageId.hashCode.abs());
    final notifTag = reminderId != null ? 'reminder_$reminderId' : null;

    await LocalNotificationService.instance.showNotification(
      source: 'fcm_foreground',
      id: notifId,
      tag: notifTag,
      title: title,
      body: body,
      payload: jsonEncode({
        'type': message.data['type'],
        'article_id': message.data['article_id'],
        'reminder_id': message.data['reminder_id'],
        'action_type': message.data['action_type'],
        'occurrence_id': message.data['occurrence_id'],
        'scheduled_at': message.data['scheduled_at'],
        'sent_at': message.data['sent_at'],
      }),
    );
  }

  Future<void> invalidateLocalToken() async {
    if (!_initialized) return;
    try {
      await _messaging.deleteToken();
    } catch (error) {
      debugPrint('[FCM] local token invalidation failed: $error');
    }
    _repository = null;
    _pendingMessage = null;
    NotificationActionRouter.clearPending();
  }

  void _handleOpenedMessage(RemoteMessage message) {
    debugPrint(
      '[FCM][OPENED] message=${message.messageId} type=${message.data['type']} sent_at=${message.data['sent_at']} opened_at=${DateTime.now().toUtc().toIso8601String()}',
    );

    final context = appNavigatorKey.currentContext;
    if (context == null || !context.mounted) {
      _pendingMessage = message;
      return;
    }

    NotificationActionRouter.open(
      context,
      actionType: message.data['action_type'],
      articleId: message.data['article_id'],
      legacyType: message.data['type'],
    );
  }
}

final firebaseMessagingService = FirebaseMessagingService.instance;
