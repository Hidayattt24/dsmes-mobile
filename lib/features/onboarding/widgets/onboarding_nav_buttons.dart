import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class OnboardingNavButtons extends StatelessWidget {
  const OnboardingNavButtons({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.canProceed,
    required this.onNext,
    this.isLoading = false,
    this.isLastStep = false,
  });

  final int currentStep;
  final int totalSteps;
  final bool canProceed;
  final VoidCallback? onNext;
  final bool isLoading;
  final bool isLastStep;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.md,
        AppSpacing.page,
        AppSpacing.lg + bottomPadding,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.surface.withValues(alpha: 0),
            AppColors.surface,
          ],
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: canProceed && !isLoading ? onNext : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryContainer,
            foregroundColor: AppColors.onPrimary,
            disabledBackgroundColor: AppColors.primaryContainer.withValues(alpha: 0.5),
            disabledForegroundColor: AppColors.onPrimary.withValues(alpha: 0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
            shadowColor: AppColors.primaryContainer.withValues(alpha: 0.2),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.onPrimary,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isLastStep
                          ? AppStrings.step13ButtonCreate
                          : AppStrings.buttonNext,
                      style: AppTextStyles.poppinsButton,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Icon(
                      isLastStep ? Icons.check_circle_outline : Icons.arrow_forward,
                      size: 20,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
