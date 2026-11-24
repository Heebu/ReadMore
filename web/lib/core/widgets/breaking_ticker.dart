import 'package:flartdart/flartdart.dart';
import '../../viewmodels/news_app_viewmodel.dart';
import '../constants/app_colors.dart';
import 'centered_shell.dart';

/// Animated live breaking news ticker ribbon.
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
      decoration: const BoxDecoration(
        color: AppColors.darkBreaking,
        border: Border(bottom: BorderSide(color: FlartColor('rgba(239, 68, 68, 0.3)'), width: 1)),
      ),
      child: CenteredShell(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 28, vertical: 8),
        child: FDRow(
          children: [
            FDRawHTML('''
              <div style="display: flex; align-items: center; gap: 8px;">
                <span class="live-dot"></span>
                <span style="background: #EF4444; color: #FFF; font-size: 11px; font-weight: 800; padding: 2px 6px; border-radius: 4px; text-transform: uppercase;">
                  BREAKING
                </span>
              </div>
            '''),
            const FDSizedBox(width: 12),
            Expanded(
              child: FDGestureDetector(
                onTap: () => vm.openArticleReader(breakingArticle),
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
            if (!isMobile)
              FDGestureDetector(
                onTap: () => vm.openFullCoverage(),
                child: FDRow(
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
        ),
      ),
    );
  }
}
