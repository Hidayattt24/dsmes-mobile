import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_onboarding_question.dart';
import '../models/onboarding_form_state.dart';
import '../viewmodels/onboarding_notifier.dart';

class Step4Password extends ConsumerStatefulWidget {
  const Step4Password({super.key});

  @override
  ConsumerState<Step4Password> createState() => _Step4PasswordState();
}

class _Step4PasswordState extends ConsumerState<Step4Password> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(onboardingProvider.notifier);
    final password = ref.watch(onboardingProvider.select((s) => s.password));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppOnboardingQuestion(
          icon: Icons.lock_outline,
          question: AppStrings.step4Title,
          description: AppStrings.step4Subtitle,
          iconBackgroundColor: AppColors.primaryFixed,
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          AppStrings.step4FieldLabel,
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
              const Icon(Icons.lock_outline, color: AppColors.outline, size: 22),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: TextFormField(
                  onChanged: notifier.onPasswordChanged,
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
                    hintText: AppStrings.step4FieldHint,
                    hintStyle: AppTextStyles.bodyLg.copyWith(
                      color: AppColors.outline,
                    ),
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: AppColors.outline,
                  size: 22,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
              const SizedBox(width: AppSpacing.sm),
            ],
          ),
        ),
        if (password.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          _PasswordStrengthBar(password: password),
          const SizedBox(height: AppSpacing.xs),
          Text(
            _strengthText(password),
            style: AppTextStyles.labelMd.copyWith(
              color: _strengthColor(password),
            ),
          ),
        ],
      ],
    );
  }

  String _strengthText(String pw) {
    final s = OnboardingFormState(password: pw).passwordStrengthText;
    switch (s) {
      case 'Kuat':
        return 'Kata sandi kuat';
      case 'Sedang':
        return 'Kata sandi sedang';
      default:
        return 'Kata sandi lemah — gunakan huruf besar, kecil, dan angka';
    }
  }

  Color _strengthColor(String pw) {
    final s = OnboardingFormState(password: pw).passwordStrengthText;
    switch (s) {
      case 'Kuat':
        return AppColors.primary;
      case 'Sedang':
        return AppColors.tertiary;
      default:
        return AppColors.error;
    }
  }
}

class _PasswordStrengthBar extends StatelessWidget {
  const _PasswordStrengthBar({required this.password});

  final String password;

  @override
  Widget build(BuildContext context) {
    final strength = OnboardingFormState(password: password).passwordStrengthText;
    const segments = 3;
    final filled = switch (strength) {
      'Kuat' => 3,
      'Sedang' => 2,
      _ => 1,
    };
    final barColor = switch (strength) {
      'Kuat' => AppColors.primary,
      'Sedang' => AppColors.tertiary,
      _ => AppColors.error,
    };

    return Row(
      children: List.generate(segments, (i) {
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: i < segments - 1 ? 4 : 0),
            decoration: BoxDecoration(
              color: i < filled ? barColor : AppColors.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}
