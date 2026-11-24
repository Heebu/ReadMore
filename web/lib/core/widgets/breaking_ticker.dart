import 'package:flartdart/flartdart.dart';
import '../../viewmodels/news_app_viewmodel.dart';
import 'centered_shell.dart';

/// Animated live breaking news ticker ribbon with robust single-line scaling across all zoom levels.
class BreakingTicker extends StatelessWidget {
  final NewsAppViewModel vm;
  final bool isMobile;

  const BreakingTicker({
    required this.vm,
    required this.isMobile,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final breakingArticle = vm.headlinesArticles.isNotEmpty
        ? vm.headlinesArticles.first
        : vm.exploreArticles.first;

    return FDContainer(
      width: double.infinity,
      decoration: BoxDecoration(
        color: vm.isDarkMode ? const FlartColor('#15161C') : const FlartColor('#111111'),
        border: Border(
          top: BorderSide(
            color: vm.isDarkMode ? const FlartColor('#33353F') : const FlartColor('#000000'),
            width: 1,
          ),
          bottom: BorderSide(
            color: vm.isDarkMode ? const FlartColor('#33353F') : const FlartColor('#000000'),
            width: 2,
          ),
        ),
      ),
      child: CenteredShell(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 28, vertical: 8),
        child: FDRow(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Broadsheet Telegraph Badge
            FDRow(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              cssStyle: const {'flex-shrink': '0'},
              children: [
                FDContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: FlartColors.transparent,
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(
                      color: FlartColors.white,
                      width: 1,
                    ),
                  ),
                  child: const FDText(
                    'SPECIAL DISPATCH',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Space Grotesk',
                      letterSpacing: 0.1,
                      color: FlartColors.white,
                    ),
                  ),
                ),
              ],
            ),
            const FDSizedBox(width: 12),

            // Ticker Headline Text in Editorial Italic Serif (Robust single line, no vertical wrap)
            Expanded(
              child: FDContainer(
                onClick: () => vm.openArticleReader(breakingArticle),
                cssStyle: const {
                  'width': '100%',
                  'min-width': '0',
                  'overflow': 'hidden',
                  'white-space': 'nowrap',
                  'text-overflow': 'ellipsis',
                  'display': 'block',
                  'cursor': 'pointer',
                },
                child: FDText(
                  breakingArticle.title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    fontFamily: 'Playfair Display',
                    color: FlartColors.white,
                    letterSpacing: -0.01,
                  ),
                ),
              ),
            ),

            // Full Coverage Link
            if (!isMobile) ...[
              const FDSizedBox(width: 16),
              FDContainer(
                onClick: () => vm.openFullCoverage(),
                cssStyle: const {
                  'flex-shrink': '0',
                  'cursor': 'pointer',
                  'white-space': 'nowrap',
                },
                child: FDRow(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    FDText(
                      'READ DISPATCH',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Space Grotesk',
                        letterSpacing: 0.08,
                        color: FlartColors.white,
                      ),
                    ),
                    FDSizedBox(width: 4),
                    FDText('→', style: TextStyle(fontSize: 12, color: FlartColors.white)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
