import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class Step7WelcomeIntro extends ConsumerWidget {
  const Step7WelcomeIntro({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: AppSpacing.xl),
        // Illustration placeholder
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            color: AppColors.primaryContainer.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(100),
          ),
          child: const Icon(
            Icons.person_pin_circle_outlined,
            size: 96,
            color: AppColors.primaryContainer,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          AppStrings.step6Title,
          textAlign: TextAlign.center,
          style: AppTextStyles.poppinsHeadline.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            AppStrings.step6Subtitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLg.copyWith(
              color: AppColors.onSurfaceVariant,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }
}
