import 'package:flutter/material.dart';

/// Monochrome Broadsheet & Gazette color palette shared across ReadMore mobile & web.
///
/// Inspired by historic broadsheet ink on ivory paper (`#F7F5F0`) and
/// The Midnight Gazette lithograph Noir (`#0D0E11`).
class AppColors {
  AppColors._();

  // Broadsheet Ivory Paper (Light Mode)
  static const Color lightBg = Color(0xFFF7F5F0);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightCardSecondary = Color(0xFFFAF8F4);
  static const Color lightRibbon = Color(0xFFEBE7DC);
  static const Color lightNav = Color(0xFFE5E0D4);
  static const Color lightBreaking = Color(0xFF111111);
  static const Color lightInput = Color(0xFFEBE7DC);

  // Midnight Gazette Lithograph Noir (Dark Mode)
  static const Color darkBg = Color(0xFF0D0E11);
  static const Color darkSurface = Color(0xFF141519);
  static const Color darkCard = Color(0xFF1A1B20);
  static const Color darkCardSecondary = Color(0xFF212228);
  static const Color darkRibbon = Color(0xFF0A0B0D);
  static const Color darkNav = Color(0xFF121316);
  static const Color darkBreaking = Color(0xFF16171C);
  static const Color darkInput = Color(0xFF1A1B20);

  // Newspaper Ink Tokens
  static const Color inkBlack = Color(0xFF111111);
  static const Color inkDark = Color(0xFF1C1C1C);
  static const Color inkMedium = Color(0xFF4A4A48);
  static const Color inkLight = Color(0xFF73716B);
  static const Color inkFaint = Color(0xFFA3A096);

  // Broadsheet Paper Tokens
  static const Color paperWhite = Color(0xFFFFFFFF);
  static const Color paperIvory = Color(0xFFF7F5F0);
  static const Color paperCream = Color(0xFFEFECE4);
  static const Color paperMuted = Color(0xFFDCD8CE);
  static const Color paperDark = Color(0xFF26272E);

  // Monochromatic & Typographic Accents
  static const Color primaryInk = Color(0xFF111111);
  static const Color primaryInkLight = Color(0xFF444444);
  static const Color subtleWash = Color(0x1F808080);

  // Borders & Newspaper Rules
  static const Color borderSubtle = Color(0x38808080);
  static const Color borderRegular = Color(0x61808080);
  static const Color borderDarkCard = Color(0xFF33353F);
  static const Color borderLightCard = Color(0xFFD4CFBE);

  // Typography Helpers
  static const Color textPrimaryDark = Color(0xFFF4F3EE);
  static const Color textPrimaryLight = Color(0xFF111111);
  static const Color textSecondary = Color(0xFF6E6C66);
  static const Color textMuted = Color(0xFF8E8C85);
  static const Color textSubtle = Color(0xFFB5B3AC);

  // Semantic helpers keyed to dark/light mode
  static Color ink(bool isDark) => isDark ? textPrimaryDark : textPrimaryLight;
  static Color inkSecondary(bool isDark) =>
      isDark ? const Color(0xFFA8A69E) : const Color(0xFF5A5852);
  static Color paper(bool isDark) => isDark ? darkCard : lightCard;
  static Color paperSecondary(bool isDark) =>
      isDark ? darkCardSecondary : lightCardSecondary;
  static Color paperBg(bool isDark) => isDark ? darkBg : lightBg;
  static Color ribbonBg(bool isDark) => isDark ? darkRibbon : lightRibbon;
  static Color navBg(bool isDark) => isDark ? darkNav : lightNav;
  static Color surfaceBg(bool isDark) => isDark ? darkSurface : lightSurface;
  static Color inputBg(bool isDark) => isDark ? darkInput : lightInput;
  static Color rule(bool isDark) => isDark ? borderDarkCard : borderLightCard;
}
