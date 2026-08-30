import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_onboarding_question.dart';
import '../../../core/widgets/selection_card.dart';
import '../viewmodels/onboarding_notifier.dart';

class Step11Education extends ConsumerWidget {
  const Step11Education({super.key});

  static const _options = [
    (AppStrings.educationNoSchool, Icons.block),
    (AppStrings.educationSD, Icons.school_outlined),
    (AppStrings.educationSMP, Icons.school_outlined),
    (AppStrings.educationSMK, Icons.school_outlined),
    (AppStrings.educationD3, Icons.account_balance_outlined),
    (AppStrings.educationS1, Icons.account_balance_outlined),
    (AppStrings.educationS2S3, Icons.workspace_premium_outlined),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(onboardingProvider.notifier);
    final selected = ref.watch(
      onboardingProvider.select((s) => s.educationLevel),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppOnboardingQuestion(
          icon: Icons.menu_book_outlined,
          question: AppStrings.educationTitle,
          description: AppStrings.educationSubtitle,
          iconBackgroundColor: AppColors.primaryFixed,
        ),
        const SizedBox(height: AppSpacing.lg),
        ...List.generate(_options.length, (i) {
          final (value, icon) = _options[i];
          final isSelected = value == selected;
          return Padding(
            padding: EdgeInsets.only(
              bottom: i < _options.length - 1 ? AppSpacing.sm : 0,
            ),
            child: SelectionCard(
              label: value,
              isSelected: isSelected,
              isWide: true,
              icon: icon,
              onTap: () => notifier.onEducationSelected(value),
            ),
          );
        }),
      ],
    );
  }
}
