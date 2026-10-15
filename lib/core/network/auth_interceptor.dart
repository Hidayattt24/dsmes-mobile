import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_constants.dart';
import '../router/app_router.dart';
import '../router/route_names.dart';

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
        path.contains('/auth/reset-password') ||
        path.contains('/auth/forgot-password/check-phone') ||
        path.contains('/auth/reset-password-by-phone') ||
        path.contains('/auth/refresh');

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
    final isAlreadyRetried = err.requestOptions.extra['retried'] == true;
    final isRefreshRoute = err.requestOptions.path.contains('/auth/refresh');
    final isAuthRoute =
        err.requestOptions.path.contains('/auth/login') ||
        err.requestOptions.path.contains('/auth/register');

    if (err.response?.statusCode == 401 &&
        !isAlreadyRetried &&
        !isRefreshRoute &&
        !isAuthRoute) {
      final storage = _ref.read(secureStorageProvider);

      // 1. Check if token was already refreshed by another concurrent request
      final currentToken = await storage.read(key: AppConstants.keyAuthToken);
      final authHeader = err.requestOptions.headers['Authorization'] as String?;
      final sentToken = authHeader?.replaceFirst('Bearer ', '').trim();

      if (currentToken != null &&
          currentToken.isNotEmpty &&
          currentToken != sentToken) {
        // Token was already rotated; retry immediately with current token
        return _retryRequest(err.requestOptions, currentToken, handler);
      }

      // 2. Otherwise coordinate a single-flight refresh attempt across all concurrent 401s
      try {
        final refreshFuture = _refreshFuture ??= _refresh();
        final newAccessToken = await refreshFuture;
        if (identical(_refreshFuture, refreshFuture)) {
          _refreshFuture = null;
        }

        if (newAccessToken != null && newAccessToken.isNotEmpty) {
          return _retryRequest(err.requestOptions, newAccessToken, handler);
        }
      } catch (_) {
        if (_refreshFuture != null) _refreshFuture = null;
      }
    }

    handler.next(err);
  }

  Future<void> _retryRequest(
    RequestOptions requestOptions,
    String token,
    ErrorInterceptorHandler handler,
  ) async {
    final extra = Map<String, dynamic>.from(requestOptions.extra);
    extra['retried'] = true; // Guard against infinite retry loop

    final options = Options(
      method: requestOptions.method,
      headers: Map<String, dynamic>.from(requestOptions.headers)
        ..['Authorization'] = 'Bearer $token',
      responseType: requestOptions.responseType,
      contentType: requestOptions.contentType,
      validateStatus: requestOptions.validateStatus,
      receiveTimeout: requestOptions.receiveTimeout,
      sendTimeout: requestOptions.sendTimeout,
      extra: extra,
    );

    final dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.requiredBaseUrl,
        connectTimeout: AppConstants.connectTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
      ),
    );

    try {
      final response = await dio.request<dynamic>(
        requestOptions.path,
        data: requestOptions.data,
        queryParameters: requestOptions.queryParameters,
        options: options,
      );
      return handler.resolve(response);
    } on DioException catch (retryErr) {
      return handler.next(retryErr);
    }
  }

  Future<String?> _refresh() async {
    final storage = _ref.read(secureStorageProvider);
    final refreshToken = await storage.read(key: AppConstants.keyRefreshToken);
    if (refreshToken == null || refreshToken.isEmpty) {
      return null;
    }

    final dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.requiredBaseUrl,
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
      // ONLY definitive 401 on /auth/refresh indicates session is truly dead.
      // Temporary network disruptions, timeouts, or 5xx MUST preserve stored tokens!
      if (e.response?.statusCode == 401) {
        await storage.delete(key: AppConstants.keyAuthToken);
        await storage.delete(key: AppConstants.keyRefreshToken);
        await storage.delete(key: AppConstants.keyUserId);
        // Do NOT delete keyOnboardingComplete or keyPreTestCompleted!
        _triggerSessionExpiredNavigation();
        return null;
      }
      rethrow;
    }
  }

  void _triggerSessionExpiredNavigation() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = appNavigatorKey.currentContext;
      if (context != null && context.mounted) {
        try {
          final loc = GoRouterState.of(context).matchedLocation;
          if (loc != RouteNames.welcome &&
              loc != RouteNames.login &&
              loc != RouteNames.splash) {
            context.go(RouteNames.welcome);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Sesi Anda telah berakhir. Silakan masuk kembali.',
                ),
                backgroundColor: Color(0xFFD97706),
              ),
            );
          }
        } catch (_) {
          // Ignore if navigator is not mounted during headless tests
        }
      }
    });
  }
}
