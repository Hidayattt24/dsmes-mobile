import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

class RecordProgressCard extends StatelessWidget {
  const RecordProgressCard({
    super.key,
    this.completedCount = 0,
    this.totalCount = 4,
  });

  final int completedCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    final double percentage =
        totalCount > 0 ? (completedCount / totalCount).clamp(0.0, 1.0) : 0.0;
    final int percentInt = (percentage * 100).round();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.surfaceContainerLow,
          width: 1,
        ),
        boxShadow: [
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Progres Hari Ini',
                style: AppTextStyles.labelLg.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                totalCount == 0
                    ? 'Belum ada aktivitas dicatat'
                    : '$completedCount dari $totalCount aktivitas selesai',
                style: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          SizedBox(
            width: 64,
            height: 64,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 58,
                  height: 58,
                  child: CircularProgressIndicator(
                    value: percentage,
                    backgroundColor: AppColors.surfaceContainerHighest,
                    color: AppColors.primary,
                    strokeWidth: 5,
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Text(
                  '$percentInt%',
                  style: AppTextStyles.labelMd.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
