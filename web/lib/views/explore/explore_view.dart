import 'package:flartdart/flartdart.dart';
import '../../core/constants/app_colors.dart';
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
    var results = vm.sampleArticles;

    if (vm.searchQuery.trim().isNotEmpty) {
      final q = vm.searchQuery.toLowerCase().trim();
      results = results.where((a) {
        return a.title.toLowerCase().contains(q) ||
            a.summary.toLowerCase().contains(q) ||
            a.tags.any((t) => t.toLowerCase().contains(q)) ||
            a.source.name.toLowerCase().contains(q);
      }).toList();
    }

    if (vm.selectedSourceFilter != 'all') {
      results = results.where((a) => a.source.slug == vm.selectedSourceFilter).toList();
    }

    if (vm.sortBy == 'most_read') {
      results = List.from(results)..sort((a, b) => b.likeCount.compareTo(a.likeCount));
    }

    return FDColumn(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Large Search Bar
        FDContainer(
          child: FDTextField(
            placeholder: 'Search topics, breaking events, entities, or authors...',
            backgroundColor: vm.isDarkMode ? AppColors.darkInput : AppColors.lightInput,
            borderColor: AppColors.borderRegular,
            borderRadius: 16,
            prefixIcon: const FDIcon(icon: FDIcons.search, size: 20, color: FlartColors.grey),
            onChanged: (val) => vm.setSearchQuery(val),
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
                    return FilterChipPill(
                      label: t,
                      isSelected: false,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      onTap: () => vm.setSearchQuery(t.replaceAll('#', '')),
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
        FDRow(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FDText(
              '${results.length} stories found',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: FlartColors.grey),
            ),
            FDRow(
              mainAxisSize: MainAxisSize.min,
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
