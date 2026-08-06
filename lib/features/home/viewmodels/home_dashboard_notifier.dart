import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/blood_sugar_repository.dart';
import '../../../data/repositories/food_repository.dart';
import '../blood_sugar/models/blood_sugar_log_model.dart';
import '../meal/models/nutrition_summary_model.dart';
import '../models/home_dashboard_model.dart';

class HomeDashboardState {
  final HomeDashboardModel? dashboardData;
  final BloodSugarLogModel? latestBloodSugar;
  final List<BloodSugarLogModel> bloodSugarLogs;
  final DailyNutritionSummary? nutritionSummary;
  final bool isLoading;
  final String? errorMessage;

  const HomeDashboardState({
    this.dashboardData,
    this.latestBloodSugar,
    this.bloodSugarLogs = const [],
    this.nutritionSummary,
    this.isLoading = true,
    this.errorMessage,
  });

  int get consumedCalories => nutritionSummary?.consumedCaloriesRounded ?? 0;

  int get remainingCalories =>
      nutritionSummary?.remainingCaloriesRounded ??
      dashboardData?.dailyCalorieTarget ??
      2000;

  int get dailyCalorieTarget =>
      nutritionSummary?.dailyCalorieTarget ??
      dashboardData?.dailyCalorieTarget ??
      2000;

  bool get hasMealsToday => nutritionSummary?.hasMealsToday ?? false;

  HomeDashboardState copyWith({
    HomeDashboardModel? dashboardData,
    BloodSugarLogModel? latestBloodSugar,
    List<BloodSugarLogModel>? bloodSugarLogs,
    DailyNutritionSummary? nutritionSummary,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return HomeDashboardState(
      dashboardData: dashboardData ?? this.dashboardData,
      latestBloodSugar: latestBloodSugar ?? this.latestBloodSugar,
      bloodSugarLogs: bloodSugarLogs ?? this.bloodSugarLogs,
      nutritionSummary: nutritionSummary ?? this.nutritionSummary,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class HomeDashboardNotifier extends AsyncNotifier<HomeDashboardState> {
  @override
  Future<HomeDashboardState> build() async {
    return _fetchData();
  }

  Future<HomeDashboardState> _fetchData() async {
    DailyNutritionSummary? nutritionSummary;
    try {
      final authRepo = ref.read(authRepositoryProvider);
      final bloodSugarRepo = ref.read(bloodSugarRepositoryProvider);
      final foodRepo = ref.read(foodRepositoryProvider);

      final results = await Future.wait([
        authRepo.getPatientProfile(),
        bloodSugarRepo.getBloodSugarHistory(limit: 20),
      ]);

      final profileJson = results[0] as Map<String, dynamic>;
      final bloodSugarLogs = results[1] as List<BloodSugarLogModel>;

      // Fetch the nutrition summary independently so a failure of this endpoint
      // does not break the whole dashboard — the card simply shows empty state.
      try {
        nutritionSummary = await foodRepo.getDailyNutritionSummary();
      } catch (_) {
        nutritionSummary = null;
      }

      final dashboardData = HomeDashboardModel.fromJson(profileJson);
      final latestBs = bloodSugarLogs.isNotEmpty ? bloodSugarLogs.first : null;

      return HomeDashboardState(
        dashboardData: dashboardData,
        latestBloodSugar: latestBs,
        bloodSugarLogs: bloodSugarLogs,
        nutritionSummary: nutritionSummary,
        isLoading: false,
      );
    } catch (e) {
      return HomeDashboardState(
        nutritionSummary: nutritionSummary,
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetchData);
  }
}

final homeDashboardProvider =
    AsyncNotifierProvider<HomeDashboardNotifier, HomeDashboardState>(
  HomeDashboardNotifier.new,
);
