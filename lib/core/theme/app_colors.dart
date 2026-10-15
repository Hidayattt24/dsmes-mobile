import 'package:flutter/material.dart';

/// DSMES Aceh Color Tokens — extracted from HTML design system.
/// Source: Tailwind config in registration screens.
/// All colors follow Material 3 naming conventions.
abstract final class AppColors {
  AppColors._();

  // ── Primary ────────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF3B67FC);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF1A63ED);
  static const Color onPrimaryContainer = Color(0xFFB9F5FB);
  static const Color primaryFixed = Color(0xFF07CADE);
  static const Color primaryFixedDim = Color(0xFF07CADE);
  static const Color onPrimaryFixed = Color(0xFF001B6B);
  static const Color onPrimaryFixedVariant = Color(0xFF001F60);
  static const Color inversePrimary = Color(0xFF07CADE);

  // ── Secondary ──────────────────────────────────────────────────────────────
  static const Color secondary = Color(0xFF07CADE);
  static const Color onSecondary = Color(0xFF001B6B);
  static const Color secondaryContainer = Color(0xFFB9F5FB);
  static const Color onSecondaryContainer = Color(0xFF001F60);
  static const Color secondaryFixed = Color(0xFFB9F5FB);
  static const Color secondaryFixedDim = Color(0xFF07CADE);
  static const Color onSecondaryFixed = Color(0xFF001B6B);
  static const Color onSecondaryFixedVariant = Color(0xFF001F60);

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
  static const Color surfaceTint = Color(0xFF3B67FC);
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

  // ── Semantic status colors ───────────────────────────────────────────────
  static const Color success = Color(0xFF388E3C);
  static const Color successContainer = Color(0xFFE8F5E9);
  static const Color onSuccessContainer = Color(0xFF1B5E20);
  static const Color warning = Color(0xFFD97706);
  static const Color warningContainer = Color(0xFFFEF3C7);
  static const Color onWarningContainer = Color(0xFF92400E);
  static const Color info = Color(0xFF0284C7);
  static const Color infoContainer = Color(0xFFF0F9FF);
  static const Color onInfoContainer = Color(0xFF075985);

  // ── Tonal shadow base ──────────────────────────────────────────────────────
  static const Color shadowPrimary = Color(0xFF3B67FC);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF00C0F3), Color(0xFF1A63ED), Color(0xFF001F60)],
    stops: [0.0692, 0.8556, 1.0],
  );
}
