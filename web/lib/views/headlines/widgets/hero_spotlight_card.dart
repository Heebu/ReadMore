import 'package:flartdart/flartdart.dart';
import 'package:news_models/news_models.dart';
import '../../../core/constants/app_colors.dart';
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
              FDRawHTML('''
                <div style="position: relative; width: 100%; height: 320px; max-height: 360px; border-radius: 16px 16px 0 0; overflow: hidden;">
                  <img src="${article.imageUrl}" alt="${article.title}" style="width: 100%; height: 100%; object-fit: cover; transition: transform 0.5s ease;" onmouseover="this.style.transform='scale(1.03)'" onmouseout="this.style.transform='scale(1)'"/>
                  <div style="position: absolute; bottom: 0; left: 0; right: 0; height: 120px; background: linear-gradient(to top, rgba(9, 13, 22, 0.95), transparent);"></div>
                  <div style="position: absolute; top: 16px; left: 16px; display: flex; gap: 8px;">
                    <span style="background: rgba(59, 130, 246, 0.9); backdrop-filter: blur(8px); color: #FFF; font-size: 11px; font-weight: 800; padding: 4px 10px; border-radius: 12px; text-transform: uppercase;">
                      ${article.category}
                    </span>
                    <span style="background: rgba(15, 23, 42, 0.85); backdrop-filter: blur(8px); color: #94A3B8; font-size: 11px; font-weight: 700; padding: 4px 10px; border-radius: 12px;">
                      ⚡ ${article.readTimeMinutes} min read
                    </span>
                  </div>
                </div>
              '''),
            FDContainer(
              padding: const EdgeInsets.all(24),
              child: FDColumn(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FDRow(
                    children: [
                      FDRawHTML('''
                        <div style="display: flex; align-items: center; gap: 8px;">
                          <img src="${article.source.iconUrl}" style="width: 18px; height: 18px; border-radius: 4px;"/>
                          <span style="font-size: 13px; font-weight: 700; color: #3B82F6;">${article.source.name}</span>
                          <span style="color: #64748B; font-size: 12px;">• 25m ago</span>
                        </div>
                      '''),
                    ],
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
