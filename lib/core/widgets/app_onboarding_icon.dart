import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class AppOnboardingIcon extends StatelessWidget {
  const AppOnboardingIcon({
    super.key,
    required this.icon,
    this.backgroundColor = AppColors.primaryFixed,
    this.iconColor = AppColors.primary,
    this.size = 64,
  });

  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppSpacing.md),
      ),
      child: Icon(icon, color: iconColor, size: size * 0.6),
    );
  }
}
