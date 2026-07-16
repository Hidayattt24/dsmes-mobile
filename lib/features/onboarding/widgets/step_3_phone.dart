import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_onboarding_question.dart';
import '../viewmodels/onboarding_notifier.dart';

class Step3Phone extends ConsumerWidget {
  const Step3Phone({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(onboardingProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppOnboardingQuestion(
          icon: Icons.phone_outlined,
          question: AppStrings.step3Title,
          description: AppStrings.step3Subtitle,
          iconBackgroundColor: AppColors.secondaryContainer,
        ),
        const SizedBox(height: AppSpacing.lg),
        Container(
          height: 56,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.outlineVariant),
            borderRadius: BorderRadius.circular(12),
            color: AppColors.surfaceContainerLowest,
          ),
          child: Row(
            children: [
              const SizedBox(width: AppSpacing.md),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                decoration: const BoxDecoration(
                  border: Border(
                    right: BorderSide(color: AppColors.outlineVariant),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 24,
                      height: 16,
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: const Center(
                        child: Text(
                          'ID',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            color: AppColors.secondary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      '+62',
                      style: AppTextStyles.labelLg.copyWith(
                        color: AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                  child: TextFormField(
                    onChanged: notifier.onPhoneChanged,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.done,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: AppTextStyles.labelLg.copyWith(
                      color: AppColors.onSurface,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      hintText: AppStrings.step3FieldHint,
                      hintStyle: AppTextStyles.labelLg.copyWith(
                        color: AppColors.outlineVariant,
                      ),
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.primaryContainer.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.verified_user_outlined,
                color: AppColors.primaryContainer,
                size: 40,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                AppStrings.step3SecurityTitle,
                textAlign: TextAlign.center,
                style: AppTextStyles.labelMd.copyWith(
                  color: AppColors.primaryContainer,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          AppStrings.step3Terms,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMd.copyWith(
            color: AppColors.outline,
          ),
        ),
      ],
    );
  }
}
