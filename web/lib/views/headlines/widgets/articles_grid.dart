import 'package:flartdart/flartdart.dart';
import 'package:news_models/news_models.dart';
import '../../../viewmodels/news_app_viewmodel.dart';
import 'article_card.dart';

/// Bento-style multi-column article grid.
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
    if (columns == 1) {
      return FDColumn(
        children: articles.map((article) => ArticleCard(article: article, vm: vm)).toList(),
      );
    }

    final cols = List.generate(columns, (_) => <Widget>[]);
    for (var i = 0; i < articles.length; i++) {
      cols[i % columns].add(ArticleCard(article: articles[i], vm: vm));
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
