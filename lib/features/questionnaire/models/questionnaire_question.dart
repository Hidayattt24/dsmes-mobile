import 'package:flutter/foundation.dart';

@immutable
class QuestionnaireQuestion {
  final String id;
  final String questionText;
  final List<String> options;
  final int correctAnswerIndex;
  final String? explanation;

  const QuestionnaireQuestion({
    required this.id,
    required this.questionText,
    required this.options,
    required this.correctAnswerIndex,
    this.explanation,
  });
}
