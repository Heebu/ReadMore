import 'package:flartdart/flartdart.dart';
import 'package:news_models/news_models.dart';
import '../../core/constants/app_colors.dart';
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

    List<Article> displayed;
    if (vm.libraryTab == 'bookmarks') {
      displayed = vm.sampleArticles.where((a) => vm.bookmarkedIds.contains(a.id)).toList();
    } else if (vm.libraryTab == 'read_later') {
      displayed = vm.sampleArticles.where((a) => vm.readLaterIds.contains(a.id)).toList();
    } else {
      displayed = vm.sampleArticles.where((a) => vm.readingHistoryIds.contains(a.id)).toList();
    }

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
                final isSelected = vm.libraryTab == t['id'];
                return FDGestureDetector(
                  onTap: () => vm.setLibraryTab(t['id'] as String),
                  child: FDContainer(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryBlue
                          : (vm.isDarkMode ? AppColors.darkCard : AppColors.lightCard),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isSelected ? AppColors.primaryBlue : AppColors.borderRegular,
                        width: 1,
                      ),
                    ),
                    child: FDRow(
                      children: [
                        FDText(t['icon'] as String, style: const TextStyle(fontSize: 14)),
                        const FDSizedBox(width: 6),
                        FDText(
                          t['name'] as String,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: isSelected ? FlartColors.white : (vm.isDarkMode ? FlartColors.white : FlartColors.black),
                          ),
                        ),
                        const FDSizedBox(width: 6),
                        FDContainer(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primaryBlueDark : AppColors.primaryBlueSubtle,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: FDText(
                            '${t['count']}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
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
                  'Estimated Total Reading Time: ~$totalReadingMinutes minutes across ${displayed.length} articles.',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: FlartColor('#C4B5FD')),
                ),
              ],
            ),
          ),
        const FDSizedBox(height: 20),

        // Items Grid or Empty State
        if (displayed.isEmpty)
          FDContainer(
            padding: const EdgeInsets.symmetric(vertical: 80),
            child: FDCenter(
              child: FDColumn(
                children: [
                  const FDText('📭', style: TextStyle(fontSize: 48)),
                  const FDSizedBox(height: 16),
                  FDText(
                    vm.libraryTab == 'bookmarks'
                        ? 'No bookmarks saved yet'
                        : (vm.libraryTab == 'read_later' ? 'Your Read Later queue is empty' : 'No reading history yet'),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const FDSizedBox(height: 8),
                  const FDText(
                    'Save articles while browsing to read them anytime, anywhere.',
                    style: TextStyle(fontSize: 13, color: FlartColors.grey),
                  ),
                  const FDSizedBox(height: 20),
                  FDGestureDetector(
                    onTap: () => vm.setActiveScreen('headlines'),
                    child: FDContainer(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const FDText(
                        'Explore Top Stories',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: FlartColors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ArticlesGrid(articles: displayed, columns: isMobile ? 1 : 2, vm: vm),
      ],
    );
  }
}
