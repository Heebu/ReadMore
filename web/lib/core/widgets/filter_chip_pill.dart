import 'package:flartdart/flartdart.dart';
import '../constants/app_colors.dart';

/// Reusable pill chip for category selection, city switching, sector filters,
/// sub-tabs, tags, and topic customization.
class FilterChipPill extends StatelessWidget {
  final String label;
  final String? iconOrEmoji;
  final String? badge;
  final bool isSelected;
  final VoidCallback onTap;
  final FlartColor activeColor;
  final bool isDarkMode;
  final EdgeInsets padding;

  const FilterChipPill({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.iconOrEmoji,
    this.badge,
    this.activeColor = AppColors.primaryBlue,
    this.isDarkMode = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FDGestureDetector(
      onTap: onTap,
      child: FDContainer(
        margin: const EdgeInsets.only(right: 8),
        padding: padding,
        cssStyle: const {
          'transition': 'all 0.22s cubic-bezier(0.16, 1, 0.3, 1)',
          'cursor': 'pointer',
        },
        decoration: BoxDecoration(
          color: isSelected
              ? (isDarkMode ? FlartColors.white : FlartColors.black)
              : (isDarkMode ? const FlartColor('#18191F') : const FlartColor('#FAF9F5')),
          borderRadius: BorderRadius.circular(3),
          border: Border.all(
            color: isSelected
                ? (isDarkMode ? FlartColors.white : FlartColors.black)
                : (isDarkMode ? const FlartColor('#2D2F38') : const FlartColor('#C8C4B6')),
            width: 1,
          ),
        ),
        child: FDRow(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (iconOrEmoji != null) ...[
              FDText(iconOrEmoji!, style: const TextStyle(fontSize: 12)),
              const FDSizedBox(width: 5),
            ],
            FDText(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                fontFamily: 'Space Grotesk',
                letterSpacing: 0.06,
                color: isSelected
                    ? (isDarkMode ? FlartColors.black : FlartColors.white)
                    : (isDarkMode ? const FlartColor('#EAE8E0') : const FlartColor('#222222')),
              ),
            ),
            if (badge != null && badge != '0') ...[
              const FDSizedBox(width: 6),
              FDContainer(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDarkMode ? const FlartColor('#E2DFD2') : const FlartColor('#222222'))
                      : (isDarkMode ? const FlartColor('#2A2B33') : const FlartColor('#E2DFD2')),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: FDText(
                  badge!,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Space Grotesk',
                    color: isSelected
                        ? (isDarkMode ? FlartColors.black : FlartColors.white)
                        : (isDarkMode ? FlartColors.white : FlartColors.black),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
