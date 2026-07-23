import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_constants.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/auth_interceptor.dart';
import '../../core/network/dio_client.dart';
import '../../features/onboarding/models/onboarding_form_state.dart';

abstract class IAuthRepository {
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  });

  Future<Map<String, dynamic>> register(OnboardingFormState form);

  Future<Map<String, dynamic>> calculateCalories(OnboardingFormState form);

  Future<void> forgotPassword({required String email});


  Future<void> logout();

  Future<bool> isLoggedIn();
}

class AuthRepository implements IAuthRepository {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  AuthRepository(this._dio, this._storage);

  @override
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {
          'email': email.trim(),
          'password': password,
        },
      );

      final data = response.data['data'] as Map<String, dynamic>;
      final tokens = data['tokens'] as Map<String, dynamic>;
      final user = data['user'] as Map<String, dynamic>;

      // Ensure user role is patient / user
      final role = user['role'] as String?;
      if (role != null && role != 'user') {
        throw const ApiException(
          message: 'Akun ini bukan akun pasien.',
          statusCode: 403,
        );
      }

      await _saveTokens(
        accessToken: tokens['access_token'] as String,
        refreshToken: tokens['refresh_token'] as String,
        userId: user['id'] as String?,
      );

      return data;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<Map<String, dynamic>> register(OnboardingFormState form) async {
    try {
      final dobStr = form.birthDate != null
          ? DateFormat('yyyy-MM-dd').format(form.birthDate!)
          : '';

      final payload = {
        'full_name': form.fullName.trim(),
        'nickname': form.nickname.trim(),
        'email': form.email.trim(),
        'phone_number': form.phoneNumber.trim(),
        'password': form.password,
        'gender': form.gender ?? 'Laki-laki',
        'date_of_birth': dobStr,
        'blood_type': form.bloodType ?? 'Tidak Tahu',
        'height_cm': form.heightValue,
        'weight_kg': form.weightValue,
        'activity_level': form.activityLevel ?? 'Ringan',
      };


      final response = await _dio.post(
        '/auth/register',
        data: payload,
      );

      final data = response.data['data'] as Map<String, dynamic>;

      // Save tokens if returned directly upon registration
      if (data['tokens'] != null) {
        final tokens = data['tokens'] as Map<String, dynamic>;
        final user = data['user'] as Map<String, dynamic>?;

        await _saveTokens(
          accessToken: tokens['access_token'] as String,
          refreshToken: tokens['refresh_token'] as String,
          userId: user?['id'] as String?,
        );
      }

      return data;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<Map<String, dynamic>> calculateCalories(OnboardingFormState form) async {
    try {
      final dobStr = form.birthDate != null
          ? DateFormat('yyyy-MM-dd').format(form.birthDate!)
          : '';

      final payload = {
        'gender': form.gender ?? 'male',
        'date_of_birth': dobStr,
        'height_cm': form.heightValue,
        'weight_kg': form.weightValue,
        'activity_level': form.activityLevel ?? 'Ringan',
        'blood_type': form.bloodType ?? 'Tidak Tahu',
      };

      final response = await _dio.post(
        '/nutrition/calculate-calories',
        data: payload,
      );

      return response.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<void> forgotPassword({required String email}) async {

    try {
      await _dio.post(
        '/auth/forgot-password',
        data: {'email': email.trim()},
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<void> logout() async {
    try {
      final refreshToken =
          await _storage.read(key: AppConstants.keyRefreshToken);
      if (refreshToken != null) {
        await _dio.post('/auth/logout', data: {'refresh_token': refreshToken});
      }
    } catch (_) {
      // Ignore network failure on logout — proceed to clear storage
    } finally {
      await _clearTokens();
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: AppConstants.keyAuthToken);
    return token != null && token.isNotEmpty;
  }

  Future<void> _saveTokens({
    required String accessToken,
    required String refreshToken,
    String? userId,
  }) async {
    await _storage.write(key: AppConstants.keyAuthToken, value: accessToken);
    await _storage.write(
        key: AppConstants.keyRefreshToken, value: refreshToken);
    if (userId != null) {
      await _storage.write(key: AppConstants.keyUserId, value: userId);
    }
  }

  Future<void> _clearTokens() async {
    await _storage.delete(key: AppConstants.keyAuthToken);
    await _storage.delete(key: AppConstants.keyRefreshToken);
    await _storage.delete(key: AppConstants.keyUserId);
  }
}

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final dio = ref.watch(dioClientProvider);
  final storage = ref.watch(secureStorageProvider);
  return AuthRepository(dio, storage);
});
