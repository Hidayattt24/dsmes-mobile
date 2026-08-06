import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_numeric_keypad.dart';
import '../../../core/widgets/app_onboarding_question.dart';
import '../viewmodels/onboarding_notifier.dart';

class Step12Weight extends ConsumerWidget {
  const Step12Weight({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(onboardingProvider.notifier);
    final weight = ref.watch(onboardingProvider.select((s) => s.weightKg));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppOnboardingQuestion(
          icon: Icons.monitor_weight_outlined,
          question: AppStrings.step11Title,
          description: AppStrings.step11Subtitle,
          iconBackgroundColor: AppColors.primaryFixed,
        ),
        const SizedBox(height: AppSpacing.lg),
        AppNumericDisplay(
          value: weight,
          unit: AppStrings.step11Unit,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Gunakan papan ketik di bawah untuk memasukkan berat badan Anda saat ini.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMd.copyWith(
            color: AppColors.outline,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppNumericKeypad(
          onKeyTapped: notifier.onWeightKeyTapped,
          onBackspace: notifier.onWeightBackspace,
        ),
      ],
    );
  }
}
