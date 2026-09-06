import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/local_notification_service.dart';
import '../../../../data/repositories/reminder_repository.dart';
import '../models/reminder_model.dart';

class ReminderListNotifier extends AsyncNotifier<List<ReminderModel>> {
  @override
  Future<List<ReminderModel>> build() async {
    return _fetchReminders();
  }

  Future<List<ReminderModel>> _fetchReminders() async {
    final repo = ref.read(reminderRepositoryProvider);
    final reminders = await repo.list();
    for (final reminder in reminders.where((reminder) => reminder.isActive)) {
      await _scheduleSystemNotifications(reminder);
    }
    return reminders;
  }

  int _notificationId(String reminderId, int weekday) {
    return (reminderId.hashCode.abs() % 1000000) * 10 + weekday;
  }

  Future<void> _cancelSystemNotifications(String reminderId) async {
    // Cancel the legacy single daily ID as well as the current per-weekday IDs.
    await LocalNotificationService.instance.cancelNotification(
      reminderId.hashCode.abs(),
    );
    for (var weekday = 1; weekday <= 7; weekday++) {
      await LocalNotificationService.instance.cancelNotification(
        _notificationId(reminderId, weekday),
      );
    }
  }

  Future<void> _scheduleSystemNotifications(ReminderModel reminder) async {
    final parts = reminder.scheduledTime.split(':');
    if (parts.length < 2) return;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return;

    final days = reminder.activeDays.toSet().where(
      (day) => day >= 1 && day <= 7,
    );
    await _cancelSystemNotifications(reminder.id);
    for (final weekday in days) {
      await LocalNotificationService.instance.scheduleWeeklyNotification(
        id: _notificationId(reminder.id, weekday),
        title: 'Pengingat DSMES: ${reminder.activityName}',
        body:
            reminder.notes.isEmpty
                ? 'Waktunya melakukan ${reminder.activityName}.'
                : reminder.notes,
        weekday: weekday,
        hour: hour,
        minute: minute,
      );
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetchReminders);
  }

  Future<void> create({
    required String activityName,
    required String category,
    required String scheduledTime,
    String notes = '',
    String iconName = 'default',
    int repeatIntervalDays = 1,
    required List<int> activeDays,
  }) async {
    final repo = ref.read(reminderRepositoryProvider);
    final newReminder = await repo.create(
      activityName: activityName,
      category: category,
      scheduledTime: scheduledTime,
      notes: notes,
      iconName: iconName,
      repeatIntervalDays: repeatIntervalDays,
      activeDays: activeDays,
    );
    final current = <ReminderModel>[
      ...(state.valueOrNull ?? <ReminderModel>[]),
      newReminder,
    ];
    state = AsyncValue.data(current);
    if (newReminder.isActive) {
      await _scheduleSystemNotifications(newReminder);
    }
  }

  Future<void> updateReminder(
    String id, {
    required String activityName,
    required String category,
    required String scheduledTime,
    String notes = '',
    String iconName = 'default',
    int repeatIntervalDays = 1,
    required List<int> activeDays,
  }) async {
    final repo = ref.read(reminderRepositoryProvider);
    final updated = await repo.update(
      id,
      activityName: activityName,
      category: category,
      scheduledTime: scheduledTime,
      notes: notes,
      iconName: iconName,
      repeatIntervalDays: repeatIntervalDays,
      activeDays: activeDays,
    );
    final current = state.valueOrNull ?? <ReminderModel>[];
    state = AsyncValue.data(
      current.map((r) => r.id == id ? updated : r).toList(),
    );
    await _cancelSystemNotifications(id);
    if (updated.isActive) {
      await _scheduleSystemNotifications(updated);
    }
  }

  Future<void> toggle(String id) async {
    final repo = ref.read(reminderRepositoryProvider);
    final updated = await repo.toggle(id);
    final current = state.valueOrNull ?? <ReminderModel>[];
    state = AsyncValue.data(
      current.map((r) => r.id == id ? updated : r).toList(),
    );
    if (updated.isActive) {
      await _cancelSystemNotifications(id);
      await _scheduleSystemNotifications(updated);
    } else {
      await _cancelSystemNotifications(id);
    }
  }

  Future<void> delete(String id) async {
    final repo = ref.read(reminderRepositoryProvider);
    await repo.delete(id);
    await _cancelSystemNotifications(id);
    final current = state.valueOrNull ?? <ReminderModel>[];
    state = AsyncValue.data(current.where((r) => r.id != id).toList());
  }
}

final reminderListProvider =
    AsyncNotifierProvider<ReminderListNotifier, List<ReminderModel>>(
      ReminderListNotifier.new,
    );
