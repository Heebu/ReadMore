import 'dart:math';
import 'package:news_models/news_models.dart';
import '../user/engagement_service.dart';
import 'news_repository.dart';

/// Algorithmic recommendation engine powering the "For You" personalized feed
class RecommendationEngine {
  final NewsRepository _newsRepo;
  final EngagementService _engagementService;

  RecommendationEngine({
    required NewsRepository newsRepo,
    required EngagementService engagementService,
  })  : _newsRepo = newsRepo,
        _engagementService = engagementService;

  /// Generates a personalized stream of articles customized to the user's profile and telemetry
  List<Article> getForYouFeed({
    required UserPreferences preferences,
    String? userId,
    int limit = 25,
    int offset = 0,
  }) {
    final allArticles = _newsRepo.getArticles(limit: 250);
    if (allArticles.isEmpty) return [];

    final blockedSources = preferences.blockedSources.map((s) => s.toLowerCase()).toSet();
    final mutedTopics = preferences.mutedTopics.map((t) => t.toLowerCase()).toSet();
    final followedTopics = preferences.followedTopics.map((t) => t.toLowerCase()).toSet();

    // User's implicit topic affinity learned from dwell time & clicks
    final topicAffinities = userId != null
        ? _engagementService.calculateTopicAffinities(userId)
        : <String, double>{};

    final now = DateTime.now();
    final scoredArticles = <Article>[];

    for (final article in allArticles) {
      // Hard filter: Never show blocked sources or muted topics
      if (blockedSources.contains(article.source.slug.toLowerCase()) ||
          blockedSources.contains(article.source.name.toLowerCase())) {
        continue;
      }
      if (mutedTopics.contains(article.category.toLowerCase())) {
        continue;
      }

      // 1. Topic Affinity Score (0.0 to 1.0)
      var topicScore = 0.2; // Baseline
      final catLower = article.category.toLowerCase();
      final matchesFollowedTopic = followedTopics.contains(catLower) ||
          followedTopics.any((topic) =>
              catLower.contains(topic) ||
              topic.contains(catLower) ||
              article.tags.any((t) =>
                  topic.contains(t.toLowerCase()) ||
                  t.toLowerCase().contains(topic.replaceAll(' ', ''))));
      if (matchesFollowedTopic) {
        topicScore = 1.0;
      } else if (topicAffinities.containsKey(catLower)) {
        topicScore = (topicAffinities[catLower] ?? 0.2).clamp(0.0, 1.0);
      }

      // 2. Freshness Decay (Exponential decay over hours)
      final hoursOld = now.difference(article.publishedAt).inMinutes / 60.0;
      final freshnessScore = exp(-0.06 * hoursOld); // Halves roughly every 12 hours

      // 3. Geolocation Match
      var geoScore = 0.0;
      if (preferences.locationCountry != null &&
          article.country?.toLowerCase() == preferences.locationCountry?.toLowerCase()) {
        geoScore += 0.5;
      }
      if (preferences.locationCity != null &&
          article.city?.toLowerCase() == preferences.locationCity?.toLowerCase()) {
        geoScore += 0.5;
      }

      // 4. Global Engagement Velocity
      final engagementScore = ((article.viewCount * 0.1 + article.likeCount * 2) / 100).clamp(0.0, 1.0);

      // Composite Score Formula
      final totalScore = (topicScore * 0.35) +
          (freshnessScore * 0.25) +
          (geoScore * 0.20) +
          (engagementScore * 0.20);

      scoredArticles.add(article.copyWith(relevanceScore: totalScore));
    }

    // Sort by descending score
    scoredArticles.sort((a, b) => (b.relevanceScore ?? 0).compareTo(a.relevanceScore ?? 0));

    // Exploration / Serendipity Injection (every 5th article is a high-quality diverse discovery)
    final finalizedFeed = _injectSerendipity(scoredArticles, followedTopics);

    if (offset >= finalizedFeed.length) return [];
    final end = (offset + limit).clamp(0, finalizedFeed.length);
    return finalizedFeed.sublist(offset, end);
  }

  List<Article> _injectSerendipity(List<Article> scored, Set<String> followedTopics) {
    if (scored.length <= 5) return scored;

    final result = <Article>[];
    final explorationPool = scored
        .where((a) => !followedTopics.contains(a.category.toLowerCase()))
        .toList();

    var exploreIndex = 0;
    for (var i = 0; i < scored.length; i++) {
      if ((i + 1) % 5 == 0 && exploreIndex < explorationPool.length) {
        final exploreArticle = explorationPool[exploreIndex++];
        if (!result.contains(exploreArticle)) {
          result.add(exploreArticle);
          continue;
        }
      }
      if (!result.contains(scored[i])) {
        result.add(scored[i]);
      }
    }

    return result;
  }
}
