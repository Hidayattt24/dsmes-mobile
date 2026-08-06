import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../models/history_item_model.dart';

class DailyHistorySummary extends StatelessWidget {
  const DailyHistorySummary({
    super.key,
    required this.aggregate,
  });

  final DailyHistoryAggregate aggregate;

  String _formatIndonesianDate(DateTime date) {
    const dayNames = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    const monthNames = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
    ];
    return '${dayNames[date.weekday - 1]}, ${date.day} ${monthNames[date.month - 1]} ${date.year}';
  }

  String? _extractBloodSugarClassification(DailyHistoryAggregate agg) {
    final bsItems = agg.items.where((i) => i.activityType == 'blood_sugar').toList();
    if (bsItems.isEmpty) return null;
    bsItems.sort((a, b) => b.parsedMeasuredAt!.compareTo(a.parsedMeasuredAt!));
    final status = bsItems.first.status;
    switch (status) {
      case 'normal':
        return 'Normal';
      case 'hypoglycemia':
        return 'Hipoglikemia';
      case 'severe_hypoglycemia':
        return 'Hipoglikemia Berat';
      case 'hyperglycemia':
        return 'Hiperglikemia';
      case 'severe_hyperglycemia':
        return 'Hiperglikemia Berat';
      default:
        return 'Normal';
    }
  }

  Color _parseColor(String hex) {
    try {
      final cleanHex = hex.replaceAll('#', '');
      if (cleanHex.length == 6) {
        return Color(int.parse('FF$cleanHex', radix: 16));
      }
    } catch (_) {}
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = aggregate.recordedCategoriesCount;
    final isFullyCompleted = aggregate.isFullyCompleted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatIndonesianDate(aggregate.date),
              style: AppTextStyles.labelLg.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isFullyCompleted
                    ? AppColors.secondaryContainer
                    : AppColors.tertiaryContainer.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isFullyCompleted ? 'Lengkap (4/4)' : 'Sebagian ($completedCount/4)',
                style: AppTextStyles.labelMd.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isFullyCompleted
                      ? AppColors.onSecondaryContainer
                      : AppColors.tertiary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // 1. Blood Sugar Record
        if (aggregate.hasBloodSugar) ...[
          _buildMetricCard(
            icon: Icons.bloodtype_outlined,
            iconColor: _parseColor(aggregate.latestBloodSugarColor ?? '#00695C'),
            iconBgColor: _parseColor(aggregate.latestBloodSugarColor ?? '#00695C').withValues(alpha: 0.1),
            title: 'Gula Darah',
            value: '${aggregate.latestBloodSugarValue ?? '-'} mg/dL',
            subtitle: _extractBloodSugarClassification(aggregate) ?? 'Normal',
            statusBadge: _buildStatusBadge(
              label: _extractBloodSugarClassification(aggregate) ?? 'Normal',
              isError: aggregate.latestBloodSugarStatus == 'hyperglycemia' ||
                  aggregate.latestBloodSugarStatus == 'severe_hyperglycemia' ||
                  aggregate.latestBloodSugarStatus == 'severe_hypoglycemia',
              isSuccess: aggregate.latestBloodSugarStatus == 'normal',
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],

        // 2. Food & Calories
        if (aggregate.hasMeal) ...[
          _buildMetricCard(
            icon: Icons.restaurant_rounded,
            iconColor: AppColors.tertiary,
            iconBgColor: AppColors.tertiaryFixed,
            title: 'Makanan & Kalori',
            value: '${aggregate.mealsRecorded} kali makan tercatat',
            subtitle: '${aggregate.totalCaloriesConsumed.toInt()} kcal',
            statusBadge: _buildStatusBadge(
              label: '${aggregate.mealsRecorded} Makanan',
              isSuccess: true,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],

        // 3. Physical Activity
        if (aggregate.hasActivity) ...[
          _buildMetricCard(
            icon: Icons.directions_walk_rounded,
            iconColor: AppColors.secondary,
            iconBgColor: AppColors.secondaryFixed,
            title: 'Aktivitas Fisik',
            value: '${aggregate.totalActivityMinutes} menit',
            subtitle: aggregate.totalActivityMinutes >= 30
                ? 'Target Harian Tercapai (Min. 30 Mnt)'
                : 'Aktivitas Fisik Ringan',
            statusBadge: _buildStatusBadge(
              label: aggregate.totalActivityMinutes >= 30 ? 'Tercapai' : 'Ringan',
              isSuccess: aggregate.totalActivityMinutes >= 30,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],

        // 4. Medication
        if (aggregate.medicationPartiallyCompleted) ...[
          _buildMetricCard(
            icon: Icons.medication_outlined,
            iconColor: AppColors.primary,
            iconBgColor: AppColors.surfaceContainerHighest,
            title: 'Obat-obatan',
            value: aggregate.medicationCompleted
                ? 'Kepatuhan Obat Selesai'
                : 'Belum Tercatat Semua',
            subtitle: aggregate.medicationCompleted
                ? 'Semua obat diminum sesuai jadwal'
                : 'Ada obat yang belum diminum',
            statusBadge: _buildStatusBadge(
              label: aggregate.medicationCompleted ? 'Sudah Minum' : 'Belum',
              isSuccess: aggregate.medicationCompleted,
              isWarning: !aggregate.medicationCompleted,
            ),
          ),
        ],

        // Detailed Timeline of individual records for the day
        if (aggregate.items.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Detail Catatan Harian',
            style: AppTextStyles.labelLg.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ...aggregate.items.map((item) {
            final formattedTime = item.parsedMeasuredAt != null
                ? '${item.parsedMeasuredAt!.hour.toString().padLeft(2, '0')}:${item.parsedMeasuredAt!.minute.toString().padLeft(2, '0')} WIB'
                : '-';
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.history_rounded, size: 20, color: AppColors.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: AppTextStyles.labelLg.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: AppColors.onSurface,
                            ),
                          ),
                          Text(
                            '${item.subtitle} • $formattedTime',
                            style: AppTextStyles.bodyMd.copyWith(
                              fontSize: 11,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (item.status.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item.status,
                          style: AppTextStyles.labelMd.copyWith(
                            fontSize: 10,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
        ],
      ],
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String value,
    required String subtitle,
    Widget? statusBadge,
    double? progressValue,
  }) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 22,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.labelMd.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (statusBadge != null) statusBadge,
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTextStyles.labelLg.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                if (progressValue != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progressValue.clamp(0.0, 1.0),
                      minHeight: 6,
                      backgroundColor: AppColors.outlineVariant.withValues(alpha: 0.3),
                      color: progressValue >= 1.0 ? AppColors.secondary : AppColors.primary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge({
    required String label,
    bool isError = false,
    bool isSuccess = false,
    bool isWarning = false,
  }) {
    final Color bgColor = isError
        ? AppColors.errorContainer
        : isSuccess
            ? AppColors.secondaryContainer
            : isWarning
                ? AppColors.tertiaryContainer.withValues(alpha: 0.2)
                : AppColors.primaryContainer.withValues(alpha: 0.1);

    final Color textColor = isError
        ? AppColors.onErrorContainer
        : isSuccess
            ? AppColors.onSecondaryContainer
            : isWarning
                ? AppColors.tertiary
                : AppColors.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelMd.copyWith(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }
}
