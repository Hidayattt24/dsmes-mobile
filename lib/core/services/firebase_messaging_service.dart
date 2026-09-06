import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import '../../data/repositories/device_token_repository.dart';
import '../../firebase_options.dart';
import '../router/app_router.dart';
import '../router/route_names.dart';
import 'local_notification_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('[FCM][BACKGROUND] message=${message.messageId}');
}

class FirebaseMessagingService {
  FirebaseMessagingService._();

  static final instance = FirebaseMessagingService._();
  late final FirebaseMessaging _messaging;
  DeviceTokenRepository? _repository;
  bool _tokenRefreshAttached = false;
  bool _initialized = false;

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

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleOpenedMessage(initialMessage);
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

    final title =
        message.notification?.title ??
        message.data['title'] ??
        'Notifikasi DSMES';
    final body = message.notification?.body ?? message.data['body'] ?? '';

    await LocalNotificationService.instance.showNotification(
      id: message.messageId.hashCode.abs(),
      title: title,
      body: body,
      payload: jsonEncode({
        'type': message.data['type'],
        'article_id': message.data['article_id'],
      }),
    );
  }

  void _handleOpenedMessage(RemoteMessage message) {
    debugPrint(
      '[FCM][OPENED] message=${message.messageId} type=${message.data['type']}',
    );

    if (message.data['type'] == 'education') {
      final articleId = message.data['article_id'];
      if (articleId == null || articleId.isEmpty) return;

      appNavigatorKey.currentContext?.go(
        '${RouteNames.educationDetail}/$articleId',
      );
    }
  }
}

final firebaseMessagingService = FirebaseMessagingService.instance;
