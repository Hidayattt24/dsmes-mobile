import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';

/// Reusable card container matching the HTML design system.
///
/// Uses [AppRadius.card] (24px), [AppShadows.soft], and design tokens.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.borderColor,
    this.hasShadow = true,
    this.hasBorder = true,
    this.borderWidth = 1.0,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final Color? borderColor;
  final bool hasShadow;
  final bool hasBorder;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? AppColors.surfaceContainerLowest,
        borderRadius: AppRadius.card,
        border: hasBorder
            ? Border.all(
                color: borderColor ?? AppColors.outlineVariant,
                width: borderWidth,
              )
            : null,
        boxShadow: hasShadow ? AppShadows.soft : null,
      ),
      child: Padding(
        padding: padding ??
            const EdgeInsets.all(AppSpacing.lg),
        child: child,
      ),
    );
  }
}
