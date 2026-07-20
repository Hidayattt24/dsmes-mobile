import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';

class DailyCaloriesCard extends StatelessWidget {
  const DailyCaloriesCard({
    super.key,
    required this.consumed,
    required this.remaining,
    required this.target,
    required this.onRecordFoodPressed,
    this.isToday = true,
    this.hasRecord = true,
    this.historyMessage,
  });

  const DailyCaloriesCard.empty({
    super.key,
    required this.onRecordFoodPressed,
    this.isToday = true,
    this.historyMessage,
  })  : consumed = 0,
        remaining = 0,
        target = 0,
        hasRecord = false;

  final int consumed;
  final int remaining;
  final int target;
  final VoidCallback onRecordFoodPressed;
  final bool isToday;
  final bool hasRecord;
  final String? historyMessage;

  @override
  Widget build(BuildContext context) {
    // ── Empty State ──────────────────────────────────────────────────────────
    if (!hasRecord) {
      return AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Title
            Text(
              'Kalori Harian',
              style: AppTextStyles.labelLg.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            // Centered Empty State Details
            Center(
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.restaurant_outlined,
                      color: AppColors.outlineVariant,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'No meals have been recorded.',
                    style: AppTextStyles.poppinsHeadline.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    isToday
                        ? 'Catat makanan yang Anda konsumsi hari ini.'
                        : (historyMessage ?? 'Data makanan tidak diisi pada hari ini.'),
                    style: AppTextStyles.bodyMd.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            // CTA or Read-only banner
            if (isToday)
              AppButton(
                label: 'Catat Makanan',
                icon: Icons.restaurant_rounded,
                variant: AppButtonVariant.outlined,
                onPressed: onRecordFoodPressed,
              )
            else
              _buildHistoryBanner(),
          ],
        ),
      );
    }

    // ── Normal Card State ────────────────────────────────────────────────────
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Title
          Text(
            'Kalori Harian',
            style: AppTextStyles.labelLg.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // 3-Column Calories Summary
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'Dikonsumsi',
                      style: AppTextStyles.labelMd.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$consumed',
                      style: AppTextStyles.poppinsHeadline.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 36,
                width: 1,
                color: AppColors.outlineVariant.withValues(alpha: 0.5),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'Tersisa',
                      style: AppTextStyles.labelMd.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$remaining',
                      style: AppTextStyles.poppinsHeadline.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 36,
                width: 1,
                color: AppColors.outlineVariant.withValues(alpha: 0.5),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'Target',
                      style: AppTextStyles.labelMd.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$target',
                      style: AppTextStyles.poppinsHeadline.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          // CTA Button (Today) or read-only Banner (History)
          if (isToday)
            AppButton(
              label: 'Catat Makanan',
              icon: Icons.restaurant_rounded,
              variant: AppButtonVariant.outlined,
              onPressed: onRecordFoodPressed,
            )
          else
            _buildHistoryBanner(),
        ],
      ),
    );
  }

  Widget _buildHistoryBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: AppRadius.cardMd,
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.history_toggle_off_rounded,
            color: AppColors.outline,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              historyMessage ?? 'Anda sedang melihat data riwayat. Catatan masa lalu tidak dapat diubah.',
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
