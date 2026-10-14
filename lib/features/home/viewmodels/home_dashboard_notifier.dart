import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/offline_cache_manager.dart';
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
  final bool isFromCache;
  final DateTime? lastCachedAt;

  const HomeDashboardState({
    this.dashboardData,
    this.latestBloodSugar,
    this.bloodSugarLogs = const [],
    this.nutritionSummary,
    this.isLoading = true,
    this.errorMessage,
    this.isFromCache = false,
    this.lastCachedAt,
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
    bool? isFromCache,
    DateTime? lastCachedAt,
    bool clearError = false,
  }) {
    return HomeDashboardState(
      dashboardData: dashboardData ?? this.dashboardData,
      latestBloodSugar: latestBloodSugar ?? this.latestBloodSugar,
      bloodSugarLogs: bloodSugarLogs ?? this.bloodSugarLogs,
      nutritionSummary: nutritionSummary ?? this.nutritionSummary,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isFromCache: isFromCache ?? this.isFromCache,
      lastCachedAt: lastCachedAt ?? this.lastCachedAt,
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
      final cacheManager = ref.read(offlineCacheManagerProvider);

      final results = await Future.wait([
        authRepo.getPatientProfile(),
        bloodSugarRepo.getBloodSugarHistory(limit: 20),
      ]);

      final profileJson = results[0] as Map<String, dynamic>;
      final bloodSugarLogs = results[1] as List<BloodSugarLogModel>;

      // Persist to encrypted offline cache for safe offline usage
      await cacheManager.saveCache(
        OfflineCacheManager.keyDashboardProfile,
        profileJson,
      );
      await cacheManager.saveCache(
        OfflineCacheManager.keyBloodSugarLogs,
        bloodSugarLogs.map((e) => e.toJson()).toList(),
      );

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
        isFromCache: false,
        lastCachedAt: DateTime.now(),
      );
    } catch (e) {
      // Graceful degradation: Load from local offline cache
      try {
        final cacheManager = ref.read(offlineCacheManagerProvider);
        final cachedProfile = await cacheManager.getCache(
          OfflineCacheManager.keyDashboardProfile,
        );
        final cachedLogsRaw = await cacheManager.getCache(
          OfflineCacheManager.keyBloodSugarLogs,
        );
        final lastSync = await cacheManager.getLastSyncTime(
          OfflineCacheManager.keyDashboardProfile,
        );

        if (cachedProfile is Map<String, dynamic>) {
          final dashboardData = HomeDashboardModel.fromJson(cachedProfile);
          List<BloodSugarLogModel> bloodSugarLogs = [];
          if (cachedLogsRaw is List) {
            bloodSugarLogs = cachedLogsRaw
                .whereType<Map<String, dynamic>>()
                .map(BloodSugarLogModel.fromJson)
                .toList();
          }
          final latestBs =
              bloodSugarLogs.isNotEmpty ? bloodSugarLogs.first : null;

          return HomeDashboardState(
            dashboardData: dashboardData,
            latestBloodSugar: latestBs,
            bloodSugarLogs: bloodSugarLogs,
            nutritionSummary: null,
            isLoading: false,
            isFromCache: true,
            lastCachedAt: lastSync,
            errorMessage: e.toString().replaceFirst('Exception: ', ''),
          );
        }
      } catch (_) {
        // Fall through to error state if cache retrieval also fails
      }

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
