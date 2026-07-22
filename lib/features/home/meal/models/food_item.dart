import 'package:flutter/material.dart';

@immutable
class FoodItem {
  final String id;
  final String name;
  final String servingSize;
  final int calories;
  final double carbs;
  final double protein;
  final double fat;
  final String mealType;
  final List<String>? servingOptions;

  const FoodItem({
    required this.id,
    required this.name,
    required this.servingSize,
    required this.calories,
    required this.carbs,
    required this.protein,
    required this.fat,
    this.mealType = 'Makan Siang',
    this.servingOptions,
  });

  List<String> get servingOptionsList {
    final list = servingOptions ??
        [
          servingSize,
          '1 Porsi Standar (100g)',
          '1 Mangkuk (150g)',
          '100 Gram',
        ];
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

  const MealEntryState({
    this.selectedMealType = 'Makan Siang',
    this.searchQuery = '',
    this.recommendedFoods = defaultFoods,
    this.selectedFoodIds = const {},
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
  }) {
    return MealEntryState(
      selectedMealType: selectedMealType ?? this.selectedMealType,
      searchQuery: searchQuery ?? this.searchQuery,
      recommendedFoods: recommendedFoods ?? this.recommendedFoods,
      selectedFoodIds: selectedFoodIds ?? this.selectedFoodIds,
    );
  }
}

const List<FoodItem> defaultFoods = [
  FoodItem(
    id: 'nasi_putih',
    name: 'Nasi Putih',
    servingSize: '1 centong (100g)',
    servingOptions: [
      '1 centong (100g)',
      '1 porsi (150g)',
      '1/2 centong (50g)',
      '100 Gram',
    ],
    calories: 178,
    carbs: 39.0,
    protein: 3.0,
    fat: 0.4,
    mealType: 'Makan Siang',
  ),
  FoodItem(
    id: 'mie_aceh',
    name: 'Mie Aceh Goreng',
    servingSize: '1 porsi (250g)',
    servingOptions: [
      '1 porsi (250g)',
      '1/2 porsi (125g)',
      '1 mangkuk (200g)',
      '100 Gram',
    ],
    calories: 450,
    carbs: 55.0,
    protein: 18.0,
    fat: 15.0,
    mealType: 'Makan Siang',
  ),
  FoodItem(
    id: 'kuah_pliek_u',
    name: 'Kuah Pliek U',
    servingSize: '1 mangkuk',
    servingOptions: [
      '1 mangkuk',
      '1/2 mangkuk',
      '1 porsi (200g)',
      '100 Gram',
    ],
    calories: 210,
    carbs: 12.0,
    protein: 6.0,
    fat: 14.0,
    mealType: 'Makan Siang',
  ),
  FoodItem(
    id: 'sate_matang',
    name: 'Sate Matang',
    servingSize: '5 tusuk (150g)',
    servingOptions: [
      '5 tusuk (150g)',
      '10 tusuk (300g)',
      '1 tusuk (30g)',
      '1 porsi (150g)',
    ],
    calories: 310,
    carbs: 12.0,
    protein: 24.0,
    fat: 18.0,
    mealType: 'Makan Siang',
  ),
];
