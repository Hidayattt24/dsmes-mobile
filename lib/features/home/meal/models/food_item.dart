import 'package:flutter/foundation.dart';
import '../../../../data/models/food_master_model.dart';

@immutable
class FoodItem {
  final String id;
  final String name;
  final String manufacturer;
  final String servingSize;
  final double energyKcal;
  final double carbs;
  final double protein;
  final double fat;
  final double sugarG;
  final double sodiumMg;
  final double fiberG;
  final String nutritionBasis;
  final String mealType;
  final List<String>? servingOptions;

  const FoodItem({
    required this.id,
    required this.name,
    this.manufacturer = '',
    required this.servingSize,
    required this.energyKcal,
    required this.carbs,
    required this.protein,
    required this.fat,
    this.sugarG = 0.0,
    this.sodiumMg = 0.0,
    this.fiberG = 0.0,
    this.nutritionBasis = 'PER_100G',
    this.mealType = 'Makan Siang',
    this.servingOptions,
  });

  int get calories => energyKcal.round();

  factory FoodItem.fromFoodMasterModel(FoodMasterModel model, {String mealType = 'Makan Siang'}) {
    final String cleanServingSize = model.servingSize.trim().isNotEmpty
        ? model.servingSize.trim()
        : '1 porsi';
    return FoodItem(
      id: model.id,
      name: model.name,
      manufacturer: model.manufacturer,
      servingSize: cleanServingSize,
      energyKcal: model.energyKcal,
      carbs: model.carbohydrateG,
      protein: model.proteinG,
      fat: model.fatG,
      sugarG: model.sugarG,
      sodiumMg: model.sodiumMg,
      fiberG: model.fiberG,
      nutritionBasis: model.nutritionBasis,
      mealType: mealType,
      servingOptions: [
        cleanServingSize,
      ],
    );
  }

  List<String> get servingOptionsList {
    final list = servingOptions ?? [servingSize];
    if (!list.contains(servingSize)) {
      return [servingSize, ...list];
    }
    return list.toSet().toList();
  }
}

@immutable
class MealEntryState {
  final String selectedMealType;
  final String searchQuery;
  final List<FoodItem> recommendedFoods;
  final Set<String> selectedFoodIds;
  final List<String> recentSearches;
  final bool isLoading;
  final bool isMoreLoading;
  final int currentPage;
  final bool hasMore;

  const MealEntryState({
    this.selectedMealType = 'Makan Siang',
    this.searchQuery = '',
    this.recommendedFoods = const [],
    this.selectedFoodIds = const {},
    this.recentSearches = const ['Nasi Goreng', 'Ayam Bakar', 'Tempe Goreng', 'Tahu Goreng'],
    this.isLoading = false,
    this.isMoreLoading = false,
    this.currentPage = 1,
    this.hasMore = true,
  });

  int get totalCalories {
    int total = 0;
    for (final id in selectedFoodIds) {
      final food = recommendedFoods.where((f) => f.id == id).firstOrNull;
      if (food != null) total += food.calories;
    }
    return total;
  }

  List<FoodItem> get selectedFoods {
    return recommendedFoods.where((f) => selectedFoodIds.contains(f.id)).toList();
  }

  MealEntryState copyWith({
    String? selectedMealType,
    String? searchQuery,
    List<FoodItem>? recommendedFoods,
    Set<String>? selectedFoodIds,
    List<String>? recentSearches,
    bool? isLoading,
    bool? isMoreLoading,
    int? currentPage,
    bool? hasMore,
  }) {
    return MealEntryState(
      selectedMealType: selectedMealType ?? this.selectedMealType,
      searchQuery: searchQuery ?? this.searchQuery,
      recommendedFoods: recommendedFoods ?? this.recommendedFoods,
      selectedFoodIds: selectedFoodIds ?? this.selectedFoodIds,
      recentSearches: recentSearches ?? this.recentSearches,
      isLoading: isLoading ?? this.isLoading,
      isMoreLoading: isMoreLoading ?? this.isMoreLoading,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

const List<FoodItem> defaultFoods = [];
