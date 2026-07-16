import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_onboarding_question.dart';
import '../viewmodels/onboarding_notifier.dart';

class Step5ConfirmPassword extends ConsumerStatefulWidget {
  const Step5ConfirmPassword({super.key});

  @override
  ConsumerState<Step5ConfirmPassword> createState() =>
      _Step5ConfirmPasswordState();
}

class _Step5ConfirmPasswordState extends ConsumerState<Step5ConfirmPassword> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(onboardingProvider.notifier);
    final confirmPassword = ref.watch(
      onboardingProvider.select((s) => s.confirmPassword),
    );
    final password = ref.watch(onboardingProvider.select((s) => s.password));
    final doMatch = confirmPassword.isNotEmpty && confirmPassword == password;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppOnboardingQuestion(
          icon: Icons.lock_outline,
          question: AppStrings.step5Title,
          description: AppStrings.step5Subtitle,
          iconBackgroundColor: AppColors.primaryFixed,
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          AppStrings.step5FieldLabel,
          style: AppTextStyles.labelLg.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          height: 56,
          decoration: BoxDecoration(
            border: Border.all(
              color:
                  confirmPassword.isNotEmpty
                      ? doMatch
                          ? AppColors.primary
                          : AppColors.error
                      : AppColors.outlineVariant,
            ),
            borderRadius: BorderRadius.circular(12),
            color: AppColors.surfaceContainerLowest,
          ),
          child: Row(
            children: [
              const SizedBox(width: AppSpacing.lg),
              const Icon(
                Icons.lock_outline,
                color: AppColors.outline,
                size: 22,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: TextFormField(
                  onChanged: notifier.onConfirmPasswordChanged,
                  obscureText: _obscure,
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
                    hintText: AppStrings.step5FieldHint,
                    hintStyle: AppTextStyles.bodyLg.copyWith(
                      color: AppColors.outline,
                    ),
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              if (confirmPassword.isNotEmpty)
                Icon(
                  doMatch ? Icons.check_circle : Icons.cancel,
                  color: doMatch ? AppColors.primary : AppColors.error,
                  size: 22,
                ),
              IconButton(
                icon: Icon(
                  _obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.outline,
                  size: 22,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
              const SizedBox(width: AppSpacing.sm),
            ],
          ),
        ),
        if (confirmPassword.isNotEmpty && !doMatch) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            AppStrings.validationPasswordNotMatch,
            style: AppTextStyles.labelMd.copyWith(color: AppColors.error),
          ),
        ],
      ],
    );
  }
}
