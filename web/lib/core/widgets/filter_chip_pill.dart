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
              ? activeColor
              : (isDarkMode ? AppColors.darkCard : AppColors.lightCard),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? activeColor : AppColors.borderRegular,
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: FlartColor('rgba(59, 130, 246, 0.3)'),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: FDRow(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (iconOrEmoji != null) ...[
              FDText(iconOrEmoji!, style: const TextStyle(fontSize: 13)),
              const FDSizedBox(width: 6),
            ],
            FDText(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected
                    ? FlartColors.white
                    : (isDarkMode ? FlartColors.white : FlartColors.black),
              ),
            ),
            if (badge != null && badge != '0') ...[
              const FDSizedBox(width: 6),
              FDContainer(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryBlueDark : AppColors.primaryBlueSubtle,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: FDText(
                  badge!,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? FlartColors.white : AppColors.primaryBlueLight,
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
