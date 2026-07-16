import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Button variants supported by [AppButton].
enum AppButtonVariant {
  /// Filled teal button — primary actions.
  primary,

  /// Outlined button — secondary actions.
  outlined,

  /// Text-only button — tertiary/link actions.
  text,
}

/// Reusable button component for DSMES Aceh.
///
/// Uses theme tokens exclusively — no hardcoded values.
/// Supports loading state, icons, and full-width layout.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.trailingIcon,
    this.height = 56.0,
    this.borderRadius,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final IconData? trailingIcon;
  final double height;
  final BorderRadiusGeometry? borderRadius;

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null || isLoading;
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: height,
      child: switch (variant) {
        AppButtonVariant.primary => _PrimaryButton(
            label: label,
            onPressed: isDisabled ? null : onPressed,
            isLoading: isLoading,
            icon: icon,
            trailingIcon: trailingIcon,
            borderRadius: borderRadius,
          ),
        AppButtonVariant.outlined => _OutlinedButton(
            label: label,
            onPressed: isDisabled ? null : onPressed,
            isLoading: isLoading,
            icon: icon,
            trailingIcon: trailingIcon,
          ),
        AppButtonVariant.text => _TextButton(
            label: label,
            onPressed: isDisabled ? null : onPressed,
            icon: icon,
          ),
      },
    );
  }
}

// ── Private button variants ────────────────────────────────────────────────

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    this.onPressed,
    required this.isLoading,
    this.icon,
    this.trailingIcon,
    this.borderRadius,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final IconData? trailingIcon;
  final BorderRadiusGeometry? borderRadius;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? AppRadius.button;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: onPressed != null ? AppShadows.button : [],
      ),
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primaryContainer,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor:
              AppColors.primaryContainer.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(borderRadius: radius),
        ),
        child: _ButtonContent(
          label: label,
          isLoading: isLoading,
          icon: icon,
          trailingIcon: trailingIcon,
          textStyle: AppTextStyles.poppinsButton,
        ),
      ),
    );
  }
}

class _OutlinedButton extends StatelessWidget {
  const _OutlinedButton({
    required this.label,
    this.onPressed,
    required this.isLoading,
    this.icon,
    this.trailingIcon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final IconData? trailingIcon;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary, width: 1.5),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
      ),
      child: _ButtonContent(
        label: label,
        isLoading: isLoading,
        icon: icon,
        trailingIcon: trailingIcon,
        textStyle: AppTextStyles.labelLg.copyWith(color: AppColors.primary),
      ),
    );
  }
}

class _TextButton extends StatelessWidget {
  const _TextButton({
    required this.label,
    this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(
            label,
            style: AppTextStyles.labelLg.copyWith(color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

class _ButtonContent extends StatelessWidget {
  const _ButtonContent({
    required this.label,
    required this.isLoading,
    required this.textStyle,
    this.icon,
    this.trailingIcon,
  });

  final String label;
  final bool isLoading;
  final TextStyle textStyle;
  final IconData? icon;
  final IconData? trailingIcon;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: AppColors.onPrimary,
        ),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20),
          const SizedBox(width: AppSpacing.xs),
        ],
        Text(label, style: textStyle),
        if (trailingIcon != null) ...[
          const SizedBox(width: AppSpacing.xs),
          Icon(trailingIcon, size: 20),
        ],
      ],
    );
  }
}
