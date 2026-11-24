import 'package:flartdart/flartdart.dart';
import '../constants/app_colors.dart';

/// Reusable interaction pill for actions (Bookmarks, Queue, Likes, Share).
class InteractionPill extends StatelessWidget {
  final dynamic icon;
  final String label;
  final FlartColor color;
  final VoidCallback onTap;
  final bool isDarkMode;

  const InteractionPill({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.isDarkMode = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FDGestureDetector(
      onTap: onTap,
      child: FDContainer(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.borderSubtle : AppColors.lightNav,
          borderRadius: BorderRadius.circular(16),
        ),
        cssStyle: const {
          'transition': 'transform 0.18s cubic-bezier(0.16, 1, 0.3, 1), background-color 0.2s ease',
          'cursor': 'pointer',
        },
        child: FDRow(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FDIcon(icon: icon, size: 14, color: color),
            const FDSizedBox(width: 4),
            FDText(
              label,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
