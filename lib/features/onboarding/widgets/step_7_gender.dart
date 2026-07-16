import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_onboarding_question.dart';
import '../../../core/widgets/selection_card.dart';
import '../viewmodels/onboarding_notifier.dart';

class Step7Gender extends ConsumerWidget {
  const Step7Gender({super.key});

  static const _options = [
    ('Laki-laki', Icons.male),
    ('Perempuan', Icons.female),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(onboardingProvider.notifier);
    final gender = ref.watch(onboardingProvider.select((s) => s.gender));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppOnboardingQuestion(
          icon: Icons.wc,
          question: AppStrings.step7Title,
          iconBackgroundColor: AppColors.secondaryContainer,
        ),
        const SizedBox(height: AppSpacing.lg),
        ...List.generate(_options.length, (i) {
          final (value, icon) = _options[i];
          final isSelected = value == gender;
          return Padding(
            padding: EdgeInsets.only(
              bottom: i < _options.length - 1 ? AppSpacing.sm : 0,
            ),
            child: SelectionCard(
              label: value,
              isSelected: isSelected,
              isWide: true,
              icon: icon,
              onTap: () => notifier.onGenderSelected(value),
            ),
          );
        }),
        const SizedBox(height: AppSpacing.lg),
        Text(
          AppStrings.step7Subtitle,
          textAlign: TextAlign.center,
          style: AppTextStyles.labelMd.copyWith(
            color: AppColors.outline,
          ),
        ),
      ],
    );
  }
}
