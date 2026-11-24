import 'package:flartdart/flartdart.dart';
import 'package:news_models/news_models.dart';
import '../constants/app_colors.dart';
import '../../viewmodels/news_app_viewmodel.dart';
import 'article_meta_bar.dart';
import 'interaction_pill.dart';

/// Versatile Bento-style news article card with cover image, category badge,
/// reading time, metadata byline, headline, summary, and action pills.
class ArticleCard extends StatelessWidget {
  final Article article;
  final NewsAppViewModel vm;
  final bool showSummary;
  final double imageHeight;

  const ArticleCard({
    required this.article,
    required this.vm,
    this.showSummary = true,
    this.imageHeight = 180,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isBookmarked = vm.isBookmarked(article.id);
    final isReadLater = vm.isReadLater(article.id);
    final isLiked = vm.isLiked(article.id);

    return FDGestureDetector(
      onTap: () => vm.openArticleReader(article),
      child: FDContainer(
        id: 'card-${article.id}',
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: vm.isDarkMode ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderRegular, width: 1),
          boxShadow: const [
            BoxShadow(color: FlartColor('rgba(0, 0, 0, 0.2)'), blurRadius: 10, offset: Offset(0, 4)),
          ],
        ),
        cssStyle: const {
          'transition': 'transform 0.28s cubic-bezier(0.16, 1, 0.3, 1), box-shadow 0.28s cubic-bezier(0.16, 1, 0.3, 1), border-color 0.28s ease',
          'cursor': 'pointer',
        },
        child: FDColumn(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cover Image with Overlays
            if (article.imageUrl != null)
              FDStack(
                children: [
                  FDContainer(
                    height: imageHeight,
                    width: double.infinity,
                    clipBehavior: Clip.antiAlias,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.vertical(top: 14),
                    ),
                    child: FDImage.network(
                      article.imageUrl!,
                      height: imageHeight,
                      fit: BoxFit.cover,
                      cssStyle: {
                        'width': '100%',
                        'height': '${imageHeight}px',
                        'object-fit': 'cover',
                        'display': 'block',
                      },
                    ),
                  ),
                  FDPositioned(
                    top: 10,
                    left: 10,
                    child: FDContainer(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.darkSurface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: FDText(
                        article.category.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryBlueLight,
                        ),
                      ),
                    ),
                  ),
                  FDPositioned(
                    top: 10,
                    right: 10,
                    child: FDContainer(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.darkSurface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: FDText(
                        '⚡ ${article.readTimeMinutes}m',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

            // Card Body
            FDContainer(
              padding: const EdgeInsets.all(16),
              child: FDColumn(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Publisher Meta Bar
                  ArticleMetaBar(
                    source: article.source,
                    timestamp: '1h ago',
                    isDarkMode: vm.isDarkMode,
                    isCompact: true,
                  ),
                  const FDSizedBox(height: 8),

                  // Headline
                  FDText(
                    article.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: vm.isDarkMode ? FlartColors.white : FlartColors.black,
                    ),
                  ),
                  const FDSizedBox(height: 8),

                  // Summary
                  if (showSummary) ...[
                    FDText(
                      article.summary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                    const FDSizedBox(height: 14),
                  ],

                  // Action Pills & Like Count
                  FDRow(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      FDRow(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InteractionPill(
                            icon: FDIcons.favorite,
                            label: isBookmarked ? 'Saved' : 'Save',
                            color: isBookmarked ? FlartColors.red : FlartColors.grey,
                            onTap: () => vm.toggleBookmark(article.id),
                            isDarkMode: vm.isDarkMode,
                          ),
                          const FDSizedBox(width: 8),
                          InteractionPill(
                            icon: FDIcons.hourglass,
                            label: isReadLater ? 'Queued' : 'Later',
                            color: isReadLater ? FlartColors.amber : FlartColors.grey,
                            onTap: () => vm.toggleReadLater(article.id),
                            isDarkMode: vm.isDarkMode,
                          ),
                        ],
                      ),
                      FDGestureDetector(
                        onTap: () => vm.toggleLike(article.id),
                        child: FDRow(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            FDText(
                              '${article.likeCount + (isLiked ? 1 : 0)}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isLiked ? FlartColors.amber : FlartColors.grey,
                              ),
                            ),
                            const FDSizedBox(width: 4),
                            FDIcon(
                              icon: FDIcons.star,
                              size: 14,
                              color: isLiked ? FlartColors.amber : FlartColors.grey,
                            ),
                          ],
                        ),
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
