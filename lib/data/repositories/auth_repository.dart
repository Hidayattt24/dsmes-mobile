import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

import '../../core/constants/app_constants.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/auth_interceptor.dart';
import '../../core/network/dio_client.dart';
import '../../features/onboarding/models/onboarding_form_state.dart';

abstract class IAuthRepository {
  Future<Map<String, dynamic>> login({
    required String phoneNumber,
    required String password,
  });

  Future<Map<String, dynamic>> register(OnboardingFormState form);

  Future<Map<String, dynamic>> setupHealthProfile(OnboardingFormState form);

  Future<Map<String, dynamic>> setupSociodemographic(OnboardingFormState form);

  Future<Map<String, dynamic>> updateSociodemographic({
    required String district,
    required String address,
    required String healthFacility,
    required String livingArrangement,
    required String educationLevel,
    required String diabetesDuration,
  });

  Future<Map<String, dynamic>> calculateCalories(OnboardingFormState form);

  Future<Map<String, dynamic>> getPatientProfile();

  Future<Map<String, dynamic>> updatePatientProfile({
    required String fullName,
    required String nickname,
    required String whatsappNumber,
    required double heightCm,
    required double weightKg,
    required String activityLevel,
    String gender = '',
    String dateOfBirth = '',
    String bloodType = '',
    String? profilePhotoUrl,
  });

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<void> checkPhoneNumber({required String phoneNumber});

  Future<void> resetPasswordByPhone({
    required String phoneNumber,
    required String newPassword,
    required String confirmPassword,
  });

  Future<void> logout();

  Future<bool> isLoggedIn();

  Future<bool> restoreSession();
}

class AuthRepository implements IAuthRepository {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  AuthRepository(this._dio, this._storage);

