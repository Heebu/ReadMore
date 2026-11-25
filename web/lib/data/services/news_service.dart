import 'package:news_models/news_models.dart';
import '../mock_data.dart';
export 'api_news_service.dart';

/// Contract for the News data service layer.
abstract class NewsService {
  List<Article> getArticles({String? category, String? city, String? query, String? source, String? sortBy});
  List<Article> getForYouArticles({Set<String>? interests});
  List<Article> getLocalArticles({String? city});
  List<Article> getBreakingArticles();
  List<Article> getTrendingArticles();
  List<NewsCategory> getCategories();
  StoryCluster getFullCoverageCluster();
  List<TimelineEvent> getClusterTimeline();
  WeatherSnapshot getWeather(String city);
  List<MarketTickerItem> getMarketTickers({String? sector});
  List<String> getTrendingTags();
  List<AppNotification> getNotifications();
  List<ArticleComment> getComments(String articleId);
  List<String> getAvailableInterests();
  List<SponsoredAd> getSponsoredAds({String? placement, String? category});
}

/// In-memory / Mock implementation for end-to-end self-contained fallback & tests.
class MockNewsService implements NewsService {
  @override
  List<Article> getArticles({String? category, String? city, String? query, String? source, String? sortBy}) {
    var list = WebMockData.sampleArticles;

    if (category != null && category != 'top' && category != 'all') {
      list = list.where((a) => a.category.toLowerCase() == category.toLowerCase()).toList();
    }

    if (city != null && city.isNotEmpty) {
      list = list.where((a) {
        return a.category == 'local' &&
            (a.tags.any((t) => t.toLowerCase() == city.toLowerCase()) ||
                a.title.toLowerCase().contains(city.toLowerCase()) ||
                a.summary.toLowerCase().contains(city.toLowerCase()));
      }).toList();
    }

    if (query != null && query.trim().isNotEmpty) {
      final q = query.toLowerCase().trim();
      list = list.where((a) {
        return a.title.toLowerCase().contains(q) ||
            a.summary.toLowerCase().contains(q) ||
            a.tags.any((t) => t.toLowerCase().contains(q)) ||
            a.source.name.toLowerCase().contains(q);
      }).toList();
    }

    if (source != null && source != 'all') {
      list = list.where((a) => a.source.slug == source).toList();
    }

    if (sortBy == 'most_read' || sortBy == 'popular') {
      list = List.from(list)..sort((a, b) => b.likeCount.compareTo(a.likeCount));
    }

    return list;
  }

  @override
  List<Article> getForYouArticles({Set<String>? interests}) {
    final all = WebMockData.sampleArticles;
    if (interests == null || interests.isEmpty) return all;
    final matched = all.where((a) {
      return a.tags.any((t) => interests.any((ui) => ui.toLowerCase().contains(t.toLowerCase()))) ||
          interests.any((ui) => a.category.toLowerCase().contains(ui.toLowerCase()));
    }).toList();
    return matched.isNotEmpty ? matched : all;
  }

  @override
  List<Article> getLocalArticles({String? city}) {
    final matched = getArticles(city: city);
    if (matched.isNotEmpty) return matched;
    return WebMockData.sampleArticles.where((a) => a.category == 'local').toList();
  }

  @override
  List<Article> getBreakingArticles() {
    return WebMockData.sampleArticles.where((a) => a.isBreaking).toList();
  }

  @override
  List<Article> getTrendingArticles() {
    return List.from(WebMockData.sampleArticles)
      ..sort((a, b) => (b.viewCount + b.likeCount).compareTo(a.viewCount + a.likeCount));
  }

  @override
  List<NewsCategory> getCategories() => NewsCategory.allCategories;

  @override
  StoryCluster getFullCoverageCluster() => WebMockData.fullCoverageCluster;

  @override
  List<TimelineEvent> getClusterTimeline() => WebMockData.clusterTimeline;

  @override
  WeatherSnapshot getWeather(String city) {
    return WebMockData.cityWeatherMap[city] ?? WebMockData.currentWeather;
  }

  @override
  List<MarketTickerItem> getMarketTickers({String? sector}) {
    if (sector == null || sector == 'All') return WebMockData.marketTicker;
    final filtered = WebMockData.marketTicker.where((m) => m.sector == sector).toList();
    return filtered.isNotEmpty ? filtered : WebMockData.marketTicker;
  }

  @override
  List<String> getTrendingTags() => WebMockData.trendingTags;

  @override
  List<AppNotification> getNotifications() => WebMockData.notifications;

  @override
  List<ArticleComment> getComments(String articleId) {
    return List.from(WebMockData.initialComments);
  }

  @override
  List<String> getAvailableInterests() => WebMockData.allAvailableInterests;

  @override
  List<SponsoredAd> getSponsoredAds({String? placement, String? category}) {
    var list = List<SponsoredAd>.from(WebMockData.initialAds);
    if (placement != null) {
      list = list.where((a) => a.placement.toString().contains(placement)).toList();
    }
    if (category != null && category != 'all') {
      list = list.where((a) => a.targetCategory == 'all' || a.targetCategory == category).toList();
    }
    return list;
  }
}
