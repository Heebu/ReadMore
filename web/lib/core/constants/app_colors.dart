import 'package:flartdart/flartdart.dart';

/// Centralized color palette for ReadMore following design tokens.
class AppColors {
  // Backgrounds
  static const darkBg = FlartColor('#090D16');
  static const darkSurface = FlartColor('#111827');
  static const darkCard = FlartColor('#131D2E');
  static const darkCardSecondary = FlartColor('#161F33');
  static const darkRibbon = FlartColor('#05080F');
  static const darkNav = FlartColor('#0D1424');
  static const darkBreaking = FlartColor('#1E1B4B');
  static const darkInput = FlartColor('#1E293B');

  static const lightBg = FlartColor('#F8FAFC');
  static const lightSurface = FlartColor('#FFFFFF');
  static const lightCard = FlartColor('#FFFFFF');
  static const lightRibbon = FlartColor('#EDE9FE');
  static const lightNav = FlartColor('#F1F5F9');
  static const lightInput = FlartColor('#F1F5F9');

  // Accents & Indicators
  static const primaryBlue = FlartColor('#3B82F6');
  static const primaryBlueHover = FlartColor('#2563EB');
  static const primaryBlueDark = FlartColor('#1D4ED8');
  static const primaryBlueLight = FlartColor('#60A5FA');
  static const primaryBlueSubtle = FlartColor('rgba(59, 130, 246, 0.15)');

  static const accentPurple = FlartColor('#8B5CF6');
  static const accentEmerald = FlartColor('#10B981');
  static const accentRed = FlartColor('#EF4444');
  static const accentAmber = FlartColor('#F59E0B');

  // Market & Status
  static const bullGreen = FlartColor('#10B981');
  static const bullGreenSubtle = FlartColor('rgba(16, 185, 129, 0.15)');
  static const bearRed = FlartColor('#EF4444');
  static const bearRedSubtle = FlartColor('rgba(239, 68, 68, 0.15)');

  // Borders
  static const borderSubtle = FlartColor('rgba(255, 255, 255, 0.08)');
  static const borderRegular = FlartColor('rgba(255, 255, 255, 0.12)');
  static const borderHighlighted = FlartColor('rgba(59, 130, 246, 0.3)');

  // Text
  static const textPrimaryDark = FlartColors.white;
  static const textPrimaryLight = FlartColors.black;
  static const textSecondary = FlartColor('#94A3B8');
  static const textMuted = FlartColor('#64748B');
  static const textSubtle = FlartColor('#CBD5E1');

  // Overlays
  static const modalBackdrop = FlartColor('rgba(0, 0, 0, 0.85)');
}
