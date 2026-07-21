import 'package:flutter/material.dart';

class BloodSugarEntryState {
  final String condition;
  final String value;
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final bool isInitialDefault;

  const BloodSugarEntryState({
    this.condition = 'Sebelum Makan',
    this.value = '148',
    required this.selectedDate,
    required this.selectedTime,
    this.isInitialDefault = true,
  });

  String get normalRangeText {
    return switch (condition) {
      'Sebelum Makan' => 'Rentang normal: 70–140 mg/dL (sebelum makan)',
      'Sesudah Makan' => 'Rentang normal: < 180 mg/dL (2 jam sesudah makan)',
      'Sewaktu' => 'Rentang normal: < 200 mg/dL (sewaktu)',
      _ => 'Rentang normal: 70–140 mg/dL',
    };
  }

  BloodSugarEntryState copyWith({
    String? condition,
    String? value,
    DateTime? selectedDate,
    TimeOfDay? selectedTime,
    bool? isInitialDefault,
  }) {
    return BloodSugarEntryState(
      condition: condition ?? this.condition,
      value: value ?? this.value,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTime: selectedTime ?? this.selectedTime,
      isInitialDefault: isInitialDefault ?? this.isInitialDefault,
    );
  }
}
