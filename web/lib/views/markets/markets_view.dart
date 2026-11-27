import 'package:flartdart/flartdart.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/filter_chip_pill.dart';
import '../../core/widgets/market_quote_card.dart';
import '../../core/widgets/section_header.dart';
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
    final sectorTabs = ['All', 'Indices', 'Crypto', 'Tech Equities', 'Commodities', 'Currencies'];
    final items = vm.marketTickers;

    return FDColumn(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Sector Switcher Ribbon
        FDSingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: FDRow(
            children: sectorTabs.map((sector) {
              return FilterChipPill(
                label: sector,
                isSelected: vm.selectedMarketSector == sector,
                activeColor: AppColors.bullGreen,
                onTap: () => vm.setSelectedMarketSector(sector),
                isDarkMode: vm.isDarkMode,
              );
            }).toList(),
          ),
        ),
        const FDSizedBox(height: 24),

        // Live Market Movers Cards Grid
        FDWrap(
          spacing: 16,
          runSpacing: 16,
          cssStyle: const {'width': '100%', 'max-width': '100%'},
          children: items.map((m) {
            return MarketQuoteCard(
              item: m,
              vm: vm,
              width: isMobile ? null : (isTablet ? 280 : 320),
            );
          }).toList(),
        ),
        const FDSizedBox(height: 32),

        // Financial News Feed
        SectionHeader(
          title: 'Financial & Business Intelligence',
          accentColor: AppColors.bullGreen,
          isDarkMode: vm.isDarkMode,
        ),
        const FDSizedBox(height: 16),
        ArticlesGrid(
          articles: vm.marketArticles,
          columns: isMobile ? 1 : 2,
          vm: vm,
        ),
      ],
    );
  }
}
