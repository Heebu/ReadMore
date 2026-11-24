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
                FDRawHTML('''
                  <div style="display: flex; gap: 16px; font-size: 13px; color: #94A3B8;">
                    <a href="/sitemap.xml" style="color: inherit; text-decoration: none;">Sitemap</a>
                    <a href="/sitemap_news.xml" style="color: inherit; text-decoration: none;">Google News XML</a>
                    <a href="/rss.xml" style="color: inherit; text-decoration: none;">RSS 2.0</a>
                  </div>
                '''),
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
