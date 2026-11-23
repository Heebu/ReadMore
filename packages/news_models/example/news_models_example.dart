import 'package:news_models/news_models.dart';

void main() {
  print('Available Categories:');
  for (final cat in NewsCategory.allCategories) {
    print('- ${cat.name} (/${cat.slug})');
  }
}
