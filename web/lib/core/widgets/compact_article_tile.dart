import 'package:flartdart/flartdart.dart';
import 'package:news_models/news_models.dart';
import '../../viewmodels/news_app_viewmodel.dart';
import '../constants/app_colors.dart';
import 'article_meta_bar.dart';

/// Sleek horizontal news tile for sidebars, perspective clusters, and compact list views.
class CompactArticleTile extends StatelessWidget {
  final Article article;
  final NewsAppViewModel vm;
  final bool showThumbnail;
  final bool showSummary;

  const CompactArticleTile({
    required this.article,
    required this.vm,
    this.showThumbnail = true,
    this.showSummary = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isBookmarked = vm.isBookmarked(article.id);
    final isReadLater = vm.isReadLater(article.id);

    return FDGestureDetector(
      onTap: () => vm.openArticleReader(article),
      child: FDContainer(
        id: 'compact-card-${article.id}',
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: vm.isDarkMode ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(3),
          border: Border.all(
            color: vm.isDarkMode ? AppColors.borderRegular : const FlartColor('#D4CFBE'),
            width: 1,
          ),
          boxShadow: const [
            BoxShadow(color: FlartColor('rgba(0, 0, 0, 0.06)'), blurRadius: 6, offset: Offset(0, 1)),
          ],
        ),
        cssStyle: const {
          'transition': 'transform 0.25s cubic-bezier(0.16, 1, 0.3, 1), box-shadow 0.25s ease, border-color 0.25s ease',
          'cursor': 'pointer',
        },
        child: FDRow(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left/Main Content
            Expanded(
              child: FDColumn(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ArticleMetaBar(
                    source: article.source,
                    timestamp: '30m ago',
                    readTimeMinutes: article.readTimeMinutes,
                    isDarkMode: vm.isDarkMode,
                    isCompact: true,
                  ),
                  const FDSizedBox(height: 6),
                  FDText(
                    article.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Playfair Display',
                      color: vm.isDarkMode ? const FlartColor('#F4F3EE') : const FlartColor('#111111'),
                    ),
                  ),
                  if (showSummary) ...[
                    const FDSizedBox(height: 4),
                    FDText(
                      article.summary,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Newsreader',
                        color: vm.isDarkMode ? const FlartColor('#A2A098') : const FlartColor('#4A4842'),
                      ),
                    ),
                  ],
                  const FDSizedBox(height: 8),
                  FDRow(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FDGestureDetector(
                        onTap: () => vm.toggleBookmark(article.id),
                        child: FDIcon(
                          icon: FDIcons.favorite,
                          size: 14,
                          color: isBookmarked ? FlartColors.red : FlartColors.grey,
                        ),
                      ),
                      const FDSizedBox(width: 10),
                      FDGestureDetector(
                        onTap: () => vm.toggleReadLater(article.id),
                        child: FDIcon(
                          icon: FDIcons.hourglass,
                          size: 14,
                          color: isReadLater ? FlartColors.amber : FlartColors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Optional Right Thumbnail
            if (showThumbnail && article.imageUrl != null) ...[
              const FDSizedBox(width: 12),
              FDContainer(
                width: 72,
                height: 72,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: FDImage.network(
                  article.imageUrl!,
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
