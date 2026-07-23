import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_numeric_keypad.dart';
import '../../../core/widgets/app_onboarding_question.dart';
import '../viewmodels/onboarding_notifier.dart';

class Step11Height extends ConsumerWidget {
  const Step11Height({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(onboardingProvider.notifier);
    final height = ref.watch(onboardingProvider.select((s) => s.heightCm));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppOnboardingQuestion(
          icon: Icons.height,
          question: AppStrings.step10Title,
          description: AppStrings.step10Subtitle,
          iconBackgroundColor: AppColors.primaryFixed,
        ),
        const SizedBox(height: AppSpacing.lg),
        AppNumericDisplay(value: height, unit: AppStrings.step10Unit),
        const SizedBox(height: AppSpacing.xl),
        AppNumericKeypad(
          onKeyTapped: notifier.onHeightKeyTapped,
          onBackspace: notifier.onHeightBackspace,
        ),
      ],
    );
  }
}
