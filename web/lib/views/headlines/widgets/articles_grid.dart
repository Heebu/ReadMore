import 'package:flartdart/flartdart.dart';
import 'package:news_models/news_models.dart';
import '../../../core/widgets/ads/in_feed_native_ad_card.dart';
import '../../../viewmodels/news_app_viewmodel.dart';
import 'article_card.dart';

/// Bento-style multi-column article grid with dynamic native in-feed sponsored ads.
class ArticlesGrid extends StatelessWidget {
  final List<Article> articles;
  final NewsAppViewModel vm;
  final int columns;

  const ArticlesGrid({
    required this.articles,
    required this.vm,
    required this.columns,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final nativeAd = vm.showAds ? vm.getInFeedNativeAd(category: vm.selectedCategory) : null;

    if (columns == 1) {
      final items = <Widget>[];
      for (var i = 0; i < articles.length; i++) {
        items.add(ArticleCard(article: articles[i], vm: vm));
        if (i == 1 && nativeAd != null) {
          items.add(InFeedNativeAdCard(ad: nativeAd, vm: vm));
        }
      }
      return FDColumn(children: items);
    }

    final cols = List.generate(columns, (_) => <Widget>[]);
    var adInserted = false;

    for (var i = 0; i < articles.length; i++) {
      final targetCol = i % columns;
      cols[targetCol].add(ArticleCard(article: articles[i], vm: vm));

      if (i == 1 && nativeAd != null && !adInserted) {
        cols[(targetCol + 1) % columns].add(InFeedNativeAdCard(ad: nativeAd, vm: vm));
        adInserted = true;
      }
    }

    return FDRow(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: cols
          .map((c) => Expanded(child: FDColumn(children: c)))
          .expand((w) => [w, const FDSizedBox(width: 20)])
          .take(columns * 2 - 1)
          .toList(),
    );
  }
}
