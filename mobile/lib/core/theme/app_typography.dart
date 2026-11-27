import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Broadsheet typography tokens mirroring the web client's Google Fonts stack:
/// Cinzel, UnifrakturMaguntia, Playfair Display, Newsreader, Space Grotesk,
/// and Plus Jakarta Sans.
class AppTypography {
  AppTypography._();

  static TextStyle masthead({
    required double fontSize,
    required Color color,
    FontWeight fontWeight = FontWeight.w900,
    double letterSpacing = 0.04,
  }) {
    return GoogleFonts.cinzel(
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      color: color,
    );
  }

  static TextStyle blackletterSeal({
    required double fontSize,
    required Color color,
  }) {
    return GoogleFonts.unifrakturMaguntia(
      fontSize: fontSize,
      color: color,
    );
  }

  static TextStyle displayHeadline({
    required double fontSize,
    required Color color,
    FontWeight fontWeight = FontWeight.w800,
    double height = 1.16,
    double letterSpacing = -0.02,
    FontStyle fontStyle = FontStyle.normal,
  }) {
    return GoogleFonts.playfairDisplay(
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      letterSpacing: letterSpacing,
      fontStyle: fontStyle,
      color: color,
    );
  }

  static TextStyle editorialBody({
    required double fontSize,
    required Color color,
    FontWeight fontWeight = FontWeight.w400,
    double height = 1.65,
    FontStyle fontStyle = FontStyle.normal,
  }) {
    return GoogleFonts.newsreader(
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      fontStyle: fontStyle,
      color: color,
    );
  }

  static TextStyle deskLabel({
    required double fontSize,
    required Color color,
    FontWeight fontWeight = FontWeight.w800,
    double letterSpacing = 0.08,
    TextDecoration? decoration,
  }) {
    return GoogleFonts.spaceGrotesk(
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      color: color,
      decoration: decoration,
    );
  }

  static TextStyle uiSans({
    required double fontSize,
    required Color color,
    FontWeight fontWeight = FontWeight.w500,
    double height = 1.4,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      color: color,
    );
  }

  static TextTheme buildTextTheme(bool isDark) {
    final primary = AppColors.ink(isDark);
    final secondary = AppColors.inkSecondary(isDark);
    return TextTheme(
      displayLarge: masthead(fontSize: 30, color: primary),
      headlineMedium: displayHeadline(fontSize: 22, color: primary),
      titleLarge: displayHeadline(fontSize: 18, color: primary),
      titleMedium: deskLabel(fontSize: 13, color: primary),
      bodyLarge: editorialBody(fontSize: 16, color: primary),
      bodyMedium: editorialBody(fontSize: 14, color: secondary),
      labelLarge: deskLabel(fontSize: 11, color: primary),
      labelSmall: deskLabel(fontSize: 10, color: secondary),
    );
  }
}
