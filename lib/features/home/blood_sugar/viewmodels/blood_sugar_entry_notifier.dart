import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/blood_sugar_entry_state.dart';

class BloodSugarEntryNotifier extends Notifier<BloodSugarEntryState> {
  @override
  BloodSugarEntryState build() {
    return BloodSugarEntryState(
      selectedDate: DateTime.now(),
      selectedTime: TimeOfDay.now(),
      isInitialDefault: true,
    );
  }

  void setCondition(String condition) {
    state = state.copyWith(condition: condition);
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
}

final bloodSugarEntryProvider = NotifierProvider<BloodSugarEntryNotifier, BloodSugarEntryState>(
  BloodSugarEntryNotifier.new,
);
