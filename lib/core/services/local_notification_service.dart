import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../router/app_router.dart';
import '../router/route_names.dart';

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
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
    } catch (e) {
      // If timezone initialization fails, the schedule would silently be off.
      // Log it so the issue is visible instead of scheduling at the wrong time.
      debugPrint('LocalNotificationService: timezone init failed: $e');
    }

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
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

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    // Create high-importance Android Notification Channel & Request Permissions
    final androidImplementation =
        _notificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
    if (androidImplementation != null) {
      const channel = AndroidNotificationChannel(
        'dsmes_reminders_channel',
        'Pengingat DSMES',
        description: 'Saluran notifikasi pengingat harian diabetes DSMES',
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

    _isInitialized = true;
    debugPrint('[REMINDER][NOTIFICATION] initialize complete');
  }

  Future<void> _onNotificationResponse(NotificationResponse response) async {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;

    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      if (data['type'] == 'education') {
        final articleId = data['article_id'] as String?;
        if (articleId == null || articleId.isEmpty) return;
        appNavigatorKey.currentContext?.go(
          '${RouteNames.educationDetail}/$articleId',
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
      'Pengingat DSMES',
      channelDescription: 'Saluran notifikasi pengingat harian diabetes DSMES',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      playSound: true,
      enableVibration: true,
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

    await _notificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
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
      'Pengingat DSMES',
      channelDescription: 'Saluran notifikasi pengingat harian diabetes DSMES',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
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
      final tzLocation = tz.getLocation('Asia/Jakarta');
      final now = tz.TZDateTime.now(tzLocation);
      var scheduledTzDateTime = tz.TZDateTime(
        tzLocation,
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
    } catch (e) {
      // Scheduling a recurring alarm can fail on some devices. We intentionally
      // do NOT fall back to an immediate pop-up (that would notify the user at
      // the wrong time); the in-app inbox entry still reminds the user while
      // the app is open.
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
      'Pengingat DSMES',
      channelDescription: 'Saluran notifikasi pengingat harian diabetes DSMES',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
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
      final location = tz.getLocation('Asia/Jakarta');
      final now = tz.TZDateTime.now(location);
      var scheduled = tz.TZDateTime(
        location,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );
      var daysUntil = (weekday - scheduled.weekday) % 7;
      if (daysUntil == 0 && !scheduled.isAfter(now)) daysUntil = 7;
      scheduled = scheduled.add(Duration(days: daysUntil));

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
    await _notificationsPlugin.cancel(id);
  }

  /// Cancel all scheduled notifications
  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }
}
