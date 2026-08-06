import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_exception.dart';
import '../../core/network/dio_client.dart';
import '../../features/home/meal/models/nutrition_summary_model.dart';
import '../models/food_master_model.dart';

abstract class IFoodRepository {
  Future<List<FoodMasterModel>> searchFoods({
    String query = '',
    int page = 1,
    int limit = 20,
  });

  Future<List<String>> getRecentSearches();

  Future<void> logMeal({
    required String foodId,
    required String mealType,
    double portionMultiplier = 1.0,
  });

  Future<DailyNutritionSummary> getDailyNutritionSummary({DateTime? date});
}

class FoodRepository implements IFoodRepository {
  final Dio _dio;

  FoodRepository(this._dio);

  @override
  Future<List<FoodMasterModel>> searchFoods({
    String query = '',
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/foods/search',
        queryParameters: {
          'q': query,
          'page': page,
          'limit': limit,
          'status': 'active',
        },
      );
      final data = response.data['data'] as List<dynamic>? ?? [];
      return data
          .map((e) => FoodMasterModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<List<String>> getRecentSearches() async {
    try {
      final response = await _dio.get('/patient/foods/recent');
      final data = response.data['data'] as List<dynamic>? ?? [];
      final names = <String>[];
      for (final item in data) {
        if (item is Map<String, dynamic> && item.containsKey('name')) {
          names.add(item['name'].toString());
        }
      }
      return names;
    } catch (_) {
      return ['Nasi Goreng', 'Ayam Bakar', 'Tempe Goreng', 'Tahu Goreng'];
    }
  }

  @override
  Future<void> logMeal({
    required String foodId,
    required String mealType,
    double portionMultiplier = 1.0,
  }) async {
    try {
      String formattedType = 'makan_siang';
      final lower = mealType.toLowerCase();
      if (lower.contains('sarapan')) {
        formattedType = 'sarapan';
      } else if (lower.contains('malam')) {
        formattedType = 'makan_malam';
      } else if (lower.contains('camilan') || lower.contains('snack')) {
        formattedType = 'camilan';
      }

      await _dio.post(
        '/patient/meals',
        data: {
          'food_id': foodId,
          'meal_type': formattedType,
          'portion_multiplier': portionMultiplier,
        },
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<DailyNutritionSummary> getDailyNutritionSummary({DateTime? date}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (date != null) {
        final d = date.toLocal();
        queryParams['date'] =
            '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      }
      final response = await _dio.get(
        '/patient/meals/summary',
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );
      final data = response.data['data'] as Map<String, dynamic>? ?? {};
      return DailyNutritionSummary.fromJson(data);
    } on DioException catch (e) {
      return const DailyNutritionSummary(
        caloriesConsumed: 0,
        dailyCalorieTarget: 2000,
        caloriesRemaining: 2000,
        totalFoodToday: 0,
        totalCarbsG: 0,
        totalProteinG: 0,
        totalFatG: 0,
      );
    }
  }
}

final foodRepositoryProvider = Provider<IFoodRepository>((ref) {
  final dio = ref.watch(dioClientProvider);
  return FoodRepository(dio);
});
