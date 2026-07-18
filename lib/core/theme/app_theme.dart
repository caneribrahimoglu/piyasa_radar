import 'package:flutter/material.dart';
import 'package:piyasa_radar/core/theme/app_colors.dart';
import 'package:piyasa_radar/core/theme/app_radius.dart';

abstract final class AppTheme {
  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.lightSeed,
      brightness: Brightness.light,
      primary: AppColors.lightPrimary,
      secondary: AppColors.lightSecondary,
      tertiary: AppColors.lightTertiary,
      error: AppColors.lightError,
      surface: AppColors.lightSurface,
    );

    return _base(colorScheme).copyWith(
      scaffoldBackgroundColor: AppColors.lightBackground,
      dividerColor: AppColors.lightOutline,
    );
  }

  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.darkSeed,
      brightness: Brightness.dark,
      primary: AppColors.darkPrimary,
      secondary: AppColors.darkSecondary,
      tertiary: AppColors.darkTertiary,
      error: AppColors.darkError,
      surface: AppColors.darkSurface,
    );

    return _base(colorScheme).copyWith(
      scaffoldBackgroundColor: AppColors.darkBackground,
      dividerColor: AppColors.darkOutline,
    );
  }

  static ThemeData _base(ColorScheme colorScheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: colorScheme.surfaceTint,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),
    );
  }
}
