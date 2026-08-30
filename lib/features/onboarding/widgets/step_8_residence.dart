import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_onboarding_question.dart';
import '../viewmodels/onboarding_notifier.dart';

class Step8Residence extends ConsumerWidget {
  const Step8Residence({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(onboardingProvider.notifier);
    final city = ref.watch(onboardingProvider.select((s) => s.city));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppOnboardingQuestion(
          icon: Icons.home_outlined,
          question: AppStrings.residenceTitle,
          description: AppStrings.residenceSubtitle,
          iconBackgroundColor: AppColors.secondaryContainer,
        ),
        const SizedBox(height: AppSpacing.lg),
        _StaticField(
          label: AppStrings.residenceCityLabel,
          value: city,
        ),
        const SizedBox(height: AppSpacing.md),
        _TextField(
          label: AppStrings.residenceDistrictLabel,
          hint: AppStrings.residenceDistrictHint,
          initialValue: ref.watch(
            onboardingProvider.select((s) => s.district),
          ),
          onChanged: notifier.onDistrictChanged,
        ),
        const SizedBox(height: AppSpacing.md),
        _TextField(
          label: AppStrings.residenceAddressLabel,
          hint: AppStrings.residenceAddressHint,
          initialValue: ref.watch(
            onboardingProvider.select((s) => s.address),
          ),
          onChanged: notifier.onAddressChanged,
          maxLines: 3,
          keyboardType: TextInputType.streetAddress,
        ),
      ],
    );
  }
}

class _StaticField extends StatelessWidget {
  const _StaticField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelLg.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.outlineVariant),
            borderRadius: BorderRadius.circular(12),
            color: AppColors.surfaceContainerLowest,
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: AppTextStyles.bodyLg.copyWith(color: AppColors.onSurface),
            ),
          ),
        ),
      ],
    );
  }
}

class _TextField extends StatelessWidget {
  const _TextField({
    required this.label,
    required this.hint,
    required this.initialValue,
    required this.onChanged,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
  });

  final String label;
  final String hint;
  final String initialValue;
  final ValueChanged<String> onChanged;
  final int maxLines;
  final TextInputType keyboardType;

  @override
  Widget build(BuildContext context) {
    final isMultiline = maxLines > 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelLg.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          height: isMultiline ? null : 56,
          constraints: isMultiline
              ? const BoxConstraints(minHeight: 56)
              : null,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.outlineVariant),
            borderRadius: BorderRadius.circular(12),
            color: AppColors.surfaceContainerLowest,
          ),
          child: isMultiline
              ? Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  child: TextFormField(
                    initialValue: initialValue,
                    onChanged: onChanged,
                    maxLines: maxLines,
                    keyboardType: keyboardType,
                    textInputAction: TextInputAction.newline,
                    style: AppTextStyles.bodyLg.copyWith(
                      color: AppColors.onSurface,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      hintText: hint,
                      hintStyle: AppTextStyles.bodyLg.copyWith(
                        color: AppColors.outline,
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                )
              : Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                        ),
                        child: TextFormField(
                          initialValue: initialValue,
                          onChanged: onChanged,
                          keyboardType: keyboardType,
                          textInputAction: TextInputAction.next,
                          style: AppTextStyles.bodyLg.copyWith(
                            color: AppColors.onSurface,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            hintText: hint,
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
      ],
    );
  }
}
