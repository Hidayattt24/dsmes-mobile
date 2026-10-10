import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

import '../../data/repositories/device_token_repository.dart';
import '../../features/notifications/helpers/notification_copywriter.dart';
import '../../features/notifications/models/notification_item.dart';
import '../../firebase_options.dart';
import '../constants/app_constants.dart';
import '../router/app_router.dart';
import '../router/route_names.dart';
import 'local_notification_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('[FCM][BACKGROUND] message=${message.messageId}');

  // If payload is data-only (no system notification), show notification only if user is logged in
  if (message.notification == null) {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: AppConstants.keyAuthToken);
    if (token != null && token.isNotEmpty) {
      final rawTitle = message.data['title'] ?? 'Pengingat DIBA';
      final rawBody = message.data['body'] ?? '';
      await LocalNotificationService.instance.showNotification(
        id: message.messageId.hashCode.abs(),
        title: rawTitle,
        body: rawBody,
        payload: jsonEncode({
          'type': message.data['type'],
          'article_id': message.data['article_id'],
          'reminder_id': message.data['reminder_id'],
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
    if (token == null || token.isEmpty) return;
    await repository.delete(token);
    _repository = null;
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
    debugPrint('[FCM][FOREGROUND] message=${message.messageId}');

    // Guard: only display notifications if user is currently logged in
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: AppConstants.keyAuthToken);
    if (token == null || token.isEmpty) {
      debugPrint('[FCM] Ignoring foreground notification: no active user session.');
      return;
    }

    final rawTitle =
        message.notification?.title ??
        message.data['title'] ??
        'Pengingat DIBA';
    final rawBody = message.notification?.body ?? message.data['body'] ?? '';
    final notifTypeStr = message.data['type'] as String? ?? 'reminder';
    final iconName = message.data['icon_name'] as String?;
    final activityName = message.data['activity_name'] as String?;
    final notifType = notifTypeStr == 'education'
        ? NotificationType.education
        : NotificationType.medication;

    final (title, body) = NotificationCopywriter.getInteractiveCopy(
      rawTitle: rawTitle,
      rawDescription: rawBody,
      type: notifType,
      iconName: iconName,
      activityName: activityName,
    );

    await LocalNotificationService.instance.showNotification(
      id: message.messageId.hashCode.abs(),
      title: title,
      body: body,
      payload: jsonEncode({
        'type': message.data['type'],
        'article_id': message.data['article_id'],
        'reminder_id': message.data['reminder_id'],
      }),
    );
  }

  void _handleOpenedMessage(RemoteMessage message) {
    debugPrint(
      '[FCM][OPENED] message=${message.messageId} type=${message.data['type']}',
    );

    final context = appNavigatorKey.currentContext;
    if (context == null || !context.mounted) {
      _pendingMessage = message;
      return;
    }

    final type = message.data['type'];
    final articleId = message.data['article_id'];

    if (type == 'education' && articleId != null && articleId.toString().isNotEmpty) {
      context.go('${RouteNames.educationDetail}/$articleId');
    } else if (type == 'reminder') {
      context.go(RouteNames.reminders);
    } else if (type == 'blood_sugar') {
      context.go(RouteNames.bloodSugarEntry);
    }
  }
}

final firebaseMessagingService = FirebaseMessagingService.instance;
