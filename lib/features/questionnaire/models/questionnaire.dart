import 'package:flutter/foundation.dart';
import 'questionnaire_question.dart';

@immutable
class Questionnaire {
  final String id;
  final String title;
  final String category;
  final String iconName;
  final String? iconBgColorHex;
  final String imageUrl;
  final String description;
  final String difficulty;
  final int questionCount;
  final int estimatedMinutes;
  final String? educationStatus;
  final bool isEducationCompleted;
  final bool isCompleted;
  final double? scorePercentage;
  final List<QuestionnaireQuestion> questions;

  const Questionnaire({
    required this.id,
    required this.title,
    required this.category,
    required this.iconName,
    this.iconBgColorHex,
    required this.imageUrl,
    required this.description,
    this.difficulty = 'Mudah',
    required this.questionCount,
    required this.estimatedMinutes,
    this.educationStatus,
    this.isEducationCompleted = false,
    this.isCompleted = false,
    this.scorePercentage,
    required this.questions,
  });

  Questionnaire copyWith({
    String? id,
    String? title,
    String? category,
    String? iconName,
    String? iconBgColorHex,
    String? imageUrl,
    String? description,
    String? difficulty,
    int? questionCount,
    int? estimatedMinutes,
    String? educationStatus,
    bool? isEducationCompleted,
    bool? isCompleted,
    double? scorePercentage,
    List<QuestionnaireQuestion>? questions,
  }) {
    return Questionnaire(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      iconName: iconName ?? this.iconName,
      iconBgColorHex: iconBgColorHex ?? this.iconBgColorHex,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      difficulty: difficulty ?? this.difficulty,
      questionCount: questionCount ?? this.questionCount,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      educationStatus: educationStatus ?? this.educationStatus,
      isEducationCompleted: isEducationCompleted ?? this.isEducationCompleted,
      isCompleted: isCompleted ?? this.isCompleted,
      scorePercentage: scorePercentage ?? this.scorePercentage,
      questions: questions ?? this.questions,
    );
  }
}
