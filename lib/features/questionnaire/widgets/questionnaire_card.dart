import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../models/questionnaire_detail_model.dart';

class QuestionnaireCard extends StatelessWidget {
  const QuestionnaireCard({
    super.key,
    required this.questionnaire,
    required this.onStartTap,
    required this.onViewResultTap,
    this.onReadMaterialTap,
    this.isCompleted = false,
    this.scorePercentage,
  });

  final QuestionnaireDetailModel questionnaire;
  final VoidCallback onStartTap;
  final VoidCallback onViewResultTap;
  final VoidCallback? onReadMaterialTap;
  final bool isCompleted;
  final int? scorePercentage;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryContainer.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row (Icon + Info + Score)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon Badge
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? const Color(0xFFABF4AC)
                      : AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  questionnaire.isPreTest
                      ? Icons.assignment_turned_in_rounded
                      : Icons.quiz_rounded,
                  color: isCompleted
                      ? const Color(0xFF07521D)
                      : AppColors.outline,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),

              // Title & Badges Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            questionnaire.title,
                            style: AppTextStyles.headlineMd.copyWith(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurface,
                            ),
                          ),
                        ),
                        if (isCompleted && scorePercentage != null)
                          Text(
                            '$scorePercentage',
                            style: AppTextStyles.headlineMd.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Type badge
                    _buildChip(
                      text: questionnaire.isPreTest ? 'PRE-TEST' : 'POST-TEST',
                      bgColor: questionnaire.isPreTest
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : AppColors.secondary.withValues(alpha: 0.1),
                      textColor: questionnaire.isPreTest
                          ? AppColors.primary
                          : AppColors.secondary,
                    ),
                    const SizedBox(height: 6),

                    // Meta Text
                    Text(
                      '${questionnaire.questionCount} Pertanyaan',
                      style: AppTextStyles.bodyMd.copyWith(
                        fontSize: 13,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Main Action Button
          if (isCompleted)
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: onViewResultTap,
                child: Text(
                  'Lihat Hasil',
                  style: AppTextStyles.poppinsButton.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            )
          else
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
                onPressed: onStartTap,
                child: Text(
                  questionnaire.isPreTest
                      ? 'Mulai Pre-Test'
                      : 'Mulai Post-Test',
                  style: AppTextStyles.poppinsButton.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          // Secondary action for post-test
          if (!isCompleted && onReadMaterialTap != null) ...[
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: onReadMaterialTap,
                child: Text(
                  'Baca Materi Edukasi',
                  style: AppTextStyles.labelMd.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChip({
    required String text,
    required Color bgColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        text,
        style: AppTextStyles.labelMd.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
