import 'package:flartdart/flartdart.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/empty_state_widget.dart';
import '../../core/widgets/filter_chip_pill.dart';
import '../../viewmodels/news_app_viewmodel.dart';
import '../headlines/widgets/articles_grid.dart';

/// Explore and deep search view offering free-text query matching, trending hashtags cloud,
/// and multifaceted sorting.
class ExploreView extends StatelessWidget {
  final NewsAppViewModel vm;
  final bool isMobile;
  final bool isTablet;

  const ExploreView({
    required this.vm,
    required this.isMobile,
    required this.isTablet,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final results = vm.exploreArticles;

    return FDColumn(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Large Search Bar
        FDContainer(
          child: AppTextField(
            key: const ValueKey('explore-search-input'),
            value: vm.searchQuery,
            placeholder: 'Search topics, breaking events, entities, or authors...',
            ariaLabel: 'Search topics, breaking events, entities, or authors',
            backgroundColor: vm.isDarkMode ? AppColors.darkInput : AppColors.lightInput,
            borderColor: AppColors.borderRegular,
            borderRadius: 16,
            prefixIcon: const FDIcon(icon: FDIcons.search, size: 20, color: FlartColors.grey),
            suffixIcon: vm.searchQuery.trim().isNotEmpty
                ? FDGestureDetector(
                    onTap: () => vm.clearSearchQuery(),
                    child: const FDIcon(icon: FDIcons.close, size: 18, color: FlartColors.grey),
                  )
                : null,
            onChanged: (val) => vm.setSearchQuery(val),
            onSubmitted: (val) => vm.setSearchQuery(val),
          ),
        ),
        const FDSizedBox(height: 16),

        // Trending Topic Pills
        FDRow(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const FDText('Trending: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: FlartColors.grey)),
            const FDSizedBox(width: 8),
            Expanded(
              child: FDSingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: FDRow(
                  children: vm.trendingTags.map((t) {
                    final tagQuery = t.replaceAll('#', '');
                    final isSelected = vm.searchQuery.trim().toLowerCase() == tagQuery.toLowerCase();
                    return FilterChipPill(
                      label: t,
                      isSelected: isSelected,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      onTap: () => vm.setSearchQuery(tagQuery),
                      isDarkMode: vm.isDarkMode,
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
        const FDSizedBox(height: 20),

        // Sort By & Results Count Bar
        FDWrap(
          alignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 8,
          cssStyle: const {'width': '100%', 'max-width': '100%'},
          children: [
            FDText(
              '${results.length} ${results.length == 1 ? 'story' : 'stories'} found',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: FlartColors.grey),
            ),
            FDWrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                FilterChipPill(
                  label: 'Latest',
                  isSelected: vm.sortBy == 'latest',
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  onTap: () => vm.setSortBy('latest'),
                  isDarkMode: vm.isDarkMode,
                ),
                FilterChipPill(
                  label: 'Most Read',
                  isSelected: vm.sortBy == 'most_read',
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  onTap: () => vm.setSortBy('most_read'),
                  isDarkMode: vm.isDarkMode,
                ),
              ],
            ),
          ],
        ),
        const FDSizedBox(height: 16),

        // Search Results Grid or Empty State
        if (results.isEmpty)
          const EmptyStateWidget(
            emoji: '🔍',
            title: 'No stories found matching your query',
            description: 'Try searching for broader keywords or browsing by category.',
          )
        else
          ArticlesGrid(articles: results, columns: isMobile ? 1 : (isTablet ? 2 : 3), vm: vm),
      ],
    );
  }
}
