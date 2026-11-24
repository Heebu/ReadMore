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
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.darkBreaking,
        border: Border(bottom: BorderSide(color: FlartColor('rgba(239, 68, 68, 0.3)'), width: 1)),
      ),
      child: CenteredShell(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 28, vertical: 10),
        child: FDRow(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FDRow(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
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
            const FDSizedBox(width: 14),
            Expanded(
              child: FDGestureDetector(
                onTap: () => vm.openArticleReader(breakingArticle),
                child: FDText(
                  breakingArticle.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: FlartColor('#E0E7FF'),
                  ),
                ),
              ),
            ),
            if (!isMobile) ...[
              const FDSizedBox(width: 16),
              FDGestureDetector(
                onTap: () => vm.openFullCoverage(),
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
