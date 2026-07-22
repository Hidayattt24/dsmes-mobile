import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

class AnswerOptionTile extends StatelessWidget {
  const AnswerOptionTile({
    super.key,
    required this.optionText,
    required this.optionIndex,
    required this.isSelected,
    required this.onTap,
  });

  final String optionText;
  final int optionIndex;
  final bool isSelected;
  final VoidCallback onTap;

  String _getOptionLabel(int index) {
    return switch (index) {
      0 => 'A',
      1 => 'B',
      2 => 'C',
      3 => 'D',
      _ => '${index + 1}',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryContainer.withValues(alpha: 0.08)
                : AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : AppColors.outlineVariant.withValues(alpha: 0.3),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Row(
            children: [
              // Option Letter Circle (A, B, C, D)
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.surfaceContainerLow,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    _getOptionLabel(optionIndex),
                    style: AppTextStyles.labelMd.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),

              // Option Text
              Expanded(
                child: Text(
                  optionText,
                  style: AppTextStyles.bodyLg.copyWith(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w400,
                    color: isSelected ? AppColors.primary : AppColors.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),

              // Selection Checkmark / Radio
              Icon(
                isSelected
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: isSelected ? AppColors.primary : AppColors.outline,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
