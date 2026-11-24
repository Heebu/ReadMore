import 'package:flartdart/flartdart.dart';
import '../../core/constants/app_colors.dart';
import '../../viewmodels/news_app_viewmodel.dart';
import '../headlines/widgets/articles_grid.dart';

/// Markets & Financial Hub view displaying real-time tickers, sector switchers,
/// watchlist management, and business intelligence reporting.
class MarketsView extends StatelessWidget {
  final NewsAppViewModel vm;
  final bool isMobile;
  final bool isTablet;

  const MarketsView({
    required this.vm,
    required this.isMobile,
    required this.isTablet,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final sectorTabs = ['All', 'Indices', 'Crypto', 'Tech Equities', 'Commodities'];
    final items = vm.marketTickers;

    return FDColumn(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Sector Switcher Ribbon
        FDSingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: FDRow(
            children: sectorTabs.map((sector) {
              final isSelected = vm.selectedMarketSector == sector;
              return FDGestureDetector(
                onTap: () => vm.setSelectedMarketSector(sector),
                child: FDContainer(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.bullGreen
                        : (vm.isDarkMode ? AppColors.darkCard : AppColors.lightCard),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected ? AppColors.bullGreen : AppColors.borderRegular,
                      width: 1,
                    ),
                  ),
                  child: FDText(
                    sector,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected ? FlartColors.white : (vm.isDarkMode ? FlartColors.white : FlartColors.black),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const FDSizedBox(height: 24),

        // Live Market Movers Cards Grid
        FDWrap(
          spacing: 16,
          runSpacing: 16,
          children: items.map((m) {
            final isWatched = vm.isWatched(m.symbol);

            return FDContainer(
              width: isMobile ? 320 : (isTablet ? 280 : 320),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: vm.isDarkMode ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderRegular, width: 1),
              ),
              child: FDColumn(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FDRow(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FDColumn(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FDText(m.symbol, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                          FDText(m.name, style: const TextStyle(fontSize: 11, color: FlartColors.grey)),
                        ],
                      ),
                      FDGestureDetector(
                        onTap: () => vm.toggleWatchlist(m.symbol),
                        child: FDIcon(
                          icon: FDIcons.star,
                          size: 18,
                          color: isWatched ? FlartColors.amber : FlartColors.grey,
                        ),
                      ),
                    ],
                  ),
                  const FDSizedBox(height: 14),
                  FDRow(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FDText(
                        '\$${m.price.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                      ),
                      FDContainer(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: m.isPositive ? AppColors.bullGreenSubtle : AppColors.bearRedSubtle,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: FDText(
                          '${m.isPositive ? '+' : ''}${m.changePercent}%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: m.isPositive ? AppColors.bullGreen : AppColors.bearRed,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        const FDSizedBox(height: 32),

        // Financial News Feed
        FDRow(
          children: [
            FDContainer(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.bullGreen,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const FDSizedBox(width: 10),
            FDText(
              'Financial & Business Intelligence',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: vm.isDarkMode ? FlartColors.white : FlartColors.black,
              ),
            ),
          ],
        ),
        const FDSizedBox(height: 16),
        ArticlesGrid(
          articles: vm.sampleArticles.where((a) => a.category == 'business' || a.category == 'tech').toList(),
          columns: isMobile ? 1 : 2,
          vm: vm,
        ),
      ],
    );
  }
}
