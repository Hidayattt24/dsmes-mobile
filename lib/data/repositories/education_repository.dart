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
    bool isCompleted = false,
  });
  Future<void> markVideoWatched(
    String id, {
    required int watchDuration,
    required int lastTimestamp,
  });
  Future<void> markAudioListened(
    String id, {
    required int listenDuration,
    required int lastTimestamp,
    bool isCompleted = false,
  });
  Future<Map<String, dynamic>> getPatientProgress(String id);
  Future<void> submitReview(String id, {required int rating, String? note});
  Future<Map<String, dynamic>> getArticleRating(String id);
}

class EducationRepository implements IEducationRepository {
  final Dio _dio;

  EducationRepository(this._dio);

  @override
  Future<List<String>> getCategories() async {
    try {
      final response = await _dio.get('/education/categories');
      final list = response.data['data'] as List<dynamic>? ?? [];
      return list
          .map((e) => (e['name'] ?? '').toString())
          .where((n) => n.isNotEmpty)
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<List<EducationArticle>> getArticles({String? categoryId}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (categoryId != null &&
          categoryId.isNotEmpty &&
          categoryId != 'Semua') {
        queryParams['category_id'] = categoryId;
      }
      final response = await _dio.get(
        '/education/articles',
        queryParameters: queryParams,
      );
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
      var article = EducationArticle.fromJson(data);

      try {
        final progressResponse = await _dio.get(
          '/patient/education/$id/progress',
        );
        final progress =
            progressResponse.data['data'] as Map<String, dynamic>? ?? const {};
        final audioListened = progress['audio_listened'] == true;
        final completed = progress['completed'] == true;

        article = article.copyWith(
          isAudioListened: audioListened,
          audioListenDuration:
              (progress['audio_listen_duration'] as num?)?.toInt() ?? 0,
          audioLastTimestamp:
              (progress['audio_last_timestamp'] as num?)?.toInt() ?? 0,
          isCompleted: article.isCompleted || completed,
          readStatus:
              article.isCompleted || completed ? 'Selesai' : article.readStatus,
          readProgress:
              article.isCompleted || completed ? 1.0 : article.readProgress,
        );
      } on DioException catch (e) {
        // A patient who has never opened this media has no progress row yet.
        // Keep the article detail usable and treat that response as not started.
        if (e.response?.statusCode != 404) rethrow;
      }

      return article;
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
    bool isCompleted = false,
  }) async {
    try {
      await _dio.post(
        '/patient/education/$id/read-article',
        data: {
          'reading_duration': readingDuration,
          'last_scroll_position': lastScroll,
          'is_completed': isCompleted,
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
  Future<void> markAudioListened(
    String id, {
    required int listenDuration,
    required int lastTimestamp,
    bool isCompleted = false,
  }) async {
    try {
      await _dio.post(
        '/patient/education/$id/listen-audio',
        data: {
          'listen_duration': listenDuration,
          'audio_last_timestamp': lastTimestamp,
          'is_completed': isCompleted,
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

  @override
  Future<void> submitReview(
    String id, {
    required int rating,
    String? note,
  }) async {
    try {
      await _dio.post(
        '/patient/education/$id/review',
        data: {'rating': rating, 'note': note ?? ''},
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<Map<String, dynamic>> getArticleRating(String id) async {
    try {
      final response = await _dio.get('/education/$id/rating');
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
