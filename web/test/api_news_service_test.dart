import 'package:read_more_web/data/services/api_news_service.dart';
import 'package:test/test.dart';

void main() {
  group('ApiNewsService Live Backend Integration (localhost:8085)', () {
    late ApiNewsService service;

    setUpAll(() async {
      service = ApiNewsService(baseUrl: 'http://localhost:8085/api');
    });

    test('fetches news articles and single article by id', () async {
      final articles = await service.fetchArticlesAsync(limit: 10);
      expect(articles, isNotEmpty);

      final first = articles.first;
      final fetched = await service.fetchArticleByIdAsync(first.id);
      expect(fetched, isNotNull);
      expect(fetched!.id, first.id);
    });

    test('fetches weather, market tickers by sector, and trending tags', () async {
      final weather = await service.fetchWeatherAsync('Tokyo');
      expect(weather.city, 'Tokyo');
      expect(weather.forecast, isNotEmpty);

      final techMarkets = await service.fetchMarketTickersAsync(sector: 'Tech Equities');
      expect(techMarkets, isNotEmpty);
      expect(techMarkets.every((m) => m.sector == 'Tech'), isTrue);

      final tags = await service.fetchTrendingTagsAsync();
      expect(tags, isNotEmpty);
      expect(tags.first.startsWith('#'), isTrue);
    });

    test('fetches For You, Local, Breaking, Trending, Clusters, Categories, Ads, and Notifications', () async {
      final forYou = await service.fetchForYouAsync(topics: {'Artificial Intelligence'}, city: 'New York');
      expect(forYou, isNotEmpty);

      final local = await service.fetchLocalNewsAsync(city: 'New York');
      expect(local, isNotEmpty);

      final breaking = await service.fetchBreakingAsync();
      expect(breaking, isNotEmpty);

      final trending = await service.fetchTrendingArticlesAsync();
      expect(trending, isNotEmpty);

      final clusters = await service.fetchClustersAsync();
      expect(clusters, isNotEmpty);
      expect(clusters.first.id, 'cluster_climate_2026');

      final categories = await service.fetchCategoriesAsync();
      expect(categories, isNotEmpty);

      final ads = await service.fetchSponsoredAdsAsync();
      expect(ads, isNotEmpty);

      final notifs = await service.fetchNotificationsAsync();
      expect(notifs, isNotEmpty);
    });

    test('authenticates user, syncs bookmarks, read later, preferences, and subscription', () async {
      final loginRes = await service.loginAsync('demo@readmore.com', 'Password123!');
      expect(loginRes, isNotNull);
      expect(loginRes!['token'], isNotEmpty);

      final me = await service.fetchCurrentUserAsync();
      expect(me, isNotNull);
      expect(me!.email, 'demo@readmore.com');

      final bookmarks = await service.fetchBookmarksAsync();
      expect(bookmarks, isNotNull);
      expect(bookmarks!, isNotEmpty);

      final saved = await service.saveBookmarkAsync('seed-science-1');
      expect(saved, isTrue);

      final readLaterSaved = await service.saveReadLaterAsync('seed-sports-1');
      expect(readLaterSaved, isTrue);

      final updatedUser = await service.updatePreferencesAsync(
        displayName: 'Verified Broadsheet Reader',
        locationCity: 'London',
        enableBreakingAlerts: true,
      );
      expect(updatedUser, isNotNull);
      expect(updatedUser!.displayName, 'Verified Broadsheet Reader');
      expect(updatedUser.preferences.locationCity, 'London');

      final upgraded = await service.upgradeSubscriptionAsync(plan: 'annual', paymentMethod: 'Google Pay');
      expect(upgraded, isTrue);

      final adFreeToggled = await service.toggleAdFreeAsync();
      expect(adFreeToggled, isTrue);

      final canceled = await service.cancelSubscriptionAsync();
      expect(canceled, isTrue);

      final restoredUser = await service.updatePreferencesAsync(
        displayName: 'News Reader',
        locationCity: 'New York',
      );
      expect(restoredUser, isNotNull);
      expect(restoredUser!.displayName, 'News Reader');
    });

    test('posts comment to dedicated test article and toggles comment like without polluting seed-top-1', () async {
      final seedComments = await service.fetchCommentsAsync('seed-top-1');
      expect(seedComments, isNotEmpty);

      const testArticleId = 'integration-test-comments';
      final created = await service.postCommentAsync(
        testArticleId,
        author: 'Integration Tester',
        avatarUrl: 'https://example.com/a.png',
        text: 'Live backend comment verification!',
      );
      expect(created, isNotNull);
      expect(created!.articleId, testArticleId);
      expect(created.text, 'Live backend comment verification!');

      final fetched = await service.fetchCommentsAsync(testArticleId);
      expect(fetched.any((c) => c.id == created.id), isTrue);

      final liked = await service.toggleCommentLikeAsync(created.id);
      expect(liked, isTrue);
    });

    test('Google OAuth endpoint issues real JWT', () async {
      final res = await service.loginWithGoogleAsync();
      expect(res, isNotNull);
      expect(res!['token'], isNotEmpty);
    });

    test('validates invalid login, password reset flow, darkMode sync, and read count tracking', () async {
      final badLogin = await service.loginAsync('demo@readmore.com', 'WrongPass!');
      expect(badLogin, isNotNull);
      expect(badLogin!['error'], isNotNull);

      final regEmail = 'reset_${DateTime.now().millisecondsSinceEpoch}@readmore.com';
      final reg = await service.registerAsync(regEmail, 'StartPass1!', 'Reset Tester');
      expect(reg, isNotNull);
      expect(reg!['token'], isNotEmpty);

      final resetReq = await service.requestPasswordResetAsync(regEmail);
      expect(resetReq, isNotNull);
      expect(resetReq!['devResetCode'], isNotNull);

      final resetConfirm = await service.resetPasswordAsync(
        token: resetReq['devResetCode'] as String,
        newPassword: 'UpdatedPass2!',
      );
      expect(resetConfirm?['error'], isNull);

      final loginNew = await service.loginAsync(regEmail, 'UpdatedPass2!');
      expect(loginNew?['token'], isNotEmpty);

      final updatedUser = await service.updatePreferencesAsync(darkMode: false);
      expect(updatedUser, isNotNull);
      expect(updatedUser!.preferences.darkMode, isFalse);

      final afterRead = await service.recordInteractionAsync('seed-top-1', 'click');
      expect(afterRead, isNotNull);
      expect(afterRead!.articlesReadCount, greaterThanOrEqualTo(1));
    });
  });
}
