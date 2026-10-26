import 'food_master_model.dart';

class MealLogDetailModel {
  const MealLogDetailModel({
    required this.id,
    required this.food,
    required this.mealType,
    required this.portionMultiplier,
    required this.loggedAt,
  });

  final String id;
  final FoodMasterModel food;
  final String mealType;
  final double portionMultiplier;
  final DateTime? loggedAt;

  factory MealLogDetailModel.fromJson(Map<String, dynamic> json) {
    return MealLogDetailModel(
      id: json['id'] as String? ?? '',
      food: FoodMasterModel.fromJson(
        (json['food'] as Map<String, dynamic>?) ?? const {},
      ),
      mealType: json['meal_type'] as String? ?? 'makan_siang',
      portionMultiplier:
          (json['portion_multiplier'] as num?)?.toDouble() ?? 1.0,
      loggedAt: DateTime.tryParse(json['logged_at'] as String? ?? ''),
    );
  }
}
