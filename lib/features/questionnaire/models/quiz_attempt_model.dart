import 'package:flutter/foundation.dart';

/// Maps backend `SubmitResultResponse` DTO returned when a patient submits answers.
@immutable
class QuizSubmitResultModel {
  const QuizSubmitResultModel({
    required this.attemptId,
    required this.questionnaireId,
    required this.score,
    required this.passed,
    required this.totalQuestions,
    required this.correctCount,
  });

  final String attemptId;
  final String questionnaireId;
  final int score;
  final bool passed;
  final int totalQuestions;
  final int correctCount;

  int get incorrectCount => (totalQuestions - correctCount).clamp(0, totalQuestions);
  int get percentage => score;

  factory QuizSubmitResultModel.fromJson(Map<String, dynamic> json) {
    return QuizSubmitResultModel(
      attemptId: json['attempt_id'] as String? ?? '',
      questionnaireId: json['questionnaire_id'] as String? ?? '',
      score: json['score'] as int? ?? 0,
      passed: json['passed'] as bool? ?? false,
      totalQuestions: json['total_questions'] as int? ?? 0,
      correctCount: json['correct_count'] as int? ?? 0,
    );
  }
}

/// Maps backend `MyAttemptResponse` DTO — patient's own attempt for a specific questionnaire.
@immutable
class MyAttemptModel {
  const MyAttemptModel({
    required this.attemptId,
    required this.questionnaireId,
    required this.score,
    required this.passed,
    required this.totalQuestions,
    required this.correctCount,
    required this.incorrectCount,
    required this.percentage,
    required this.completedAt,
  });

  final String attemptId;
  final String questionnaireId;
  final int score;
  final bool passed;
  final int totalQuestions;
  final int correctCount;
  final int incorrectCount;
  final int percentage;
  final DateTime completedAt;

  factory MyAttemptModel.fromJson(Map<String, dynamic> json) {
    return MyAttemptModel(
      attemptId: json['attempt_id'] as String? ?? '',
      questionnaireId: json['questionnaire_id'] as String? ?? '',
      score: json['score'] as int? ?? 0,
      passed: json['passed'] as bool? ?? false,
      totalQuestions: json['total_questions'] as int? ?? 0,
      correctCount: json['correct_count'] as int? ?? 0,
      incorrectCount: json['incorrect_count'] as int? ?? 0,
      percentage: json['percentage'] as int? ?? 0,
      completedAt: DateTime.tryParse(json['completed_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

/// Maps backend `MyHistoryItemResponse` DTO — a single item in the patient's questionnaire history.
@immutable
class MyHistoryItemModel {
  const MyHistoryItemModel({
    required this.attemptId,
    required this.questionnaireId,
    required this.questionnaireTitle,
    required this.type,
    required this.score,
    required this.passed,
    required this.totalQuestions,
    required this.correctCount,
    required this.incorrectCount,
    required this.percentage,
    required this.completedAt,
  });

  final String attemptId;
  final String questionnaireId;
  final String questionnaireTitle;

  /// 'PRE_TEST' or 'POST_TEST'
  final String type;
  final int score;
  final bool passed;
  final int totalQuestions;
  final int correctCount;
  final int incorrectCount;
  final int percentage;
  final DateTime completedAt;

  bool get isPreTest => type == 'PRE_TEST';

  factory MyHistoryItemModel.fromJson(Map<String, dynamic> json) {
    return MyHistoryItemModel(
      attemptId: json['attempt_id'] as String? ?? '',
      questionnaireId: json['questionnaire_id'] as String? ?? '',
      questionnaireTitle: json['questionnaire_title'] as String? ?? '',
      type: json['type'] as String? ?? 'POST_TEST',
      score: json['score'] as int? ?? 0,
      passed: json['passed'] as bool? ?? false,
      totalQuestions: json['total_questions'] as int? ?? 0,
      correctCount: json['correct_count'] as int? ?? 0,
      incorrectCount: json['incorrect_count'] as int? ?? 0,
      percentage: json['percentage'] as int? ?? 0,
      completedAt: DateTime.tryParse(json['completed_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

/// Detailed question analysis item for review screen (matches web admin).
@immutable
class QuestionAnalysisModel {
  const QuestionAnalysisModel({
    required this.id,
    required this.questionNumber,
    required this.questionText,
    required this.patientAnswer,
    required this.correctAnswer,
    required this.isCorrect,
    required this.explanation,
  });

  final String id;
  final int questionNumber;
  final String questionText;
  final String patientAnswer;
  final String correctAnswer;
  final bool isCorrect;
  final String explanation;

  factory QuestionAnalysisModel.fromJson(Map<String, dynamic> json) {
    return QuestionAnalysisModel(
      id: json['id'] as String? ?? '',
      questionNumber: json['question_number'] as int? ?? 0,
      questionText: json['question_text'] as String? ?? '',
      patientAnswer: json['patient_answer'] as String? ?? '',
      correctAnswer: json['correct_answer'] as String? ?? '',
      isCorrect: json['is_correct'] as bool? ?? false,
      explanation: json['explanation'] as String? ?? '',
    );
  }
}

/// Full attempt detail with itemized questions for review screen.
@immutable
class AttemptDetailModel {
  const AttemptDetailModel({
    required this.quizTitle,
    required this.score,
    required this.passed,
    required this.duration,
    required this.questionAnalysis,
  });

  final String quizTitle;
  final int score;
  final bool passed;
  final String duration;
  final List<QuestionAnalysisModel> questionAnalysis;

  factory AttemptDetailModel.fromJson(Map<String, dynamic> json) {
    final participant = json['participant'] as Map<String, dynamic>? ?? {};
    final rawAnalysis = json['question_analysis'] as List<dynamic>? ?? [];
    return AttemptDetailModel(
      quizTitle: json['quiz_title'] as String? ?? '',
      score: participant['score'] as int? ?? 0,
      passed: participant['passed'] as bool? ?? false,
      duration: participant['duration'] as String? ?? '',
      questionAnalysis: rawAnalysis
          .map((e) => QuestionAnalysisModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
