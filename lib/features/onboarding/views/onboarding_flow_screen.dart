import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_progress_header.dart';
import '../viewmodels/onboarding_notifier.dart';
import '../widgets/onboarding_nav_buttons.dart';
import '../widgets/step_10_blood_type.dart';
import '../widgets/step_11_height.dart';
import '../widgets/step_12_weight.dart';
import '../widgets/step_13_activity.dart';
import '../widgets/step_14_summary.dart';
import '../widgets/step_1_name.dart';
import '../widgets/step_2_nickname.dart';
import '../widgets/step_3_email.dart';
import '../widgets/step_4_phone.dart';
import '../widgets/step_5_password.dart';
import '../widgets/step_6_confirm_password.dart';
import '../widgets/step_7_welcome_intro.dart';
import '../widgets/step_8_gender.dart';
import '../widgets/step_9_birthdate.dart';

class OnboardingFlowScreen extends ConsumerStatefulWidget {
  const OnboardingFlowScreen({super.key, required this.step});

  final int step;

  @override
  ConsumerState<OnboardingFlowScreen> createState() =>
      _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends ConsumerState<OnboardingFlowScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(onboardingProvider.notifier).goToStep(widget.step);
    });
  }

  void _handleNext() async {
    final notifier = ref.read(onboardingProvider.notifier);
    if (widget.step == 13) {
      final ok = await notifier.calculateCaloriesFromBackend();
      if (mounted) {
        if (ok) {
          notifier.nextStep();
          context.go('/onboarding/14');
        } else {
          final state = ref.read(onboardingProvider);
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      }
    } else if (widget.step == AppConstants.totalOnboardingSteps) {
      await notifier.finishOnboarding();
      final state = ref.read(onboardingProvider);
      if (mounted) {
        if (state.errorMessage == null) {
          context.go(RouteNames.dailyRoutineSetup);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } else {
      notifier.nextStep();
      context.go('/onboarding/${widget.step + 1}');
    }
  }


  void _handleBack() {
    final notifier = ref.read(onboardingProvider.notifier);
    if (widget.step > 1) {
      notifier.previousStep();
      context.go('/onboarding/${widget.step - 1}');
    } else {
      context.go(RouteNames.welcome);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          AppProgressHeader(
            currentStep: widget.step,
            totalSteps: AppConstants.totalOnboardingSteps,
            onBack: _handleBack,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 600),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.lg,
                  ),
                  child: _buildStep(widget.step),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: OnboardingNavButtons(
        currentStep: widget.step,
        totalSteps: AppConstants.totalOnboardingSteps,
        canProceed: state.canProceedCurrentStep,
        onNext: _handleNext,
        isLoading: state.isLoading,
        isLastStep: widget.step == AppConstants.totalOnboardingSteps,
      ),
    );
  }

  Widget _buildStep(int step) {
    return switch (step) {
      1 => const Step1Name(),
      2 => const Step2Nickname(),
      3 => const Step3Email(),
      4 => const Step4Phone(),
      5 => const Step5Password(),
      6 => const Step6ConfirmPassword(),
      7 => const Step7WelcomeIntro(),
      8 => const Step8Gender(),
      9 => const Step9Birthdate(),
      10 => const Step10BloodType(),
      11 => const Step11Height(),
      12 => const Step12Weight(),
      13 => const Step13Activity(),
      14 => const Step14Summary(),
      _ => const SizedBox.shrink(),
    };
  }
}
