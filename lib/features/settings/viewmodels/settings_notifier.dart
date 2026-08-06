import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/body_metrics.dart';

/// Riverpod StateNotifier for managing body metrics and recalculated results.
class SettingsNotifier extends StateNotifier<BodyMetrics> {
  SettingsNotifier()
      : super(const BodyMetrics(
          heightCm: 170,
          weightKg: 65,
          activityLevel: 'Aktivitas Ringan',
        ));

  /// Update user height, weight, and activity level, recalculating metrics.
  void updateBodyMetrics({
    required double heightCm,
    required double weightKg,
    required String activityLevel,
    int? calculatedTdee,
    double? bmiVal,
    String? bmiCatVal,
    Map<String, dynamic>? recommendations,
  }) {
    state = state.copyWith(
      heightCm: heightCm,
      weightKg: weightKg,
      activityLevel: activityLevel,
      calculatedTdee: calculatedTdee,
      bmiVal: bmiVal,
      bmiCatVal: bmiCatVal,
      recommendations: recommendations,
    );
  }

  /// Reset to default values.
  void reset() {
    state = const BodyMetrics(
      heightCm: 170,
      weightKg: 65,
      activityLevel: 'Aktivitas Ringan',
    );
  }
}

/// Global provider for user body metrics state.
final bodyMetricsProvider =
    StateNotifierProvider<SettingsNotifier, BodyMetrics>((ref) {
  return SettingsNotifier();
});
