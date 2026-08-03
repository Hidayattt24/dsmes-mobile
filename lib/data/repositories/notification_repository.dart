import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_exception.dart';
import '../../core/network/dio_client.dart';
import '../models/notification_model.dart';

abstract class INotificationRepository {
  Future<List<NotificationModel>> getNotifications();
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
  Future<void> deleteNotification(String id);
  Future<void> deleteAllNotifications();
}

class NotificationRepository implements INotificationRepository {
  final Dio _dio;

  NotificationRepository(this._dio);

  @override
  Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await _dio.get('/patient/notifications');
      final list = response.data['data'] as List<dynamic>? ?? [];
      return list
          .map((json) => NotificationModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<void> markAsRead(String id) async {
    try {
      await _dio.patch('/patient/notifications/$id/read');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      await _dio.patch('/patient/notifications/read');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<void> deleteNotification(String id) async {
    try {
      await _dio.delete('/patient/notifications/$id');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<void> deleteAllNotifications() async {
    try {
      await _dio.delete('/patient/notifications');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}

final notificationRepositoryProvider = Provider<INotificationRepository>((ref) {
  final dio = ref.watch(dioClientProvider);
  return NotificationRepository(dio);
});
