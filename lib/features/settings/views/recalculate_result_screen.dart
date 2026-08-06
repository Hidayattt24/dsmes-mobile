import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../viewmodels/settings_notifier.dart';

/// Screen displaying the recalculated BMI, daily calorie, and water intake results.
class RecalculateResultScreen extends ConsumerWidget {
  const RecalculateResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metrics = ref.watch(bodyMetricsProvider);

    final rec = metrics.recommendations;

    Map<String, dynamic> getRecDetail(String key) {
      if (rec != null && rec.containsKey(key)) {
        final val = rec[key];
        if (val is Map) {
          return Map<String, dynamic>.from(val);
        }
      }
      return {};
    }

    final maintainData = getRecDetail('maintain');
    final mildLossData = getRecDetail('mild_loss');
    final weightLossData = getRecDetail('weight_loss');
    final extremeLossData = getRecDetail('extreme_loss');

    final maintainTitle = maintainData['title'] as String? ?? 'Pertahankan Berat Badan';
    final maintainCal = maintainData['calories'] as int? ?? metrics.dailyCalorie;
    final maintainPct = maintainData['percentage'] as int? ?? 100;

    final mildTitle = mildLossData['title'] as String? ?? 'Menurunkan Berat Badan Ringan';
    final mildTarget = mildLossData['weekly_target'] as String? ?? '0,25 kg/minggu';
    final mildCal = mildLossData['calories'] as int? ?? (metrics.dailyCalorie * 0.9).round();
    final mildPct = mildLossData['percentage'] as int? ?? 90;

    final weightTitle = weightLossData['title'] as String? ?? 'Menurunkan Berat Badan';
    final weightTarget = weightLossData['weekly_target'] as String? ?? '0,5 kg/minggu';
    final weightCal = weightLossData['calories'] as int? ?? (metrics.dailyCalorie * 0.8).round();
    final weightPct = weightLossData['percentage'] as int? ?? 80;

    final extremeTitle = extremeLossData['title'] as String? ?? 'Menurunkan Berat Badan Ekstrem';
    final extremeTarget = extremeLossData['weekly_target'] as String? ?? '1 kg/minggu';
    final extremeCal = extremeLossData['calories'] as int? ?? (metrics.dailyCalorie - 1000);
    final extremePct = extremeLossData['percentage'] as int? ?? 70;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.onSurface),
          onPressed: () => context.go(RouteNames.home),
        ),
        title: Text(
          'Hasil Rekalkulasi',
          style: AppTextStyles.headlineMd.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.page),
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.md),

                    // Success Icon & Badge
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.secondary,
                          size: 48,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Profil Berhasil Diperbarui!',
                      style: AppTextStyles.headlineLg.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                      child: Text(
                        'Rekomendasi kebutuhan harian Anda telah disesuaikan berdasarkan indikator tubuh terbaru.',
                        style: AppTextStyles.bodyMd.copyWith(
                          color: AppColors.onSurfaceVariant,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // ── BMI Result Card ──────────────────────────────────────
                    _ResultCard(
                      icon: Icons.speed_rounded,
                      iconBg: AppColors.primary.withValues(alpha: 0.1),
                      iconColor: AppColors.primary,
                      title: 'Indeks Massa Tubuh (BMI)',
                      value: '${metrics.bmiFormatted} kg/m²',
                      badgeText: metrics.bmiCategory,
                      badgeColor: metrics.bmiCategoryColor,
                      description:
                          'Tinggi: ${metrics.heightCm.toInt()} cm • Berat: ${metrics.weightKg.toInt()} kg',
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // ── 4-Tier Calorie Recommendation Section ──────────────────
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.outlineVariant.withValues(alpha: 0.3),
                        ),
                        boxShadow: AppShadows.soft,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.restaurant_menu_rounded,
                                  color: AppColors.tertiary, size: 22),
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                'Opsi Target Kalori Harian',
                                style: AppTextStyles.labelLg.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.onSurface,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _RecommendationRow(
                            title: maintainTitle,
                            calories: '$maintainCal kcal/hari',
                            percentage: '$maintainPct%',
                            isPrimary: true,
                          ),
                          const Divider(height: 16),
                          _RecommendationRow(
                            title: '$mildTitle ($mildTarget)',
                            calories: '$mildCal kcal/hari',
                            percentage: '$mildPct%',
                          ),
                          const Divider(height: 16),
                          _RecommendationRow(
                            title: '$weightTitle ($weightTarget)',
                            calories: '$weightCal kcal/hari',
                            percentage: '$weightPct%',
                          ),
                          const Divider(height: 16),
                          _RecommendationRow(
                            title: '$extremeTitle ($extremeTarget)',
                            calories: '$extremeCal kcal/hari',
                            percentage: '$extremePct%',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Health Explanation Tip Card
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.outlineVariant.withValues(alpha: 0.3),
                        ),
                        boxShadow: AppShadows.soft,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.lightbulb_outline_rounded,
                            color: AppColors.tertiary,
                            size: 22,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Catatan Kesehatan',
                                  style: AppTextStyles.labelLg.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Perubahan berat badan dan aktivitas mempengaruhi kebutuhan harian Anda. Pastikan untuk menjaga pola makan seimbang dan olahraga teratur.',
                                  style: AppTextStyles.bodyMd.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),

            // Bottom Action Button
            Padding(
              padding: const EdgeInsets.all(AppSpacing.page),
              child: AppButton(
                label: 'Kembali ke Pengaturan',
                onPressed: () {
                  context.go(RouteNames.home);
                },
                icon: Icons.check_circle_outline_rounded,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.badgeText,
    required this.badgeColor,
    required this.description,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String value;
  final String badgeText;
  final Color badgeColor;
  final String description;

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
                      color: iconBg,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Icon(icon, color: iconColor, size: 20),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    title,
                    style: AppTextStyles.labelMd.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  badgeText,
                  style: AppTextStyles.labelMd.copyWith(
                    color: badgeColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            value,
            style: AppTextStyles.headlineLg.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: AppTextStyles.bodyMd.copyWith(
              color: AppColors.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendationRow extends StatelessWidget {
  const _RecommendationRow({
    required this.title,
    required this.calories,
    required this.percentage,
    this.isPrimary = false,
  });

  final String title;
  final String calories;
  final String percentage;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.bodyMd.copyWith(
                  fontWeight: isPrimary ? FontWeight.bold : FontWeight.w500,
                  color: isPrimary ? AppColors.primary : AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                calories,
                style: AppTextStyles.labelLg.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isPrimary ? AppColors.primary : AppColors.tertiary,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isPrimary
                ? AppColors.primary.withValues(alpha: 0.1)
                : AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            percentage,
            style: AppTextStyles.labelMd.copyWith(
              fontWeight: FontWeight.bold,
              color: isPrimary ? AppColors.primary : AppColors.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
