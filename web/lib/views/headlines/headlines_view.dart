import 'package:flartdart/flartdart.dart';
import 'package:news_models/news_models.dart';
import '../../core/constants/app_colors.dart';
import '../../viewmodels/news_app_viewmodel.dart';
import 'widgets/articles_grid.dart';
import 'widgets/full_coverage_block.dart';
import 'widgets/hero_spotlight_card.dart';
import 'widgets/sidebar_widgets.dart';

/// Headlines view displaying the primary editorial feed, 12-category filter,
/// lead story spotlight, Google News perspective cluster, and MSN sidebar widgets.
class HeadlinesView extends StatelessWidget {
  final NewsAppViewModel vm;
  final bool isMobile;
  final bool isTablet;

  const HeadlinesView({
    required this.vm,
    required this.isMobile,
    required this.isTablet,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final articles = vm.filteredArticles;
    final heroArticle = articles.isNotEmpty ? articles.first : vm.sampleArticles.first;
    final remainingArticles = articles.length > 1 ? articles.sublist(1) : <Article>[];

    return FDColumn(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 12-Category Pill Filter Navbar
        _buildCategoryPillNavbar(),
        const FDSizedBox(height: 20),

        if (!isMobile && !isTablet)
          FDRow(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main Editorial Column (68%)
              Expanded(
                flex: 68,
                child: FDColumn(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSectionHeader('Top Global Headlines'),
                    const FDSizedBox(height: 16),
                    HeroSpotlightCard(article: heroArticle, vm: vm),
                    const FDSizedBox(height: 24),
                    FullCoverageBlock(vm: vm),
                    const FDSizedBox(height: 28),
                    ArticlesGrid(articles: remainingArticles, columns: 2, vm: vm),
                  ],
                ),
              ),
              const FDSizedBox(width: 32),

              // MSN-Style Sidebar Column (32%)
              Expanded(
                flex: 32,
                child: FDColumn(
                  children: [
                    WeatherSidebarWidget(vm: vm),
                    const FDSizedBox(height: 20),
                    MarketWatchSidebarWidget(vm: vm),
                    const FDSizedBox(height: 20),
                    TrendingTopicsSidebarWidget(vm: vm),
                    const FDSizedBox(height: 20),
                    TopReadLeaderboardWidget(vm: vm),
                    const FDSizedBox(height: 20),
                    MorningBriefingPromoWidget(vm: vm),
                    const FDSizedBox(height: 20),
                    const NewsletterWidget(),
                  ],
                ),
              ),
            ],
          )
        else
          FDColumn(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionHeader('Top Global Headlines'),
              const FDSizedBox(height: 16),
              HeroSpotlightCard(article: heroArticle, vm: vm),
              const FDSizedBox(height: 20),
              FullCoverageBlock(vm: vm),
              const FDSizedBox(height: 20),
              ArticlesGrid(articles: remainingArticles, columns: isTablet ? 2 : 1, vm: vm),
              const FDSizedBox(height: 32),
              WeatherSidebarWidget(vm: vm),
              const FDSizedBox(height: 20),
              MarketWatchSidebarWidget(vm: vm),
              const FDSizedBox(height: 20),
              TrendingTopicsSidebarWidget(vm: vm),
            ],
          ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return FDRow(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        FDRow(
          children: [
            FDContainer(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const FDSizedBox(width: 10),
            FDText(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: vm.isDarkMode ? FlartColors.white : FlartColors.black,
              ),
            ),
          ],
        ),
        FDRow(
          children: [
            FDRawHTML('''
              <span style="font-size: 12px; color: #64748B; font-weight: 600;">
                ● Live Updates Every 5m
              </span>
            '''),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryPillNavbar() {
    return FDSingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: FDRow(
        children: vm.categories.map((cat) {
          final isSelected = vm.selectedCategory.toLowerCase() == cat.slug.toLowerCase();

          return FDGestureDetector(
            onTap: () => vm.setSelectedCategory(cat.slug),
            child: FDContainer(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryBlue
                    : (vm.isDarkMode ? AppColors.darkCard : AppColors.lightCard),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.primaryBlue : AppColors.borderRegular,
                  width: 1,
                ),
              ),
              child: FDRow(
                children: [
                  FDText(_getCategoryEmoji(cat.slug), style: const TextStyle(fontSize: 13)),
                  const FDSizedBox(width: 6),
                  FDText(
                    cat.name,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isSelected ? FlartColors.white : (vm.isDarkMode ? FlartColors.white : FlartColors.black),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getCategoryEmoji(String slug) {
    switch (slug.toLowerCase()) {
      case 'top':
        return '🔥';
      case 'for_you':
        return '✨';
      case 'local':
        return '📍';
      case 'world':
        return '🌐';
      case 'tech':
        return '💻';
      case 'business':
        return '📈';
      case 'sports':
        return '🏆';
      case 'entertainment':
        return '🎬';
      case 'science':
        return '🔬';
      case 'health':
        return '🩺';
      case 'lifestyle':
        return '🌿';
      case 'gists':
        return '💬';
      case 'food':
        return '🍲';
      case 'opinion':
        return '💭';
      default:
        return '📰';
    }
  }
}
