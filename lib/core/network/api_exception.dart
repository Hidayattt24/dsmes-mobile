import 'package:dio/dio.dart';

/// Exception thrown for API HTTP & Network errors.
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  const ApiException({
    required this.message,
    this.statusCode,
    this.errors,
  });

  factory ApiException.fromDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException(
          message: 'Koneksi ke server timeout. Silakan coba lagi.',
        );
      case DioExceptionType.connectionError:
        return const ApiException(
          message: 'Tidak ada koneksi internet atau server tidak dapat dijangkau.',
        );
      case DioExceptionType.cancel:
        return const ApiException(message: 'Permintaan dibatalkan.');
      case DioExceptionType.badResponse:
        final data = e.response?.data;
        if (data is Map<String, dynamic>) {
          final msg = data['message'] as String? ?? 'Terjadi kesalahan pada server.';
          Map<String, dynamic>? fieldErrs;
          if (data['errors'] is Map<String, dynamic>) {
            fieldErrs = data['errors'] as Map<String, dynamic>;
          }
          return ApiException(
            message: msg,
            statusCode: e.response?.statusCode,
            errors: fieldErrs,
          );
        }
        return ApiException(
          message: 'Terjadi kesalahan pada server (${e.response?.statusCode}).',
          statusCode: e.response?.statusCode,
        );
      default:
        return ApiException(
          message: e.message ?? 'Terjadi kesalahan yang tidak terduga.',
        );
    }
  }

  @override
  String toString() => message;
}
