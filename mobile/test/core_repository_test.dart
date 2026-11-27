import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mobile/core/utils/article_helper.dart';
import 'package:mobile/core/utils/time_formatter.dart';
import 'package:mobile/data/mock/mock_data.dart';
import 'package:mobile/data/services/news_repository.dart';
import 'package:mobile/data/services/token_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Phase 1 — Core Utils & ApiNewsRepository', () {
    test('formatRelativeTime and formatMastheadDate format accurately', () {
      final now = DateTime(2026, 11, 27, 12, 0);
      expect(formatRelativeTime(now.subtract(const Duration(minutes: 15)), now: now), '15m ago');
      expect(formatRelativeTime(now.subtract(const Duration(hours: 3)), now: now), '3h ago');
      expect(formatMastheadDate(now), 'FRIDAY, NOV 27, 2026');
    });

    test('article_helper produces topic takeaways and paragraph splits', () {
      final hero = MobileMockData.sampleArticles.first;
      final paragraphs = splitArticleParagraphs(hero);
      final takeaways = buildArticleTakeaways(hero);

      expect(paragraphs.length, greaterThanOrEqualTo(3));
      expect(takeaways, isNotEmpty);
      expect(takeaways.length, lessThanOrEqualTo(3));
      expect(isArticleExcerpt(hero), isFalse);
    });

    test('TokenStorageService persists JWT, location, darkMode, and guest lists', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = await TokenStorageService.create();

      await storage.saveToken('jwt-test-token');
      expect(storage.getToken(), 'jwt-test-token');
      expect(storage.wasExplicitlySignedOut, isFalse);

      await storage.markSignedOut();
      expect(storage.getToken(), isNull);
      expect(storage.wasExplicitlySignedOut, isTrue);

      await storage.saveLocation('Lagos', 'Nigeria');
      expect(storage.getCity(), 'Lagos');
      expect(storage.getEdition(), 'Nigeria');

      await storage.saveDarkMode(true);
      expect(storage.getDarkMode(), isTrue);
    });

    test('ApiNewsRepository connects to backend endpoints with Bearer JWT', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = await TokenStorageService.create();
      final recordedAuthHeaders = <String?>[];

      final client = MockClient((request) async {
        recordedAuthHeaders.add(request.headers['Authorization']);
        if (request.url.path.endsWith('/api/auth/login')) {
          return http.Response(
            jsonEncode({
              'token': 'jwt_mobile_123',
              'user': {
                'id': 'u-1',
                'email': 'demo@readmore.com',
                'displayName': 'Demo Reader',
                'role': 'user',
                'createdAt': '2026-11-27T10:00:00.000Z',
                'subscriptionTier': 'pro',
                'adFreeEnabled': true,
                'readingStreakDays': 4,
                'articlesReadCount': 12,
                'preferences': {
                  'followedTopics': ['tech', 'top'],
                  'locationCity': 'London',
                  'locationCountry': 'United Kingdom',
                },
              },
            }),
            200,
          );
        }
        if (request.url.path.endsWith('/api/news')) {
          return http.Response(
            jsonEncode({
              'total': 1,
              'hasMore': false,
              'articles': [MobileMockData.sampleArticles.first.toJson()],
            }),
            200,
          );
        }
        if (request.url.path.endsWith('/api/user/bookmarks') &&
            request.method == 'POST') {
          return http.Response(jsonEncode({'message': 'Saved'}), 201);
        }
        return http.Response('{}', 200);
      });

      final repo = ApiNewsRepository(
        baseUrl: 'http://localhost:8085/api',
        client: client,
        storage: storage,
      );

      final loginResult = await repo.loginAsync('demo@readmore.com', 'Password123!');
      expect(loginResult['token'], 'jwt_mobile_123');
      expect(repo.authToken, 'jwt_mobile_123');
      expect(storage.getToken(), 'jwt_mobile_123');

      final feed = await repo.fetchArticlesAsync();
      expect(feed.articles, isNotEmpty);
      expect(repo.isBackendConnected, isTrue);

      final saved = await repo.saveBookmarkAsync('seed-top-1');
      expect(saved, isTrue);
      expect(recordedAuthHeaders.last, 'Bearer jwt_mobile_123');

      await repo.markSignedOut();
      expect(repo.authToken, isNull);
      expect(repo.wasExplicitlySignedOut, isTrue);
    });
  });
}
