import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/repositories/blood_sugar_repository.dart';
import '../../viewmodels/home_dashboard_notifier.dart';
import '../../history/viewmodels/history_provider.dart';
import '../models/blood_sugar_entry_state.dart';
import '../models/blood_sugar_log_model.dart';

class BloodSugarEntryNotifier extends Notifier<BloodSugarEntryState> {
  @override
  BloodSugarEntryState build() {
    return BloodSugarEntryState(
      selectedDate: DateTime.now(),
      selectedTime: TimeOfDay.now(),
      isInitialDefault: true,
    );
  }

  void setMeasurementType(String mType) {
    state = state.copyWith(measurementType: mType);
  }

  void appendDigit(String digit) {
    if (state.value.length >= 5 && !state.isInitialDefault) return;

    if (digit == '.' && state.value.contains('.')) return;

    if (state.value == '0' || state.isInitialDefault) {
      state = state.copyWith(value: digit, isInitialDefault: false);
    } else {
      state = state.copyWith(value: '${state.value}$digit', isInitialDefault: false);
    }
  }

  void deleteDigit() {
    if (state.value.isEmpty) return;
    if (state.value.length <= 1 || state.isInitialDefault) {
      state = state.copyWith(value: '', isInitialDefault: false);
    } else {
      state = state.copyWith(
        value: state.value.substring(0, state.value.length - 1),
        isInitialDefault: false,
      );
    }
  }

  void setTime(TimeOfDay time) {
    state = state.copyWith(selectedTime: time);
  }

  Future<BloodSugarLogModel?> submitBloodSugar() async {
    final val = int.tryParse(state.value);
    if (val == null || val <= 0) {
      state = state.copyWith(errorMessage: 'Nilai gula darah harus lebih dari 0');
      return null;
    }

    state = state.copyWith(isSubmitting: true, clearError: true);

    final measuredDateTime = DateTime(
      state.selectedDate.year,
      state.selectedDate.month,
      state.selectedDate.day,
      state.selectedTime.hour,
      state.selectedTime.minute,
    );

    try {
      final repo = ref.read(bloodSugarRepositoryProvider);
      final result = await repo.logBloodSugar(
        glucoseValue: val,
        measurementType: state.measurementType,
        measuredAt: measuredDateTime,
      );
      state = state.copyWith(isSubmitting: false);
      // Automatically refresh Home Dashboard and History data
      ref.read(homeDashboardProvider.notifier).refresh();
      ref.read(historyProvider.notifier).refresh();
      return result;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
      return null;
    }
  }
}

final bloodSugarEntryProvider = NotifierProvider<BloodSugarEntryNotifier, BloodSugarEntryState>(
  BloodSugarEntryNotifier.new,
);
