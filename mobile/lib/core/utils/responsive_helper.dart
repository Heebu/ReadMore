import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Responsive viewport & ScreenUtil helpers tailored for phones, foldables,
/// and tablet two-page open-book broadsheet spreads.
class ResponsiveHelper {
  ResponsiveHelper._();

  static const Size phoneDesignSize = Size(390, 844);
  static const Size tabletDesignSize = Size(834, 1194);

  /// Chooses the `ScreenUtil` baseline from the device's physical shortest side
  /// so fonts and paddings scale naturally across both phones and tablets.
  static Size designSizeFor(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= 600 ? tabletDesignSize : phoneDesignSize;
  }

  static bool isPhone(BuildContext context) =>
      MediaQuery.sizeOf(context).width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 600;

  /// Returns true when the viewport is wide enough to present a two-page
  /// open-book broadsheet spread (tablets, foldables, and landscape desktops).
  static bool isBookSpread(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 720;

  /// Safe horizontal gutter adapting cleanly between phone and book layouts.
  static double pagePadding(BuildContext context) =>
      isTablet(context) ? 20.w.clamp(16, 28) : 14.w.clamp(12, 18);

  /// Clamps scaled font sizes to preserve broadsheet legibility across extremes.
  static double sp(double value, {double min = 9, double max = 40}) =>
      value.sp.clamp(min, max).toDouble();
}
