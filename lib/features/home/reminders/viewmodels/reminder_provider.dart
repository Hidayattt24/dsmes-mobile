import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/services/local_notification_service.dart';
import '../../../../core/storage/offline_cache_manager.dart';
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
    final cacheManager = ref.read(offlineCacheManagerProvider);

    try {
      final repo = ref.read(reminderRepositoryProvider);
      final reminders = await repo.list();
      debugPrint('[REMINDER][PARSE] received=${reminders.length}');
      debugPrint('[REMINDER] returning=${reminders.length}');

      // Persist to encrypted offline cache
      await cacheManager.saveCache(
        OfflineCacheManager.keyReminders,
        reminders.map((e) => e.toJson()).toList(),
      );

      // Sync all active reminders with device local alarm scheduler
      unawaited(_syncLocalAlarms(reminders));

      return reminders;
    } catch (e) {
      // Graceful offline fallback: load from local cache
      try {
        final cached = await cacheManager.getCache(
          OfflineCacheManager.keyReminders,
        );
        if (cached is List && cached.isNotEmpty) {
          final cachedReminders =
              cached
                  .whereType<Map<String, dynamic>>()
                  .map(ReminderModel.fromJson)
                  .toList();

          unawaited(_syncLocalAlarms(cachedReminders));
          return cachedReminders;
        }
      } catch (_) {}

      // Empty fallback rather than throwing error that breaks UI
      return const <ReminderModel>[];
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
    unawaited(_syncLocalAlarms(current));
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
        final tag = 'reminder_${item.id}';

        // Always cancel existing alarms for this reminder across all day IDs first
        // to prevent duplicate ghost alarms when editing schedules or day sets.
        await LocalNotificationService.instance.cancelNotification(baseId);
        for (int d = 1; d <= 7; d++) {
          await LocalNotificationService.instance.cancelNotification(
            baseId + d,
          );
        }

        if (!item.isActive) {
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
          category: item.category,
        );

        final days = item.activeDays;
        if (days.isEmpty || days.length == 7) {
          await LocalNotificationService.instance.scheduleDailyNotification(
            id: baseId,
            tag: tag,
            title: title,
            body: body,
            hour: hour,
            minute: minute,
          );
        } else {
          for (final day in days) {
            await LocalNotificationService.instance.scheduleWeeklyNotification(
              id: baseId + day,
              tag: tag,
              title: title,
              body: body,
              weekday: day,
              hour: hour,
              minute: minute,
            );
          }
        }
      }
      debugPrint(
        '[REMINDER][SYNC] synchronized local alarms count=${reminders.length}',
      );
    } catch (e) {
      debugPrint('[REMINDER][SYNC][ERROR] failed to sync local alarms: $e');
    }
  }
}

final reminderListProvider =
    AsyncNotifierProvider<ReminderListNotifier, List<ReminderModel>>(
      ReminderListNotifier.new,
    );
