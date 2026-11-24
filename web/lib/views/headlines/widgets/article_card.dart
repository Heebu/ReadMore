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
              FDRawHTML('''
                <div style="position: relative; width: 100%; height: 180px; border-radius: 14px 14px 0 0; overflow: hidden;">
                  <img src="${article.imageUrl}" alt="${article.title}" style="width: 100%; height: 100%; object-fit: cover;"/>
                  <span style="position: absolute; top: 10px; left: 10px; background: rgba(15, 23, 42, 0.85); backdrop-filter: blur(8px); color: #60A5FA; font-size: 10px; font-weight: 800; padding: 2px 8px; border-radius: 8px; text-transform: uppercase;">
                    ${article.category}
                  </span>
                  <span style="position: absolute; top: 10px; right: 10px; background: rgba(15, 23, 42, 0.85); backdrop-filter: blur(8px); color: #94A3B8; font-size: 10px; font-weight: 700; padding: 2px 8px; border-radius: 8px;">
                    ⚡ ${article.readTimeMinutes}m
                  </span>
                </div>
              '''),
            FDContainer(
              padding: const EdgeInsets.all(16),
              child: FDColumn(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FDRow(
                    children: [
                      FDRawHTML('''
                        <div style="display: flex; align-items: center; gap: 6px;">
                          <img src="${article.source.iconUrl}" style="width: 14px; height: 14px; border-radius: 3px;"/>
                          <span style="font-size: 11px; font-weight: 700; color: #3B82F6;">${article.source.name}</span>
                          <span style="color: #64748B; font-size: 11px;">• 1h ago</span>
                        </div>
                      '''),
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
