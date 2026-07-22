import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../models/history_mock_data.dart';

class DailyHistorySummary extends StatelessWidget {
  const DailyHistorySummary({
    super.key,
    required this.record,
  });

  final HealthActivityRecord record;

  String _formatIndonesianDate(DateTime date) {
    const dayNames = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    const monthNames = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${dayNames[date.weekday - 1]}, ${date.day} ${monthNames[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = record.recordedCategoriesCount;
    final isFullyCompleted = completedCount >= 4;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatIndonesianDate(record.date),
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

        // 1. Blood Sugar Record (Gula Darah)
        if (record.bloodSugar != null) ...[
          _buildMetricCard(
            icon: Icons.bloodtype_outlined,
            iconColor: record.bloodSugarStatus == 'Tinggi' ? AppColors.error : AppColors.primary,
            iconBgColor: (record.bloodSugarStatus == 'Tinggi' ? AppColors.error : AppColors.primary)
                .withValues(alpha: 0.1),
            title: 'Gula Darah',
            value: '${record.bloodSugar!.toInt()} mg/dL',
            subtitle: record.bloodSugarStatus ?? 'Normal',
            statusBadge: _buildStatusBadge(
              label: record.bloodSugarStatus ?? 'Normal',
              isError: record.bloodSugarStatus == 'Tinggi',
              isSuccess: record.bloodSugarStatus == 'Normal',
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],

        // 2. Makanan & Kalori (Food)
        if (record.mealsRecorded > 0 || record.caloriesConsumed > 0) ...[
          _buildMetricCard(
            icon: Icons.restaurant_rounded,
            iconColor: AppColors.tertiary,
            iconBgColor: AppColors.tertiaryFixed,
            title: 'Makanan & Kalori',
            value: '${record.mealsRecorded} kali makan tercatat',
            subtitle: '${record.caloriesConsumed} / ${record.caloriesTarget} kcal',
            progressValue: record.caloriesTarget > 0 ? record.caloriesConsumed / record.caloriesTarget : 0.0,
            statusBadge: _buildStatusBadge(
              label: '${record.mealsRecorded} Makanan',
              isSuccess: true,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],

        // 3. Physical Activity Record (Aktivitas Fisik)
        if (record.physicalActivityMinutes > 0) ...[
          _buildMetricCard(
            icon: Icons.directions_walk_rounded,
            iconColor: AppColors.secondary,
            iconBgColor: AppColors.secondaryFixed,
            title: 'Aktivitas Fisik',
            value: '${record.physicalActivityMinutes} menit',
            subtitle: record.physicalActivityMinutes >= 30
                ? 'Target Harian Tercapai (Min. 30 Mnt)'
                : 'Aktivitas Fisik Ringan',
            statusBadge: _buildStatusBadge(
              label: record.physicalActivityMinutes >= 30 ? 'Tercapai' : 'Ringan',
              isSuccess: record.physicalActivityMinutes >= 30,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],

        // 4. Medication Record (Obat-obatan)
        if (record.medicationCompleted) ...[
          _buildMetricCard(
            icon: Icons.medication_outlined,
            iconColor: AppColors.primary,
            iconBgColor: AppColors.surfaceContainerHighest,
            title: 'Obat-obatan',
            value: 'Kepatuhan Obat Selesai',
            subtitle: 'Semua obat diminum sesuai jadwal',
            statusBadge: _buildStatusBadge(
              label: 'Sudah Minum',
              isSuccess: true,
            ),
          ),
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
