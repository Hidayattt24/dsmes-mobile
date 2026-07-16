import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Reusable onboarding progress header.
///
/// Shows back button, step label (e.g. "Langkah 3 dari 12"),
/// percentage, and an animated linear progress bar.
///
/// Used at the top of every onboarding step — never duplicated.
class AppProgressHeader extends StatelessWidget {
  const AppProgressHeader({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.onBack,
    this.showBackButton = true,
  });

  final int currentStep;
  final int totalSteps;
  final VoidCallback? onBack;
  final bool showBackButton;

  double get _progress => totalSteps > 0 ? currentStep / totalSteps : 0.0;

  String get _percentageLabel => '${(_progress * 100).round()}%';

  String get _stepLabel => 'Langkah $currentStep dari $totalSteps';

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _HeaderRow(
              stepLabel: _stepLabel,
              percentageLabel: _percentageLabel,
              onBack: onBack,
              showBackButton: showBackButton,
            ),
            const SizedBox(height: AppSpacing.sm),
            _ProgressBar(progress: _progress),
          ],
        ),
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({
    required this.stepLabel,
    required this.percentageLabel,
    this.onBack,
    required this.showBackButton,
  });

  final String stepLabel;
  final String percentageLabel;
  final VoidCallback? onBack;
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (showBackButton) ...[
          _BackButton(onBack: onBack),
          const SizedBox(width: AppSpacing.md),
        ],
        Expanded(
          child: Text(
            stepLabel,
            style: AppTextStyles.poppinsLabel,
          ),
        ),
        Text(
          percentageLabel,
          style: AppTextStyles.poppinsLabel.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Kembali',
      button: true,
      child: InkWell(
        onTap: onBack ?? () => Navigator.of(context).maybePop(),
        borderRadius: BorderRadius.circular(AppSpacing.lg),
        child: const Padding(
          padding: EdgeInsets.all(AppSpacing.xs),
          child: Icon(
            Icons.arrow_back,
            color: AppColors.onSurfaceVariant,
            size: 24,
          ),
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.xs),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: progress),
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeOut,
        builder: (context, value, child) => LinearProgressIndicator(
          value: value,
          minHeight: 8,
          backgroundColor: AppColors.surfaceContainerHighest,
          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondary),
        ),
      ),
    );
  }
}
