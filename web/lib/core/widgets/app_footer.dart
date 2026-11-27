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
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkRibbon : AppColors.lightNav,
        border: Border(
          top: BorderSide(
            color: isDarkMode ? const FlartColor('#33353F') : const FlartColor('#111111'),
            width: 2,
          ),
        ),
      ),
      child: CenteredShell(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 28, vertical: 36),
        child: FDColumn(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FDWrap(
              alignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 16,
              runSpacing: 16,
              cssStyle: const {'width': '100%', 'max-width': '100%'},
              children: [
                FDContainer(
                  cssStyle: const {'max-width': '100%', 'min-width': '0'},
                  child: FDColumn(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FDText(
                        'ReadMore',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Cinzel',
                          letterSpacing: 0.04,
                          color: isDarkMode ? FlartColors.white : FlartColors.black,
                        ),
                      ),
                      const FDSizedBox(height: 4),
                      const FDText(
                        'THE DAILY CHRONICLE OF WORLD AFFAIRS & REAL-TIME DISPATCHES',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Space Grotesk',
                          letterSpacing: 0.1,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                FDWrap(
                  spacing: 14,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    FDLinkText(
                      text: 'ARCHIVE INDEX',
                      url: '/sitemap.xml',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Space Grotesk',
                        letterSpacing: 0.06,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    FDLinkText(
                      text: 'WIRE SYNDICATION',
                      url: '/sitemap_news.xml',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Space Grotesk',
                        letterSpacing: 0.06,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    FDLinkText(
                      text: 'TELEGRAPH FEED',
                      url: '/rss.xml',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Space Grotesk',
                        letterSpacing: 0.06,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const FDSizedBox(height: 24),
            FDDivider(color: isDarkMode ? const FlartColor('#262830') : const FlartColor('#D4CFBE')),
            const FDSizedBox(height: 16),
            const FDText(
              '✦ ESTABLISHED MDCCCLXXXVIII · CIRCULATING THROUGHOUT THE PRINCIPAL CITIES OF THE WORLD · ALL RIGHTS RESERVED',
              style: TextStyle(
                fontSize: 10,
                fontFamily: 'Space Grotesk',
                fontWeight: FontWeight.w600,
                letterSpacing: 0.06,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
