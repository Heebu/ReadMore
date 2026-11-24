import 'package:flartdart/flartdart.dart';
import '../../viewmodels/news_app_viewmodel.dart';
import '../constants/app_colors.dart';
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
      decoration: const BoxDecoration(
        color: AppColors.darkBreaking,
        border: Border(bottom: BorderSide(color: FlartColor('rgba(239, 68, 68, 0.3)'), width: 1)),
      ),
      child: CenteredShell(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 28, vertical: 9),
        child: FDRow(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Live dot + BREAKING tag
            FDRow(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              cssStyle: const {'flex-shrink': '0'},
              children: [
                FDContainer(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.bearRed,
                    shape: BoxShape.circle,
                  ),
                ),
                const FDSizedBox(width: 6),
                FDContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.bearRed,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const FDText(
                    'BREAKING',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: FlartColors.white,
                    ),
                  ),
                ),
              ],
            ),
            const FDSizedBox(width: 12),

            // Ticker Headline Text - Pure single line with text-overflow ellipsis
            Expanded(
              child: FDContainer(
                onClick: () => vm.openArticleReader(breakingArticle),
                cssStyle: const {
                  'width': '100%',
                  'overflow': 'hidden',
                  'white-space': 'nowrap',
                  'text-overflow': 'ellipsis',
                  'cursor': 'pointer',
                },
                child: FDText(
                  breakingArticle.title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: FlartColor('#E0E7FF'),
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
                      'Full Coverage',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: FlartColor('#818CF8')),
                    ),
                    FDSizedBox(width: 4),
                    FDIcon(icon: FDIcons.arrow_forward, size: 14, color: FlartColor('#818CF8')),
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
