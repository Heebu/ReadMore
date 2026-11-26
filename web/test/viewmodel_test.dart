import 'package:news_models/news_models.dart';
import 'package:read_more_web/core/utils/article_helper.dart';
import 'package:read_more_web/core/utils/time_formatter.dart';
import 'package:read_more_web/data/services/news_service.dart';
import 'package:read_more_web/viewmodels/news_app_viewmodel.dart';
import 'package:test/test.dart';

void main() {
  group('QA Fixes — ViewModel, Helpers & Guest/Auth Flow', () {
    test('Starts cleanly as Guest without mock user leakage, and clears state on Sign Out', () async {
      final vm = NewsAppViewModel(service: MockNewsService());

      expect(vm.isAuthenticated, isFalse);
      expect(vm.currentUser.displayName, equals('Guest Reader'));
      expect(vm.currentUser.readingStreakDays, equals(0));
      expect(vm.currentUser.articlesReadCount, equals(0));
      expect(vm.bookmarkedIds, isEmpty);
      expect(vm.readLaterIds, isEmpty);
      expect(vm.readingHistoryIds, isEmpty);

      // Guest comment is attributed as Guest Reader, never Verified Reader
      final firstArticle = vm.sampleArticles.first;
      vm.openArticleReader(firstArticle);
      vm.setNewCommentDraft('Guest perspective');
      vm.postComment();
      expect(vm.comments.first.author, equals('Guest Reader'));
      expect(vm.comments.first.author, isNot(contains('Verified Reader')));
      expect(vm.newCommentDraft, isEmpty);

      // Toggling audio does not duplicate comments
      final countBefore = vm.comments.length;
      vm.toggleAudioPlaying();
      vm.toggleAudioPlaying();
      expect(vm.comments.length, equals(countBefore));

      // Sign in via offline fallback updates user cleanly
      await vm.signInWithEmail('reader@example.com', 'Secret123!');
      expect(vm.isAuthenticated, isTrue);
      expect(vm.currentUser.email, equals('reader@example.com'));

      vm.toggleBookmark(firstArticle.id);
      vm.openArticleReader(firstArticle);
      expect(vm.bookmarkedIds, contains(firstArticle.id));
      expect(vm.readingHistoryIds, contains(firstArticle.id));

      // Sign Out resets all user-specific collections and identity
      vm.signOut();
      expect(vm.isAuthenticated, isFalse);
      expect(vm.currentUser.displayName, equals('Guest Reader'));
      expect(vm.currentUser.readingStreakDays, equals(0));
      expect(vm.bookmarkedIds, isEmpty);
      expect(vm.readLaterIds, isEmpty);
      expect(vm.likedIds, isEmpty);
      expect(vm.readingHistoryIds, isEmpty);
      expect(vm.isAudioPlaying, isFalse);
    });

    test('For You category pill works with both for-you and for_you slugs', () {
      final vm = NewsAppViewModel(service: MockNewsService());

      vm.setSelectedCategory('for-you');
      expect(vm.activeScreen, equals('for_you'));
      expect(vm.personalizedArticles, isNotEmpty);

      vm.setActiveScreen('headlines');
      vm.setSelectedCategory('for_you');
      expect(vm.activeScreen, equals('for_you'));
    });

    test('openArticleById opens the exact targeted article instead of feed item 0', () async {
      final vm = NewsAppViewModel(service: MockNewsService());

      await vm.openArticleById('seed-science-1');
      expect(vm.activeReadingArticle, isNotNull);
      expect(vm.activeReadingArticle!.id, equals('seed-science-1'));

      // Re-opening does not duplicate reading history
      await vm.openArticleById('seed-science-1');
      expect(vm.readingHistoryIds.where((id) => id == 'seed-science-1').length, equals(1));
    });

    test('Audio autoplay honors user preference when authenticated', () async {
      final vm = NewsAppViewModel(service: MockNewsService());
      final art = vm.sampleArticles.first;

      // Guest: audioAutoplay is false
      vm.openArticleReader(art);
      expect(vm.isAudioPlaying, isFalse);
      vm.closeArticleReader();

      // Sign in and enable audioAutoplay
      await vm.signInWithEmail('audio@example.com', 'Password123!');
      vm.updateUserProfile(audioAutoplay: true);
      vm.openArticleReader(art);
      expect(vm.isAudioPlaying, isTrue);
      vm.closeArticleReader();

      // Disable audioAutoplay
      vm.updateUserProfile(audioAutoplay: false);
      vm.openArticleReader(art);
      expect(vm.isAudioPlaying, isFalse);
      vm.dispose();
    });

    test('MockNewsService trending tags all match real articles and local city never leaks unrelated cities', () {
      final service = MockNewsService();
      for (final tag in service.getTrendingTags()) {
        final query = tag.replaceAll('#', '');
        final results = service.getArticles(query: query);
        expect(results, isNotEmpty, reason: 'Mock trending tag $tag matched 0 articles');
      }

      final lagos = service.getLocalArticles(city: 'Lagos');
      expect(lagos, isNotEmpty);
      expect(lagos.every((a) => a.city == 'Lagos'), isTrue);

      expect(service.getLocalArticles(city: 'UnknownCity'), isEmpty);
    });

    test('article_helper produces topic-accurate takeaways and detects RSS excerpts', () {
      final techArticle = Article(
        id: 't1',
        title: 'Quantum Chip Milestone',
        slug: 'quantum-chip-milestone',
        summary: 'Engineers demonstrated a 1,000-qubit superconducting chip…',
        content: 'Engineers demonstrated a 1,000-qubit superconducting chip…',
        originalUrl: 'https://example.com/q',
        source: const NewsSource(id: 'tc', name: 'TechCrunch', slug: 'techcrunch', domain: 'techcrunch.com', iconUrl: ''),
        category: 'tech',
        tags: const ['Quantum', 'Hardware'],
        publishedAt: DateTime.now(),
        readTimeMinutes: 3,
      );

      final takeaways = buildArticleTakeaways(techArticle);
      expect(takeaways.length, equals(3));
      expect(takeaways.join(' '), isNot(contains('2035')));
      expect(takeaways.join(' '), contains('TechCrunch'));
      expect(isArticleExcerpt(techArticle), isTrue);

      final fullArticle = techArticle.copyWith(
        content:
            'First full paragraph explaining the quantum breakthrough in detail with more than enough context.\n\n'
            'Second full paragraph covering error correction rates across cryogenic cooling stages and benchmark verification.\n\n'
            'Third full paragraph detailing commercial roadmap and materials discovery simulations over the coming years.\n\n'
            'Fourth paragraph providing industrial deployment timelines and long-term superconducting material impact across laboratories.',
      );
      expect(isArticleExcerpt(fullArticle), isFalse);
      expect(splitArticleParagraphs(fullArticle).length, equals(4));

      // Quoted sentences must never be split inside quotation marks
      final quotedArticle = techArticle.copyWith(
        summary: '“We fight to end FGM because it is a human rights violation. We are not fighting culture.” Caroline Lagat discusses the challenges.',
        content: '“We fight to end FGM because it is a human rights violation. We are not fighting culture.” Caroline Lagat discusses the challenges.',
      );
      final quotedTakeaways = buildArticleTakeaways(quotedArticle);
      expect(
        quotedTakeaways.first,
        equals('“We fight to end FGM because it is a human rights violation. We are not fighting culture.” Caroline Lagat discusses the challenges.'),
      );
      expect(isArticleExcerpt(quotedArticle), isTrue);

      // Category search works for #Tech
      final service = MockNewsService();
      expect(service.getArticles(query: 'Tech').length, greaterThanOrEqualTo(2));
    });

    test('time_formatter formats relative timestamps and masthead dates accurately', () {
      final now = DateTime(2026, 11, 25, 15, 0);
      expect(formatRelativeTime(now.subtract(const Duration(minutes: 15)), now: now), equals('15m ago'));
      expect(formatRelativeTime(now.subtract(const Duration(hours: 3)), now: now), equals('3h ago'));
      expect(formatRelativeTime(DateTime(2022, 4, 14, 10, 15), now: now), equals('Apr 14, 2022'));
      expect(formatMastheadDate(now), equals('WEDNESDAY, NOV 25, 2026'));
    });
  });
}
