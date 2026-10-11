import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/repositories/food_repository.dart';
import '../../../../features/home/viewmodels/home_dashboard_notifier.dart';
import '../models/food_item.dart';

class MealEntryNotifier extends Notifier<MealEntryState> {
  Timer? _debounceTimer;

  @override
  MealEntryState build() {
    ref.onDispose(() {
      _debounceTimer?.cancel();
    });

    // Schedule initial data load after build
    Future.microtask(() {
      fetchFoods();
      fetchRecentSearches();
    });

    return const MealEntryState();
  }

  Future<void> fetchRecentSearches() async {
    try {
      final repo = ref.read(foodRepositoryProvider);
      final recent = await repo.getRecentSearches();
      if (recent.isNotEmpty) {
        state = state.copyWith(recentSearches: recent);
      }
    } catch (e) {
      // Recent searches are non-critical; log instead of showing an error.
      debugPrint('MealEntry: failed to fetch recent searches: $e');
    }
  }

  Future<void> fetchFoods({bool isRefresh = true}) async {
    if (isRefresh) {
      state = state.copyWith(isLoading: true, currentPage: 1, hasMore: true);
    } else {
      if (!state.hasMore || state.isMoreLoading) return;
      state = state.copyWith(isMoreLoading: true);
    }

    try {
      final repo = ref.read(foodRepositoryProvider);
      final page = isRefresh ? 1 : state.currentPage + 1;
      final results = await repo.searchFoods(
        query: state.searchQuery,
        page: page,
        limit: 15,
      );

      final newItems = results
          .map((m) => FoodItem.fromFoodMasterModel(m, mealType: state.selectedMealType))
          .toList();

      final updatedList = isRefresh
          ? (newItems.isNotEmpty ? newItems : defaultFoods)
          : [...state.recommendedFoods, ...newItems];

      state = state.copyWith(
        recommendedFoods: updatedList,
        isLoading: false,
        isMoreLoading: false,
        currentPage: page,
        hasMore: newItems.length >= 15,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isMoreLoading: false,
        recommendedFoods: isRefresh ? defaultFoods : state.recommendedFoods,
      );
    }
  }

  void setMealType(String type) {
    state = state.copyWith(selectedMealType: type);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      fetchFoods(isRefresh: true);
    });
  }

  void selectRecentSearch(String query) {
    setSearchQuery(query);
  }

  void toggleFoodSelection(String foodId, [double portionMultiplier = 1.0]) {
    final updated = Set<String>.from(state.selectedFoodIds);
    final multipliers = Map<String, double>.from(state.foodPortionMultipliers);
    if (updated.contains(foodId)) {
      updated.remove(foodId);
      multipliers.remove(foodId);
    } else {
      updated.add(foodId);
      multipliers[foodId] = portionMultiplier;
    }
    state = state.copyWith(
      selectedFoodIds: updated,
      foodPortionMultipliers: multipliers,
    );
  }

  void addFoodToLog(String foodId, [double portionMultiplier = 1.0]) {
    final updated = Set<String>.from(state.selectedFoodIds);
    updated.add(foodId);
    final multipliers = Map<String, double>.from(state.foodPortionMultipliers);
    multipliers[foodId] = portionMultiplier;
    state = state.copyWith(
      selectedFoodIds: updated,
      foodPortionMultipliers: multipliers,
    );
  }

  void removeFoodFromLog(String foodId) {
    final updated = Set<String>.from(state.selectedFoodIds);
    updated.remove(foodId);
    final multipliers = Map<String, double>.from(state.foodPortionMultipliers);
    multipliers.remove(foodId);
    state = state.copyWith(
      selectedFoodIds: updated,
      foodPortionMultipliers: multipliers,
    );
  }

  void resetSelection() {
    state = state.copyWith(
      selectedFoodIds: {},
      foodPortionMultipliers: {},
    );
  }

  Future<bool> saveMealLogs() async {
    if (state.selectedFoodIds.isEmpty) return false;
    try {
      final repo = ref.read(foodRepositoryProvider);
      for (final id in state.selectedFoodIds) {
        final multiplier = state.foodPortionMultipliers[id] ?? 1.0;
        await repo.logMeal(
          foodId: id,
          mealType: state.selectedMealType,
          portionMultiplier: multiplier,
        );
      }
      // Reset selected foods so next entry starts fresh at 0
      state = state.copyWith(
        selectedFoodIds: {},
        foodPortionMultipliers: {},
      );
      // Refresh the dashboard so the Daily Calories Card shows updated values.
      await ref.read(homeDashboardProvider.notifier).refresh();
      return true;
    } catch (e) {
      return false;
    }
  }
}

final mealEntryProvider = NotifierProvider<MealEntryNotifier, MealEntryState>(
  MealEntryNotifier.new,
);
