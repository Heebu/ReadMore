import 'package:flartdart/flartdart.dart';

/// Centralized Monochrome Broadsheet & Gazette color palette for ReadMore.
/// Inspired by 18th & 19th-century newspaper printing press aesthetics.
class AppColors {
  // Broadsheet Aged Newsprint Paper (Light Mode)
  static const lightBg = FlartColor('#F7F5F0'); // Authentic ivory broadsheet paper
  static const lightSurface = FlartColor('#FFFFFF'); // Clean paper
  static const lightCard = FlartColor('#FFFFFF'); // Broadsheet page sheet
  static const lightCardSecondary = FlartColor('#FAF8F4');
  static const lightRibbon = FlartColor('#EBE7DC'); // Folio header tape
  static const lightNav = FlartColor('#E5E0D4'); // Section index bar
  static const lightBreaking = FlartColor('#111111'); // Inverted black dispatch tape
  static const lightInput = FlartColor('#EBE7DC');

  // The Midnight Gazette Lithograph Noir (Dark Mode)
  static const darkBg = FlartColor('#0D0E11'); // Deep lithograph printer ink
  static const darkSurface = FlartColor('#141519'); // Dark press card surface
  static const darkCard = FlartColor('#1A1B20'); // Dark newsprint card
  static const darkCardSecondary = FlartColor('#212228');
  static const darkRibbon = FlartColor('#0A0B0D');
  static const darkNav = FlartColor('#121316');
  static const darkBreaking = FlartColor('#16171C');
  static const darkInput = FlartColor('#1A1B20');

  // Newspaper Ink Tokens
  static const inkBlack = FlartColor('#111111');
  static const inkDark = FlartColor('#1C1C1C');
  static const inkMedium = FlartColor('#4A4A48');
  static const inkLight = FlartColor('#73716B');
  static const inkFaint = FlartColor('#A3A096');

  // Broad-sheet Paper Tokens
  static const paperWhite = FlartColor('#FFFFFF');
  static const paperIvory = FlartColor('#F7F5F0');
  static const paperCream = FlartColor('#EFECE4');
  static const paperMuted = FlartColor('#DCD8CE');
  static const paperDark = FlartColor('#26272E');

  // Monochromatic Accents (Replacing bright neons with rich printer's ink & paper whites)
  static const primaryBlue = FlartColor('#111111'); // Bold printing press black
  static const primaryBlueHover = FlartColor('#282828');
  static const primaryBlueDark = FlartColor('#000000'); // Pitch ink black
  static const primaryBlueLight = FlartColor('#444444'); // Charcoal accent
  static const primaryBlueSubtle = FlartColor('rgba(128, 128, 128, 0.12)'); // Subtle ink wash

  static const accentPurple = FlartColor('#222222'); // Charcoal tone
  static const accentEmerald = FlartColor('#333333'); // Graphite tone
  static const accentRed = FlartColor('#111111'); // Monochromatic press accent
  static const accentAmber = FlartColor('#444444'); // Engraver gray

  // Market & Status (Classic Typographic Monochrome Cues)
  static const bullGreen = FlartColor('#111111');
  static const bullGreenSubtle = FlartColor('rgba(128, 128, 128, 0.1)');
  static const bearRed = FlartColor('#111111');
  static const bearRedSubtle = FlartColor('rgba(128, 128, 128, 0.1)');

  // Borders & Newspaper Rules (Hairlines and double-rules)
  static const borderSubtle = FlartColor('rgba(128, 128, 128, 0.22)');
  static const borderRegular = FlartColor('rgba(128, 128, 128, 0.38)');
  static const borderHighlighted = FlartColor('#111111');
  static const borderDouble = FlartColor('#111111');

  // Text / Typesetting
  static const textPrimaryDark = FlartColor('#F4F3EE'); // Antique newsprint white
  static const textPrimaryLight = FlartColor('#111111'); // Deep press ink
  static const textSecondary = FlartColor('#6E6C66'); // Muted typeset gray
  static const textMuted = FlartColor('#8E8C85'); // Subtitle / date gray
  static const textSubtle = FlartColor('#B5B3AC'); // Hairline caption gray

  // Overlays
  static const modalBackdrop = FlartColor('rgba(0, 0, 0, 0.88)');

  // Helper Methods for dynamic Light/Dark broadsheet ink & paper
  static FlartColor ink(bool isDark) => isDark ? const FlartColor('#F4F3EE') : const FlartColor('#111111');
  static FlartColor inkSecondary(bool isDark) => isDark ? const FlartColor('#A8A69E') : const FlartColor('#5A5852');
  static FlartColor paper(bool isDark) => isDark ? const FlartColor('#1A1B20') : const FlartColor('#FFFFFF');
  static FlartColor paperBg(bool isDark) => isDark ? const FlartColor('#0D0E11') : const FlartColor('#F7F5F0');
  static FlartColor cardBorder(bool isDark) => isDark ? const FlartColor('rgba(255, 255, 255, 0.16)') : const FlartColor('rgba(0, 0, 0, 0.2)');
}
