import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/repositories/reminder_repository.dart';
import '../models/reminder_model.dart';

class ReminderListNotifier extends AsyncNotifier<List<ReminderModel>> {
  @override
  Future<List<ReminderModel>> build() async {
    return _fetchReminders();
  }

  Future<List<ReminderModel>> _fetchReminders() async {
    final repo = ref.read(reminderRepositoryProvider);
    return repo.list();
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
    final current = <ReminderModel>[...(state.valueOrNull ?? <ReminderModel>[]), newReminder];
    state = AsyncValue.data(current);
  }

  Future<void> updateReminder(String id, {
    required String activityName,
    required String category,
    required String scheduledTime,
    String notes = '',
    String iconName = 'default',
    int repeatIntervalDays = 1,
    required List<int> activeDays,
  }) async {
    final repo = ref.read(reminderRepositoryProvider);
    final updated = await repo.update(id,
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
  }

  Future<void> toggle(String id) async {
    final repo = ref.read(reminderRepositoryProvider);
    final updated = await repo.toggle(id);
    final current = state.valueOrNull ?? <ReminderModel>[];
    state = AsyncValue.data(
      current.map((r) => r.id == id ? updated : r).toList(),
    );
  }

  Future<void> delete(String id) async {
    final repo = ref.read(reminderRepositoryProvider);
    await repo.delete(id);
    final current = state.valueOrNull ?? <ReminderModel>[];
    state = AsyncValue.data(current.where((r) => r.id != id).toList());
  }
}

final reminderListProvider =
    AsyncNotifierProvider<ReminderListNotifier, List<ReminderModel>>(
  ReminderListNotifier.new,
);
