import 'package:news_models/news_models.dart';
import '../mock_data.dart';

/// Contract for the News data service layer.
abstract class NewsService {
  List<Article> getArticles({String? category, String? city, String? query});
  StoryCluster getFullCoverageCluster();
  List<TimelineEvent> getClusterTimeline();
  WeatherSnapshot getWeather(String city);
  List<MarketTickerItem> getMarketTickers();
  List<String> getTrendingTags();
  List<AppNotification> getNotifications();
  List<ArticleComment> getComments(String articleId);
  List<String> getAvailableInterests();
  List<SponsoredAd> getSponsoredAds();
}

/// In-memory / Mock implementation for end-to-end self-contained testing.
class MockNewsService implements NewsService {
  @override
  List<Article> getArticles({String? category, String? city, String? query}) {
    var list = WebMockData.sampleArticles;

    if (category != null && category != 'top' && category != 'all') {
      list = list.where((a) => a.category.toLowerCase() == category.toLowerCase()).toList();
    }

    if (city != null) {
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

    return list;
  }

  @override
  StoryCluster getFullCoverageCluster() => WebMockData.fullCoverageCluster;

  @override
  List<TimelineEvent> getClusterTimeline() => WebMockData.clusterTimeline;

  @override
  WeatherSnapshot getWeather(String city) {
    return WebMockData.cityWeatherMap[city] ?? WebMockData.currentWeather;
  }

  @override
  List<MarketTickerItem> getMarketTickers() => WebMockData.marketTicker;

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
  List<SponsoredAd> getSponsoredAds() => List.from(WebMockData.initialAds);
}
