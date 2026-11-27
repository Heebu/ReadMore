import 'package:flartdart/flartdart.dart';
import 'package:news_models/news_models.dart';
import '../constants/app_colors.dart';

/// Reusable publisher metadata bar with favicon, publisher name, timestamp,
/// and optional category and reading-time indicator.
class ArticleMetaBar extends StatelessWidget {
  final NewsSource source;
  final String timestamp;
  final String? category;
  final int? readTimeMinutes;
  final bool isDarkMode;
  final bool isCompact;

  const ArticleMetaBar({
    required this.source,
    this.timestamp = '25m ago',
    this.category,
    this.readTimeMinutes,
    this.isDarkMode = true,
    this.isCompact = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final iconSize = isCompact ? 14.0 : 16.0;
    final fontSize = isCompact ? 11.0 : 12.0;

    return FDWrap(
      spacing: 6,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      cssStyle: const {'max-width': '100%'},
      children: [
        // Source Favicon
        FDImage.network(
          source.iconUrl,
          width: iconSize,
          height: iconSize,
          borderRadius: BorderRadius.circular(3),
          fit: BoxFit.cover,
        ),

        // Source Name
        FDText(
          source.name,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryBlue,
          ),
        ),

        // Relative Timestamp
        FDText(
          '• $timestamp',
          style: TextStyle(
            fontSize: fontSize,
            color: AppColors.textMuted,
          ),
        ),

        // Optional Read Time
        if (readTimeMinutes != null)
          FDText(
            '• ${readTimeMinutes}m read',
            style: TextStyle(
              fontSize: fontSize,
              color: AppColors.textMuted,
            ),
          ),

        // Optional Category Badge
        if (category != null)
          FDContainer(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.borderSubtle : AppColors.lightNav,
              borderRadius: BorderRadius.circular(6),
            ),
            child: FDText(
              category!.toUpperCase(),
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: isDarkMode ? AppColors.textSecondary : const FlartColor('#475569'),
              ),
            ),
          ),
      ],
    );
  }
}
