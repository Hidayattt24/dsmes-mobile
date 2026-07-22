import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/body_metrics.dart';

/// Card widget displaying height, weight, BMI score, and activity level summary.
class BodyMetricCard extends StatelessWidget {
  const BodyMetricCard({
    super.key,
    required this.metrics,
    this.onEditTap,
  });

  final BodyMetrics metrics;
  final VoidCallback? onEditTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.3),
        ),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: const Icon(
                      Icons.accessibility_new_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Indikator Tubuh',
                    style: AppTextStyles.labelLg.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                ],
              ),
              if (onEditTap != null)
                TextButton.icon(
                  onPressed: onEditTap,
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Edit'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Heights & Weight Metrics Row
          Row(
            children: [
              Expanded(
                child: _MetricTile(
                  icon: Icons.height_rounded,
                  label: 'Tinggi Badan',
                  value: '${metrics.heightCm.toInt()}',
                  unit: 'cm',
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _MetricTile(
                  icon: Icons.monitor_weight_outlined,
                  label: 'Berat Badan',
                  value: '${metrics.weightKg.toInt()}',
                  unit: 'kg',
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _MetricTile(
                  icon: Icons.speed_rounded,
                  label: 'BMI (${metrics.bmiCategory})',
                  value: metrics.bmiFormatted,
                  unit: 'kg/m²',
                  valueColor: metrics.bmiCategoryColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Activity Level Row
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.directions_run_rounded,
                  size: 18,
                  color: AppColors.onSurfaceVariant,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'Aktivitas: ',
                  style: AppTextStyles.bodyMd.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                Expanded(
                  child: Text(
                    metrics.activityLevel,
                    style: AppTextStyles.bodyMd.copyWith(
                      color: AppColors.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
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

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: AppColors.outline),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.labelMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          RichText(
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              text: value,
              style: AppTextStyles.headlineMd.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: valueColor ?? AppColors.onSurface,
              ),
              children: [
                TextSpan(
                  text: ' $unit',
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.normal,
                    fontSize: 11,
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
