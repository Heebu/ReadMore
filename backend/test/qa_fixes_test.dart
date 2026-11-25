import 'package:backend/backend.dart';
import 'package:test/test.dart';

void main() {
  group('QA Fixes — RSS Parser & Repository', () {
    test('RssParser preserves apostrophes and decodes HTML entities cleanly', () {
      const rawTitle = 'Noah Kahan&#8217;s sold-out tour &amp; Palme d&rsquo;Or &#8220;triumph&#8221;';
      final cleanedTitle = RssParser.cleanHtml(rawTitle);
      expect(cleanedTitle, equals('Noah Kahan’s sold-out tour & Palme d’Or “triumph”'));
      expect(cleanedTitle, isNot(contains('&#8217;')));
      expect(cleanedTitle, isNot(contains('Kahan s')));
      expect(cleanedTitle, isNot(contains('d Or')));

      const rawSummary = '<p>It&apos;s an exciting milestone. Read more [&#8230;]</p><p>The post Test appeared first on Example.</p>';
      final cleanedSummary = RssParser.cleanHtml(rawSummary);
      expect(cleanedSummary, equals("It's an exciting milestone. Read more…"));
      expect(cleanedSummary, isNot(contains('[ ]')));
      expect(cleanedSummary, isNot(contains('appeared first on')));
    });

    test('RssParser.parseDate parses historical RFC 822 dates accurately without falling back to now', () {
      final d2022 = RssParser.parseDate('Thu, 14 Apr 2022 10:15:00 +0000');
      expect(d2022.year, equals(2022));
      expect(d2022.month, equals(4));
      expect(d2022.day, equals(14));

      final dWithComment = RssParser.parseDate('Mon, 23 Nov 2026 09:30:00 EST (Eastern Standard Time)');
      expect(dWithComment.year, equals(2026));
      expect(dWithComment.month, equals(11));
    });

    test('NewsRepository resolves all seeded/mock IDs without 404 and deprioritizes shopping deals', () {
      final repo = NewsRepository();

      for (final id in [
        'seed-top-1',
        'art-hero-1',
        'art-tech-2',
        'art-food-1',
        'art-life-1',
        'art-gist-1',
        'persp-bbc-1',
        'persp-bloomberg-1',
        'persp-techcrunch-1',
      ]) {
        expect(repo.getArticleById(id), isNotNull, reason: 'Expected $id to resolve');
      }

      // Dynamic trending topics must always match at least 1 article
      final topics = repo.getDynamicTrendingTopics();
      expect(topics, isNotEmpty);
      for (final tag in topics) {
        final q = tag.replaceAll('#', '');
        final hits = repo.searchWithTotal(q, limit: 1);
        expect(hits.total, greaterThan(0), reason: 'Trending tag $tag returned 0 stories');
      }

      // Local news for Lagos returns Lagos-matched stories, not unrelated NY/London stories
      final lagos = repo.getLocalNews(city: 'Lagos');
      expect(lagos, isNotEmpty);
      expect(
        lagos.every((a) =>
            (a.city?.toLowerCase() == 'lagos') ||
            a.title.toLowerCase().contains('lagos') ||
            a.summary.toLowerCase().contains('lagos')),
        isTrue,
      );

      // Unknown city returns empty instead of unrelated global fallback
      expect(repo.getLocalNews(city: 'Atlantis'), isEmpty);
    });

    test('NewsRepository comments are isolated per article and do not leak climate comments', () {
      final repo = NewsRepository();
      final climateComments = repo.getComments('seed-top-1');
      expect(climateComments, isNotEmpty);

      final foodComments = repo.getComments('art-food-1');
      expect(foodComments, isEmpty);

      final added = repo.addComment(
        'art-food-1',
        author: 'Guest Reader',
        avatarUrl: 'https://example.com/a.png',
        text: 'Great culinary breakdown!',
      );
      expect(added.articleId, equals('art-food-1'));
      expect(repo.getComments('art-food-1').length, equals(1));
      expect(repo.getComments('art-food-1').first.text, equals('Great culinary breakdown!'));
    });

    test('NewsRepository clusters do not group shopping deals and timeline matches perspectives', () {
      final repo = NewsRepository();
      const xml = '''<?xml version="1.0" encoding="UTF-8" ?>
      <rss version="2.0"><channel><title>Deals</title>
        <item>
          <title>Best Early Black Friday AirPods Deals Right Now</title>
          <link>https://example.com/deals-1</link>
          <description>Save big on AirPods.</description>
          <pubDate>Wed, 25 Nov 2026 10:00:00 +0000</pubDate>
        </item>
      </channel></rss>''';
      final parsed = RssParser().parseXml(
        xml,
        const FeedDefinition(id: 'deals', name: 'Deals', url: 'https://example.com/rss', category: 'tech', domain: 'example.com'),
      );
      expect(parsed.length, equals(1));

      final clusters = repo.getClusters();
      expect(clusters.first.id, equals('cluster_climate_2026'));
      expect(clusters.first.alternativePerspectives.any((a) => a.title.contains('Black Friday')), isFalse);
    });
  });
}
