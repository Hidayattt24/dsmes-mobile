import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/survey_repository.dart';
import '../models/survey_model.dart';

/// Notifier for fetching active published surveys for patient.
final activeSurveysProvider = AutoDisposeAsyncNotifierProvider<ActiveSurveysNotifier, List<SurveyModel>>(
  ActiveSurveysNotifier.new,
);

class ActiveSurveysNotifier extends AutoDisposeAsyncNotifier<List<SurveyModel>> {
  @override
  Future<List<SurveyModel>> build() => _fetch();

  Future<List<SurveyModel>> _fetch() {
    return ref.read(surveyRepositoryProvider).getActiveSurveys();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }
}

/// Backward compatible single survey provider alias
final activeSurveyProvider = Provider.autoDispose<AsyncValue<SurveyModel?>>((ref) {
  return ref.watch(activeSurveysProvider).whenData((list) => list.isNotEmpty ? list.first : null);
});

/// Notifier for submitting survey.
final surveySubmissionProvider = StateNotifierProvider<SurveySubmissionNotifier, AsyncValue<void>>(
  (ref) => SurveySubmissionNotifier(ref.read(surveyRepositoryProvider)),
);

class SurveySubmissionNotifier extends StateNotifier<AsyncValue<void>> {
  final ISurveyRepository _repository;

  SurveySubmissionNotifier(this._repository) : super(const AsyncData(null));

  Future<bool> submit({
    required String surveyId,
    required Map<String, int> answers,
    required int durationSeconds,
  }) async {
    state = const AsyncLoading();
    try {
      await _repository.submitSurvey(
        surveyId: surveyId,
        answers: answers,
        durationSeconds: durationSeconds,
      );
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}
