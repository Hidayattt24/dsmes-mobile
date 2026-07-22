import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class RecordActionCard extends StatelessWidget {
  const RecordActionCard({
    super.key,
    required this.title,
    required this.valueText,
    this.unitText,
    required this.subtitle,
    required this.buttonText,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    this.badgeText,
    this.badgeBgColor,
    this.badgeTextColor,
    this.isPrimaryButton = false,
    required this.onTap,
  });

  final String title;
  final String valueText;
  final String? unitText;
  final String subtitle;
  final String buttonText;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String? badgeText;
  final Color? badgeBgColor;
  final Color? badgeTextColor;
  final bool isPrimaryButton;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.surfaceContainerLow,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryContainer.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          // Top Row: Icon & Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 16,
                ),
              ),
              if (badgeText != null)
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: badgeBgColor ?? AppColors.secondaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      badgeText!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelMd.copyWith(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: badgeTextColor ?? AppColors.onSecondaryContainer,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          // Title
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.labelMd.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          // Value & Unit (FittedBox to prevent horizontal & vertical overflows)
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  valueText,
                  style: AppTextStyles.headlineMd.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                if (unitText != null) ...[
                  const SizedBox(width: 3),
                  Text(
                    unitText!,
                    style: AppTextStyles.bodyMd.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 1),
          // Subtitle
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyMd.copyWith(
              color: AppColors.onSurfaceVariant,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
          // Action Button
          SizedBox(
            width: double.infinity,
            height: 34,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isPrimaryButton
                    ? AppColors.primaryContainer
                    : AppColors.surfaceContainerLow,
                foregroundColor: isPrimaryButton
                    ? AppColors.onPrimaryContainer
                    : AppColors.primary,
                elevation: 0,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: isPrimaryButton
                      ? BorderSide.none
                      : BorderSide(
                          color: AppColors.outlineVariant.withValues(alpha: 0.3),
                        ),
                ),
              ),
              onPressed: onTap,
              child: Text(
                buttonText,
                style: AppTextStyles.labelMd.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isPrimaryButton
                      ? AppColors.onPrimaryContainer
                      : AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
