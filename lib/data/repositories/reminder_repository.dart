import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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
  Future<ReminderModel> update(
    String id, {
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
      debugPrint('[REMINDER][API] GET /patient/reminders');
      final response = await _dio.get('/patient/reminders');
      final payload = response.data;
      final items =
          payload is Map<String, dynamic>
              ? payload['data'] as List<dynamic>? ?? []
              : <dynamic>[];
      final reminders =
          items
              .map(
                (json) => ReminderModel.fromJson(json as Map<String, dynamic>),
              )
              .toList();
      debugPrint(
        '[REMINDER][API] status=${response.statusCode} count=${reminders.length}',
      );
      return reminders;
    } on DioException catch (e) {
      debugPrint(
        '[REMINDER][API][ERROR] status=${e.response?.statusCode} '
        'type=${e.type} message=${e.message}',
      );
      throw ApiException.fromDioException(e);
    } catch (e, stackTrace) {
      debugPrint('[REMINDER][PARSE][ERROR] $e\n$stackTrace');
      rethrow;
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
      debugPrint('[REMINDER][API] POST /patient/reminders');
      final response = await _dio.post(
        '/patient/reminders',
        data: {
          'activity_name': activityName,
          'category': category,
          'scheduled_time': scheduledTime,
          'notes': notes,
          'icon_name': iconName,
          'repeat_interval_days': repeatIntervalDays,
          'active_days': activeDays,
        },
      );
      final data = response.data['data'] as Map<String, dynamic>;
      debugPrint('[REMINDER][API] POST status=${response.statusCode}');
      return ReminderModel.fromJson(data);
    } on DioException catch (e) {
      debugPrint(
        '[REMINDER][API][ERROR] POST status=${e.response?.statusCode} '
        'message=${e.message}',
      );
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<ReminderModel> update(
    String id, {
    required String activityName,
    required String category,
    required String scheduledTime,
    String notes = '',
    String iconName = 'default',
    int repeatIntervalDays = 1,
    required List<int> activeDays,
  }) async {
    try {
      debugPrint('[REMINDER][API] PUT /patient/reminders/$id');
      final response = await _dio.put(
        '/patient/reminders/$id',
        data: {
          'activity_name': activityName,
          'category': category,
          'scheduled_time': scheduledTime,
          'notes': notes,
          'icon_name': iconName,
          'repeat_interval_days': repeatIntervalDays,
          'active_days': activeDays,
        },
      );
      final data = response.data['data'] as Map<String, dynamic>;
      debugPrint('[REMINDER][API] PUT status=${response.statusCode} id=$id');
      return ReminderModel.fromJson(data);
    } on DioException catch (e) {
      debugPrint(
        '[REMINDER][API][ERROR] PUT id=$id status=${e.response?.statusCode} '
        'message=${e.message}',
      );
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<ReminderModel> toggle(String id) async {
    try {
      debugPrint('[REMINDER][API] PATCH /patient/reminders/$id/toggle');
      final response = await _dio.patch('/patient/reminders/$id/toggle');
      final data = response.data['data'] as Map<String, dynamic>;
      debugPrint('[REMINDER][API] PATCH status=${response.statusCode} id=$id');
      return ReminderModel.fromJson(data);
    } on DioException catch (e) {
      debugPrint(
        '[REMINDER][API][ERROR] PATCH id=$id status=${e.response?.statusCode} '
        'message=${e.message}',
      );
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      debugPrint('[REMINDER][API] DELETE /patient/reminders/$id');
      final response = await _dio.delete('/patient/reminders/$id');
      debugPrint('[REMINDER][API] DELETE status=${response.statusCode} id=$id');
    } on DioException catch (e) {
      debugPrint(
        '[REMINDER][API][ERROR] DELETE id=$id status=${e.response?.statusCode} '
        'message=${e.message}',
      );
      throw ApiException.fromDioException(e);
    }
  }
}

final reminderRepositoryProvider = Provider<IReminderRepository>((ref) {
  final dio = ref.watch(dioClientProvider);
  return ReminderRepository(dio);
});
