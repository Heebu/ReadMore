import 'package:flartdart/flartdart.dart';
import 'package:news_models/news_models.dart';
import '../../viewmodels/news_app_viewmodel.dart';
import '../constants/app_colors.dart';

/// Numbered article tile for ranked leaderboards (e.g. Editor's Top Reads, Trending Top 5).
class RankedArticleTile extends StatelessWidget {
  final int rank;
  final Article article;
  final NewsAppViewModel vm;

  const RankedArticleTile({
    required this.rank,
    required this.article,
    required this.vm,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final rankFormatted = rank < 10 ? '0$rank' : '$rank';

    return FDGestureDetector(
      onTap: () => vm.openArticleReader(article),
      child: FDContainer(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: FDRow(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Prominent Rank Digits
            FDText(
              rankFormatted,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppColors.primaryBlue,
                letterSpacing: -0.05,
              ),
            ),
            const FDSizedBox(width: 12),

            // Title & Publisher
            Expanded(
              child: FDColumn(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FDText(
                    article.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: vm.isDarkMode ? FlartColors.white : FlartColors.black,
                    ),
                  ),
                  const FDSizedBox(height: 4),
                  FDRow(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FDImage.network(
                        article.source.iconUrl,
                        width: 12,
                        height: 12,
                        borderRadius: BorderRadius.circular(2),
                        fit: BoxFit.cover,
                      ),
                      const FDSizedBox(width: 4),
                      FDText(
                        article.source.name,
                        style: const TextStyle(fontSize: 11, color: FlartColors.grey, fontWeight: FontWeight.w600),
                      ),
                      const FDSizedBox(width: 6),
                      FDText(
                        '• ${article.readTimeMinutes}m',
                        style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
