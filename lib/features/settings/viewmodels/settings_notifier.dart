import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/settings_mock_data.dart';
import '../models/body_metrics.dart';

/// Riverpod StateNotifier for managing body metrics and recalculated results.
class SettingsNotifier extends StateNotifier<BodyMetrics> {
  SettingsNotifier() : super(SettingsMockData.initialMetrics);

  /// Update user height, weight, and activity level, recalculating metrics.
  void updateBodyMetrics({
    required double heightCm,
    required double weightKg,
    required String activityLevel,
  }) {
    state = state.copyWith(
      heightCm: heightCm,
      weightKg: weightKg,
      activityLevel: activityLevel,
    );
  }

  /// Reset to initial mock data.
  void reset() {
    state = SettingsMockData.initialMetrics;
  }
}

/// Global provider for user body metrics state.
final bodyMetricsProvider =
    StateNotifierProvider<SettingsNotifier, BodyMetrics>((ref) {
  return SettingsNotifier();
});
