import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

enum QuestionnaireActionVariant { primary, secondary, success }

class QuestionnaireActionButton extends StatelessWidget {
  const QuestionnaireActionButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = QuestionnaireActionVariant.secondary,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final QuestionnaireActionVariant variant;

  @override
  Widget build(BuildContext context) {
    final isPrimary = variant == QuestionnaireActionVariant.primary;
    final isSuccess = variant == QuestionnaireActionVariant.success;
    final color = isSuccess ? AppColors.secondary : AppColors.primary;

    return SizedBox(
      height: 46,
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        style: FilledButton.styleFrom(
          backgroundColor:
              isPrimary ? AppColors.primary : color.withValues(alpha: 0.1),
          foregroundColor: isPrimary ? Colors.white : color,
          disabledBackgroundColor: AppColors.surfaceContainerHighest,
          disabledForegroundColor: AppColors.outline,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.center,
          textStyle: AppTextStyles.labelLg.copyWith(
            fontWeight: FontWeight.bold,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side:
                isPrimary
                    ? BorderSide.none
                    : BorderSide(color: color.withValues(alpha: 0.22)),
          ),
        ),
      ),
    );
  }
}
