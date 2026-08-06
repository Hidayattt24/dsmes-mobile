import 'package:flutter/material.dart';

class BloodSugarEntryState {
  final String measurementType; // 'fasting' | 'before_meal' | 'after_meal' | 'before_bed' | 'random'
  final String value;
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final bool isInitialDefault;
  final bool isSubmitting;
  final String? errorMessage;

  const BloodSugarEntryState({
    this.measurementType = 'before_meal',
    this.value = '100',
    required this.selectedDate,
    required this.selectedTime,
    this.isInitialDefault = true,
    this.isSubmitting = false,
    this.errorMessage,
  });

  String get normalRangeText {
    return switch (measurementType) {
      'fasting' => 'Rentang acuan normal: 70–100 mg/dL (Puasa)',
      'before_meal' => 'Rentang acuan normal: 80–120 mg/dL (Sebelum Makan)',
      'after_meal' => 'Rentang acuan normal: < 140 mg/dL (2 Jam Sesudah Makan)',
      'before_bed' => 'Rentang acuan normal: 100–140 mg/dL (Sebelum Tidur)',
      'random' => 'Rentang acuan normal: < 140 mg/dL (Sewaktu)',
      _ => 'Rentang acuan normal: 80–120 mg/dL',
    };
  }

  BloodSugarEntryState copyWith({
    String? measurementType,
    String? value,
    DateTime? selectedDate,
    TimeOfDay? selectedTime,
    bool? isInitialDefault,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
  }) {
    return BloodSugarEntryState(
      measurementType: measurementType ?? this.measurementType,
      value: value ?? this.value,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTime: selectedTime ?? this.selectedTime,
      isInitialDefault: isInitialDefault ?? this.isInitialDefault,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
