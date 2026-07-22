import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../education/views/education_detail_screen.dart';
import '../data/questionnaire_mock_data.dart';
import '../models/questionnaire.dart';
import 'questionnaire_detail_screen.dart';

class QuestionnaireResultScreen extends StatelessWidget {
  const QuestionnaireResultScreen({
    super.key,
    required this.questionnaireId,
    required this.scorePercentage,
    required this.correctCount,
    required this.totalQuestions,
    this.userAnswers,
  });

  final String questionnaireId;
  final double scorePercentage;
  final int correctCount;
  final int totalQuestions;
  final Map<int, int>? userAnswers;

  @override
  Widget build(BuildContext context) {
    final Questionnaire questionnaire =
        MockQuestionnaireData.getQuestionnaireById(questionnaireId);

    final scoreInt = scorePercentage.toInt();
    final incorrectCount = (totalQuestions - correctCount).clamp(0, totalQuestions);
    final isPassed = scorePercentage >= 70.0;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 1,
        shadowColor: AppColors.primaryContainer.withValues(alpha: 0.1),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Hasil Kuesioner',
          style: AppTextStyles.headlineMd.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(
              left: AppSpacing.page,
              right: AppSpacing.page,
              top: AppSpacing.lg,
              bottom: 160,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bento Score Hero Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryContainer.withValues(alpha: 0.08),
                        blurRadius: 24,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Nilai Akhir',
                        style: AppTextStyles.labelLg.copyWith(
                          color: AppColors.outline,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Circular Score Ring
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryContainer.withValues(alpha: 0.08),
                          border: Border.all(
                            color: AppColors.primary,
                            width: 6,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '$scoreInt',
                            style: AppTextStyles.headlineLg.copyWith(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      Text(
                        isPassed ? 'Sangat Baik' : 'Perlu Belajar Lagi',
                        style: AppTextStyles.headlineMd.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryContainer,
                        ),
                      ),
                      const SizedBox(height: 8),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.outline),
                          const SizedBox(width: 4),
                          Text(
                            '24 Okt 2023',
                            style: AppTextStyles.bodyMd.copyWith(fontSize: 13, color: AppColors.outline),
                          ),
                          const SizedBox(width: 16),
                          const Icon(Icons.schedule_rounded, size: 14, color: AppColors.outline),
                          const SizedBox(width: 4),
                          Text(
                            '${questionnaire.estimatedMinutes} Menit',
                            style: AppTextStyles.bodyMd.copyWith(fontSize: 13, color: AppColors.outline),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Asymmetric Stats Row (Benar / Salah)
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.outlineVariant.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                color: Color(0xFFABF4AC),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check_circle_rounded,
                                color: Color(0xFF07521D),
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$correctCount',
                                  style: AppTextStyles.headlineMd.copyWith(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Benar',
                                  style: AppTextStyles.bodyMd.copyWith(
                                    fontSize: 12,
                                    color: AppColors.outline,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.outlineVariant.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFFDAD6),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.cancel_rounded,
                                color: Color(0xFF93000A),
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$incorrectCount',
                                  style: AppTextStyles.headlineMd.copyWith(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Salah',
                                  style: AppTextStyles.bodyMd.copyWith(
                                    fontSize: 12,
                                    color: AppColors.outline,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                // Recommendation Banner
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.lightbulb_rounded, color: Colors.white, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: AppTextStyles.bodyMd.copyWith(
                              color: Colors.white,
                              fontSize: 14,
                              height: 1.4,
                            ),
                            children: [
                              const TextSpan(
                                text: 'Luar Biasa! ',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text: isPassed
                                    ? 'Materi telah dipahami dengan baik. Tetap konsisten dalam menerapkan pola makan sehat.'
                                    : 'Pelajari kembali materi edukasi untuk memperdalam pemahaman manajemen diabetes.',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Question Review List Header
                Text(
                  'Ulasan Pertanyaan',
                  style: AppTextStyles.headlineMd.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Question Review Cards List
                for (int idx = 0; idx < questionnaire.questions.length; idx++) ...[
                  _buildReviewCard(
                    questionIndex: idx,
                    question: questionnaire.questions[idx],
                    userSelected: userAnswers?[idx],
                  ),
                  const SizedBox(height: 14),
                ],
              ],
            ),
          ),

          // Fixed Action Buttons at Bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.page),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.95),
                border: Border(
                  top: BorderSide(
                    color: AppColors.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const EducationDetailScreen(articleId: 'art_featured'),
                            ),
                          );
                        },
                        child: Text(
                          'Lihat Materi Edukasi',
                          style: AppTextStyles.poppinsButton.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 52,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                backgroundColor: AppColors.surfaceTint.withValues(alpha: 0.1),
                                foregroundColor: AppColors.primary,
                                side: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) => QuestionnaireDetailScreen(
                                      questionnaireId: questionnaire.id,
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                'Ulangi',
                                style: AppTextStyles.poppinsButton.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 52,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.outline,
                                side: const BorderSide(color: AppColors.outline),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text(
                                'Kembali',
                                style: AppTextStyles.poppinsButton.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.outline,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard({
    required int questionIndex,
    required dynamic question,
    required int? userSelected,
  }) {
    final bool isCorrect = userSelected == question.correctAnswerIndex;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Pertanyaan ${questionIndex + 1}',
                  style: AppTextStyles.labelMd.copyWith(
                    fontSize: 12,
                    color: AppColors.outline,
                  ),
                ),
              ),
              Icon(
                isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: isCorrect ? AppColors.secondary : AppColors.error,
                size: 22,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            question.questionText,
            style: AppTextStyles.bodyLg.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          if (isCorrect) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: const Color(0xFFABF4AC).withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.secondary.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Jawaban Anda (Benar):',
                    style: AppTextStyles.labelMd.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    question.options[userSelected ?? question.correctAnswerIndex],
                    style: AppTextStyles.bodyMd.copyWith(
                      fontSize: 14,
                      color: AppColors.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            if (userSelected != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFDAD6).withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.close_rounded, size: 14, color: AppColors.error),
                        SizedBox(width: 4),
                        Text(
                          'Jawaban Anda:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      question.options[userSelected],
                      style: AppTextStyles.bodyMd.copyWith(
                        fontSize: 14,
                        decoration: TextDecoration.lineThrough,
                        color: AppColors.outline,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: const Color(0xFFABF4AC).withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.secondary.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.check_rounded, size: 14, color: AppColors.secondary),
                      SizedBox(width: 4),
                      Text(
                        'Jawaban Benar:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    question.options[question.correctAnswerIndex],
                    style: AppTextStyles.bodyMd.copyWith(
                      fontSize: 14,
                      color: AppColors.onSurface,
                    ),
                  ),
                  if (question.explanation != null) ...[
                    const Divider(height: 16),
                    Text(
                      'Penjelasan: ${question.explanation}',
                      style: AppTextStyles.bodyMd.copyWith(
                        fontSize: 12,
                        color: AppColors.outline,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
