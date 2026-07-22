import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

/// Navigation menu item row used inside [SettingsSection].
class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
    this.iconBackgroundColor,
    this.iconColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;
  final Color? iconBackgroundColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final effectiveIconBg = isDestructive
        ? AppColors.error.withValues(alpha: 0.08)
        : iconBackgroundColor ?? AppColors.primary.withValues(alpha: 0.08);

    final effectiveIconColor = isDestructive
        ? AppColors.error
        : iconColor ?? AppColors.primary;

    final effectiveTitleColor =
        isDestructive ? AppColors.error : AppColors.onSurface;

    final effectiveSubtitleColor = isDestructive
        ? AppColors.error.withValues(alpha: 0.7)
        : AppColors.onSurfaceVariant;

    final effectiveChevronColor = isDestructive
        ? AppColors.error.withValues(alpha: 0.4)
        : AppColors.outline;

    return InkWell(
      onTap: onTap,
      splashColor: isDestructive
          ? AppColors.error.withValues(alpha: 0.1)
          : AppColors.primary.withValues(alpha: 0.08),
      highlightColor: isDestructive
          ? AppColors.error.withValues(alpha: 0.05)
          : AppColors.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            // Icon container rounded 16px
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: effectiveIconBg,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Icon(
                icon,
                color: effectiveIconColor,
                size: 22,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            // Title & Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.labelLg.copyWith(
                      color: effectiveTitleColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodyMd.copyWith(
                      color: effectiveSubtitleColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Icon(
              Icons.chevron_right_rounded,
              color: effectiveChevronColor,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
