import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_onboarding_question.dart';
import '../viewmodels/onboarding_notifier.dart';

class Step2Nickname extends ConsumerWidget {
  const Step2Nickname({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(onboardingProvider.notifier);
    final state = ref.watch(onboardingProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppOnboardingQuestion(
          icon: Icons.badge_outlined,
          question: AppStrings.stepNicknameTitle,
          description: AppStrings.stepNicknameSubtitle,
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          AppStrings.stepNicknameFieldLabel,
          style: AppTextStyles.labelLg.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          height: 56,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.outlineVariant),
            borderRadius: BorderRadius.circular(12),
            color: AppColors.surfaceContainerLowest,
          ),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  child: TextFormField(
                    initialValue: state.nickname,
                    onChanged: notifier.onNicknameChanged,
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.done,
                    style: AppTextStyles.bodyLg.copyWith(
                      color: AppColors.onSurface,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      hintText: AppStrings.stepNicknameFieldHint,
                      hintStyle: AppTextStyles.bodyLg.copyWith(
                        color: AppColors.outline,
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
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            const Icon(
              Icons.info_outline,
              size: 18,
              color: AppColors.onSurfaceVariant,
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                'Nama ini akan digunakan untuk menyapa Anda di aplikasi.',
                style: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
