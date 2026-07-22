import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/food_item.dart';

class MealEntryNotifier extends Notifier<MealEntryState> {
  @override
  MealEntryState build() => const MealEntryState();

  void setMealType(String type) {
    state = state.copyWith(selectedMealType: type);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void toggleFoodSelection(String foodId) {
    final updated = Set<String>.from(state.selectedFoodIds);
    if (updated.contains(foodId)) {
      updated.remove(foodId);
    } else {
      updated.add(foodId);
    }
    state = state.copyWith(selectedFoodIds: updated);
  }

  void addFoodToLog(String foodId) {
    final updated = Set<String>.from(state.selectedFoodIds);
    updated.add(foodId);
    state = state.copyWith(selectedFoodIds: updated);
  }

  void removeFoodFromLog(String foodId) {
    final updated = Set<String>.from(state.selectedFoodIds);
    updated.remove(foodId);
    state = state.copyWith(selectedFoodIds: updated);
  }

  List<FoodItem> get filteredFoods {
    final query = state.searchQuery.trim().toLowerCase();
    if (query.isEmpty) return state.recommendedFoods;
    return state.recommendedFoods
        .where((f) => f.name.toLowerCase().contains(query))
        .toList();
  }
}

final mealEntryProvider = NotifierProvider<MealEntryNotifier, MealEntryState>(
  MealEntryNotifier.new,
);
