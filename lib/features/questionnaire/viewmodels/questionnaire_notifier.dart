import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/network/auth_interceptor.dart';
import '../../../core/storage/offline_cache_manager.dart';
import '../../../core/sync/sync_queue_item.dart';
import '../../../core/sync/sync_queue_manager.dart';
import '../../../data/repositories/questionnaire_repository.dart';
import '../models/questionnaire_detail_model.dart';
import '../models/quiz_attempt_model.dart';

// ── Active Pre-Test ──────────────────────────────────────────────────────────

/// Loads the active Pre-Test questionnaire from backend.
/// Used on Pre-Test intro screen and during navigation guard check.
final activePreTestProvider = AutoDisposeAsyncNotifierProvider<
  ActivePreTestNotifier,
  QuestionnaireDetailModel
>(ActivePreTestNotifier.new);

class ActivePreTestNotifier
    extends AutoDisposeAsyncNotifier<QuestionnaireDetailModel> {
  @override
  Future<QuestionnaireDetailModel> build() => _fetch();

  Future<QuestionnaireDetailModel> _fetch() {
    return ref.read(questionnaireRepositoryProvider).getActivePreTest();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }
}

// ── Post-Test by Education ────────────────────────────────────────────────────

/// Loads a Post-Test for a given education material.
/// Returns null (AsyncData(null)) if no Post-Test linked to the education.
final postTestByEducationProvider = AutoDisposeAsyncNotifierProviderFamily<
  PostTestByEducationNotifier,
  QuestionnaireDetailModel?,
  String
>(PostTestByEducationNotifier.new);

class PostTestByEducationNotifier
    extends AutoDisposeFamilyAsyncNotifier<QuestionnaireDetailModel?, String> {
  @override
  Future<QuestionnaireDetailModel?> build(String educationId) async {
    if (educationId.isEmpty) return null;
    try {
      return await ref
          .read(questionnaireRepositoryProvider)
          .getPostTestByEducation(educationId);
    } catch (_) {
      // No post-test linked — treat as null, not an error
      return null;
    }
  }
}

// ── Questionnaire by ID ───────────────────────────────────────────────────────

final questionnaireDetailProvider = AutoDisposeAsyncNotifierProviderFamily<
  QuestionnaireDetailNotifier,
  QuestionnaireDetailModel,
  String
>(QuestionnaireDetailNotifier.new);

class QuestionnaireDetailNotifier
    extends AutoDisposeFamilyAsyncNotifier<QuestionnaireDetailModel, String> {
  @override
  Future<QuestionnaireDetailModel> build(String id) {
    return ref.read(questionnaireRepositoryProvider).getQuestionnaireById(id);
  }
}

// ── Attempt Detail for Review ──────────────────────────────────────────────────

final myAttemptDetailProvider = AutoDisposeAsyncNotifierProviderFamily<
  MyAttemptDetailNotifier,
  AttemptDetailModel,
  String
>(MyAttemptDetailNotifier.new);

class AttemptDetailQuery {
  const AttemptDetailQuery({
    required this.questionnaireId,
    required this.attemptId,
  });

  final String questionnaireId;
  final String attemptId;

  @override
  bool operator ==(Object other) =>
      other is AttemptDetailQuery &&
      other.questionnaireId == questionnaireId &&
      other.attemptId == attemptId;

  @override
  int get hashCode => Object.hash(questionnaireId, attemptId);
}

final attemptDetailByIdProvider = AutoDisposeAsyncNotifierProviderFamily<
  AttemptDetailByIdNotifier,
  AttemptDetailModel,
  AttemptDetailQuery
>(AttemptDetailByIdNotifier.new);

class AttemptDetailByIdNotifier
    extends
        AutoDisposeFamilyAsyncNotifier<AttemptDetailModel, AttemptDetailQuery> {
  @override
  Future<AttemptDetailModel> build(AttemptDetailQuery query) {
    return ref
        .read(questionnaireRepositoryProvider)
        .getMyAttemptDetailById(
          questionnaireId: query.questionnaireId,
          attemptId: query.attemptId,
        );
  }
}

class MyAttemptDetailNotifier
    extends AutoDisposeFamilyAsyncNotifier<AttemptDetailModel, String> {
  @override
  Future<AttemptDetailModel> build(String questionnaireId) {
    return ref
        .read(questionnaireRepositoryProvider)
        .getMyAttemptDetail(questionnaireId);
  }
}

// ── Pre-Test History ─────────────────────────────────────────────────────────

/// Loads all PRE_TEST attempts made by the current patient.
/// Used in Questionnaire history section and navigation guard.
final preTestHistoryProvider = AutoDisposeAsyncNotifierProvider<
  PreTestHistoryNotifier,
  List<MyHistoryItemModel>
>(PreTestHistoryNotifier.new);

