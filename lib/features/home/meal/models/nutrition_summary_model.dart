class DailyNutritionSummary {
  final double caloriesConsumed;
  final int dailyCalorieTarget;
  final double caloriesRemaining;
  final int totalFoodToday;
  final double totalCarbsG;
  final double totalProteinG;
  final double totalFatG;

  const DailyNutritionSummary({
    required this.caloriesConsumed,
    required this.dailyCalorieTarget,
    required this.caloriesRemaining,
    required this.totalFoodToday,
    required this.totalCarbsG,
    required this.totalProteinG,
    required this.totalFatG,
  });

  int get consumedCaloriesRounded => caloriesConsumed.round();
  int get remainingCaloriesRounded => caloriesRemaining.round();
  bool get hasMealsToday => totalFoodToday > 0;

  factory DailyNutritionSummary.fromJson(Map<String, dynamic> json) {
    return DailyNutritionSummary(
      caloriesConsumed: (json['calories_consumed'] as num?)?.toDouble() ?? 0,
      dailyCalorieTarget: (json['daily_calorie_target'] as num?)?.toInt() ?? 2000,
      caloriesRemaining: (json['calories_remaining'] as num?)?.toDouble() ?? 0,
      totalFoodToday: (json['total_food_today'] as num?)?.toInt() ?? 0,
      totalCarbsG: (json['total_carbs_g'] as num?)?.toDouble() ?? 0,
      totalProteinG: (json['total_protein_g'] as num?)?.toDouble() ?? 0,
      totalFatG: (json['total_fat_g'] as num?)?.toDouble() ?? 0,
    );
  }
}
