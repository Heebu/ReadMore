import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

/// Builds ReadMore Material 3 themes aligned with the monochrome broadsheet web design.
class AppTheme {
  AppTheme._();

  static ThemeData light() => _build(isDark: false);
  static ThemeData dark() => _build(isDark: true);

  static ThemeData _build({required bool isDark}) {
    final bg = AppColors.paperBg(isDark);
    final surface = AppColors.paper(isDark);
    final ink = AppColors.ink(isDark);
    final secondaryInk = AppColors.inkSecondary(isDark);
    final rule = AppColors.rule(isDark);

    final colorScheme = isDark
        ? ColorScheme.dark(
            primary: AppColors.textPrimaryDark,
            onPrimary: AppColors.inkBlack,
            secondary: const Color(0xFFCCCCCC),
            onSecondary: AppColors.inkBlack,
            surface: surface,
            onSurface: ink,
            outline: rule,
          )
        : ColorScheme.light(
            primary: AppColors.inkBlack,
            onPrimary: AppColors.paperWhite,
            secondary: AppColors.inkMedium,
            onSecondary: AppColors.paperWhite,
            surface: surface,
            onSurface: ink,
            outline: rule,
          );

    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: bg,
      cardColor: surface,
      dividerColor: rule,
      textTheme: AppTypography.buildTextTheme(isDark),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surfaceBg(isDark),
        foregroundColor: ink,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      dividerTheme: DividerThemeData(
        color: rule,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputBg(isDark),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: BorderSide(color: rule),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: BorderSide(color: rule),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: BorderSide(color: ink, width: 1.5),
        ),
        hintStyle: AppTypography.uiSans(fontSize: 13, color: secondaryInk),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? AppColors.textPrimaryDark : AppColors.inkBlack,
        contentTextStyle: AppTypography.uiSans(
          fontSize: 12,
          color: isDark ? AppColors.inkBlack : AppColors.paperWhite,
          fontWeight: FontWeight.w600,
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
