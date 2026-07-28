import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_exception.dart';
import '../../core/network/dio_client.dart';
import '../../features/home/reminders/models/reminder_model.dart';

abstract class IReminderRepository {
  Future<List<ReminderModel>> list();
  Future<ReminderModel> create({
    required String activityName,
    required String category,
    required String scheduledTime,
    String notes = '',
    String iconName = 'default',
    int repeatIntervalDays = 1,
    required List<int> activeDays,
  });
  Future<ReminderModel> update(String id, {
    required String activityName,
    required String category,
    required String scheduledTime,
    String notes = '',
    String iconName = 'default',
    int repeatIntervalDays = 1,
    required List<int> activeDays,
  });
  Future<ReminderModel> toggle(String id);
  Future<void> delete(String id);
}

class ReminderRepository implements IReminderRepository {
  final Dio _dio;

  ReminderRepository(this._dio);

  @override
  Future<List<ReminderModel>> list() async {
    try {
      final response = await _dio.get('/patient/reminders');
      final items = response.data['data'] as List<dynamic>? ?? [];
      return items
          .map((json) => ReminderModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<ReminderModel> create({
    required String activityName,
    required String category,
    required String scheduledTime,
    String notes = '',
    String iconName = 'default',
    int repeatIntervalDays = 1,
    required List<int> activeDays,
  }) async {
    try {
      final response = await _dio.post('/patient/reminders', data: {
        'activity_name': activityName,
        'category': category,
        'scheduled_time': scheduledTime,
        'notes': notes,
        'icon_name': iconName,
        'repeat_interval_days': repeatIntervalDays,
        'active_days': activeDays,
      });
      final data = response.data['data'] as Map<String, dynamic>;
      return ReminderModel.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<ReminderModel> update(String id, {
    required String activityName,
    required String category,
    required String scheduledTime,
    String notes = '',
    String iconName = 'default',
    int repeatIntervalDays = 1,
    required List<int> activeDays,
  }) async {
    try {
      final response = await _dio.put('/patient/reminders/$id', data: {
        'activity_name': activityName,
        'category': category,
        'scheduled_time': scheduledTime,
        'notes': notes,
        'icon_name': iconName,
        'repeat_interval_days': repeatIntervalDays,
        'active_days': activeDays,
      });
      final data = response.data['data'] as Map<String, dynamic>;
      return ReminderModel.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<ReminderModel> toggle(String id) async {
    try {
      final response = await _dio.patch('/patient/reminders/$id/toggle');
      final data = response.data['data'] as Map<String, dynamic>;
      return ReminderModel.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _dio.delete('/patient/reminders/$id');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}

final reminderRepositoryProvider = Provider<IReminderRepository>((ref) {
  final dio = ref.watch(dioClientProvider);
  return ReminderRepository(dio);
});
