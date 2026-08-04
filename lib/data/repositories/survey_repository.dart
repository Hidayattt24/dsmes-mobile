import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_exception.dart';
import '../../core/network/dio_client.dart';
import '../../features/questionnaire/models/survey_model.dart';

abstract class ISurveyRepository {
  Future<List<SurveyModel>> getActiveSurveys({String? type});
  Future<void> submitSurvey({
    required String surveyId,
    required Map<String, int> answers,
    required int durationSeconds,
  });
}

class SurveyRepository implements ISurveyRepository {
  final Dio _dio;

  SurveyRepository(this._dio);

  @override
  Future<List<SurveyModel>> getActiveSurveys({String? type}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (type != null && type.isNotEmpty) {
        queryParams['type'] = type;
      }
      final response = await _dio.get(
        '/patient/surveys/active',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      final data = response.data['data'];
      if (data == null) return [];
      if (data is List) {
        return data.map((e) => SurveyModel.fromJson(e as Map<String, dynamic>)).toList();
      } else if (data is Map<String, dynamic>) {
        return [SurveyModel.fromJson(data)];
      }
      return [];
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return [];
      }
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<void> submitSurvey({
    required String surveyId,
    required Map<String, int> answers,
    required int durationSeconds,
  }) async {
    try {
      final answerList = answers.entries
          .map((e) => {
                'question_id': e.key,
                'rating_value': e.value,
              })
          .toList();

      await _dio.post(
        '/patient/surveys/$surveyId/submit',
        data: {
          'answers': answerList,
          'duration_seconds': durationSeconds,
        },
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}

final surveyRepositoryProvider = Provider<ISurveyRepository>((ref) {
  final dio = ref.watch(dioClientProvider);
  return SurveyRepository(dio);
});
