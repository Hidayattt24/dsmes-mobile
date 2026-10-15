import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_exception.dart';
import '../../core/network/dio_client.dart';
import '../../features/questionnaire/models/questionnaire_detail_model.dart';
import '../../features/questionnaire/models/quiz_attempt_model.dart';

abstract class IQuestionnaireRepository {
  /// Fetches the active Pre-Test questionnaire with all categories and questions.
  Future<QuestionnaireDetailModel> getActivePreTest({String? educationId});

  /// Fetches the Post-Test linked to a given education material.
  Future<QuestionnaireDetailModel> getPostTestByEducation(String educationId);

  /// Fetches a questionnaire by its ID.
  Future<QuestionnaireDetailModel> getQuestionnaireById(String id);

  /// Submits answers for a questionnaire. Backend calculates score.
  ///
  /// [answers] is a map of questionID → optionID (or Likert value for PRE_TEST).
  /// Numeric Likert IDs use `selected_value`; persisted option IDs use `option_id`.
  Future<QuizSubmitResultModel> submitQuestionnaire({
    required String questionnaireId,
    required Map<String, String> answers,
    required int durationSeconds,
    bool isPreTest = false,
  });

  /// Returns the patient's most recent attempt for a specific questionnaire.
  Future<MyAttemptModel> getMyAttempt(String questionnaireId);

  /// Returns full attempt analysis (questions, user answers, correct answers, explanations).
  Future<AttemptDetailModel> getMyAttemptDetail(String questionnaireId);
  Future<AttemptDetailModel> getMyAttemptDetailById({
    required String questionnaireId,
    required String attemptId,
  });

  /// Returns all questionnaire attempts by the current patient.
  /// Optionally filter by [type] = 'PRE_TEST' | 'POST_TEST'.
  Future<List<MyHistoryItemModel>> getMyHistory({String? type, String? scope});

  /// Returns all active questionnaires available to the patient, with completion status.
  /// Optionally filter by [type] = 'PRE_TEST' | 'POST_TEST'.
  /// [page] and [perPage] control pagination.
  Future<PaginatedQuestionnaireResult> getPatientQuestionnaireList({
    String? type,
    int page = 1,
    int perPage = 20,
  });
}

class QuestionnaireRepository implements IQuestionnaireRepository {
  QuestionnaireRepository(this._dio);

  final Dio _dio;

  @override
  Future<QuestionnaireDetailModel> getActivePreTest({
    String? educationId,
  }) async {
    try {
      final response = await _dio.get(
        '/patient/questionnaires/pre-test',
        queryParameters:
            educationId != null && educationId.isNotEmpty
                ? {'education_id': educationId}
                : null,
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return QuestionnaireDetailModel.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<QuestionnaireDetailModel> getPostTestByEducation(
    String educationId,
  ) async {
    try {
      final response = await _dio.get(
        '/patient/questionnaires/post-test',
        queryParameters: {'education_id': educationId},
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return QuestionnaireDetailModel.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<QuestionnaireDetailModel> getQuestionnaireById(String id) async {
    try {
      final response = await _dio.get('/patient/questionnaires/$id');
      final data = response.data['data'] as Map<String, dynamic>;
      return QuestionnaireDetailModel.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<QuizSubmitResultModel> submitQuestionnaire({
    required String questionnaireId,
    required Map<String, String> answers,
    required int durationSeconds,
    bool isPreTest = false,
  }) async {
    try {
      List<Map<String, dynamic>> answerList;

      if (isPreTest) {
        // PRE_TEST supports both numeric default choices and database options.
        answerList =
            answers.entries.map((e) {
              final val = int.tryParse(e.value);
              return <String, dynamic>{
                'question_id': e.key,
                if (val != null && val >= 1 && val <= 5)
                  'selected_value': val
                else
                  'option_id': e.value,
              };
            }).toList();
      } else {
        // POST_TEST: backend expects `option_id` (UUID)
        answerList =
            answers.entries
                .map(
                  (e) => <String, dynamic>{
                    'question_id': e.key,
                    'option_id': e.value,
                  },
                )
                .toList();
      }

      final response = await _dio.post(
        '/patient/questionnaires/$questionnaireId/submit',
        data: {'duration_seconds': durationSeconds, 'answers': answerList},
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return QuizSubmitResultModel.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<MyAttemptModel> getMyAttempt(String questionnaireId) async {
    try {
      final response = await _dio.get(
        '/patient/questionnaires/$questionnaireId/my-attempt',
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return MyAttemptModel.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<AttemptDetailModel> getMyAttemptDetail(String questionnaireId) async {
    try {
      final response = await _dio.get(
        '/patient/questionnaires/$questionnaireId/my-attempt/detail',
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return AttemptDetailModel.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<AttemptDetailModel> getMyAttemptDetailById({
    required String questionnaireId,
    required String attemptId,
  }) async {
    try {
      final response = await _dio.get(
        '/patient/questionnaires/$questionnaireId/attempts/$attemptId',
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return AttemptDetailModel.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<PaginatedQuestionnaireResult> getPatientQuestionnaireList({
    String? type,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'per_page': perPage};
      if (type != null && type.isNotEmpty) {
        queryParams['type'] = type;
      }
      final response = await _dio.get(
        '/patient/questionnaires',
        queryParameters: queryParams,
      );
      return PaginatedQuestionnaireResult.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<List<MyHistoryItemModel>> getMyHistory({
    String? type,
    String? scope,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (type != null && type.isNotEmpty) {
        queryParams['type'] = type;
      }
      if (scope != null && scope.isNotEmpty) {
        queryParams['scope'] = scope;
      }
      final response = await _dio.get(
        '/patient/questionnaires/my-history',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      final list = response.data['data'] as List<dynamic>? ?? [];
      return list
          .map((e) => MyHistoryItemModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}

final questionnaireRepositoryProvider = Provider<IQuestionnaireRepository>((
  ref,
) {
  final dio = ref.watch(dioClientProvider);
  return QuestionnaireRepository(dio);
});
