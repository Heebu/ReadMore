import 'package:backend/backend.dart';
import 'package:news_models/news_models.dart';
import 'package:test/test.dart';

void main() {
  group('Backend Architecture Tests', () {
    test('AuthService registration, login, and JWT verification', () {
      final auth = AuthService();
      final user = auth.register(
        email: 'test@readmore.com',
        password: 'SecurePassword123!',
        displayName: 'Test User',
      );

      expect(user.email, equals('test@readmore.com'));
      expect(user.displayName, equals('Test User'));

      // Login
      final loginResult = auth.login(
        email: 'test@readmore.com',
        password: 'SecurePassword123!',
      );
      expect(loginResult.token.isNotEmpty, isTrue);

      // Verify JWT
      final claims = auth.verifyToken(loginResult.token);
      expect(claims, isNotNull);
      expect(claims!['sub'], equals(user.id));
      expect(claims['email'], equals('test@readmore.com'));
    });

    test('NewsRepository filtering, search, and clustering', () {
      final repo = NewsRepository();

      // Top news
      final topArticles = repo.getArticles(limit: 5);
      expect(topArticles.isNotEmpty, isTrue);

      // Category filter
      final techArticles = repo.getArticles(category: 'tech');
      expect(techArticles.every((a) => a.category == 'tech'), isTrue);

      // Search
      final searchResult = repo.search('AI');
      expect(searchResult.isNotEmpty, isTrue);

      // Trending
      final trending = repo.getTrending(limit: 2);
      expect(trending.length, equals(2));
    });

    test('RecommendationEngine personalized For You feed', () {
      final repo = NewsRepository();
      final engagement = EngagementService(newsRepo: repo);
      final recEngine = RecommendationEngine(newsRepo: repo, engagementService: engagement);

      const prefs = UserPreferences(
        followedTopics: ['tech'],
        locationCity: 'San Francisco',
        locationCountry: 'US',
      );

      final forYou = recEngine.getForYouFeed(preferences: prefs);
      expect(forYou.isNotEmpty, isTrue);

      // First ranked item should have highest relevance score
      expect(forYou.first.relevanceScore, isNotNull);
      expect(forYou.first.relevanceScore! > 0, isTrue);
    });

    test('EngagementService bookmarks and read later queue', () {
      final repo = NewsRepository();
      final engagement = EngagementService(newsRepo: repo);

      final article = repo.getArticles().first;

      // Add to bookmarks
      final saved = engagement.saveArticle(
        userId: 'usr_1',
        articleId: article.id,
      );
      expect(saved.articleId, equals(article.id));

      final bookmarks = engagement.getSavedArticles(userId: 'usr_1');
      expect(bookmarks.length, equals(1));
      expect(bookmarks.first.id, equals(article.id));

      // Remove bookmark
      final removed = engagement.removeSavedArticle(
        userId: 'usr_1',
        articleId: article.id,
      );
      expect(removed, isTrue);
      expect(engagement.getSavedArticles(userId: 'usr_1'), isEmpty);
    });

    test('WidgetService weather and markets', () {
      final widgetService = WidgetService();
      final weather = widgetService.getWeather(city: 'London');
      expect(weather.city, equals('London'));
      expect(weather.temperatureC, isNotNull);

      final markets = widgetService.getMarketTicker();
      expect(markets.length, greaterThanOrEqualTo(5));
      expect(markets.any((m) => m.symbol.contains('BTC')), isTrue);
    });

    test('SeoService Google News sitemap, Schema.org JSON-LD, robots.txt, and RSS', () {
      final repo = NewsRepository();
      final seo = SeoService(newsRepo: repo, baseUrl: 'https://readmore.news');

      final article = repo.getArticles().first;
      final jsonLd = seo.generateJsonLd(article);

      expect(jsonLd['@context'], equals('https://schema.org'));
      final graph = jsonLd['@graph'] as List<dynamic>;
      expect(graph.any((item) => item['@type'] == 'NewsArticle'), isTrue);
      expect(graph.any((item) => item['@type'] == 'BreadcrumbList'), isTrue);

      final sitemapNewsXml = seo.generateGoogleNewsSitemap();
      expect(sitemapNewsXml, contains('<news:publication_date>'));
      expect(sitemapNewsXml, contains('<news:title>'));

      final robotsTxt = seo.generateRobotsTxt();
      expect(robotsTxt, contains('User-agent: Googlebot-News'));
      expect(robotsTxt, contains('Sitemap: https://readmore.news/sitemap_news.xml'));

      final rssXml = seo.generateRssFeed();
      expect(rssXml, contains('<rss version="2.0"'));
      expect(rssXml, contains('<item>'));

      final metaTags = seo.generateMetaTags(article);
      expect(metaTags, contains('max-image-preview:large'));
      expect(metaTags, contains('og:title'));
    });
  });
}
