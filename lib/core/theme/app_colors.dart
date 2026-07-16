import 'package:flutter/material.dart';

/// DSMES Aceh Color Tokens — extracted from HTML design system.
/// Source: Tailwind config in registration screens.
/// All colors follow Material 3 naming conventions.
abstract final class AppColors {
  AppColors._();

  // ── Primary ────────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF004f45);
  static const Color onPrimary = Color(0xFFffffff);
  static const Color primaryContainer = Color(0xFF00695c);
  static const Color onPrimaryContainer = Color(0xFF94e5d5);
  static const Color primaryFixed = Color(0xFFa0f2e1);
  static const Color primaryFixedDim = Color(0xFF84d5c5);
  static const Color onPrimaryFixed = Color(0xFF00201b);
  static const Color onPrimaryFixedVariant = Color(0xFF005046);
  static const Color inversePrimary = Color(0xFF84d5c5);

  // ── Secondary ──────────────────────────────────────────────────────────────
  static const Color secondary = Color(0xFF286b33);
  static const Color onSecondary = Color(0xFFffffff);
  static const Color secondaryContainer = Color(0xFFabf4ac);
  static const Color onSecondaryContainer = Color(0xFF2e7238);
  static const Color secondaryFixed = Color(0xFFabf4ac);
  static const Color secondaryFixedDim = Color(0xFF90d792);
  static const Color onSecondaryFixed = Color(0xFF002107);
  static const Color onSecondaryFixedVariant = Color(0xFF07521d);

  // ── Tertiary ───────────────────────────────────────────────────────────────
  static const Color tertiary = Color(0xFF613e00);
  static const Color onTertiary = Color(0xFFffffff);
  static const Color tertiaryContainer = Color(0xFF815300);
  static const Color onTertiaryContainer = Color(0xFFffce8d);
  static const Color tertiaryFixed = Color(0xFFffddb4);
  static const Color tertiaryFixedDim = Color(0xFFffb954);
  static const Color onTertiaryFixed = Color(0xFF291800);
  static const Color onTertiaryFixedVariant = Color(0xFF633f00);

  // ── Surface ────────────────────────────────────────────────────────────────
  static const Color surface = Color(0xFFfbf9f8);
  static const Color surfaceBright = Color(0xFFfbf9f8);
  static const Color surfaceDim = Color(0xFFdcd9d9);
  static const Color surfaceContainerLowest = Color(0xFFffffff);
  static const Color surfaceContainerLow = Color(0xFFf5f3f3);
  static const Color surfaceContainer = Color(0xFFf0eded);
  static const Color surfaceContainerHigh = Color(0xFFeae8e7);
  static const Color surfaceContainerHighest = Color(0xFFe4e2e1);
  static const Color surfaceVariant = Color(0xFFe4e2e1);
  static const Color surfaceTint = Color(0xFF046b5e);
  static const Color inverseSurface = Color(0xFF303030);
  static const Color inverseOnSurface = Color(0xFFf2f0f0);

  // ── On Surface ─────────────────────────────────────────────────────────────
  static const Color onSurface = Color(0xFF1b1c1c);
  static const Color onSurfaceVariant = Color(0xFF3e4946);
  static const Color onBackground = Color(0xFF1b1c1c);
  static const Color background = Color(0xFFfbf9f8);

  // ── Outline ────────────────────────────────────────────────────────────────
  static const Color outline = Color(0xFF6e7976);
  static const Color outlineVariant = Color(0xFFbec9c5);

  // ── Error ──────────────────────────────────────────────────────────────────
  static const Color error = Color(0xFFba1a1a);
  static const Color onError = Color(0xFFffffff);
  static const Color errorContainer = Color(0xFFffdad6);
  static const Color onErrorContainer = Color(0xFF93000a);

  // ── Tonal shadow base ──────────────────────────────────────────────────────
  static const Color shadowPrimary = Color(0xFF00695c);
}