class PreTestHistoryNotifier
    extends AutoDisposeAsyncNotifier<List<MyHistoryItemModel>> {
  @override
  Future<List<MyHistoryItemModel>> build() => _fetch();

  Future<List<MyHistoryItemModel>> _fetch() async {
    final storage = ref.read(secureStorageProvider);
    try {
      final items = await ref
          .read(questionnaireRepositoryProvider)
          .getMyHistory(type: 'PRE_TEST');
      if (items.isNotEmpty) {
        await storage.write(
          key: AppConstants.keyPreTestCompleted,
          value: 'true',
        );
      }
      return items;
    } catch (e) {
      final cached = await storage.read(key: AppConstants.keyPreTestCompleted);
      if (cached == 'true') {
        return [
          MyHistoryItemModel(
            attemptId: 'cached_pre_test',
            questionnaireId: 'pre_test',
            questionnaireTitle: 'Pre-Test',
            type: 'PRE_TEST',
            score: 100,
            passed: true,
            totalQuestions: 10,
            correctCount: 10,
            incorrectCount: 0,
            percentage: 100,
            completedAt: DateTime.now(),
          ),
        ];
      }
      rethrow;
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }
}

/// Returns true if the patient has already completed the Pre-Test.
/// Flutter only reads this flag — never determines eligibility locally.
final hasCompletedPreTestProvider = Provider.autoDispose<AsyncValue<bool>>((
  ref,
) {
  final history = ref.watch(preTestHistoryProvider);
  return history.whenData((items) => items.isNotEmpty);
});

// ── All History ───────────────────────────────────────────────────────────────

/// Loads the full questionnaire attempt history for the current patient.
final allQuestionnaireHistoryProvider = AutoDisposeAsyncNotifierProvider<
  AllHistoryNotifier,
  List<MyHistoryItemModel>
>(AllHistoryNotifier.new);

class AllHistoryNotifier
    extends AutoDisposeAsyncNotifier<List<MyHistoryItemModel>> {
  @override
  Future<List<MyHistoryItemModel>> build() => _fetch();

  Future<List<MyHistoryItemModel>> _fetch() async {
    final cacheManager = ref.read(offlineCacheManagerProvider);
    try {
      final items =
          await ref.read(questionnaireRepositoryProvider).getMyHistory();
      await cacheManager.saveCache(
        OfflineCacheManager.keyQuestionnaireHistory,
        items.map((e) => e.toJson()).toList(),
      );
      return items;
    } catch (_) {
      try {
        final cached = await cacheManager.getCache(
          OfflineCacheManager.keyQuestionnaireHistory,
        );
        if (cached is List && cached.isNotEmpty) {
          return cached
              .whereType<Map<String, dynamic>>()
              .map(MyHistoryItemModel.fromJson)
              .toList();
        }
      } catch (_) {}
      return const <MyHistoryItemModel>[];
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }
}

// ── Unified Questionnaire List (Available / Completed / Locked) ──────────────

/// Loads every questionnaire visible to the patient (Pre-Test & Post-Test) in a
/// single request. Each item carries its backend status, completion state, and
/// lock state, so the UI renders one unified list without any hardcoded status.
///
/// While the screen watches this provider it silently re-fetches every
/// [QuestionnaireListNotifier.pollInterval] so admin status changes
/// (publish / unpublish / edit availability) appear automatically without a
/// manual refresh.
final questionnaireListProvider = AutoDisposeAsyncNotifierProvider<
  QuestionnaireListNotifier,
  PaginatedQuestionnaireResult
>(QuestionnaireListNotifier.new);

class QuestionnaireListNotifier
    extends AutoDisposeAsyncNotifier<PaginatedQuestionnaireResult> {
  /// How often the list silently re-fetches while visible.
  static const Duration pollInterval = Duration(seconds: 30);

  Timer? _timer;
  bool _fetching = false;

  @override
  Future<PaginatedQuestionnaireResult> build() async {
    _timer?.cancel();
    _timer = Timer.periodic(pollInterval, (_) => silentRefresh());
    ref.onDispose(() => _timer?.cancel());
    return _fetch();
  }

  Future<PaginatedQuestionnaireResult> _fetch() async {
    _fetching = true;
    final cacheManager = ref.read(offlineCacheManagerProvider);
    try {
      final result = await ref
          .read(questionnaireRepositoryProvider)
          .getPatientQuestionnaireList(perPage: 100);
      await cacheManager.saveCache(
        OfflineCacheManager.keyQuestionnairesList,
        result.toJson(),
      );
      return result;
    } catch (_) {
      try {
        final cached = await cacheManager.getCache(
          OfflineCacheManager.keyQuestionnairesList,
        );
        if (cached is Map<String, dynamic>) {
          return PaginatedQuestionnaireResult.fromJson(cached);
        }
      } catch (_) {}
      return const PaginatedQuestionnaireResult(items: [], total: 0);
    } finally {
      _fetching = false;
    }
  }

  /// Explicit refresh (pull-to-refresh / retry).
  ///
  /// When there is already data, the current value is kept on screen while
  /// fetching (no flicker) and only replaced on success. When there is no data
  /// yet (first load / after an error) a loading state is shown.
  Future<void> refresh() async {
    if (_fetching) return;
    final hadData = state.hasValue;
    if (!hadData) state = const AsyncLoading();
    final next = await AsyncValue.guard(_fetch);
    if (!hadData || next.hasValue) {
      state = next;
    }
  }

  /// Background refresh — keeps the current data while fetching to avoid
  /// flicker. Errors during background refresh are ignored so stale data is
  /// never replaced with an error.
  Future<void> silentRefresh() async {
    if (_fetching) return;
    final next = await AsyncValue.guard(_fetch);
    if (next.hasValue) {
      state = next;
    }
  }
}

// ── Questionnaire Submission ──────────────────────────────────────────────────

/// State for questionnaire submission.
class QuizSubmissionState {
  const QuizSubmissionState({
    this.isLoading = false,
    this.result,
    this.errorMessage,
  });

  final bool isLoading;
  final QuizSubmitResultModel? result;
  final String? errorMessage;

  bool get hasResult => result != null;
  bool get hasError => errorMessage != null;

  QuizSubmissionState copyWith({
    bool? isLoading,
    QuizSubmitResultModel? result,
    String? errorMessage,
    bool clearError = false,
  }) {
    return QuizSubmissionState(
      isLoading: isLoading ?? this.isLoading,
      result: result ?? this.result,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class QuizSubmissionNotifier extends Notifier<QuizSubmissionState> {
  @override
  QuizSubmissionState build() => const QuizSubmissionState();

  Future<QuizSubmitResultModel?> submit({
    required String questionnaireId,
    required Map<String, String> answers,
    required int durationSeconds,
    bool isPreTest = false,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await ref
          .read(questionnaireRepositoryProvider)
          .submitQuestionnaire(
            questionnaireId: questionnaireId,
            answers: answers,
            durationSeconds: durationSeconds,
            isPreTest: isPreTest,
          );
      state = state.copyWith(isLoading: false, result: result);

      if (isPreTest && result != null) {
        await ref
            .read(secureStorageProvider)
            .write(key: AppConstants.keyPreTestCompleted, value: 'true');
      }

      return result;
    } catch (e) {
      // Offline fallback: enqueue persistent sync item
      try {
        final clientId = const Uuid().v4();
        final syncItem = SyncQueueItem(
          clientId: clientId,
          userId: '',
          dataType: SyncDataType.questionnaire,
          endpoint: '/patient/questionnaires/$questionnaireId/submit',
          method: 'POST',
          payload: {
            'answers': answers.entries.map((entry) {
              if (isPreTest) {
                return {
                  'question_id': entry.key,
                  'selected_value': int.tryParse(entry.value) ?? 1,
                };
              }
              return {
                'question_id': entry.key,
                'option_id': entry.value,
              };
            }).toList(),
            'duration_seconds': durationSeconds,
            'client_id': clientId,
          },
          createdAt: DateTime.now(),
        );
        await ref.read(syncQueueManagerProvider.notifier).enqueue(syncItem);

        if (isPreTest) {
          int totalLikert = 0;
          for (final val in answers.values) {
            totalLikert += int.tryParse(val) ?? 1;
          }
          String selfEffCat;
          if (totalLikert <= 40) {
            selfEffCat = 'Low Self-Efficacy';
          } else if (totalLikert <= 60) {
            selfEffCat = 'Moderate Self-Efficacy';
          } else if (totalLikert <= 80) {
            selfEffCat = 'Good Self-Efficacy';
          } else {
            selfEffCat = 'Very High Self-Efficacy';
          }

          final localResult = QuizSubmitResultModel(
            attemptId: clientId,
            questionnaireId: questionnaireId,
            score: totalLikert,
            passed: false, // NOT officially confirmed until server confirms
            totalQuestions: answers.length,
            correctCount: answers.length,
            selfEfficacyCategory: '$selfEffCat (Tersimpan Offline)',
          );

          state = state.copyWith(isLoading: false, result: localResult);
          return localResult;
        } else {
          final pendingResult = QuizSubmitResultModel(
            attemptId: clientId,
            questionnaireId: questionnaireId,
            score: 0,
            passed: false,
            totalQuestions: answers.length,
            correctCount: 0,
            selfEfficacyCategory: 'Menunggu Sinkronisasi Server',
          );

          state = state.copyWith(isLoading: false, result: pendingResult);
          return pendingResult;
        }
      } catch (_) {}

      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
      return null;
    }
  }

  void reset() {
    state = const QuizSubmissionState();
  }

  /// Refresh result sources after the result route has been presented.
  ///
  /// This must not run inside [submit]. The completion provider is also used
  /// by the GoRouter guard, so invalidating it before navigation can trigger a
  /// redirect while the result page is still being pushed.
  void refreshAfterSubmission(String questionnaireId) {
    ref.invalidate(preTestHistoryProvider);
    ref.invalidate(allQuestionnaireHistoryProvider);
    ref.invalidate(questionnaireListProvider);
    ref.invalidate(myAttemptDetailProvider(questionnaireId));
  }
}

final quizSubmissionProvider =
    NotifierProvider<QuizSubmissionNotifier, QuizSubmissionState>(
      QuizSubmissionNotifier.new,
    );
