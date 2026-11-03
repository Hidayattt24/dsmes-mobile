import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../router/app_router.dart';
import '../router/notification_action_router.dart';
import '../theme/app_colors.dart';
import 'notification_deduplicator.dart';

class LocalNotificationService {
  LocalNotificationService._();
  static final LocalNotificationService instance = LocalNotificationService._();

  static const String keyLegacyLocalAlarmsCleaned =
      'legacy_local_alarms_cleaned_v1';
  static const String keyLegacyActiveNotificationsCleaned =
      'legacy_active_notifications_cleaned_v2';

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  bool _appLaunchActionHandled = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    debugPrint('[REMINDER][NOTIFICATION] initialize start');

    try {
      tz.initializeTimeZones();
      try {
        tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
      } catch (_) {}
    } catch (e) {
      debugPrint('LocalNotificationService: timezone init failed: $e');
    }

    const androidSettings = AndroidInitializationSettings('ic_stat_diba');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    try {
      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationResponse,
      );

      final androidImplementation =
          _notificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();
      if (androidImplementation != null) {
        const channel = AndroidNotificationChannel(
          'dsmes_reminders_channel',
          'Pengingat DIBA',
          description: 'Saluran notifikasi pengingat harian diabetes DIBA',
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
        );
        await androidImplementation.createNotificationChannel(channel);

        // Safely request permission only if supported/safe, never crash background isolate
        try {
          final notificationsGranted =
              await androidImplementation.requestNotificationsPermission();
          debugPrint(
            '[REMINDER][NOTIFICATION] permissions notifications=$notificationsGranted',
          );
        } catch (permError) {
          debugPrint(
            '[REMINDER][NOTIFICATION] requestNotificationsPermission skipped: $permError',
          );
        }
      }
    } catch (e) {
      debugPrint('[REMINDER][NOTIFICATION] initialize skipped/failed: $e');
    }

    _isInitialized = true;
    debugPrint('[REMINDER][NOTIFICATION] initialize complete');
  }

  /// Checks if the application was launched by tapping a local notification from terminated state
  Future<void> checkAppLaunchNotification() async {
    if (_appLaunchActionHandled) return;
    try {
      final details =
          await _notificationsPlugin.getNotificationAppLaunchDetails();
      if (details != null && details.didNotificationLaunchApp) {
        final response = details.notificationResponse;
        if (response != null) {
          _appLaunchActionHandled = true;
          await _onNotificationResponse(response);
        }
      }
    } catch (e) {
      debugPrint(
        '[REMINDER][NOTIFICATION] checkAppLaunchNotification error: $e',
      );
    }
  }

  Future<void> _onNotificationResponse(NotificationResponse response) async {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;

    try {
      if (payload.startsWith('{')) {
        final data = jsonDecode(payload) as Map<String, dynamic>;
        final context = appNavigatorKey.currentContext;
        if (context != null) {
          NotificationActionRouter.open(
            context,
            actionType: data['action_type'] as String?,
            articleId: data['article_id'] as String?,
            legacyType: data['type'] as String?,
          );
        }
      } else {
        // Plain string articleId fallback
        final context = appNavigatorKey.currentContext;
        if (context != null) {
          NotificationActionRouter.open(
            context,
            actionType: NotificationActions.educationDetail,
            articleId: payload,
          );
        }
      }
    } catch (_) {
      // Ignore malformed payloads.
    }
  }

  /// Instantly trigger a system pop-up notification on Android status bar
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    String? tag,
    String source = 'local',
  }) async {
    await initialize();

    final androidDetails = AndroidNotificationDetails(
      'dsmes_reminders_channel',
      'Pengingat DIBA',
      channelDescription: 'Saluran notifikasi pengingat harian diabetes DIBA',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      playSound: true,
      enableVibration: true,
      icon: 'ic_stat_diba',
      color: AppColors.primary,
      tag: tag,
      onlyAlertOnce: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _notificationsPlugin.show(
        id,
        title,
        body,
        notificationDetails,
        payload: payload,
      );
      debugPrint(
        '[REMINDER][NOTIFICATION] displayed source=$source id=$id tag=$tag',
      );
    } catch (e, stack) {
      debugPrint(
        '[REMINDER][NOTIFICATION][ERROR] primary show failed: $e\n$stack',
      );
      // Secondary fallback without sound/vibration if policy blocks
      try {
        final fallbackAndroid = AndroidNotificationDetails(
          'dsmes_reminders_channel',
          'Pengingat DIBA',
          channelDescription:
              'Saluran notifikasi pengingat harian diabetes DIBA',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: 'ic_stat_diba',
          color: AppColors.primary,
          tag: tag,
          onlyAlertOnce: true,
        );
        await _notificationsPlugin.show(
          id,
          title,
          body,
          NotificationDetails(android: fallbackAndroid),
          payload: payload,
        );
      } catch (fallbackError) {
        debugPrint(
          '[REMINDER][NOTIFICATION][FATAL] fallback show failed: $fallbackError',
        );
      }
    }
  }

  /// Cancels all pending scheduled notifications from legacy local alarm schedulers.
  /// Does NOT cancel active status bar notifications or affect inbox.
  /// If [force] is false, runs only once per installation/migration.
  Future<int> cleanupLegacyScheduledNotifications({bool force = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!force && (prefs.getBool(keyLegacyLocalAlarmsCleaned) ?? false)) {
        return 0;
      }

      await initialize();
      final pendingRequests =
          await _notificationsPlugin.pendingNotificationRequests();
      final count = pendingRequests.length;
      debugPrint(
        '[REMINDER][STARTUP_CLEANUP] found $count legacy scheduled notifications',
      );

      for (final req in pendingRequests) {
        await _notificationsPlugin.cancel(req.id);
      }

      var activeCanceled = 0;
      if (defaultTargetPlatform == TargetPlatform.android &&
          !(prefs.getBool(keyLegacyActiveNotificationsCleaned) ?? false)) {
        try {
          final active = await _notificationsPlugin.getActiveNotifications();
          for (final notification in active) {
            final title = notification.title ?? '';
            final body = notification.body ?? '';
            final isOldReminder =
                notification.id != null &&
                notification.channelId == 'dsmes_reminders_channel' &&
                (notification.tag == null || notification.tag!.isEmpty) &&
                (title.startsWith('Waktunya ') ||
                    title.startsWith('Saatnya ')) &&
                !body.startsWith('Hai,');
            if (isOldReminder) {
              await _notificationsPlugin.cancel(notification.id!);
              activeCanceled++;
            }
          }
          await prefs.setBool(keyLegacyActiveNotificationsCleaned, true);
        } catch (error) {
          debugPrint(
            '[REMINDER][STARTUP_CLEANUP] active notification scan failed: $error',
          );
        }
      }

      await prefs.setBool(keyLegacyLocalAlarmsCleaned, true);
      debugPrint(
        '[REMINDER][STARTUP_CLEANUP] canceled_pending=$count canceled_active_legacy=$activeCanceled',
      );
      NotificationDeduplicator.logDecision(
        source: 'legacy_local',
        occurrenceId: 'all_pending',
        decision: 'cleaned_up ($count)',
      );
      return count;
    } catch (e) {
      debugPrint(
        '[REMINDER][STARTUP_CLEANUP] failed to cleanup legacy alarms: $e',
      );
      return 0;
    }
  }

  /// Deprecated: FCM worker is the authoritative scheduler.
  /// Kept as no-op to prevent duplicate alarm registration.
  @Deprecated('FCM worker is the authoritative scheduler. Local alarms are disabled.')
  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String? tag,
  }) async {
    debugPrint(
      '[REMINDER][NOTIFICATION][DEPRECATED] scheduleDailyNotification called for id=$id, ignored to prevent duplicate popup.',
    );
  }

  /// Deprecated: FCM worker is the authoritative scheduler.
  /// Kept as no-op to prevent duplicate alarm registration.
  @Deprecated('FCM worker is the authoritative scheduler. Local alarms are disabled.')
  Future<void> scheduleWeeklyNotification({
    required int id,
    required String title,
    required String body,
    required int weekday,
    required int hour,
    required int minute,
    String? tag,
  }) async {
    debugPrint(
      '[REMINDER][NOTIFICATION][DEPRECATED] scheduleWeeklyNotification called for id=$id, ignored to prevent duplicate popup.',
    );
  }

  /// Cancel scheduled notification by ID
  Future<void> cancelNotification(int id) async {
    try {
      await _notificationsPlugin.cancel(id);
    } catch (e) {
      debugPrint('[REMINDER][NOTIFICATION] cancel failed: $e');
    }
  }

  /// Cancel all scheduled notifications
  Future<void> cancelAllNotifications() async {
    try {
      await _notificationsPlugin.cancelAll();
    } catch (e) {
      debugPrint('[REMINDER][NOTIFICATION] cancelAll failed: $e');
    }
  }
}
