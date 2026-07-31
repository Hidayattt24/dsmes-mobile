import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/notification_item.dart';

class NotificationsNotifier extends Notifier<List<NotificationItem>> {
  final Map<String, Timer> _scheduledTimers = {};

  @override
  List<NotificationItem> build() {
    ref.onDispose(() {
      for (final timer in _scheduledTimers.values) {
        timer.cancel();
      }
      _scheduledTimers.clear();
    });
    return const [];
  }

  void markAsRead(String id) {
    state = [
      for (final notification in state)
        if (notification.id == id) notification.copyWith(isUnread: false) else notification,
    ];
  }

  void markAllAsRead() {
    state = [
      for (final notification in state)
        if (notification.isUnread) notification.copyWith(isUnread: false) else notification,
    ];
  }

  void deleteNotification(String id) {
    state = [
      for (final notification in state)
        if (notification.id != id) notification,
    ];
  }

  void clearAll() {
    state = const [];
  }

  void addNotification({
    required String title,
    required String description,
    NotificationType type = NotificationType.medication,
    String? customTimestamp,
  }) {
    final newItem = NotificationItem(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      description: description,
      timestamp: customTimestamp ?? 'Baru saja',
      type: type,
      isUnread: true,
      group: 'Hari Ini',
    );
    state = [newItem, ...state];
  }

  /// Schedule a notification to be added to the inbox list at a specific time (HH:mm)
  void scheduleReminderNotification({
    required String title,
    required String description,
    required String scheduledTimeStr,
    NotificationType type = NotificationType.medication,
  }) {
    final timeParts = scheduledTimeStr.split(':');
    if (timeParts.length < 2) {
      addNotification(title: title, description: description, type: type);
      return;
    }

    final hour = int.tryParse(timeParts[0]) ?? 8;
    final minute = int.tryParse(timeParts[1]) ?? 0;

    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);

    // If target time for today has already passed, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final delay = scheduledDate.difference(now);
    final timerId = '${title}_${scheduledDate.millisecondsSinceEpoch}';

    _scheduledTimers[timerId]?.cancel();
    _scheduledTimers[timerId] = Timer(delay, () {
      addNotification(
        title: title,
        description: description,
        type: type,
        customTimestamp: '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} WIB',
      );
      _scheduledTimers.remove(timerId);
    });
  }
}

final notificationsProvider = NotifierProvider<NotificationsNotifier, List<NotificationItem>>(
  NotificationsNotifier.new,
);

