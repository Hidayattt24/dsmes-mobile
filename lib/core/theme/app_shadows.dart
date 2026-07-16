import 'package:flutter/material.dart';

import 'app_colors.dart';

/// DSMES Aceh Shadow Tokens.
/// Soft tonal shadow using primary color tint at low opacity.
abstract final class AppShadows {
  AppShadows._();

  /// Subtle card elevation — matches HTML `soft-shadow` class.
  static const List<BoxShadow> soft = [
    BoxShadow(
      color: Color(0x0A00695c), // shadowPrimary at ~4% opacity
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  /// Medium elevation for floating elements (FAB, bottom bar).
  static const List<BoxShadow> medium = [
    BoxShadow(
      color: Color(0x1A00695c), // shadowPrimary at ~10% opacity
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  /// Button shadow — for primary action buttons.
  static List<BoxShadow> get button => [
        BoxShadow(
          color: AppColors.primaryContainer.withValues(alpha: 0.2),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];
}
