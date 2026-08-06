import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/questionnaire_repository.dart';
import '../models/questionnaire_detail_model.dart';
import '../models/quiz_attempt_model.dart';

// ── Active Pre-Test ──────────────────────────────────────────────────────────

/// Loads the active Pre-Test questionnaire from backend.
/// Used on Pre-Test intro screen and during navigation guard check.
final activePreTestProvider =
    AutoDisposeAsyncNotifierProvider<ActivePreTestNotifier, QuestionnaireDetailModel>(
  ActivePreTestNotifier.new,
);

class ActivePreTestNotifier
    extends AutoDisposeAsyncNotifier<QuestionnaireDetailModel> {
  @override
  Future<QuestionnaireDetailModel> build() => _fetch();

  Future<QuestionnaireDetailModel> _fetch() {
    return ref
        .read(questionnaireRepositoryProvider)
        .getActivePreTest();
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
    String>(PostTestByEducationNotifier.new);

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
    String>(QuestionnaireDetailNotifier.new);

class QuestionnaireDetailNotifier
    extends AutoDisposeFamilyAsyncNotifier<QuestionnaireDetailModel, String> {
  @override
  Future<QuestionnaireDetailModel> build(String id) {
    return ref
        .read(questionnaireRepositoryProvider)
        .getQuestionnaireById(id);
  }
}

// ── Attempt Detail for Review ──────────────────────────────────────────────────

final myAttemptDetailProvider = AutoDisposeAsyncNotifierProviderFamily<
    MyAttemptDetailNotifier,
    AttemptDetailModel,
    String>(MyAttemptDetailNotifier.new);

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
final preTestHistoryProvider =
    AutoDisposeAsyncNotifierProvider<PreTestHistoryNotifier, List<MyHistoryItemModel>>(
  PreTestHistoryNotifier.new,
);

class PreTestHistoryNotifier
    extends AutoDisposeAsyncNotifier<List<MyHistoryItemModel>> {
  @override
  Future<List<MyHistoryItemModel>> build() => _fetch();

  Future<List<MyHistoryItemModel>> _fetch() {
    return ref
        .read(questionnaireRepositoryProvider)
        .getMyHistory(type: 'PRE_TEST');
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }
}

/// Returns true if the patient has already completed the Pre-Test.
/// Flutter only reads this flag — never determines eligibility locally.
final hasCompletedPreTestProvider = Provider.autoDispose<AsyncValue<bool>>((ref) {
  final history = ref.watch(preTestHistoryProvider);
  return history.whenData((items) => items.isNotEmpty);
});

// ── All History ───────────────────────────────────────────────────────────────

/// Loads the full questionnaire attempt history for the current patient.
final allQuestionnaireHistoryProvider =
    AutoDisposeAsyncNotifierProvider<AllHistoryNotifier, List<MyHistoryItemModel>>(
  AllHistoryNotifier.new,
);

class AllHistoryNotifier extends AutoDisposeAsyncNotifier<List<MyHistoryItemModel>> {
  @override
  Future<List<MyHistoryItemModel>> build() => _fetch();

  Future<List<MyHistoryItemModel>> _fetch() {
    return ref.read(questionnaireRepositoryProvider).getMyHistory();
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
    PaginatedQuestionnaireResult>(QuestionnaireListNotifier.new);

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

  Future<PaginatedQuestionnaireResult> _fetch() {
    _fetching = true;
    return ref
        .read(questionnaireRepositoryProvider)
        .getPatientQuestionnaireList(perPage: 100)
        .whenComplete(() => _fetching = false);
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

      // Refresh history after successful submission
      ref.invalidate(preTestHistoryProvider);
      ref.invalidate(allQuestionnaireHistoryProvider);
      ref.invalidate(questionnaireListProvider);

      return result;
    } catch (e) {
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
}

final quizSubmissionProvider =
    NotifierProvider<QuizSubmissionNotifier, QuizSubmissionState>(
  QuizSubmissionNotifier.new,
);
