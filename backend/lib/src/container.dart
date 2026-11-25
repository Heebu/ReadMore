import 'package:backend/src/auth/auth_service.dart';
import 'package:backend/src/news/news_repository.dart';
import 'package:backend/src/news/recommendation_engine.dart';
import 'package:backend/src/news/rss_parser.dart';
import 'package:backend/src/seo/seo_service.dart';
import 'package:backend/src/user/engagement_service.dart';
import 'package:backend/src/widgets/widget_service.dart';

/// Central dependency container providing shared services across Dart Frog routes
class AppContainer {
  static AppContainer? _instance;

  final AuthService authService;
  final NewsRepository newsRepository;
  final EngagementService engagementService;
  final RecommendationEngine recommendationEngine;
  final WidgetService widgetService;
  final SeoService seoService;

  AppContainer._({
    required this.authService,
    required this.newsRepository,
    required this.engagementService,
    required this.recommendationEngine,
    required this.widgetService,
    required this.seoService,
  });

  factory AppContainer.create() {
    if (_instance != null) return _instance!;

    final authService = AuthService();
    final newsRepository = NewsRepository(parser: RssParser());
    final engagementService = EngagementService(newsRepo: newsRepository);
    final recommendationEngine = RecommendationEngine(
      newsRepo: newsRepository,
      engagementService: engagementService,
    );
    final widgetService = WidgetService();
    final seoService = SeoService(newsRepo: newsRepository);

    // Seed initial bookmarks & read-later queue for default demo user
    final demoUser = authService.getUserByEmail('demo@readmore.com');
    if (demoUser != null) {
      engagementService.saveArticle(userId: demoUser.id, articleId: 'seed-top-1', isReadLater: false);
      engagementService.saveArticle(userId: demoUser.id, articleId: 'seed-tech-1', isReadLater: false);
      engagementService.saveArticle(userId: demoUser.id, articleId: 'seed-business-1', isReadLater: false);
      engagementService.saveArticle(userId: demoUser.id, articleId: 'seed-science-1', isReadLater: true);
    }

    // Start background RSS polling every 15 minutes
    newsRepository.startAutoPolling(interval: const Duration(minutes: 15));

    _instance = AppContainer._(
      authService: authService,
      newsRepository: newsRepository,
      engagementService: engagementService,
      recommendationEngine: recommendationEngine,
      widgetService: widgetService,
      seoService: seoService,
    );

    return _instance!;
  }

  static AppContainer get instance => _instance ?? AppContainer.create();
}
