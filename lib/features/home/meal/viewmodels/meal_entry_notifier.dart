import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/sync/sync_queue_item.dart';
import '../../../../core/sync/sync_queue_manager.dart';
import '../../../../data/repositories/food_repository.dart';
import '../../../../features/home/viewmodels/home_dashboard_notifier.dart';
import '../models/food_item.dart';

class MealEntryNotifier extends Notifier<MealEntryState> {
  Timer? _debounceTimer;
  int _searchRevision = 0;

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
    final revision = _searchRevision;
    final query = state.searchQuery;
    if (isRefresh) {
      state = state.copyWith(
        isLoading: true,
        isMoreLoading: false,
        currentPage: 1,
        hasMore: true,
      );
    } else {
      if (!state.hasMore || state.isMoreLoading) return;
      state = state.copyWith(isMoreLoading: true);
    }

    try {
      final repo = ref.read(foodRepositoryProvider);
      final page = isRefresh ? 1 : state.currentPage + 1;
      final results = await repo.searchFoods(
        query: query,
        page: page,
        limit: 15,
      );

      if (revision != _searchRevision) return;

      final newItems =
          results
              .map(
                (m) => FoodItem.fromFoodMasterModel(
                  m,
                  mealType: state.selectedMealType,
                ),
              )
              .toList();

      final updatedList =
          isRefresh
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
      if (revision != _searchRevision) return;
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
    _searchRevision++;
    state = state.copyWith(searchQuery: query);
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      fetchFoods(isRefresh: true);
    });
  }

  void selectRecentSearch(String query) {
    setSearchQuery(query);
  }

  void toggleFoodSelection(FoodItem food, [double portionMultiplier = 1.0]) {
    final selected = Map<String, FoodItem>.from(state.selectedFoodsById);
    final multipliers = Map<String, double>.from(state.foodPortionMultipliers);
    if (selected.containsKey(food.id)) {
      selected.remove(food.id);
      multipliers.remove(food.id);
    } else {
      selected[food.id] = food;
      multipliers[food.id] = portionMultiplier;
    }
    state = state.copyWith(
      selectedFoodsById: selected,
      foodPortionMultipliers: multipliers,
    );
  }

  void addFoodToLog(FoodItem food, [double portionMultiplier = 1.0]) {
    final selected = Map<String, FoodItem>.from(state.selectedFoodsById);
    selected[food.id] = food;
    final multipliers = Map<String, double>.from(state.foodPortionMultipliers);
    multipliers[food.id] = portionMultiplier;
    state = state.copyWith(
      selectedFoodsById: selected,
      foodPortionMultipliers: multipliers,
    );
  }

  void removeFoodFromLog(String foodId) {
    final selected = Map<String, FoodItem>.from(state.selectedFoodsById);
    selected.remove(foodId);
    final multipliers = Map<String, double>.from(state.foodPortionMultipliers);
    multipliers.remove(foodId);
    state = state.copyWith(
      selectedFoodsById: selected,
      foodPortionMultipliers: multipliers,
    );
  }

  void resetSelection() {
    state = state.copyWith(selectedFoodsById: {}, foodPortionMultipliers: {});
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
      state = state.copyWith(selectedFoodsById: {}, foodPortionMultipliers: {});
      // Refresh the dashboard so the Daily Calories Card shows updated values.
      await ref.read(homeDashboardProvider.notifier).refresh();
      return true;
    } catch (e) {
      // Offline fallback: enqueue each meal item to persistent sync queue
      try {
        final syncManager = ref.read(syncQueueManagerProvider.notifier);
        for (final id in state.selectedFoodIds) {
          final clientId = const Uuid().v4();
          final multiplier = state.foodPortionMultipliers[id] ?? 1.0;
          await syncManager.enqueue(
            SyncQueueItem(
              clientId: clientId,
              userId: '',
              dataType: SyncDataType.meal,
              endpoint: '/patient/meals',
              method: 'POST',
              payload: {
                'food_id': id,
                'meal_type': state.selectedMealType,
                'portion_multiplier': multiplier,
                'client_id': clientId,
              },
              createdAt: DateTime.now(),
            ),
          );
        }

        state = state.copyWith(
          selectedFoodsById: {},
          foodPortionMultipliers: {},
        );
        await ref.read(homeDashboardProvider.notifier).refresh();
        return true;
      } catch (_) {
        return false;
      }
    }
  }
}

final mealEntryProvider = NotifierProvider<MealEntryNotifier, MealEntryState>(
  MealEntryNotifier.new,
);
