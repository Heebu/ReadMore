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
    return FDContainer(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDarkMode ? const FlartColor('#33353F') : const FlartColor('#111111'),
            width: 2,
          ),
          top: BorderSide(
            color: isDarkMode ? const FlartColor('#262830') : const FlartColor('#D4CFBE'),
            width: 1,
          ),
        ),
      ),
      child: FDRow(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FDRow(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FDText(
                '✦ ',
                style: TextStyle(
                  fontSize: 12,
                  color: isDarkMode ? const FlartColor('#A2A096') : const FlartColor('#4A4842'),
                ),
              ),
              FDColumn(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  FDText(
                    title.toUpperCase(),
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Playfair Display',
                      letterSpacing: 0.06,
                      color: isDarkMode ? const FlartColor('#F4F3EE') : const FlartColor('#111111'),
                    ),
                  ),
                  if (subtitle != null) ...[
                    const FDSizedBox(height: 2),
                    FDText(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 11,
                        fontFamily: 'Newsreader',
                        color: isDarkMode ? AppColors.textSecondary : const FlartColor('#6E6C66'),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),

          // Optional Trailing Action or Indicator
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
