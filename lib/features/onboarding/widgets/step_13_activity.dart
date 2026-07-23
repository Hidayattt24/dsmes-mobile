import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_onboarding_question.dart';
import '../viewmodels/onboarding_notifier.dart';

class Step13Activity extends ConsumerWidget {
  const Step13Activity({super.key});

  static const _options = [
    (AppStrings.step12Sedentary, AppStrings.step12SedentaryDesc),
    (AppStrings.step12LightlyActive, AppStrings.step12LightlyActiveDesc),
    (AppStrings.step12ModeratelyActive, AppStrings.step12ModeratelyActiveDesc),
    (AppStrings.step12Active, AppStrings.step12ActiveDesc),
    (AppStrings.step12VeryActive, AppStrings.step12VeryActiveDesc),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(onboardingProvider.notifier);
    final selected = ref.watch(onboardingProvider.select((s) => s.activityLevel));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppOnboardingQuestion(
          icon: Icons.directions_run,
          question: AppStrings.step12Title,
          description: AppStrings.step12Subtitle,
          iconBackgroundColor: AppColors.primaryFixed,
        ),
        const SizedBox(height: AppSpacing.lg),
        ...List.generate(_options.length, (i) {
          final (title, desc) = _options[i];
          final isSelected = title == selected;
          return Padding(
            padding: EdgeInsets.only(
              bottom: i < _options.length - 1 ? AppSpacing.sm : 0,
            ),
            child: _ActivityCard(
              title: title,
              description: desc,
              isSelected: isSelected,
              onTap: () => notifier.onActivitySelected(title),
            ),
          );
        }),
      ],
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryContainer
              : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.poppinsButton.copyWith(
                      color: isSelected
                          ? AppColors.onPrimary
                          : AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: AppTextStyles.labelMd.copyWith(
                      color: isSelected
                          ? AppColors.onPrimary.withValues(alpha: 0.85)
                          : AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected
                  ? AppColors.onPrimary
                  : AppColors.outlineVariant,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
