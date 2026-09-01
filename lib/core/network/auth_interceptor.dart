import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/app_constants.dart';

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

class AuthInterceptor extends Interceptor {
  final Ref _ref;
  Future<String?>? _refreshFuture;

  AuthInterceptor(this._ref);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final path = options.path;
    final isPublicAuth =
        path.contains('/auth/login') ||
        path.contains('/auth/register') ||
        path.contains('/auth/forgot-password') ||
        path.contains('/auth/verify-otp') ||
        path.contains('/auth/reset-password');

    if (!isPublicAuth) {
      final storage = _ref.read(secureStorageProvider);
      final token = await storage.read(key: AppConstants.keyAuthToken);

      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 &&
        !err.requestOptions.path.contains('/auth/login') &&
        !err.requestOptions.path.contains('/auth/register') &&
        !err.requestOptions.path.contains('/auth/refresh')) {
      // Attempt token refresh
      final storage = _ref.read(secureStorageProvider);
      final refreshToken = await storage.read(
        key: AppConstants.keyRefreshToken,
      );

      if (refreshToken != null && refreshToken.isNotEmpty) {
        try {
          final refreshFuture = _refreshFuture ??= _refresh(refreshToken);
          final newAccessToken = await refreshFuture;
          if (identical(_refreshFuture, refreshFuture)) {
            _refreshFuture = null;
          }

          if (newAccessToken != null) {
            final options = err.requestOptions;
            options.headers['Authorization'] = 'Bearer $newAccessToken';
            final dio = Dio(
              BaseOptions(
                baseUrl: AppConstants.baseUrl,
                connectTimeout: AppConstants.connectTimeout,
                receiveTimeout: AppConstants.receiveTimeout,
                headers: {'Content-Type': 'application/json'},
              ),
            );
            final retryResponse = await dio.fetch(options);
            return handler.resolve(retryResponse);
          }
        } catch (_) {
          // Preserve tokens for temporary network/server failures.
          if (_refreshFuture != null) _refreshFuture = null;
        }
      }
    }

    handler.next(err);
  }

  Future<String?> _refresh(String refreshToken) async {
    final storage = _ref.read(secureStorageProvider);
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: AppConstants.connectTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        headers: {'Content-Type': 'application/json'},
      ),
    );

    try {
      final response = await dio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );
      final data = response.data['data'] as Map<String, dynamic>;
      final tokens = data['tokens'] as Map<String, dynamic>;
      final newAccessToken = tokens['access_token'] as String;
      final newRefreshToken = tokens['refresh_token'] as String;

      await storage.write(
        key: AppConstants.keyAuthToken,
        value: newAccessToken,
      );
      await storage.write(
        key: AppConstants.keyRefreshToken,
        value: newRefreshToken,
      );
      return newAccessToken;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        await storage.delete(key: AppConstants.keyAuthToken);
        await storage.delete(key: AppConstants.keyRefreshToken);
        return null;
      }
      rethrow;
    }
  }
}
