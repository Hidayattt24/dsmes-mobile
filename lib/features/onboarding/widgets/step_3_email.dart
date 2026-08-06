import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_onboarding_question.dart';
import '../viewmodels/onboarding_notifier.dart';

class Step3Email extends ConsumerWidget {
  const Step3Email({super.key});

  static bool _isValidEmail(String email) {
    final regex = RegExp(r'^[\w.-]+@[\w.-]+\.\w{2,}$');
    return regex.hasMatch(email.trim());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(onboardingProvider.notifier);
    final email = ref.watch(onboardingProvider.select((s) => s.email));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppOnboardingQuestion(
          icon: Icons.email_outlined,
          question: AppStrings.step2Title,
          description: AppStrings.step2Subtitle,
          iconBackgroundColor: AppColors.primaryFixed,
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          AppStrings.step2FieldLabel,
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
              const SizedBox(width: AppSpacing.lg),
              const Icon(
                Icons.email_outlined,
                color: AppColors.outline,
                size: 22,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: TextFormField(
                  initialValue: email,
                  onChanged: notifier.onEmailChanged,
                  keyboardType: TextInputType.emailAddress,
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
                    hintText: AppStrings.step2FieldHint,
                    hintStyle: AppTextStyles.bodyLg.copyWith(
                      color: AppColors.outline,
                    ),
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (email.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            _isValidEmail(email) ? 'Email valid' : 'Format email tidak valid',
            style: AppTextStyles.labelMd.copyWith(
              color: _isValidEmail(email) ? AppColors.primary : AppColors.error,
            ),
          ),
        ],
      ],
    );
  }
}
