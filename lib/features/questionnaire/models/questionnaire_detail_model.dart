import 'package:flutter/foundation.dart';

/// Maps backend `ChoiceResponse` DTO.
@immutable
class ChoiceModel {
  const ChoiceModel({
    required this.id,
    required this.optionText,
    required this.displayOrder,
  });

  final String id;
  final String optionText;
  final int displayOrder;

  factory ChoiceModel.fromJson(Map<String, dynamic> json) {
    return ChoiceModel(
      id: json['id'] as String? ?? '',
      optionText: json['option_text'] as String? ?? '',
      displayOrder: json['display_order'] as int? ?? 0,
    );
  }
}

/// Maps backend `QuestionResponse` DTO.
@immutable
class QuestionModel {
  const QuestionModel({
    required this.id,
    required this.questionText,
    required this.explanation,
    required this.displayOrder,
    required this.choices,
  });

  final String id;
  final String questionText;
  final String explanation;
  final int displayOrder;
  final List<ChoiceModel> choices;

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    final rawChoices = json['choices'] as List<dynamic>? ?? [];
    return QuestionModel(
      id: json['id'] as String? ?? '',
      questionText: json['question_text'] as String? ?? '',
      explanation: json['explanation'] as String? ?? '',
      displayOrder: json['display_order'] as int? ?? 0,
      choices: rawChoices
          .map((e) => ChoiceModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Maps backend `QuestionCategoryResponse` DTO.
@immutable
class QuestionCategoryModel {
  const QuestionCategoryModel({
    required this.id,
    required this.title,
    required this.description,
    required this.displayOrder,
    required this.questions,
  });

  final String id;
  final String title;
  final String description;
  final int displayOrder;
  final List<QuestionModel> questions;

  factory QuestionCategoryModel.fromJson(Map<String, dynamic> json) {
    final rawQuestions = json['questions'] as List<dynamic>? ?? [];
    return QuestionCategoryModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      displayOrder: json['display_order'] as int? ?? 0,
      questions: rawQuestions
          .map((e) => QuestionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Maps backend `QuestionnaireDetailResponse` DTO.
/// Used for both PRE_TEST and POST_TEST.
@immutable
class QuestionnaireDetailModel {
  const QuestionnaireDetailModel({
    required this.id,
    required this.title,
    required this.type,
    required this.description,
    this.educationId,
    this.educationTitle,
    this.passingScore,
    this.difficulty,
    required this.status,
    required this.categoryCount,
    required this.questionCount,
    required this.categories,
  });

  final String id;
  final String title;

  /// 'PRE_TEST' or 'POST_TEST'
  final String type;
  final String description;
  final String? educationId;
  final String? educationTitle;
  final int? passingScore;
  final String? difficulty;
  final String status;
  final int categoryCount;
  final int questionCount;
  final List<QuestionCategoryModel> categories;

  bool get isPreTest => type == 'PRE_TEST';
  bool get isPostTest => type == 'POST_TEST';

  /// Returns a flat ordered list of all questions across all categories.
  List<QuestionModel> get allQuestions {
    final sorted = [...categories]
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    return sorted.expand((cat) {
      final questions = [...cat.questions]
        ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
      return questions;
    }).toList();
  }

  factory QuestionnaireDetailModel.fromJson(Map<String, dynamic> json) {
    final rawCategories = json['categories'] as List<dynamic>? ?? [];
    return QuestionnaireDetailModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      type: json['type'] as String? ?? 'POST_TEST',
      description: json['description'] as String? ?? '',
      educationId: json['education_id'] as String?,
      educationTitle: json['education_title'] as String?,
      passingScore: json['passing_score'] as int?,
      difficulty: json['difficulty'] as String?,
      status: json['status'] as String? ?? 'draft',
      categoryCount: json['category_count'] as int? ?? 0,
      questionCount: json['question_count'] as int? ?? 0,
      categories: rawCategories
          .map((e) =>
              QuestionCategoryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Maps backend `PatientQuestionnaireItem` DTO.
@immutable
class PatientQuestionnaireItemModel {
  const PatientQuestionnaireItemModel({
    required this.id,
    required this.title,
    required this.type,
    required this.description,
    this.educationId,
    this.educationTitle,
    required this.questionCount,
    this.passingScore,
    this.difficulty,
    required this.isCompleted,
    this.score,
  });

  final String id;
  final String title;
  final String type;
  final String description;
  final String? educationId;
  final String? educationTitle;
  final int questionCount;
  final int? passingScore;
  final String? difficulty;
  final bool isCompleted;
  final int? score;

  bool get isPreTest => type == 'PRE_TEST';
  bool get isPostTest => type == 'POST_TEST';

  factory PatientQuestionnaireItemModel.fromJson(Map<String, dynamic> json) {
    return PatientQuestionnaireItemModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      type: json['type'] as String? ?? 'POST_TEST',
      description: json['description'] as String? ?? '',
      educationId: json['education_id'] as String?,
      educationTitle: json['education_title'] as String?,
      questionCount: json['question_count'] as int? ?? 0,
      passingScore: json['passing_score'] as int?,
      difficulty: json['difficulty'] as String?,
      isCompleted: json['is_completed'] as bool? ?? false,
      score: json['score'] as int?,
    );
  }
}

/// Paginated list wrapper for `PatientQuestionnaireItemModel`.
@immutable
class PaginatedQuestionnaireResult {
  const PaginatedQuestionnaireResult({
    required this.items,
    required this.total,
  });

  final List<PatientQuestionnaireItemModel> items;
  final int total;

  factory PaginatedQuestionnaireResult.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'] as List<dynamic>? ?? [];
    final total = json['total'] as int? ?? rawData.length;
    return PaginatedQuestionnaireResult(
      items: rawData
          .map((e) => PatientQuestionnaireItemModel.fromJson(
              e as Map<String, dynamic>))
          .toList(),
      total: total,
    );
  }
}
