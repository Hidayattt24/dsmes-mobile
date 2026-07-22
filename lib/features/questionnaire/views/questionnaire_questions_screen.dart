import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../data/questionnaire_mock_data.dart';
import '../models/questionnaire.dart';
import 'questionnaire_result_screen.dart';

class QuestionnaireQuestionsScreen extends StatefulWidget {
  const QuestionnaireQuestionsScreen({
    super.key,
    required this.questionnaireId,
  });

  final String questionnaireId;

  @override
  State<QuestionnaireQuestionsScreen> createState() => _QuestionnaireQuestionsScreenState();
}

class _QuestionnaireQuestionsScreenState extends State<QuestionnaireQuestionsScreen> {
  late Questionnaire _questionnaire;
  int _currentQuestionIndex = 0;
  final Map<int, int> _userAnswers = {};

  @override
  void initState() {
    super.initState();
    _questionnaire = MockQuestionnaireData.getQuestionnaireById(widget.questionnaireId);
  }

  void _selectOption(int optionIndex) {
    setState(() {
      _userAnswers[_currentQuestionIndex] = optionIndex;
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questionnaire.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      _submitQuestionnaire();
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  void _submitQuestionnaire() {
    int correctCount = 0;
    for (int i = 0; i < _questionnaire.questions.length; i++) {
      final question = _questionnaire.questions[i];
      final userAns = _userAnswers[i];
      if (userAns != null && userAns == question.correctAnswerIndex) {
        correctCount++;
      }
    }

    final double score = _questionnaire.questions.isNotEmpty
        ? (correctCount / _questionnaire.questions.length) * 100
        : 100.0;

    MockQuestionnaireData.markCompleted(_questionnaire.id, score);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => QuestionnaireResultScreen(
          questionnaireId: _questionnaire.id,
          scorePercentage: score,
          correctCount: correctCount,
          totalQuestions: _questionnaire.questions.length,
          userAnswers: _userAnswers,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final questions = _questionnaire.questions;
    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(_questionnaire.title)),
        body: const Center(child: Text('Kuesioner ini belum memiliki pertanyaan.')),
      );
    }

    final currentQuestion = questions[_currentQuestionIndex];
    final selectedOption = _userAnswers[_currentQuestionIndex];
    final isLastQuestion = _currentQuestionIndex == questions.length - 1;
    final double progress = ((_currentQuestionIndex + 1) / questions.length).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 1,
        shadowColor: AppColors.primaryContainer.withValues(alpha: 0.1),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.onSurfaceVariant),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Kuesioner',
          style: AppTextStyles.headlineMd.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.page),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress Bar Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pertanyaan ${_currentQuestionIndex + 1} dari ${questions.length}',
                        style: AppTextStyles.labelMd.copyWith(
                          color: AppColors.outline,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: AppTextStyles.labelMd.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: AppColors.surfaceContainerHighest,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Question Title Section
                  Text(
                    currentQuestion.questionText,
                    style: AppTextStyles.headlineLg.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      height: 1.35,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Options Cards List
                  for (int i = 0; i < currentQuestion.options.length; i++) ...[
                    _buildOptionCard(
                      optionText: currentQuestion.options[i],
                      isSelected: selectedOption == i,
                      onTap: () => _selectOption(i),
                    ),
                    const SizedBox(height: 14),
                  ],
                ],
              ),
            ),
          ),

          // Task-specific Bottom Bar Footer
          Container(
            padding: const EdgeInsets.all(AppSpacing.page),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(
                top: BorderSide(
                  color: AppColors.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Previous Button
                  if (_currentQuestionIndex > 0) ...[
                    Expanded(
                      child: SizedBox(
                        height: 56,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: AppColors.surfaceTint.withValues(alpha: 0.1),
                            foregroundColor: AppColors.primary,
                            side: BorderSide.none,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: _previousQuestion,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.arrow_back_rounded, size: 18),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  'Sebelumnya',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.poppinsButton.copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],

                  // Next / Submit Button
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedOption != null
                              ? AppColors.primary
                              : AppColors.outlineVariant,
                          foregroundColor: Colors.white,
                          elevation: selectedOption != null ? 2 : 0,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: selectedOption != null ? _nextQuestion : null,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                isLastQuestion ? 'Selesai & Kirim' : 'Selanjutnya',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.poppinsButton.copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              isLastQuestion
                                  ? Icons.check_circle_rounded
                                  : Icons.arrow_forward_rounded,
                              size: 18,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    required String optionText,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.05)
                : AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : AppColors.outlineVariant,
              width: 2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: AppColors.primaryContainer.withValues(alpha: 0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  optionText,
                  style: AppTextStyles.bodyLg.copyWith(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? AppColors.primary : AppColors.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              if (isSelected)
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                )
              else
                const Icon(
                  Icons.radio_button_unchecked_rounded,
                  color: AppColors.outline,
                  size: 22,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
