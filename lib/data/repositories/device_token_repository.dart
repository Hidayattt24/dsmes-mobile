import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_exception.dart';
import '../../core/network/dio_client.dart';

class DeviceTokenRepository {
  DeviceTokenRepository(this._dio);

  final Dio _dio;

  Future<void> register(String token) async {
    try {
      await _dio.post(
        '/patient/device-tokens',
        data: {'token': token, 'platform': 'android'},
      );
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
  }

  Future<void> delete(String token) async {
    try {
      await _dio.delete('/patient/device-tokens', data: {'token': token});
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
  }
}

final deviceTokenRepositoryProvider = Provider<DeviceTokenRepository>((ref) {
  return DeviceTokenRepository(ref.watch(dioClientProvider));
});
