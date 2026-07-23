import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../models/routine_model.dart';

import '../../../data/repositories/routine_repository.dart';

@immutable
class DailyRoutineState {
  const DailyRoutineState({
    required this.routines,
    this.useReminder = true,
    this.isLoading = false,
    this.errorMessage,
  });

  final List<RoutineModel> routines;
  final bool useReminder;
  final bool isLoading;
  final String? errorMessage;

  DailyRoutineState copyWith({
    List<RoutineModel>? routines,
    bool? useReminder,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return DailyRoutineState(
      routines: routines ?? this.routines,
      useReminder: useReminder ?? this.useReminder,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class DailyRoutineNotifier extends Notifier<DailyRoutineState> {
  @override
  DailyRoutineState build() {
    return const DailyRoutineState(
      routines: [
        RoutineModel(
          id: 'morning',
          name: AppStrings.dailyRoutineActivity1,
          iconName: 'walk',
          scheduleText: AppStrings.dailyRoutineActivity1Desc,
          isPredefined: true,
        ),
        RoutineModel(
          id: 'water',
          name: AppStrings.dailyRoutineActivity2,
          iconName: 'water',
          scheduleText: AppStrings.dailyRoutineActivity2Desc,
          isPredefined: true,
        ),
        RoutineModel(
          id: 'blood_sugar',
          name: AppStrings.dailyRoutineActivity3,
          iconName: 'blood',
          scheduleText: AppStrings.dailyRoutineActivity3Desc,
          isPredefined: true,
        ),
      ],
    );
  }

  void renameRoutine(String id, String newName) {
    state = state.copyWith(
      routines: state.routines.map((r) {
        return r.id == id ? r.copyWith(name: newName) : r;
      }).toList(),
    );
  }

  void changeIcon(String id, String iconName) {
    state = state.copyWith(
      routines: state.routines.map((r) {
        return r.id == id ? r.copyWith(iconName: iconName) : r;
      }).toList(),
    );
  }

  void addCustomTime(String id) {
    state = state.copyWith(
      routines: state.routines.map((r) {
        if (r.id != id) return r;
        return r.copyWith(
          customTimes: [...r.customTimes, const TimeOfDay(hour: 7, minute: 0)],
        );
      }).toList(),
    );
  }

  void removeCustomTime(String id, int index) {
    state = state.copyWith(
      routines: state.routines.map((r) {
        if (r.id != id) return r;
        final updated = [...r.customTimes];
        updated.removeAt(index);
        return r.copyWith(customTimes: updated);
      }).toList(),
    );
  }

  void updateCustomTime(String id, int index, TimeOfDay time) {
    state = state.copyWith(
      routines: state.routines.map((r) {
        if (r.id != id) return r;
        final updated = [...r.customTimes];
        updated[index] = time;
        return r.copyWith(customTimes: updated);
      }).toList(),
    );
  }

  void deleteRoutine(String id) {
    state = state.copyWith(
      routines: state.routines.where((r) => r.id != id).toList(),
    );
  }

  void addRoutine(RoutineModel routine) {
    state = state.copyWith(
      routines: [...state.routines, routine],
    );
  }

  void toggleReminder(bool value) {
    state = state.copyWith(useReminder: value);
  }

  Future<bool> finishOnboarding() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final repo = ref.read(routineRepositoryProvider);
      await repo.saveRoutinesSetup(
        useReminder: state.useReminder,
        routines: state.routines,
      );
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal menyimpan pengaturan rutinitas: ${e.toString()}',
      );
      return false;
    }
  }
}


final dailyRoutineProvider =
    NotifierProvider<DailyRoutineNotifier, DailyRoutineState>(
  DailyRoutineNotifier.new,
);
