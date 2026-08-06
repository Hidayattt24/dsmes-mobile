import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_exception.dart';
import '../../core/network/dio_client.dart';
import '../../features/onboarding/models/routine_model.dart';

abstract class IRoutineRepository {
  Future<List<Map<String, dynamic>>> getRoutines();
  Future<void> saveRoutinesSetup({
    required bool useReminder,
    required List<RoutineModel> routines,
  });
}

class RoutineRepository implements IRoutineRepository {
  final Dio _dio;

  RoutineRepository(this._dio);

  @override
  Future<List<Map<String, dynamic>>> getRoutines() async {
    try {
      final response = await _dio.get('/patient/routines');
      final data = response.data['data'] as List<dynamic>? ?? [];
      return data.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<void> saveRoutinesSetup({
    required bool useReminder,
    required List<RoutineModel> routines,
  }) async {
    try {
      final routineItems = routines.map((r) {
        final times = r.customTimes.map((t) {
          final h = t.hour.toString().padLeft(2, '0');
          final m = t.minute.toString().padLeft(2, '0');
          return '$h:$m';
        }).toList();

        return {
          'id': r.id,
          'name': r.name,
          'icon_name': r.iconName,
          'schedule_text': r.scheduleText,
          'is_predefined': r.isPredefined,
          'custom_times': times,
        };
      }).toList();

      final payload = {
        'use_reminder': useReminder,
        'routines': routineItems,
      };

      await _dio.post(
        '/patient/routines/setup',
        data: payload,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}

final routineRepositoryProvider = Provider<IRoutineRepository>((ref) {
  final dio = ref.watch(dioClientProvider);
  return RoutineRepository(dio);
});
