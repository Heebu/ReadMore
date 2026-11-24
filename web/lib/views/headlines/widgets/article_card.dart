import 'package:flartdart/flartdart.dart';
import 'package:news_models/news_models.dart';
import '../../../core/constants/app_colors.dart';
import '../../../viewmodels/news_app_viewmodel.dart';

/// Reusable card representation for a syndicated article in grids or lists.
class ArticleCard extends StatelessWidget {
  final Article article;
  final NewsAppViewModel vm;

  const ArticleCard({
    required this.article,
    required this.vm,
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
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: vm.isDarkMode ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderRegular, width: 1),
          boxShadow: const [
            BoxShadow(color: FlartColor('rgba(0, 0, 0, 0.2)'), blurRadius: 10, offset: Offset(0, 4)),
          ],
        ),
        child: FDColumn(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (article.imageUrl != null)
              FDStack(
                children: [
                  FDContainer(
                    height: 180,
                    width: double.infinity,
                    clipBehavior: Clip.antiAlias,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.vertical(top: 14),
                    ),
                    child: FDImage.network(
                      article.imageUrl!,
                      width: double.infinity,
                      height: 180,
                      fit: BoxFit.cover,
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
            FDContainer(
              padding: const EdgeInsets.all(16),
              child: FDColumn(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FDRow(
                    children: [
                      FDImage.network(
                        article.source.iconUrl,
                        width: 14,
                        height: 14,
                        borderRadius: BorderRadius.circular(3),
                        fit: BoxFit.cover,
                      ),
                      const FDSizedBox(width: 6),
                      FDText(
                        article.source.name,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primaryBlue),
                      ),
                      const FDSizedBox(width: 6),
                      const FDText(
                        '• 1h ago',
                        style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                  const FDSizedBox(height: 8),
                  FDText(
                    article.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: vm.isDarkMode ? FlartColors.white : FlartColors.black,
                    ),
                  ),
                  const FDSizedBox(height: 8),
                  FDText(
                    article.summary,
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  const FDSizedBox(height: 14),
                  FDRow(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FDRow(
                        children: [
                          FDGestureDetector(
                            onTap: () => vm.toggleBookmark(article.id),
                            child: FDIcon(
                              icon: FDIcons.favorite,
                              size: 16,
                              color: isBookmarked ? FlartColors.red : FlartColors.grey,
                            ),
                          ),
                          const FDSizedBox(width: 12),
                          FDGestureDetector(
                            onTap: () => vm.toggleReadLater(article.id),
                            child: FDIcon(
                              icon: FDIcons.hourglass,
                              size: 16,
                              color: isReadLater ? FlartColors.amber : FlartColors.grey,
                            ),
                          ),
                        ],
                      ),
                      FDRow(
                        children: [
                          FDText(
                            '${article.likeCount + (isLiked ? 1 : 0)}',
                            style: const TextStyle(fontSize: 11, color: FlartColors.grey),
                          ),
                          const FDSizedBox(width: 4),
                          FDGestureDetector(
                            onTap: () => vm.toggleLike(article.id),
                            child: FDIcon(
                              icon: FDIcons.star,
                              size: 14,
                              color: isLiked ? FlartColors.amber : FlartColors.grey,
                            ),
                          ),
                        ],
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
