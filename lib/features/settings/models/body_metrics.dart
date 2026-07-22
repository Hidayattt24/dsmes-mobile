import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Model representing user's physical parameters and health metrics.
@immutable
class BodyMetrics {
  const BodyMetrics({
    required this.heightCm,
    required this.weightKg,
    required this.activityLevel,
    this.gender = 'Laki-laki',
    this.age = 45,
  });

  final double heightCm;
  final double weightKg;
  final String activityLevel;
  final String gender;
  final int age;

  /// Body Mass Index (BMI) = weight (kg) / (height (m))^2
  double get bmi {
    if (heightCm <= 0) return 0;
    final heightMeters = heightCm / 100.0;
    return weightKg / (heightMeters * heightMeters);
  }

  /// Formatted BMI value string with 1 decimal place.
  String get bmiFormatted => bmi.toStringAsFixed(1);

  /// BMI Category according to standard classification.
  String get bmiCategory {
    final value = bmi;
    if (value < 18.5) {
      return 'Kurus';
    } else if (value <= 22.9) {
      return 'Normal';
    } else if (value <= 24.9) {
      return 'Kelebihan Berat Badan';
    } else {
      return 'Obesitas';
    }
  }

  /// Color associated with the BMI category badge.
  Color get bmiCategoryColor {
    final value = bmi;
    if (value < 18.5) {
      return AppColors.tertiary;
    } else if (value <= 22.9) {
      return AppColors.secondary;
    } else if (value <= 24.9) {
      return AppColors.tertiary;
    } else {
      return AppColors.error;
    }
  }

  /// Estimated Daily Calorie Recommendation (BMR * Activity Factor).
  int get dailyCalorie {
    if (heightCm <= 0 || weightKg <= 0) return 2000;
    // Mifflin-St Jeor Equation
    final isMale = gender.toLowerCase().contains('laki');
    final bmr = isMale
        ? (10 * weightKg) + (6.25 * heightCm) - (5 * age) + 5
        : (10 * weightKg) + (6.25 * heightCm) - (5 * age) - 161;

    double multiplier = 1.375; // Default moderate/light
    final act = activityLevel.toLowerCase();
    if (act.contains('jarang') || act.contains('sedentary')) {
      multiplier = 1.2;
    } else if (act.contains('ringan')) {
      multiplier = 1.375;
    } else if (act.contains('sedang')) {
      multiplier = 1.55;
    } else if (act.contains('sangat aktif')) {
      multiplier = 1.9;
    } else if (act.contains('berat') || act.contains('aktif')) {
      multiplier = 1.725;
    }

    return (bmr * multiplier).round();
  }

  /// Daily Calorie formatted with thousands separator (e.g. 1,850 kcal)
  String get dailyCalorieFormatted {
    final val = dailyCalorie;
    final valStr = val.toString();
    if (valStr.length > 3) {
      final sub1 = valStr.substring(0, valStr.length - 3);
      final sub2 = valStr.substring(valStr.length - 3);
      return '$sub1,$sub2';
    }
    return valStr;
  }

  /// Recommended Daily Water Intake in mL based on body weight (~35 ml per kg).
  int get dailyWaterMl {
    if (weightKg <= 0) return 2000;
    return (weightKg * 35).round();
  }

  /// Daily Water formatted in Liters (e.g. 2.4 Liter).
  String get dailyWaterLitersFormatted {
    final liters = dailyWaterMl / 1000.0;
    return '${liters.toStringAsFixed(1)} Liter';
  }

  BodyMetrics copyWith({
    double? heightCm,
    double? weightKg,
    String? activityLevel,
    String? gender,
    int? age,
  }) {
    return BodyMetrics(
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      activityLevel: activityLevel ?? this.activityLevel,
      gender: gender ?? this.gender,
      age: age ?? this.age,
    );
  }
}
