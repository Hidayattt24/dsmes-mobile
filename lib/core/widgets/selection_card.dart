import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class SelectionCard extends StatelessWidget {
  const SelectionCard({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.subtitle,
    this.isWide = false,
    this.icon,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final String? subtitle;
  final bool isWide;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : AppColors.surfaceContainerLowest,
          borderRadius: AppRadius.cardMd,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.outlineVariant,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: isWide ? AppSpacing.sm : AppSpacing.xl,
        ),
        child: isWide ? _WideContent(label: label, isSelected: isSelected, icon: icon) : _GridContent(label: label, isSelected: isSelected, subtitle: subtitle),
      ),
    );
  }
}

class _GridContent extends StatelessWidget {
  const _GridContent({required this.label, required this.isSelected, this.subtitle});

  final String label;
  final bool isSelected;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: AppTextStyles.poppinsHeadline.copyWith(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: isSelected ? AppColors.onPrimary : AppColors.primary,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: AppSpacing.xxs),
          Text(
            subtitle!,
            style: AppTextStyles.labelMd.copyWith(
              color: isSelected
                  ? AppColors.onPrimary.withValues(alpha: 0.85)
                  : AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

class _WideContent extends StatelessWidget {
  const _WideContent({required this.label, required this.isSelected, this.icon});

  final String label;
  final bool isSelected;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon ?? Icons.help_outline,
          color: isSelected ? AppColors.onPrimary : AppColors.secondary,
          size: 24,
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          label,
          style: AppTextStyles.headlineMd.copyWith(
            color: isSelected ? AppColors.onPrimary : AppColors.onSurface,
          ),
        ),
      ],
    );
  }
}
