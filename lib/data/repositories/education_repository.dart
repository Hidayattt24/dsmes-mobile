import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_exception.dart';
import '../../core/network/dio_client.dart';
import '../../features/education/models/education_article.dart';

abstract class IEducationRepository {
  Future<List<String>> getCategories();
  Future<List<EducationArticle>> getArticles({String? categoryId});
  Future<EducationArticle> getArticleDetail(String id);
  Future<void> saveBookmark(String id);
  Future<void> unsaveBookmark(String id);
  Future<List<EducationArticle>> getSavedArticles();
  Future<void> markArticleRead(
    String id, {
    required int readingDuration,
    required int lastScroll,
  });
  Future<void> markVideoWatched(
    String id, {
    required int watchDuration,
    required int lastTimestamp,
  });
  Future<Map<String, dynamic>> getPatientProgress(String id);
}

class EducationRepository implements IEducationRepository {
  final Dio _dio;

  EducationRepository(this._dio);

  @override
  Future<List<String>> getCategories() async {
    try {
      final response = await _dio.get('/education/categories');
      final list = response.data['data'] as List<dynamic>? ?? [];
      return list.map((e) => (e['name'] ?? '').toString()).where((n) => n.isNotEmpty).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<List<EducationArticle>> getArticles({String? categoryId}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (categoryId != null && categoryId.isNotEmpty && categoryId != 'Semua') {
        queryParams['category_id'] = categoryId;
      }
      final response = await _dio.get('/education/articles', queryParameters: queryParams);
      final list = response.data['data'] as List<dynamic>? ?? [];
      return list.map((json) => EducationArticle.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<EducationArticle> getArticleDetail(String id) async {
    try {
      final response = await _dio.get('/education/articles/$id');
      final data = response.data['data'] as Map<String, dynamic>;
      return EducationArticle.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<void> saveBookmark(String id) async {
    try {
      await _dio.post('/patient/education/$id/save');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<void> unsaveBookmark(String id) async {
    try {
      await _dio.delete('/patient/education/$id/save');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<List<EducationArticle>> getSavedArticles() async {
    try {
      final response = await _dio.get('/patient/education/saved');
      final list = response.data['data'] as List<dynamic>? ?? [];
      return list.map((json) => EducationArticle.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<void> markArticleRead(
    String id, {
    required int readingDuration,
    required int lastScroll,
  }) async {
    try {
      await _dio.post(
        '/patient/education/$id/read-article',
        data: {
          'reading_duration': readingDuration,
          'last_scroll_position': lastScroll,
        },
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<void> markVideoWatched(
    String id, {
    required int watchDuration,
    required int lastTimestamp,
  }) async {
    try {
      await _dio.post(
        '/patient/education/$id/watch-video',
        data: {
          'watch_duration': watchDuration,
          'video_last_timestamp': lastTimestamp,
        },
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<Map<String, dynamic>> getPatientProgress(String id) async {
    try {
      final response = await _dio.get('/patient/education/$id/progress');
      return response.data['data'] as Map<String, dynamic>? ?? {};
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}

final educationRepositoryProvider = Provider<IEducationRepository>((ref) {
  final dio = ref.watch(dioClientProvider);
  return EducationRepository(dio);
});
