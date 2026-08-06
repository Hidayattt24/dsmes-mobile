import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/local_notification_service.dart';
import '../../../data/models/notification_model.dart';
import '../../../data/repositories/notification_repository.dart';
import '../models/notification_item.dart';

class NotificationsNotifier extends Notifier<List<NotificationItem>> {
  final Map<String, Timer> _scheduledTimers = {};
  final Set<String> _shownEducationIds = {};

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

  /// Fetch notifications from the backend and merge them into the inbox state.
  /// Locally-generated items (reminders scheduled in-app) are preserved.
  Future<void> loadFromBackend() async {
    try {
      final repo = ref.read(notificationRepositoryProvider);
      final items = await repo.getNotifications();

      final backendItems = items.map(_toItem).toList();
      final localItems =
          state.where((n) => n.id.startsWith('notif_')).toList();

      // De-duplicate by id (backend wins on conflict).
      final seen = <String>{};
      final merged = <NotificationItem>[];
      for (final item in [...backendItems, ...localItems]) {
        if (seen.add(item.id)) {
          merged.add(item);
        }
      }

      state = merged;

      // Auto-trigger system pop-ups for unread education notifications.
      _triggerEducationPopups(backendItems);
    } catch (_) {
      // Silently ignore network/auth failures (e.g. app opened pre-login).
    }
  }

  NotificationItem _toItem(NotificationModel n) {
    final isEducation = n.notifType == 'education';
    return NotificationItem(
      id: n.id,
      title: isEducation ? 'Materi Edukasi Baru' : 'Pengingat DSMES',
      description: n.messageText,
      timestamp: _formatTimestamp(n.notifiedAt),
      type: isEducation ? NotificationType.education : NotificationType.medication,
      isUnread: !n.isRead,
      group: _groupFor(n.notifiedAt),
      articleId: n.articleId,
    );
  }

  void _triggerEducationPopups(List<NotificationItem> backendItems) {
    for (final item in backendItems) {
      final isUnreadEducation =
          item.type == NotificationType.education && item.isUnread;
      if (isUnreadEducation && item.articleId != null) {
        if (_shownEducationIds.add(item.id)) {
          LocalNotificationService.instance.showNotification(
            id: item.articleId.hashCode.abs(),
            title: item.title,
            body: item.description,
            payload: item.articleId,
          );
        }
      }
    }
  }

  String _groupFor(String notifiedAt) {
    final dt = DateTime.tryParse(notifiedAt)?.toLocal();
    if (dt == null) return 'Hari Ini';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(dt.year, dt.month, dt.day);
    final diff = today.difference(day).inDays;

    if (diff == 0) return 'Hari Ini';
    if (diff == 1) return 'Kemarin';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  String _formatTimestamp(String notifiedAt) {
    final dt = DateTime.tryParse(notifiedAt)?.toLocal();
    if (dt == null) return notifiedAt;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(dt.year, dt.month, dt.day);
    final diff = today.difference(day).inDays;

    if (diff == 0) {
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
    if (diff == 1) return 'Kemarin';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  Future<void> markAsRead(String id) async {
    state = [
      for (final notification in state)
        if (notification.id == id) notification.copyWith(isUnread: false) else notification,
    ];
    // Locally-generated notifications (id prefix "notif_") only live in the
    // app's in-memory inbox and do NOT exist in the backend DB. Sending their
    // id to the API would fail (the DB uses UUID primary keys), so only
    // backend-synced (UUID) notifications are persisted via the API.
    if (id.startsWith('notif_')) return;
    try {
      await ref.read(notificationRepositoryProvider).markAsRead(id);
    } catch (_) {
      // Ignore sync failures; local state already updated.
    }
  }

  Future<void> markAllAsRead() async {
    state = [
      for (final notification in state)
        if (notification.isUnread) notification.copyWith(isUnread: false) else notification,
    ];
    try {
      await ref.read(notificationRepositoryProvider).markAllAsRead();
    } catch (_) {
      // Ignore sync failures; local state already updated.
    }
  }

  Future<void> deleteNotification(String id) async {
    state = [
      for (final notification in state)
        if (notification.id != id) notification,
    ];
    // Same as markAsRead: local notifications are not persisted in the backend.
    if (id.startsWith('notif_')) return;
    try {
      await ref.read(notificationRepositoryProvider).deleteNotification(id);
    } catch (_) {
      // Ignore sync failures; local state already updated.
    }
  }

  Future<void> clearAll() async {
    state = const [];
    try {
      await ref.read(notificationRepositoryProvider).deleteAllNotifications();
    } catch (_) {
      // Ignore sync failures; local state already updated.
    }
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
