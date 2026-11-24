import 'package:flartdart/flartdart.dart';
import 'package:news_models/news_models.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/article_meta_bar.dart';
import '../../../core/widgets/interaction_pill.dart';
import '../../../viewmodels/news_app_viewmodel.dart';

/// Hero spotlight card for the top lead headline.
class HeroSpotlightCard extends StatelessWidget {
  final Article article;
  final NewsAppViewModel vm;

  const HeroSpotlightCard({
    required this.article,
    required this.vm,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isBookmarked = vm.isBookmarked(article.id);
    final isReadLater = vm.isReadLater(article.id);

    return FDGestureDetector(
      onTap: () => vm.openArticleReader(article),
      child: FDContainer(
        decoration: BoxDecoration(
          color: vm.isDarkMode ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderRegular, width: 1),
          boxShadow: const [
            BoxShadow(color: FlartColor('rgba(0, 0, 0, 0.3)'), blurRadius: 20, offset: Offset(0, 8)),
          ],
        ),
        child: FDColumn(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (article.imageUrl != null)
              FDStack(
                children: [
                  FDContainer(
                    height: 340,
                    width: double.infinity,
                    clipBehavior: Clip.antiAlias,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.vertical(top: 16),
                    ),
                    child: FDImage.network(
                      article.imageUrl!,
                      height: 340,
                      fit: BoxFit.cover,
                      cssStyle: const {
                        'width': '100%',
                        'height': '340px',
                        'object-fit': 'cover',
                        'display': 'block',
                      },
                    ),
                  ),
                  FDPositioned(
                    top: 16,
                    left: 16,
                    child: FDRow(
                      children: [
                        FDContainer(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: FDText(
                            article.category.toUpperCase(),
                            style: const TextStyle(
                              color: FlartColors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const FDSizedBox(width: 8),
                        FDContainer(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.darkSurface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: FDText(
                            '⚡ ${article.readTimeMinutes} min read',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            FDContainer(
              padding: const EdgeInsets.all(24),
              child: FDColumn(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ArticleMetaBar(
                    source: article.source,
                    timestamp: '25m ago',
                    isDarkMode: vm.isDarkMode,
                  ),
                  const FDSizedBox(height: 12),
                  FDText(
                    article.title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: vm.isDarkMode ? FlartColors.white : FlartColors.black,
                    ),
                  ),
                  const FDSizedBox(height: 10),
                  FDText(
                    article.summary,
                    style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                  ),
                  const FDSizedBox(height: 18),
                  FDRow(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FDRow(
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
                            label: isReadLater ? 'In Queue' : 'Read Later',
                            color: isReadLater ? FlartColors.amber : FlartColors.grey,
                            onTap: () => vm.toggleReadLater(article.id),
                            isDarkMode: vm.isDarkMode,
                          ),
                        ],
                      ),
                      FDRow(
                        children: const [
                          FDText(
                            'Read Full Story',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                          ),
                          FDSizedBox(width: 4),
                          FDIcon(icon: FDIcons.arrow_forward, size: 16, color: AppColors.primaryBlue),
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
