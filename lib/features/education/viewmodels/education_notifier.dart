import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/offline_cache_manager.dart';
import '../../../data/repositories/education_repository.dart';
import '../models/education_article.dart';

// ── Categories Provider ──────────────────────────────────────────────────────

/// Fetches category names from the backend and prepends 'Semua'.
class EducationCategoriesNotifier
    extends AutoDisposeAsyncNotifier<List<String>> {
  @override
  FutureOr<List<String>> build() => _fetch();

  Future<List<String>> _fetch() async {
    final cacheManager = ref.read(offlineCacheManagerProvider);
    try {
      final repo = ref.read(educationRepositoryProvider);
      final names = await repo.getCategories();
      await cacheManager.saveCache(
        OfflineCacheManager.keyEducationCategories,
        names,
      );
      return ['Semua', ...names];
    } catch (error) {
      try {
        final cached = await cacheManager.getCache(
          OfflineCacheManager.keyEducationCategories,
        );
        if (cached is List && cached.isNotEmpty) {
          return ['Semua', ...cached.cast<String>()];
        }
      } catch (_) {}
      return const ['Semua'];
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetch);
  }
}

final educationCategoriesProvider =
    AutoDisposeAsyncNotifierProvider<EducationCategoriesNotifier, List<String>>(
      () => EducationCategoriesNotifier(),
    );

// Notifier for fetching and managing all articles
class EducationListNotifier
    extends AutoDisposeAsyncNotifier<List<EducationArticle>> {
  @override
  FutureOr<List<EducationArticle>> build() {
    return _fetchArticles();
  }

  Future<List<EducationArticle>> _fetchArticles({String? categoryId}) async {
    final cacheManager = ref.read(offlineCacheManagerProvider);
    try {
      final repo = ref.read(educationRepositoryProvider);
      final started = DateTime.now();
      final articles = await repo.getArticles(categoryId: categoryId);
      debugPrint(
        '[EDUCATION][LIST] api_ms=${DateTime.now().difference(started).inMilliseconds} count=${articles.length}',
      );
      if (categoryId == null || categoryId == 'Semua' || categoryId.isEmpty) {
        final cacheStarted = DateTime.now();
        // Banner data URIs are about 800 KB each. Encrypting several of them
        // synchronously for the offline list can stall the UI isolate.
        final cacheArticles =
            articles.map((article) {
              final json = article.toJson();
              final banner = json['banner_image_url'] as String? ?? '';
              if (banner.startsWith('data:image/')) {
                json['banner_image_url'] = '';
              }
              return json;
            }).toList();
        unawaited(
          cacheManager
              .saveCache(
                OfflineCacheManager.keyEducationArticles,
                cacheArticles,
              )
              .then(
                (_) => debugPrint(
                  '[EDUCATION][LIST] cache_ms=${DateTime.now().difference(cacheStarted).inMilliseconds}',
                ),
              )
              .catchError(
                (Object error) =>
                    debugPrint('[EDUCATION][LIST] cache_failed=$error'),
              ),
        );
      }
      return articles;
    } catch (error) {
      try {
        final cached = await cacheManager.getCache(
          OfflineCacheManager.keyEducationArticles,
        );
        if (cached is List && cached.isNotEmpty) {
          final list =
              cached
                  .whereType<Map<String, dynamic>>()
                  .map(
                    (json) =>
                        EducationArticle.fromJson(json, includeContent: false),
                  )
                  .toList();
          if (categoryId != null &&
              categoryId.isNotEmpty &&
              categoryId != 'Semua') {
            return list.where((a) => a.category == categoryId).toList();
          }
          return list;
        }
      } catch (_) {}
      debugPrint('[EDUCATION][LIST] api/cache unavailable: $error');
      rethrow;
    }
  }

  Future<void> filterByCategory(String categoryId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _fetchArticles(categoryId: categoryId),
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchArticles());
  }

  // Optimistic Bookmark Toggle
  Future<void> toggleBookmark(String articleId) async {
    final previousState = state;
    if (!state.hasValue) return;

    final currentArticles = state.value!;
    final index = currentArticles.indexWhere((a) => a.id == articleId);
    if (index == -1) return;

    final targetArticle = currentArticles[index];
    final newBookmarkStatus = !targetArticle.isBookmarked;

    // 1. Update UI optimistically
    final updatedArticles = List<EducationArticle>.from(currentArticles);
    updatedArticles[index] = targetArticle.copyWith(
      isBookmarked: newBookmarkStatus,
    );
    state = AsyncValue.data(updatedArticles);

    try {
      final repo = ref.read(educationRepositoryProvider);
      if (newBookmarkStatus) {
        await repo.saveBookmark(articleId);
      } else {
        await repo.unsaveBookmark(articleId);
      }
      // Refresh saved articles list in background
      ref.invalidate(savedArticlesProvider);
    } catch (e) {
      // 2. Rollback on failure
      state = previousState;
      rethrow;
    }
  }
}

