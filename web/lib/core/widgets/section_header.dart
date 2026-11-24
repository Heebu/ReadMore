import 'package:flartdart/flartdart.dart';
import '../constants/app_colors.dart';

/// Reusable section title banner with vertical colored accent bar,
/// optional subtitle, and custom trailing action or live-status pill.
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final FlartColor accentColor;
  final bool isDarkMode;

  const SectionHeader({
    required this.title,
    this.subtitle,
    this.trailing,
    this.accentColor = AppColors.primaryBlue,
    this.isDarkMode = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FDRow(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Accent Bar & Title Block
        FDRow(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FDContainer(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const FDSizedBox(width: 10),
            FDColumn(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                FDText(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: isDarkMode ? FlartColors.white : FlartColors.black,
                  ),
                ),
                if (subtitle != null) ...[
                  const FDSizedBox(height: 2),
                  FDText(
                    subtitle!,
                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ],
            ),
          ],
        ),

        // Optional Trailing Action or Indicator
        if (trailing != null) trailing!,
      ],
    );
  }
}