  @override
  Future<Map<String, dynamic>> login({
    required String phoneNumber,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'phone_number': phoneNumber.trim(), 'password': password},
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
      final payload = {
        'full_name': form.fullName.trim(),
        'nickname': form.nickname.trim(),
        'email': form.email.trim(),
        'phone_number': form.phoneNumber.trim(),
        'password': form.password,
      };

      final response = await _dio.post('/auth/register', data: payload);

      final data = response.data['data'] as Map<String, dynamic>;

      // Save tokens returned directly upon registration
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
  Future<Map<String, dynamic>> setupHealthProfile(
    OnboardingFormState form,
  ) async {
    try {
      final dobStr =
          form.birthDate != null
              ? DateFormat('yyyy-MM-dd').format(form.birthDate!)
              : '';

      final payload = {
        'gender': form.gender ?? 'Laki-laki',
        'date_of_birth': dobStr,
        'blood_type': form.bloodType ?? 'Tidak Tahu',
        'height_cm': form.heightValue,
        'weight_kg': form.weightValue,
        'activity_level': form.activityLevel ?? 'Ringan',
      };

      final response = await _dio.post('/patient/profile/setup', data: payload);

      return response.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<Map<String, dynamic>> setupSociodemographic(
    OnboardingFormState form,
  ) async {
    try {
      final payload = {
        'city': form.city,
        'district': form.district.trim(),
        'address': form.address.trim(),
        'health_facility': form.healthFacility.trim(),
        'living_arrangement': form.livingArrangement ?? '',
        'education_level': form.educationLevel ?? '',
        'diabetes_duration': form.diabetesDuration ?? '',
      };

      final response = await _dio.post(
        '/patient/profile/sociodemographic',
        data: payload,
      );

      return response.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<Map<String, dynamic>> updateSociodemographic({
    required String district,
    required String address,
    required String healthFacility,
    required String livingArrangement,
    required String educationLevel,
    required String diabetesDuration,
  }) async {
    try {
      final response = await _dio.post(
        '/patient/profile/sociodemographic',
        data: {
          'district': district.trim(),
          'address': address.trim(),
          'health_facility': healthFacility.trim(),
          'living_arrangement': livingArrangement,
          'education_level': educationLevel,
          'diabetes_duration': diabetesDuration,
        },
      );
      return response.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<Map<String, dynamic>> calculateCalories(
    OnboardingFormState form,
  ) async {
    try {
      final dobStr =
          form.birthDate != null
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
  Future<Map<String, dynamic>> getPatientProfile() async {
    try {
      final response = await _dio.get('/patient/me');
      return response.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<Map<String, dynamic>> updatePatientProfile({
    required String fullName,
    required String nickname,
    required String whatsappNumber,
    required double heightCm,
    required double weightKg,
    required String activityLevel,
    String gender = '',
    String dateOfBirth = '',
    String bloodType = '',
    String? profilePhotoUrl,
  }) async {
    try {
      final data = <String, dynamic>{
        'full_name': fullName,
        'nickname': nickname,
        'whatsapp_number': whatsappNumber,
        'height_cm': heightCm,
        'weight_kg': weightKg,
        'physical_activity_level': activityLevel,
      };
      if (gender.isNotEmpty) data['gender'] = gender;
      if (dateOfBirth.isNotEmpty) data['date_of_birth'] = dateOfBirth;
      if (bloodType.isNotEmpty) data['blood_type'] = bloodType;
      if (profilePhotoUrl != null && profilePhotoUrl.isNotEmpty) {
        data['profile_photo_url'] = profilePhotoUrl;
      }

      final response = await _dio.put('/patient/me', data: data);
      return response.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _dio.put(
        '/patient/me/password',
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<void> checkPhoneNumber({required String phoneNumber}) async {
    try {
      await _dio.post(
        '/auth/forgot-password/check-phone',
        data: {'phone_number': phoneNumber.trim()},
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<void> resetPasswordByPhone({
    required String phoneNumber,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      await _dio.post(
        '/auth/reset-password-by-phone',
        data: {
          'phone_number': phoneNumber.trim(),
          'new_password': newPassword,
          'confirm_password': confirmPassword,
        },
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<void> logout() async {
    try {
      final refreshToken = await _storage.read(
        key: AppConstants.keyRefreshToken,
      );
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

  @override
  Future<bool> restoreSession() async {
    final accessToken = await _storage.read(key: AppConstants.keyAuthToken);
    final refreshToken = await _storage.read(key: AppConstants.keyRefreshToken);

    if (accessToken == null ||
        accessToken.isEmpty ||
        refreshToken == null ||
        refreshToken.isEmpty) {
      return false;
    }

    final expiresAt = _jwtExpiry(accessToken);
    final needsRefresh =
        expiresAt == null ||
        expiresAt.isBefore(DateTime.now().add(const Duration(minutes: 1)));

    if (!needsRefresh) return true;
    return _refreshSession(refreshToken);
  }

  Future<bool> _refreshSession(String refreshToken) async {
    try {
      final response = await _dio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );
      final data = response.data['data'] as Map<String, dynamic>;
      final tokens = data['tokens'] as Map<String, dynamic>;
      await _saveTokens(
        accessToken: tokens['access_token'] as String,
        refreshToken: tokens['refresh_token'] as String,
      );
      return true;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        await _clearTokens();
        return false;
      }
      return true;
    }
  }

  DateTime? _jwtExpiry(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final payload =
          jsonDecode(
                utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
              )
              as Map<String, dynamic>;
      final exp = payload['exp'];
      if (exp is! num) return null;
      return DateTime.fromMillisecondsSinceEpoch(exp.toInt() * 1000);
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveTokens({
    required String accessToken,
    required String refreshToken,
    String? userId,
  }) async {
    await _storage.write(key: AppConstants.keyAuthToken, value: accessToken);
    await _storage.write(
      key: AppConstants.keyRefreshToken,
      value: refreshToken,
    );
    if (userId != null) {
      await _storage.write(key: AppConstants.keyUserId, value: userId);
    }
  }

  Future<void> _clearTokens() async {
    await _storage.delete(key: AppConstants.keyAuthToken);
    await _storage.delete(key: AppConstants.keyRefreshToken);
    await _storage.delete(key: AppConstants.keyUserId);
    // Clear session-scoped preferences so a different user logging in on the
    // same device starts fresh (no stale onboarding/biometric flags).
    await _storage.delete(key: AppConstants.keyOnboardingComplete);
    await _storage.delete(key: AppConstants.keyBiometricEnabled);
  }
}

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final dio = ref.watch(dioClientProvider);
  final storage = ref.watch(secureStorageProvider);
  return AuthRepository(dio, storage);
});
