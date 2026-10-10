import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../router/app_router.dart';
import '../router/route_names.dart';
import '../theme/app_colors.dart';

class LocalNotificationService {
  LocalNotificationService._();
  static final LocalNotificationService instance = LocalNotificationService._();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

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

    const androidSettings = AndroidInitializationSettings(
      'ic_stat_diba',
    );
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
        final notificationsGranted =
            await androidImplementation.requestNotificationsPermission();
        debugPrint(
          '[REMINDER][NOTIFICATION] permissions notifications=$notificationsGranted',
        );
      }
    } catch (e) {
      debugPrint('[REMINDER][NOTIFICATION] initialize skipped/failed: $e');
    }

    _isInitialized = true;
    debugPrint('[REMINDER][NOTIFICATION] initialize complete');
  }

  /// Checks if the application was launched by tapping a local notification from terminated state
  Future<void> checkAppLaunchNotification() async {
    try {
      final details =
          await _notificationsPlugin.getNotificationAppLaunchDetails();
      if (details != null && details.didNotificationLaunchApp) {
        final response = details.notificationResponse;
        if (response != null) {
          _onNotificationResponse(response);
        }
      }
    } catch (e) {
      debugPrint('[REMINDER][NOTIFICATION] checkAppLaunchNotification error: $e');
    }
  }

  Future<void> _onNotificationResponse(NotificationResponse response) async {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;

    try {
      if (payload.startsWith('{')) {
        final data = jsonDecode(payload) as Map<String, dynamic>;
        final type = data['type'] as String?;
        final articleId = data['article_id'] as String?;

        if (type == 'education' && articleId != null && articleId.isNotEmpty) {
          appNavigatorKey.currentContext?.go(
            '${RouteNames.educationDetail}/$articleId',
          );
        } else if (type == 'reminder') {
          appNavigatorKey.currentContext?.go(RouteNames.reminders);
        } else if (type == 'blood_sugar') {
          appNavigatorKey.currentContext?.go(RouteNames.bloodSugarEntry);
        }
      } else {
        // Plain string articleId fallback
        appNavigatorKey.currentContext?.go(
          '${RouteNames.educationDetail}/$payload',
        );
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
  }) async {
    await initialize();

    const androidDetails = AndroidNotificationDetails(
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
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
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
      debugPrint('[REMINDER][NOTIFICATION] showNotification SUCCESS id=$id');
    } catch (e, stack) {
      debugPrint(
        '[REMINDER][NOTIFICATION][ERROR] primary show failed: $e\n$stack',
      );
      // Fallback without explicit icon (uses initialization default icon)
      try {
        const fallbackDetails = NotificationDetails(
          android: AndroidNotificationDetails(
            'dsmes_reminders_channel',
            'Pengingat DIBA',
            channelDescription:
                'Saluran notifikasi pengingat harian diabetes DIBA',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: true,
            playSound: true,
            enableVibration: true,
            color: AppColors.primary,
          ),
          iOS: iosDetails,
        );
        await _notificationsPlugin.show(
          id,
          title,
          body,
          fallbackDetails,
          payload: payload,
        );
        debugPrint(
          '[REMINDER][NOTIFICATION] fallback showNotification SUCCESS id=$id',
        );
      } catch (fallbackError) {
        debugPrint(
          '[REMINDER][NOTIFICATION][FATAL] fallback failed: $fallbackError',
        );
      }
    }
  }

  /// Schedule a system alarm notification for daily/weekly reminders.
  ///
  /// Schedules at the given hour:minute in Asia/Jakarta regardless of the
  /// device timezone. Uses `inexactAllowWhileIdle` which does NOT require the
  /// SCHEDULE_EXACT_ALARM permission on Android 12+, making it far more likely
  /// to actually fire at the intended time.
  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    await initialize();

    const androidDetails = AndroidNotificationDetails(
      'dsmes_reminders_channel',
      'Pengingat DIBA',
      channelDescription: 'Saluran notifikasi pengingat harian diabetes DIBA',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: 'ic_stat_diba',
      color: AppColors.primary,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    try {
      final now = tz.TZDateTime.now(tz.local);
      var scheduledTzDateTime = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );
      // If today's target time already passed, schedule for tomorrow.
      if (!scheduledTzDateTime.isAfter(now)) {
        scheduledTzDateTime = scheduledTzDateTime.add(const Duration(days: 1));
      }

      try {
        await _notificationsPlugin.zonedSchedule(
          id,
          title,
          body,
          scheduledTzDateTime,
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
        );
      } catch (_) {
        await _notificationsPlugin.zonedSchedule(
          id,
          title,
          body,
          scheduledTzDateTime,
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
        );
      }
      debugPrint('[REMINDER][NOTIFICATION] daily scheduled id=$id at=$scheduledTzDateTime');
    } catch (e) {
      debugPrint('[REMINDER][NOTIFICATION][ERROR] daily id=$id error=$e');
    }
  }

  Future<void> scheduleWeeklyNotification({
    required int id,
    required String title,
    required String body,
    required int weekday,
    required int hour,
    required int minute,
  }) async {
    await initialize();

    const androidDetails = AndroidNotificationDetails(
      'dsmes_reminders_channel',
      'Pengingat DIBA',
      channelDescription: 'Saluran notifikasi pengingat harian diabetes DIBA',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: 'ic_stat_diba',
      color: AppColors.primary,
    );
    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    try {
      final now = tz.TZDateTime.now(tz.local);
      var scheduled = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );
      var daysUntil = (weekday - scheduled.weekday) % 7;
      if (daysUntil == 0 && !scheduled.isAfter(now)) daysUntil = 7;
      scheduled = scheduled.add(Duration(days: daysUntil));

      try {
        await _notificationsPlugin.zonedSchedule(
          id,
          title,
          body,
          scheduled,
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
      } catch (_) {
        await _notificationsPlugin.zonedSchedule(
          id,
          title,
          body,
          scheduled,
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
      }
      final pending = await _notificationsPlugin.pendingNotificationRequests();
      debugPrint(
        '[REMINDER][NOTIFICATION] weekly scheduled id=$id pending=${pending.length}',
      );
    } catch (e) {
      debugPrint('[REMINDER][NOTIFICATION][ERROR] weekly id=$id error=$e');
    }
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
