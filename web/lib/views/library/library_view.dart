import 'package:flartdart/flartdart.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/empty_state_widget.dart';
import '../../core/widgets/filter_chip_pill.dart';
import '../../viewmodels/news_app_viewmodel.dart';
import '../headlines/widgets/articles_grid.dart';

/// My Library view organizing saved bookmarks, read-later queue with estimated reading
/// time calculation, and reading history with clean-state actions.
class LibraryView extends StatelessWidget {
  final NewsAppViewModel vm;
  final bool isMobile;
  final bool isTablet;

  const LibraryView({
    required this.vm,
    required this.isMobile,
    required this.isTablet,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final tabs = [
      {'id': 'bookmarks', 'name': 'Bookmarks', 'count': vm.bookmarkedIds.length, 'icon': '📌'},
      {'id': 'read_later', 'name': 'Read Later Queue', 'count': vm.readLaterIds.length, 'icon': '⏳'},
      {'id': 'history', 'name': 'Reading History', 'count': vm.readingHistoryIds.length, 'icon': '🕒'},
    ];

    final displayed = vm.libraryArticles;

    final totalReadingMinutes = displayed.fold<int>(0, (sum, a) => sum + a.readTimeMinutes);

    return FDColumn(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Sub-tabs Header
        FDRow(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FDRow(
              mainAxisSize: MainAxisSize.min,
              children: tabs.map((t) {
                return FilterChipPill(
                  label: t['name'] as String,
                  iconOrEmoji: t['icon'] as String,
                  badge: '${t['count']}',
                  isSelected: vm.libraryTab == t['id'],
                  onTap: () => vm.setLibraryTab(t['id'] as String),
                  isDarkMode: vm.isDarkMode,
                );
              }).toList(),
            ),

            if (vm.libraryTab == 'history' && vm.readingHistoryIds.isNotEmpty)
              FDGestureDetector(
                onTap: () => vm.clearReadingHistory(),
                child: const FDText(
                  'Clear History',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.bearRed),
                ),
              ),
          ],
        ),
        const FDSizedBox(height: 20),

        // Guest Archive Notice
        if (!vm.isAuthenticated) ...[
          FDContainer(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: vm.isDarkMode ? const FlartColor('#17181F') : const FlartColor('#EFECE4'),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.borderRegular, width: 1),
            ),
            child: FDRow(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Expanded(
                  child: FDText(
                    'Guest Archive — Sign in to permanently sync bookmarks, queue, and reading history across devices.',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ),
                const FDSizedBox(width: 12),
                FDGestureDetector(
                  onTap: () => vm.openAuthModal(tab: 'signin'),
                  child: FDContainer(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: vm.isDarkMode ? FlartColors.white : FlartColors.black,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: FDText(
                      'SIGN IN',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Space Grotesk',
                        color: vm.isDarkMode ? FlartColors.black : FlartColors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const FDSizedBox(height: 16),
        ],

        // Read Later Time Calculator Banner
        if (vm.libraryTab == 'read_later' && displayed.isNotEmpty)
          FDContainer(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const FlartColor('rgba(139, 92, 246, 0.15)'),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const FlartColor('rgba(139, 92, 246, 0.3)'), width: 1),
            ),
            child: FDRow(
              children: [
                const FDText('⏱️ ', style: TextStyle(fontSize: 16)),
                FDText(
                  'Estimated Total Reading Time: ~$totalReadingMinutes ${totalReadingMinutes == 1 ? 'minute' : 'minutes'} across ${displayed.length} ${displayed.length == 1 ? 'article' : 'articles'}.',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: FlartColor('#C4B5FD')),
                ),
              ],
            ),
          ),
        const FDSizedBox(height: 20),

        // Items Grid or Empty State
        if (displayed.isEmpty)
          EmptyStateWidget(
            emoji: '📭',
            title: vm.libraryTab == 'bookmarks'
                ? 'No bookmarks saved yet'
                : (vm.libraryTab == 'read_later' ? 'Your Read Later queue is empty' : 'No reading history yet'),
            description: 'Save articles while browsing to read them anytime, anywhere.',
            actionLabel: 'Explore Top Stories',
            onAction: () => vm.setActiveScreen('headlines'),
          )
        else
          ArticlesGrid(articles: displayed, columns: isMobile ? 1 : 2, vm: vm),
      ],
    );
  }
}
