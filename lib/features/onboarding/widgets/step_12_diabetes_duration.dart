import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_onboarding_question.dart';
import '../../../core/widgets/selection_card.dart';
import '../viewmodels/onboarding_notifier.dart';

class Step12DiabetesDuration extends ConsumerWidget {
  const Step12DiabetesDuration({super.key});

  static const _options = [
    (AppStrings.diabetesDurationLess1, Icons.looks_one_outlined),
    (AppStrings.diabetesDuration1to3, Icons.looks_two_outlined),
    (AppStrings.diabetesDuration4to6, Icons.looks_3_outlined),
    (AppStrings.diabetesDurationMore6, Icons.looks_4_outlined),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(onboardingProvider.notifier);
    final selected = ref.watch(
      onboardingProvider.select((s) => s.diabetesDuration),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppOnboardingQuestion(
          icon: Icons.bloodtype_rounded,
          question: AppStrings.diabetesDurationTitle,
          description: AppStrings.diabetesDurationSubtitle,
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
              onTap: () => notifier.onDiabetesDurationSelected(value),
            ),
          );
        }),
      ],
    );
  }
}
