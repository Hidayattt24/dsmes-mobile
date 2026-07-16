import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_text_styles.dart';

/// DSMES Aceh App Theme.
/// Uses Material 3 with the exact color tokens from the design system.
abstract final class AppTheme {
  AppTheme._();

  static ColorScheme get _lightColorScheme => const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.onPrimaryContainer,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        secondaryContainer: AppColors.secondaryContainer,
        onSecondaryContainer: AppColors.onSecondaryContainer,
        tertiary: AppColors.tertiary,
        onTertiary: AppColors.onTertiary,
        tertiaryContainer: AppColors.tertiaryContainer,
        onTertiaryContainer: AppColors.onTertiaryContainer,
        error: AppColors.error,
        onError: AppColors.onError,
        errorContainer: AppColors.errorContainer,
        onErrorContainer: AppColors.onErrorContainer,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        onSurfaceVariant: AppColors.onSurfaceVariant,
        outline: AppColors.outline,
        outlineVariant: AppColors.outlineVariant,
        shadow: Color(0xFF000000),
        inverseSurface: AppColors.inverseSurface,
        onInverseSurface: AppColors.inverseOnSurface,
        inversePrimary: AppColors.inversePrimary,
        surfaceTint: AppColors.surfaceTint,
      );

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: _lightColorScheme,
        scaffoldBackgroundColor: AppColors.surface,
        textTheme: AppTextStyles.buildTextTheme(),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.surfaceContainerLowest,
          foregroundColor: AppColors.onSurface,
          elevation: 0,
          scrolledUnderElevation: 1,
          centerTitle: true,
          titleTextStyle: AppTextStyles.headlineMdMobile,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryContainer,
            foregroundColor: AppColors.onPrimary,
            minimumSize: const Size(double.infinity, 56),
            shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
            textStyle: AppTextStyles.labelLg,
            elevation: 0,
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primaryContainer,
            foregroundColor: AppColors.onPrimary,
            minimumSize: const Size(double.infinity, 56),
            shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
            textStyle: AppTextStyles.labelLg,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.outline),
            minimumSize: const Size(double.infinity, 56),
            shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
            textStyle: AppTextStyles.labelLg,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceContainerLowest,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: const OutlineInputBorder(
            borderRadius: AppRadius.input,
            borderSide: BorderSide(color: AppColors.outlineVariant),
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: AppRadius.input,
            borderSide: BorderSide(color: AppColors.outlineVariant),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: AppRadius.input,
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: const OutlineInputBorder(
            borderRadius: AppRadius.input,
            borderSide: BorderSide(color: AppColors.error),
          ),
          focusedErrorBorder: const OutlineInputBorder(
            borderRadius: AppRadius.input,
            borderSide: BorderSide(color: AppColors.error, width: 2),
          ),
          labelStyle: AppTextStyles.labelMd
              .copyWith(color: AppColors.onSurfaceVariant),
          hintStyle: AppTextStyles.bodyMd
              .copyWith(color: AppColors.outline),
          errorStyle: AppTextStyles.labelMd
              .copyWith(color: AppColors.error, fontSize: 12),
        ),
        cardTheme: const CardThemeData(
          color: AppColors.surfaceContainerLowest,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
          margin: EdgeInsets.zero,
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.outlineVariant,
          thickness: 1,
          space: 0,
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: AppColors.secondary,
          linearTrackColor: AppColors.surfaceContainerHighest,
          linearMinHeight: 8,
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.inverseSurface,
          contentTextStyle: AppTextStyles.bodyMd
              .copyWith(color: AppColors.inverseOnSurface),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
        ),
        textTheme: AppTextStyles.buildTextTheme(),
      );
}
