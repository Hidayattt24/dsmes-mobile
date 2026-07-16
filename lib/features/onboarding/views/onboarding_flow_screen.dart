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
import '../widgets/step_10_height.dart';
import '../widgets/step_11_weight.dart';
import '../widgets/step_12_activity.dart';
import '../widgets/step_13_summary.dart';
import '../widgets/step_1_name.dart';
import '../widgets/step_2_email.dart';
import '../widgets/step_3_phone.dart';
import '../widgets/step_4_password.dart';
import '../widgets/step_5_confirm_password.dart';
import '../widgets/step_6_welcome_intro.dart';
import '../widgets/step_7_gender.dart';
import '../widgets/step_8_birthdate.dart';
import '../widgets/step_9_blood_type.dart';

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

  void _handleNext() {
    if (widget.step < AppConstants.totalOnboardingSteps) {
      context.go(RouteNames.onboardingStep(widget.step + 1));
    } else {
      context.go(RouteNames.dailyRoutineSetup);
    }
  }

  void _handleBack() {
    if (widget.step > 1) {
      context.go(RouteNames.onboardingStep(widget.step - 1));
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
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.05, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              ),
              child: KeyedSubtree(
                key: ValueKey(widget.step),
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.page,
                    AppSpacing.lg,
                    AppSpacing.page,
                    AppSpacing.xxl,
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
      2 => const Step2Email(),
      3 => const Step3Phone(),
      4 => const Step4Password(),
      5 => const Step5ConfirmPassword(),
      6 => const Step6WelcomeIntro(),
      7 => const Step7Gender(),
      8 => const Step8Birthdate(),
      9 => const Step9BloodType(),
      10 => const Step10Height(),
      11 => const Step11Weight(),
      12 => const Step12Activity(),
      13 => const Step13Summary(),
      _ => const SizedBox.shrink(),
    };
  }
}
