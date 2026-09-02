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
      await _scheduleSystemNotification(reminder);
    }
    return reminders;
  }

  Future<void> _scheduleSystemNotification(ReminderModel reminder) async {
    final parts = reminder.scheduledTime.split(':');
    if (parts.length < 2) return;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return;

    final notificationId = reminder.id.hashCode.abs();
    await LocalNotificationService.instance.scheduleDailyNotification(
      id: notificationId,
      title: 'Pengingat DSMES: ${reminder.activityName}',
      body:
          reminder.notes.isEmpty
              ? 'Waktunya melakukan ${reminder.activityName}.'
              : reminder.notes,
      hour: hour,
      minute: minute,
    );
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
      await _scheduleSystemNotification(newReminder);
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
    await LocalNotificationService.instance.cancelNotification(
      id.hashCode.abs(),
    );
    if (updated.isActive) {
      await _scheduleSystemNotification(updated);
    }
  }

  Future<void> toggle(String id) async {
    final repo = ref.read(reminderRepositoryProvider);
    final updated = await repo.toggle(id);
    final current = state.valueOrNull ?? <ReminderModel>[];
    state = AsyncValue.data(
      current.map((r) => r.id == id ? updated : r).toList(),
    );
    final notificationId = id.hashCode.abs();
    if (updated.isActive) {
      await _scheduleSystemNotification(updated);
    } else {
      await LocalNotificationService.instance.cancelNotification(
        notificationId,
      );
    }
  }

  Future<void> delete(String id) async {
    final repo = ref.read(reminderRepositoryProvider);
    await repo.delete(id);
    await LocalNotificationService.instance.cancelNotification(
      id.hashCode.abs(),
    );
    final current = state.valueOrNull ?? <ReminderModel>[];
    state = AsyncValue.data(current.where((r) => r.id != id).toList());
  }
}

final reminderListProvider =
    AsyncNotifierProvider<ReminderListNotifier, List<ReminderModel>>(
      ReminderListNotifier.new,
    );
