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

// ── Available Questionnaires (Post-Tests) ──────────────────────────────────────

/// Returns all active questionnaires available to the patient with completion status.
/// Filter by [type] = 'PRE_TEST' | 'POST_TEST' to narrow results.
final patientQuestionnaireListProvider = FutureProvider.autoDispose.family<PaginatedQuestionnaireResult, String?>((ref, type) async {
  return ref.read(questionnaireRepositoryProvider).getPatientQuestionnaireList(type: type);
});

/// Convenience provider: only active POST_TEST questionnaires that are NOT yet completed.
final availablePostTestsProvider = FutureProvider.autoDispose<List<PatientQuestionnaireItemModel>>((ref) async {
  final result = await ref.watch(patientQuestionnaireListProvider('POST_TEST').future);
  return result.items.where((q) => !q.isCompleted).toList();
});

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
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await ref
          .read(questionnaireRepositoryProvider)
          .submitQuestionnaire(
            questionnaireId: questionnaireId,
            answers: answers,
            durationSeconds: durationSeconds,
          );
      state = state.copyWith(isLoading: false, result: result);

      // Refresh history after successful submission
      ref.invalidate(preTestHistoryProvider);
      ref.invalidate(allQuestionnaireHistoryProvider);

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
