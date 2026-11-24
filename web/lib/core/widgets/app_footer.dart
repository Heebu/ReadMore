import 'package:flartdart/flartdart.dart';
import '../constants/app_colors.dart';
import 'centered_shell.dart';

/// Clean, technology-unbranded footer conforming to syndication standards.
class AppFooter extends StatelessWidget {
  final bool isMobile;
  final bool isDarkMode;

  const AppFooter({
    required this.isMobile,
    this.isDarkMode = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FDContainer(
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkRibbon : AppColors.lightNav,
        border: const Border(top: BorderSide(color: AppColors.borderSubtle, width: 1)),
      ),
      child: CenteredShell(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 28, vertical: 36),
        child: FDColumn(
          children: [
            FDRow(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FDColumn(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FDText(
                      'ReadMore',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: isDarkMode ? FlartColors.white : FlartColors.black,
                      ),
                    ),
                    const FDSizedBox(height: 4),
                    const FDText(
                      'Global News & Real-Time Intelligence Syndication',
                      style: TextStyle(fontSize: 12, color: FlartColors.grey),
                    ),
                  ],
                ),
                FDRow(
                  children: [
                    FDLinkText(
                      text: 'Sitemap',
                      url: '/sitemap.xml',
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                    const FDSizedBox(width: 16),
                    FDLinkText(
                      text: 'Google News XML',
                      url: '/sitemap_news.xml',
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                    const FDSizedBox(width: 16),
                    FDLinkText(
                      text: 'RSS 2.0',
                      url: '/rss.xml',
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
            const FDSizedBox(height: 24),
            const FDDivider(color: AppColors.borderSubtle),
            const FDSizedBox(height: 16),
            const FDText(
              '© 2026 ReadMore News Platform. Real-time multi-source aggregation conforming to fair-use and Google News syndication standards.',
              style: TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
