import 'package:flartdart/flartdart.dart';
import '../../core/constants/app_colors.dart';
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
                    return FDGestureDetector(
                      onTap: () => vm.setSearchQuery(t.replaceAll('#', '')),
                      child: FDContainer(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlueSubtle,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderHighlighted, width: 1),
                        ),
                        child: FDText(
                          t,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryBlueLight),
                        ),
                      ),
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
          children: [
            FDText(
              '${results.length} stories found',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: FlartColors.grey),
            ),
            FDRow(
              children: [
                _buildSortPill('latest', 'Latest'),
                const FDSizedBox(width: 8),
                _buildSortPill('most_read', 'Most Read'),
              ],
            ),
          ],
        ),
        const FDSizedBox(height: 16),

        // Search Results Grid or Empty State
        if (results.isEmpty)
          FDContainer(
            padding: const EdgeInsets.symmetric(vertical: 60),
            child: FDCenter(
              child: FDColumn(
                children: [
                  const FDText('🔍', style: TextStyle(fontSize: 48)),
                  const FDSizedBox(height: 16),
                  const FDText('No stories found matching your query', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const FDSizedBox(height: 8),
                  const FDText('Try searching for broader keywords or browsing by category.', style: TextStyle(fontSize: 13, color: FlartColors.grey)),
                ],
              ),
            ),
          )
        else
          ArticlesGrid(articles: results, columns: isMobile ? 1 : (isTablet ? 2 : 3), vm: vm),
      ],
    );
  }

  Widget _buildSortPill(String id, String label) {
    final isSelected = vm.sortBy == id;
    return FDGestureDetector(
      onTap: () => vm.setSortBy(id),
      child: FDContainer(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue : AppColors.borderSubtle,
          borderRadius: BorderRadius.circular(10),
        ),
        child: FDText(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? FlartColors.white : FlartColors.grey,
          ),
        ),
      ),
    );
  }
}
