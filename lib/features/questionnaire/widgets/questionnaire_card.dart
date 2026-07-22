import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../models/questionnaire.dart';

class QuestionnaireCard extends StatelessWidget {
  const QuestionnaireCard({
    super.key,
    required this.questionnaire,
    required this.onStartTap,
    required this.onViewResultTap,
    this.onReadMaterialTap,
  });

  final Questionnaire questionnaire;
  final VoidCallback onStartTap;
  final VoidCallback onViewResultTap;
  final VoidCallback? onReadMaterialTap;

  IconData _getIconData(String iconName) {
    return switch (iconName) {
      'fitness_center' => Icons.fitness_center_rounded,
      'check_circle' => Icons.check_circle_rounded,
      'medication' => Icons.medication_rounded,
      'water_drop' => Icons.water_drop_rounded,
      _ => Icons.menu_book_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = questionnaire.isCompleted;

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
              // Icon Badge Container
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
                  _getIconData(questionnaire.iconName),
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
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurface,
                            ),
                          ),
                        ),
                        if (isCompleted && questionnaire.scorePercentage != null)
                          Text(
                            'Skor: ${questionnaire.scorePercentage!.toInt()}%',
                            style: AppTextStyles.headlineMd.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Badges Row
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _buildChip(
                          text: questionnaire.category,
                          bgColor: AppColors.surfaceContainerLow,
                          textColor: AppColors.onSurfaceVariant,
                        ),
                        if (questionnaire.educationStatus != null)
                          _buildChip(
                            text: questionnaire.educationStatus!,
                            bgColor: isCompleted
                                ? const Color(0xFFABF4AC)
                                : AppColors.surfaceContainerLow,
                            textColor: isCompleted
                                ? const Color(0xFF07521D)
                                : AppColors.onSurfaceVariant,
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),

                    // Meta Text
                    Text(
                      '${questionnaire.questionCount} Pertanyaan • ${questionnaire.estimatedMinutes} Menit',
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Mulai Kuesioner',
                      style: AppTextStyles.poppinsButton.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Secondary Action / Subtext Caption
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
          ] else if (!isCompleted) ...[
            const SizedBox(height: 8),
            Text(
              'Anda dapat langsung mengerjakan kuesioner atau membaca materi edukasi terlebih dahulu.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMd.copyWith(
                fontSize: 11,
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
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