final educationListProvider = AutoDisposeAsyncNotifierProvider<
  EducationListNotifier,
  List<EducationArticle>
>(() {
  return EducationListNotifier();
});

// Notifier for fetching saved (bookmarked) articles
class SavedArticlesNotifier
    extends AutoDisposeAsyncNotifier<List<EducationArticle>> {
  @override
  FutureOr<List<EducationArticle>> build() {
    return _fetchSaved();
  }

  Future<List<EducationArticle>> _fetchSaved() async {
    final repo = ref.read(educationRepositoryProvider);
    return repo.getSavedArticles();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchSaved());
  }
}

final savedArticlesProvider = AutoDisposeAsyncNotifierProvider<
  SavedArticlesNotifier,
  List<EducationArticle>
>(() {
  return SavedArticlesNotifier();
});

// Notifier for detail article view
class EducationDetailNotifier
    extends AutoDisposeFamilyAsyncNotifier<EducationArticle, String> {
  @override
  FutureOr<EducationArticle> build(String arg) {
    return _fetchDetail(arg);
  }

  Future<EducationArticle> _fetchDetail(String articleId) async {
    final cacheManager = ref.read(offlineCacheManagerProvider);
    final cacheKey =
        '${OfflineCacheManager.keyEducationDetailPrefix}$articleId';

    try {
      final repo = ref.read(educationRepositoryProvider);
      final started = DateTime.now();
      final article = await repo.getArticleDetail(articleId);
      debugPrint(
        '[EDUCATION][DETAIL] api_ms=${DateTime.now().difference(started).inMilliseconds}',
      );
      unawaited(
        cacheManager
            .saveCache(cacheKey, article.toJson())
            .then((_) => debugPrint('[EDUCATION][DETAIL] cache_saved')),
      );
      unawaited(_loadProgress(articleId, article, cacheKey));
      return article;
    } catch (e) {
      try {
        final cached = await cacheManager.getCache(cacheKey);
        if (cached is Map<String, dynamic>) {
          return EducationArticle.fromJson(cached);
        }
      } catch (_) {}
      rethrow;
    }
  }

  Future<void> _loadProgress(
    String articleId,
    EducationArticle initial,
    String cacheKey,
  ) async {
    final started = DateTime.now();
    try {
      final progress = await ref
          .read(educationRepositoryProvider)
          .getPatientProgress(articleId)
          .timeout(const Duration(seconds: 8));
      final listened = progress['audio_listened'] == true;
      final completed = progress['completed'] == true;
      final merged = initial.copyWith(
        isAudioListened: listened,
        audioListenDuration:
            (progress['audio_listen_duration'] as num?)?.toInt() ?? 0,
        audioLastTimestamp:
            (progress['audio_last_timestamp'] as num?)?.toInt() ?? 0,
        isCompleted: initial.isCompleted || completed,
        readStatus:
            initial.isCompleted || completed ? 'Selesai' : initial.readStatus,
        readProgress:
            initial.isCompleted || completed ? 1.0 : initial.readProgress,
      );
      if (state.hasValue && state.value?.id == articleId) {
        state = AsyncValue.data(merged);
      }
      unawaited(
        ref
            .read(offlineCacheManagerProvider)
            .saveCache(cacheKey, merged.toJson()),
      );
      debugPrint(
        '[EDUCATION][PROGRESS] api_ms=${DateTime.now().difference(started).inMilliseconds}',
      );
    } catch (error) {
      debugPrint(
        '[EDUCATION][PROGRESS] unavailable after ${DateTime.now().difference(started).inMilliseconds}ms: $error',
      );
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchDetail(arg));
  }

  Future<void> toggleBookmark() async {
    if (!state.hasValue) return;

    final currentArticle = state.value!;
    final newBookmarkStatus = !currentArticle.isBookmarked;

    // Update locally
    state = AsyncValue.data(
      currentArticle.copyWith(isBookmarked: newBookmarkStatus),
    );

    try {
      final repo = ref.read(educationRepositoryProvider);
      if (newBookmarkStatus) {
        await repo.saveBookmark(arg);
      } else {
        await repo.unsaveBookmark(arg);
      }
      // Sync other lists
      ref.invalidate(educationListProvider);
      ref.invalidate(savedArticlesProvider);
    } catch (e) {
      // Rollback
      state = AsyncValue.data(currentArticle);
      rethrow;
    }
  }

  Future<void> reportReadProgress({
    required int duration,
    required int scrollPercentage,
  }) async {
    try {
      final repo = ref.read(educationRepositoryProvider);
      await repo.markArticleRead(
        arg,
        readingDuration: duration,
        lastScroll: scrollPercentage,
        isCompleted:
            false, // Scroll telemetry only - completion is ONLY triggered via explicit button press
      );
    } catch (_) {
      // Keep silent to prevent disrupting user experience on network hiccups
    }
  }

  Future<void> markArticleRead() async {
    try {
      final repo = ref.read(educationRepositoryProvider);
      await repo.markArticleRead(
        arg,
        readingDuration: 60,
        lastScroll: 100,
        isCompleted: true, // Button press explicitly marks completion
      );
      if (state.hasValue) {
        state = AsyncValue.data(
          state.value!.copyWith(
            isCompleted: true,
            isArticleRead: true,
            readStatus: 'Selesai',
            readProgress: 1.0,
          ),
        );
      }
      ref.invalidate(educationListProvider);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markVideoWatched() async {
    try {
      final repo = ref.read(educationRepositoryProvider);
      await repo.markVideoWatched(arg, watchDuration: 60, lastTimestamp: 60);
      if (state.hasValue) {
        state = AsyncValue.data(
          state.value!.copyWith(
            isCompleted: true,
            isYoutubeWatched: true,
            readStatus: 'Selesai',
            readProgress: 1.0,
          ),
        );
      }
      ref.invalidate(educationListProvider);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markAudioListened({
    required int duration,
    required int lastTimestamp,
  }) async {
    try {
      final repo = ref.read(educationRepositoryProvider);
      await repo.markAudioListened(
        arg,
        listenDuration: duration,
        lastTimestamp: lastTimestamp,
        isCompleted: true,
      );
      if (state.hasValue) {
        state = AsyncValue.data(
          state.value!.copyWith(
            isCompleted: true,
            isAudioListened: true,
            audioListenDuration: duration,
            audioLastTimestamp: lastTimestamp,
            readStatus: 'Selesai',
            readProgress: 1.0,
          ),
        );
      }
      ref.invalidate(educationListProvider);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> reportAudioProgress({
    required int duration,
    required int lastTimestamp,
  }) async {
    try {
      final repo = ref.read(educationRepositoryProvider);
      await repo.markAudioListened(
        arg,
        listenDuration: duration,
        lastTimestamp: lastTimestamp,
        isCompleted: false,
      );
    } catch (_) {
      // Keep silent
    }
  }

  Future<void> reportWatchProgress({
    required int duration,
    required int lastTimestamp,
  }) async {
    try {
      final repo = ref.read(educationRepositoryProvider);
      await repo.markVideoWatched(
        arg,
        watchDuration: duration,
        lastTimestamp: lastTimestamp,
      );
      if (state.hasValue) {
        state = AsyncValue.data(
          state.value!.copyWith(
            isCompleted: true,
            isYoutubeWatched: true,
            readStatus: 'Selesai',
            readProgress: 1.0,
          ),
        );
      }
      ref.invalidate(educationListProvider);
    } catch (_) {
      // Keep silent
    }
  }

  Future<void> submitReview({required int rating, String? note}) async {
    try {
      final repo = ref.read(educationRepositoryProvider);
      await repo.submitReview(arg, rating: rating, note: note);
      if (state.hasValue) {
        state = AsyncValue.data(
          state.value!.copyWith(
            isCompleted: true,
            readStatus: 'Selesai',
            readProgress: 1.0,
          ),
        );
      }
      ref.invalidate(educationListProvider);
    } catch (e) {
      rethrow;
    }
  }
}

final educationDetailProvider = AutoDisposeAsyncNotifierProviderFamily<
  EducationDetailNotifier,
  EducationArticle,
  String
>(() {
  return EducationDetailNotifier();
});
