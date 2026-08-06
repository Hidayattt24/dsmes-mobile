import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_exception.dart';
import '../../core/network/dio_client.dart';
import '../../features/record/models/measurement_model.dart';

abstract class IMeasurementRepository {
  Future<List<MeasurementModel>> getMeasurements();
  Future<MeasurementModel> createMeasurement({
    double? weightKg,
    double? heightCm,
    int? bloodPressureSystolic,
    int? bloodPressureDiastolic,
    double? waistCircumferenceCm,
    String notes = '',
  });
}

class MeasurementRepository implements IMeasurementRepository {
  final Dio _dio;

  MeasurementRepository(this._dio);

  @override
  Future<List<MeasurementModel>> getMeasurements() async {
    try {
      final response = await _dio.get('/patient/measurements');
      final items = response.data['data'] as List<dynamic>? ?? [];
      return items
          .map((json) => MeasurementModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<MeasurementModel> createMeasurement({
    double? weightKg,
    double? heightCm,
    int? bloodPressureSystolic,
    int? bloodPressureDiastolic,
    double? waistCircumferenceCm,
    String notes = '',
  }) async {
    try {
      final data = <String, dynamic>{};
      if (weightKg != null) data['weight_kg'] = weightKg;
      if (heightCm != null) data['height_cm'] = heightCm;
      if (bloodPressureSystolic != null) data['blood_pressure_systolic'] = bloodPressureSystolic;
      if (bloodPressureDiastolic != null) data['blood_pressure_diastolic'] = bloodPressureDiastolic;
      if (waistCircumferenceCm != null) data['waist_circumference_cm'] = waistCircumferenceCm;
      data['notes'] = notes;

      final response = await _dio.post('/patient/measurements', data: data);
      final result = response.data['data'] as Map<String, dynamic>;
      return MeasurementModel.fromJson(result);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}

final measurementRepositoryProvider = Provider<IMeasurementRepository>((ref) {
  final dio = ref.watch(dioClientProvider);
  return MeasurementRepository(dio);
});
