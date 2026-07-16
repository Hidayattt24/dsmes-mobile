import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'app_onboarding_icon.dart';

class AppOnboardingQuestion extends StatelessWidget {
  const AppOnboardingQuestion({
    super.key,
    required this.icon,
    required this.question,
    this.description,
    this.iconBackgroundColor = AppColors.primaryFixed,
    this.iconColor = AppColors.primary,
  });

  final IconData icon;
  final String question;
  final String? description;
  final Color iconBackgroundColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppOnboardingIcon(
          icon: icon,
          backgroundColor: iconBackgroundColor,
          iconColor: iconColor,
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          question,
          style: AppTextStyles.poppinsHeadline.copyWith(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            height: 1.3,
            color: AppColors.onSurface,
          ),
        ),
        if (description != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            description!,
            style: AppTextStyles.bodyLg.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}
