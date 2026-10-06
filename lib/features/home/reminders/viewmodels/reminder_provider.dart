import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/services/local_notification_service.dart';
import '../../../../data/repositories/reminder_repository.dart';
import '../../../notifications/helpers/notification_copywriter.dart';
import '../../../notifications/models/notification_item.dart';
import '../models/reminder_model.dart';

class ReminderListNotifier extends AsyncNotifier<List<ReminderModel>> {
  @override
  Future<List<ReminderModel>> build() async {
    return _fetchReminders();
  }

  Future<List<ReminderModel>> _fetchReminders() async {
    final repo = ref.read(reminderRepositoryProvider);
    final reminders = await repo.list();
    debugPrint('[REMINDER][PARSE] received=${reminders.length}');
    debugPrint('[REMINDER] returning=${reminders.length}');

    // Sync all active reminders with device local alarm scheduler
    unawaited(_syncLocalAlarms(reminders));

    return reminders;
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
    unawaited(_syncLocalAlarms(current));

    final timeShort = scheduledTime.length >= 5
        ? scheduledTime.substring(0, 5)
        : scheduledTime;

    final (title, _) = NotificationCopywriter.getInteractiveCopy(
      rawTitle: activityName,
      rawDescription: notes,
      type: NotificationType.medication,
      iconName: iconName,
      activityName: activityName,
    );

    unawaited(
      LocalNotificationService.instance.showNotification(
        id: newReminder.id.hashCode.abs(),
        title: '$title ⏰',
        body: 'Pengingat $activityName jam $timeShort WIB telah aktif!',
      ),
    );
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
    final updatedList = current.map((r) => r.id == id ? updated : r).toList();
    state = AsyncValue.data(updatedList);
    unawaited(_syncLocalAlarms(updatedList));
  }

  Future<ReminderModel> toggle(String id) async {
    final repo = ref.read(reminderRepositoryProvider);
    final updated = await repo.toggle(id);
    final current = state.valueOrNull ?? <ReminderModel>[];
    final updatedList = current.map((r) => r.id == id ? updated : r).toList();
    state = AsyncValue.data(updatedList);
    unawaited(_syncLocalAlarms(updatedList));
    return updated;
  }

  Future<void> delete(String id) async {
    final repo = ref.read(reminderRepositoryProvider);
    await repo.delete(id);

    // Cancel alarms for deleted reminder
    final baseId = id.hashCode.abs();
    await LocalNotificationService.instance.cancelNotification(baseId);
    for (int d = 1; d <= 7; d++) {
      await LocalNotificationService.instance.cancelNotification(baseId + d);
    }

    final current = state.valueOrNull ?? <ReminderModel>[];
    final remaining = current.where((r) => r.id != id).toList();
    state = AsyncValue.data(remaining);
  }

  Future<void> _syncLocalAlarms(List<ReminderModel> reminders) async {
    try {
      for (final item in reminders) {
        final baseId = item.id.hashCode.abs();
        if (!item.isActive) {
          // Cancel alarms for inactive reminder
          await LocalNotificationService.instance.cancelNotification(baseId);
          for (int d = 1; d <= 7; d++) {
            await LocalNotificationService.instance.cancelNotification(baseId + d);
          }
          continue;
        }

        final parts = item.scheduledTime.split(':');
        if (parts.length < 2) continue;
        final hour = int.tryParse(parts[0]) ?? 8;
        final minute = int.tryParse(parts[1]) ?? 0;

        final (title, body) = NotificationCopywriter.getInteractiveCopy(
          rawTitle: item.activityName,
          rawDescription: item.notes,
          type: NotificationType.medication,
          iconName: item.iconName,
          activityName: item.activityName,
        );

        final days = item.activeDays;
        if (days.isEmpty || days.length == 7) {
          await LocalNotificationService.instance.scheduleDailyNotification(
            id: baseId,
            title: title,
            body: body,
            hour: hour,
            minute: minute,
          );
        } else {
          for (final day in days) {
            await LocalNotificationService.instance.scheduleWeeklyNotification(
              id: baseId + day,
              title: title,
              body: body,
              weekday: day,
              hour: hour,
              minute: minute,
            );
          }
        }
      }
      debugPrint('[REMINDER][SYNC] synchronized local alarms count=${reminders.length}');
    } catch (e) {
      debugPrint('[REMINDER][SYNC][ERROR] failed to sync local alarms: $e');
    }
  }
}

final reminderListProvider =
    AsyncNotifierProvider<ReminderListNotifier, List<ReminderModel>>(
      ReminderListNotifier.new,
    );
