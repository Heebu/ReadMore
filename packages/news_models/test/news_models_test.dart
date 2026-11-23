import 'package:news_models/news_models.dart';
import 'package:test/test.dart';

void main() {
  group('News Models Tests', () {
    test('NewsCategory has all required categories', () {
      expect(NewsCategory.allCategories.length, equals(12));
      expect(NewsCategory.findBySlug('tech')?.name, equals('Technology'));
      expect(NewsCategory.findBySlug('for-you')?.name, equals('For You'));
      expect(NewsCategory.findBySlug('local')?.name, equals('Local News'));
      expect(NewsCategory.findBySlug('gists')?.name, equals('Gists & Viral'));
    });

    test('Article JSON serialization and deserialization', () {
      const source = NewsSource(
        id: 'bbc-news',
        name: 'BBC News',
        slug: 'bbc-news',
        domain: 'bbc.com',
      );

      final article = Article(
        id: 'art-1',
        title: 'Tech Advances in AI',
        slug: 'tech-advances-in-ai',
        summary: 'A short summary of AI breakthroughs.',
        originalUrl: 'https://bbc.com/news/tech-1',
        source: source,
        category: 'tech',
        publishedAt: DateTime.parse('2026-11-23T12:00:00Z'),
        readTimeMinutes: 4,
        isBreaking: true,
      );

      final json = article.toJson();
      final restored = Article.fromJson(json);

      expect(restored.id, equals('art-1'));
      expect(restored.title, equals('Tech Advances in AI'));
      expect(restored.source.name, equals('BBC News'));
      expect(restored.category, equals('tech'));
      expect(restored.isBreaking, isTrue);
      expect(restored.readTimeMinutes, equals(4));
    });

    test('User and UserPreferences serialization', () {
      final user = User(
        id: 'u-1',
        email: 'user@example.com',
        displayName: 'John Doe',
        createdAt: DateTime.parse('2026-11-23T10:00:00Z'),
        preferences: const UserPreferences(
          followedTopics: ['tech', 'sports', 'food'],
          locationCity: 'San Francisco',
        ),
      );

      final json = user.toJson();
      final restored = User.fromJson(json);

      expect(restored.id, equals('u-1'));
      expect(restored.preferences.followedTopics, contains('tech'));
      expect(restored.preferences.locationCity, equals('San Francisco'));
    });
  });
}
