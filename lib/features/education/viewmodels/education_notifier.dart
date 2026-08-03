import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/education_repository.dart';
import '../models/education_article.dart';

// ── Categories Provider ──────────────────────────────────────────────────────

/// Fetches category names from the backend and prepends 'Semua'.
class EducationCategoriesNotifier extends AutoDisposeAsyncNotifier<List<String>> {
  @override
  FutureOr<List<String>> build() => _fetch();

  Future<List<String>> _fetch() async {
    final repo = ref.read(educationRepositoryProvider);
    final names = await repo.getCategories();
    return ['Semua', ...names];
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
class EducationListNotifier extends AutoDisposeAsyncNotifier<List<EducationArticle>> {
  @override
  FutureOr<List<EducationArticle>> build() {
    return _fetchArticles();
  }

  Future<List<EducationArticle>> _fetchArticles({String? categoryId}) async {
    final repo = ref.read(educationRepositoryProvider);
    return repo.getArticles(categoryId: categoryId);
  }

  Future<void> filterByCategory(String categoryId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchArticles(categoryId: categoryId));
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
    updatedArticles[index] = targetArticle.copyWith(isBookmarked: newBookmarkStatus);
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

final educationListProvider =
    AutoDisposeAsyncNotifierProvider<EducationListNotifier, List<EducationArticle>>(() {
  return EducationListNotifier();
});

// Notifier for fetching saved (bookmarked) articles
class SavedArticlesNotifier extends AutoDisposeAsyncNotifier<List<EducationArticle>> {
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

final savedArticlesProvider =
    AutoDisposeAsyncNotifierProvider<SavedArticlesNotifier, List<EducationArticle>>(() {
  return SavedArticlesNotifier();
});

// Notifier for detail article view
class EducationDetailNotifier extends AutoDisposeFamilyAsyncNotifier<EducationArticle, String> {
  @override
  FutureOr<EducationArticle> build(String arg) {
    return _fetchDetail(arg);
  }

  Future<EducationArticle> _fetchDetail(String articleId) async {
    final repo = ref.read(educationRepositoryProvider);
    return repo.getArticleDetail(articleId);
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
    state = AsyncValue.data(currentArticle.copyWith(isBookmarked: newBookmarkStatus));

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
        isCompleted: false, // Scroll telemetry only - completion is ONLY triggered via explicit button press
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
      await repo.markVideoWatched(
        arg,
        watchDuration: 60,
        lastTimestamp: 60,
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
    } catch (e) {
      rethrow;
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
      ref.invalidate(educationDetailProvider(arg));
      ref.invalidate(educationListProvider);
    } catch (e) {
      rethrow;
    }
  }
}


final educationDetailProvider =
    AutoDisposeAsyncNotifierProviderFamily<EducationDetailNotifier, EducationArticle, String>(() {
  return EducationDetailNotifier();
});
