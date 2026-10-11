import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../home/meal/models/nutrition_summary_model.dart';

class DailyNutritionSummaryCard extends StatelessWidget {
  const DailyNutritionSummaryCard({
    super.key,
    required this.summary,
    required this.selectedDate,
    this.onAddMealTap,
  });

  final DailyNutritionSummary? summary;
  final DateTime selectedDate;
  final VoidCallback? onAddMealTap;

  String _formatNumber(double val) {
    if (val == val.truncateToDouble()) {
      return val.toInt().toString();
    }
    return val.toStringAsFixed(1);
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(dt.year, dt.month, dt.day);

    if (today == target) {
      return 'Hari Ini, ${dt.day} ${_monthName(dt.month)}';
    }
    return '${dt.day} ${_monthName(dt.month)} ${dt.year}';
  }

  String _monthName(int m) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    if (m >= 1 && m <= 12) return months[m - 1];
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final hasMeals = summary != null && summary!.hasMealsToday;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.6),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Title, Date, & Calories Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ringkasan Nutrisi Harian',
                      style: AppTextStyles.titleMd.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(selectedDate),
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (hasMeals) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.local_fire_department_rounded,
                        color: AppColors.primary,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${summary!.consumedCaloriesRounded} kcal',
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Content: Grid or Empty State
          if (!hasMeals) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.lg,
                horizontal: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.restaurant_outlined,
                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                    size: 28,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Belum ada asupan makanan tercatat pada tanggal ini.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            // 6 Nutrients Grid (2 rows x 3 columns)
            Row(
              children: [
                Expanded(
                  child: _NutrientItem(
                    label: 'Protein',
                    value: '${_formatNumber(summary!.totalProteinG)} g',
                    color: const Color(0xFF0284C7),
                    bgColor: const Color(0xFFF0F9FF),
                    icon: Icons.fitness_center_rounded,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _NutrientItem(
                    label: 'Karbohidrat',
                    value: '${_formatNumber(summary!.totalCarbsG)} g',
                    color: const Color(0xFFD97706),
                    bgColor: const Color(0xFFFFFBEB),
                    icon: Icons.grain_rounded,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _NutrientItem(
                    label: 'Lemak',
                    value: '${_formatNumber(summary!.totalFatG)} g',
                    color: const Color(0xFFE11D48),
                    bgColor: const Color(0xFFFFF1F2),
                    icon: Icons.opacity_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _NutrientItem(
                    label: 'Gula',
                    value: '${_formatNumber(summary!.totalSugarG)} g',
                    color: const Color(0xFF7C3AED),
                    bgColor: const Color(0xFFF5F3FF),
                    icon: Icons.cookie_outlined,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _NutrientItem(
                    label: 'Natrium',
                    value: '${_formatNumber(summary!.totalSodiumMg)} mg',
                    color: const Color(0xFF0D9488),
                    bgColor: const Color(0xFFF0FDFA),
                    icon: Icons.shutter_speed_rounded,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _NutrientItem(
                    label: 'Serat',
                    value: '${_formatNumber(summary!.totalFiberG)} g',
                    color: const Color(0xFF059669),
                    bgColor: const Color(0xFFECFDF5),
                    icon: Icons.eco_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Total dihitung dari seluruh makanan yang dicatat hari ini',
                style: AppTextStyles.labelSm.copyWith(
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NutrientItem extends StatelessWidget {
  const _NutrientItem({
    required this.label,
    required this.value,
    required this.color,
    required this.bgColor,
    required this.icon,
  });

  final String label;
  final String value;
  final Color color;
  final Color bgColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  style: AppTextStyles.labelSm.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.titleMd.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
              fontSize: 15,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
