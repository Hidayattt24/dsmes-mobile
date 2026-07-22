import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

class ResultSummaryCard extends StatelessWidget {
  const ResultSummaryCard({
    super.key,
    required this.title,
    required this.scorePercentage,
    required this.correctCount,
    required this.totalQuestions,
    required this.elapsedTimeText,
    required this.feedbackTitle,
    required this.feedbackMessage,
    required this.recommendations,
  });

  final String title;
  final double scorePercentage;
  final int correctCount;
  final int totalQuestions;
  final String elapsedTimeText;
  final String feedbackTitle;
  final String feedbackMessage;
  final List<String> recommendations;

  @override
  Widget build(BuildContext context) {
    final scoreInt = scorePercentage.toInt();

    return Column(
      children: [
        // Top Score Circle & Trophy Container
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryContainer.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              // Circular Score Badge Ring
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryContainer.withValues(alpha: 0.1),
                  border: Border.all(
                    color: AppColors.primary,
                    width: 4,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$scoreInt%',
                        style: AppTextStyles.headlineLg.copyWith(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        'Skor Akhir',
                        style: AppTextStyles.labelMd.copyWith(
                          fontSize: 10,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Title & Subtitle Feedback
              Text(
                feedbackTitle,
                style: AppTextStyles.headlineLg.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                feedbackMessage,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMd.copyWith(
                  fontSize: 14,
                  color: AppColors.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              const Divider(),
              const SizedBox(height: AppSpacing.md),

              // Stats Breakdown Grid/Rows
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('Soal', '$totalQuestions'),
                  _buildStatItem('Benar', '$correctCount'),
                  _buildStatItem('Waktu', elapsedTimeText),
                  _buildStatItem('Status', 'Selesai'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Recommendation Box Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.secondaryContainer.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.secondary.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.lightbulb_rounded,
                    color: AppColors.secondary,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Rekomendasi Selanjutnya:',
                    style: AppTextStyles.headlineMd.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              for (final rec in recommendations) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                      Expanded(
                        child: Text(
                          rec,
                          style: AppTextStyles.bodyMd.copyWith(
                            fontSize: 13,
                            color: AppColors.onSurface,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.labelLg.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.bodyMd.copyWith(
            fontSize: 11,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
