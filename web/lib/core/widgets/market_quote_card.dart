import 'package:flartdart/flartdart.dart';
import 'package:news_models/news_models.dart';
import '../../viewmodels/news_app_viewmodel.dart';
import '../constants/app_colors.dart';

/// Reusable financial market quote card for the Markets hub and sidebar widgets.
class MarketQuoteCard extends StatelessWidget {
  final MarketTickerItem item;
  final NewsAppViewModel vm;
  final double? width;

  const MarketQuoteCard({
    required this.item,
    required this.vm,
    this.width,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isWatched = vm.isWatched(item.symbol);

    return FDContainer(
      width: width,
      padding: const EdgeInsets.all(18),
      cssStyle: width == null ? const {'width': '100%', 'max-width': '100%', 'box-sizing': 'border-box'} : null,
      decoration: BoxDecoration(
        color: vm.isDarkMode ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderRegular, width: 1),
        boxShadow: const [
          BoxShadow(color: FlartColor('rgba(0, 0, 0, 0.15)'), blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: FDColumn(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FDRow(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FDColumn(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  FDText(
                    item.symbol,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                  ),
                  const FDSizedBox(height: 2),
                  FDText(
                    item.name,
                    style: const TextStyle(fontSize: 11, color: FlartColors.grey),
                  ),
                ],
              ),
              FDGestureDetector(
                onTap: () => vm.toggleWatchlist(item.symbol),
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FDText(
                '\$${item.price.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              FDContainer(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: item.isPositive ? AppColors.bullGreenSubtle : AppColors.bearRedSubtle,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: FDText(
                  '${item.isPositive ? '+' : ''}${item.changePercent}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: item.isPositive ? AppColors.bullGreen : AppColors.bearRed,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
