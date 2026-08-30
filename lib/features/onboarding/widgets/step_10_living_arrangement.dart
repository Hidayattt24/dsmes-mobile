import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_onboarding_question.dart';
import '../../../core/widgets/selection_card.dart';
import '../viewmodels/onboarding_notifier.dart';

class Step10LivingArrangement extends ConsumerWidget {
  const Step10LivingArrangement({super.key});

  static const _options = [
    (AppStrings.livingAlone, Icons.person_outline),
    (AppStrings.livingFamily, Icons.groups_outlined),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(onboardingProvider.notifier);
    final selected = ref.watch(
      onboardingProvider.select((s) => s.livingArrangement),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppOnboardingQuestion(
          icon: Icons.people_outline,
          question: AppStrings.livingArrangementTitle,
          description: AppStrings.livingArrangementSubtitle,
          iconBackgroundColor: AppColors.secondaryContainer,
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
              onTap: () => notifier.onLivingArrangementSelected(value),
            ),
          );
        }),
      ],
    );
  }
}
