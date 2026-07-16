import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_onboarding_question.dart';
import '../../../core/widgets/selection_card.dart';
import '../viewmodels/onboarding_notifier.dart';

class Step9BloodType extends ConsumerWidget {
  const Step9BloodType({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(onboardingProvider.notifier);
    final bloodType = ref.watch(onboardingProvider.select((s) => s.bloodType));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppOnboardingQuestion(
          icon: Icons.bloodtype_outlined,
          question: AppStrings.step9Title,
          description: AppStrings.step9Subtitle,
          iconBackgroundColor: AppColors.primaryFixed,
        ),
        const SizedBox(height: AppSpacing.lg),
        ...List.generate(AppConstants.bloodTypes.length, (i) {
          final type = AppConstants.bloodTypes[i];
          final isSelected = type == bloodType;
          final isWide = type.length > 4;
          return Padding(
            padding: EdgeInsets.only(
              bottom:
                  i < AppConstants.bloodTypes.length - 1 ? AppSpacing.sm : 0,
            ),
            child: SelectionCard(
              label: type,
              isSelected: isSelected,
              isWide: isWide,
              subtitle: isWide ? null : 'Golongan $type',
              onTap: () => notifier.onBloodTypeSelected(type),
            ),
          );
        }),
      ],
    );
  }
}
