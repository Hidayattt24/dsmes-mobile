import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_exception.dart';
import '../../core/network/dio_client.dart';
import '../../features/home/blood_sugar/models/blood_sugar_log_model.dart';

abstract class IBloodSugarRepository {
  Future<BloodSugarLogModel> logBloodSugar({
    required int glucoseValue,
    required String measurementType,
    required DateTime measuredAt,
  });

  Future<List<BloodSugarLogModel>> getBloodSugarHistory({
    int page = 1,
    int limit = 20,
  });
}

class BloodSugarRepository implements IBloodSugarRepository {
  final Dio _dio;

  BloodSugarRepository(this._dio);

  @override
  Future<BloodSugarLogModel> logBloodSugar({
    required int glucoseValue,
    required String measurementType,
    required DateTime measuredAt,
  }) async {
    try {
      final response = await _dio.post(
        '/patient/blood-sugar',
        data: {
          'glucose_value': glucoseValue,
          'measurement_time_type': measurementType,
          'measured_at': measuredAt.toUtc().toIso8601String(),
        },
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return BloodSugarLogModel.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<List<BloodSugarLogModel>> getBloodSugarHistory({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/patient/blood-sugar',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );
      final items = (response.data['data'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>();
      return items.map(BloodSugarLogModel.fromJson).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}

final bloodSugarRepositoryProvider = Provider<IBloodSugarRepository>((ref) {
  final dio = ref.watch(dioClientProvider);
  return BloodSugarRepository(dio);
});
