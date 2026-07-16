import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_onboarding_question.dart';
import '../viewmodels/onboarding_notifier.dart';

class Step8Birthdate extends ConsumerWidget {
  const Step8Birthdate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(onboardingProvider.notifier);
    final birthDate = ref.watch(onboardingProvider.select((s) => s.birthDate));

    final displayText = birthDate != null
        ? DateFormat('dd MMMM yyyy', 'id').format(birthDate)
        : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppOnboardingQuestion(
          icon: Icons.calendar_month_outlined,
          question: AppStrings.step8Title,
          description: AppStrings.step8Subtitle,
          iconBackgroundColor: AppColors.secondaryContainer,
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          AppStrings.step8FieldLabel,
          style: AppTextStyles.labelLg.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        GestureDetector(
          onTap: () => _showDatePicker(context, birthDate, notifier),
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.outlineVariant),
              borderRadius: BorderRadius.circular(12),
              color: AppColors.surfaceContainerLowest,
            ),
            child: Row(
              children: [
                const SizedBox(width: AppSpacing.md),
                const Icon(Icons.calendar_month_outlined, color: AppColors.outline),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    displayText.isEmpty ? AppStrings.step8FieldHint : displayText,
                    style: AppTextStyles.bodyLg.copyWith(
                      color: displayText.isEmpty
                          ? AppColors.outlineVariant
                          : AppColors.onSurface,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_drop_down, color: AppColors.outline),
                const SizedBox(width: AppSpacing.sm),
              ],
            ),
          ),
        ),
        if (birthDate != null) ...[
          const SizedBox(height: AppSpacing.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Usia Anda: ${_calculateAge(birthDate)} Tahun',
              style: AppTextStyles.labelMd.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }

  int _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int years = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      years--;
    }
    return years;
  }

  Future<void> _showDatePicker(
    BuildContext context,
    DateTime? current,
    OnboardingNotifier notifier,
  ) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime(now.year - 30),
      firstDate: DateTime(1920),
      lastDate: now,
      helpText: AppStrings.step8FieldHint,
      locale: const Locale('id', 'ID'),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: AppColors.primary,
                onPrimary: AppColors.onPrimary,
              ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      notifier.onBirthDateSelected(picked);
    }
  }
}
