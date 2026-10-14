import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/app_constants.dart';
import '../network/auth_interceptor.dart';
import 'local_storage_service.dart';

/// Manages encrypted local offline cache for critical health data (profile, logs, summaries,
/// reminders, history, education, questionnaires) using LocalStorageService (AES-256-GCM)
/// with per-user namespacing and fallback recovery.
class OfflineCacheManager {
  final LocalStorageService _localStorage;
  final FlutterSecureStorage _secureStorage;

  const OfflineCacheManager(this._localStorage, this._secureStorage);

  static const String keyDashboardProfile = 'offline_cache_dashboard_profile';
  static const String keyBloodSugarLogs = 'offline_cache_blood_sugar_logs';
  static const String keyNutritionSummary = 'offline_cache_nutrition_summary';
  static const String keyReminders = 'offline_cache_reminders';
  static const String keyHistory = 'offline_cache_history';
  static const String keyEducationArticles = 'offline_cache_education_articles';
  static const String keyEducationCategories = 'offline_cache_education_categories';
  static const String keyEducationDetailPrefix = 'offline_cache_edu_detail_';
  static const String keyQuestionnairesList = 'offline_cache_questionnaires_list';
  static const String keyQuestionnaireHistory = 'offline_cache_questionnaire_history';
  static const String keySurveysList = 'offline_cache_surveys_list';
  static const String keyLastSyncPrefix = 'offline_cache_sync_';

  Future<String?> _resolveUserId() async {
    try {
      return await _secureStorage.read(key: AppConstants.keyUserId);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveCache(String key, dynamic data) async {
    try {
      final userId = await _resolveUserId();
      await _localStorage.writeEncryptedJson(key, data, userId: userId);
      await _secureStorage.write(
        key: '$keyLastSyncPrefix${userId ?? "global"}_$key',
        value: DateTime.now().toIso8601String(),
      );
    } catch (_) {
      // Graceful degradation if storage write fails
    }
  }

  Future<dynamic> getCache(String key) async {
    try {
      final userId = await _resolveUserId();
      final data = await _localStorage.readEncryptedJson(key, userId: userId);
      if (data != null) return data;

      // Backward compatibility fallback to secureStorage if not yet migrated
      final legacy = await _secureStorage.read(key: key);
      if (legacy != null && legacy.isNotEmpty) {
        final decoded = jsonDecode(legacy);
        // Migrate to encrypted local storage
        await _localStorage.writeEncryptedJson(key, decoded, userId: userId);
        return decoded;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<DateTime?> getLastSyncTime(String key) async {
    try {
      final userId = await _resolveUserId();
      final str = await _secureStorage.read(
        key: '$keyLastSyncPrefix${userId ?? "global"}_$key',
      );
      if (str == null || str.isEmpty) return null;
      return DateTime.tryParse(str);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearAllCache({bool preservePendingQueue = true}) async {
    try {
      final userId = await _resolveUserId();
      await _localStorage.clearUserCache(
        userId ?? 'global',
        preservePendingQueue: preservePendingQueue,
      );
    } catch (_) {
      // Ignore
    }
  }
}

final offlineCacheManagerProvider = Provider<OfflineCacheManager>((ref) {
  final localStorage = ref.watch(localStorageServiceProvider);
  final secureStorage = ref.watch(secureStorageProvider);
  return OfflineCacheManager(localStorage, secureStorage);
});
