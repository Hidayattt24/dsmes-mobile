import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

class QuestionnaireProgressCard extends StatelessWidget {
  const QuestionnaireProgressCard({
    super.key,
    required this.completedCount,
    required this.uncompletedCount,
    required this.averageScore,
  });

  final int completedCount;
  final int uncompletedCount;
  final double averageScore;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Stat 1: Selesai
          _buildStatColumn(
            count: '$completedCount',
            label: 'Selesai',
            color: AppColors.primary,
          ),
          _buildDivider(),

          // Stat 2: Belum Selesai
          _buildStatColumn(
            count: '$uncompletedCount',
            label: 'Belum Selesai',
            color: const Color(0xFFFF7F50), // Coral / Tertiary
          ),
          _buildDivider(),

          // Stat 3: Skor Rata-rata
          _buildStatColumn(
            count: '${averageScore.toInt()}%',
            label: 'Skor Rata-rata',
            color: AppColors.secondary,
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn({
    required String count,
    required String label,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count,
          style: AppTextStyles.headlineLg.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.labelMd.copyWith(
            fontSize: 12,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 36,
      color: AppColors.outlineVariant.withValues(alpha: 0.5),
    );
  }
}
