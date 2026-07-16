import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// DSMES Aceh Text Styles.
/// Primary font: Plus Jakarta Sans (body, headline)
/// Display font: Poppins (numeric keypad, large display figures)
abstract final class AppTextStyles {
  AppTextStyles._();

  // ── Plus Jakarta Sans ──────────────────────────────────────────────────────

  /// 24px / 600 — page title
  static TextStyle get headlineLg => GoogleFonts.plusJakartaSans(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.5,
        color: AppColors.onSurface,
      );

  /// 20px / 600 — section heading
  static TextStyle get headlineMd => GoogleFonts.plusJakartaSans(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.5,
        color: AppColors.onSurface,
      );

  /// 18px / 600 — mobile headline (AppBar title)
  static TextStyle get headlineMdMobile => GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.44,
        color: AppColors.onSurface,
      );

  /// 16px / 400 — body large
  static TextStyle get bodyLg => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: AppColors.onSurface,
      );

  /// 14px / 400 — body medium
  static TextStyle get bodyMd => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: AppColors.onSurface,
      );

  /// 16px / 500 — label large (buttons, chips)
  static TextStyle get labelLg => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.5,
        color: AppColors.onSurface,
      );

  /// 14px / 500 — label medium (captions, tags)
  static TextStyle get labelMd => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.43,
        color: AppColors.onSurface,
      );

  // ── Poppins ────────────────────────────────────────────────────────────────

  /// 32px / 700 — display heading (used in keypad screens)
  static TextStyle get displayLg => GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.25,
        color: AppColors.primary,
      );

  /// 48px / 800 — large numeric display (keypad value)
  static TextStyle get numericDisplay => GoogleFonts.poppins(
        fontSize: 48,
        fontWeight: FontWeight.w800,
        height: 1.0,
        color: AppColors.primary,
      );

  /// 24px / 700 — headline poppins variant
  static TextStyle get poppinsHeadline => GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.5,
        color: AppColors.onSurface,
      );

  /// 16px / 600 — button poppins
  static TextStyle get poppinsButton => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.5,
        color: AppColors.onPrimary,
      );

  /// 14px / 500 — step label poppins
  static TextStyle get poppinsLabel => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.43,
        color: AppColors.onSurfaceVariant,
      );

  // ── TextTheme builder ──────────────────────────────────────────────────────

  /// Builds the full Material 3 TextTheme using Plus Jakarta Sans.
  static TextTheme buildTextTheme() {
    return GoogleFonts.plusJakartaSansTextTheme().copyWith(
      displayLarge: GoogleFonts.poppins(
        fontSize: 57,
        fontWeight: FontWeight.w400,
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 45,
        fontWeight: FontWeight.w400,
      ),
      displaySmall: GoogleFonts.poppins(
        fontSize: 36,
        fontWeight: FontWeight.w400,
      ),
      headlineLarge: headlineLg,
      headlineMedium: headlineMd,
      headlineSmall: headlineMdMobile,
      titleLarge: labelLg.copyWith(fontWeight: FontWeight.w600),
      titleMedium: labelMd.copyWith(fontWeight: FontWeight.w600),
      titleSmall: labelMd.copyWith(fontSize: 12),
      bodyLarge: bodyLg,
      bodyMedium: bodyMd,
      bodySmall: bodyMd.copyWith(fontSize: 12),
      labelLarge: labelLg,
      labelMedium: labelMd,
      labelSmall: labelMd.copyWith(fontSize: 11),
    );
  }
}
