import 'dart:async';
import 'package:news_models/news_models.dart';
import 'feed_catalog.dart';
import 'rss_parser.dart';

/// Central store for news articles, clusters, and background ingestion
class NewsRepository {
  final RssParser _parser;
  final Map<String, Article> _articles = {};
  final Map<String, StoryCluster> _clusters = {};
  Timer? _pollingTimer;
  bool _isIngesting = false;

  NewsRepository({RssParser? parser}) : _parser = parser ?? RssParser() {
    _seedDefaultArticles();
  }

  /// Start automatic background polling at specified interval (e.g. every 15 minutes)
  void startAutoPolling({Duration interval = const Duration(minutes: 15)}) {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(interval, (_) => refreshAllFeeds());
    // Initial fetch in background
    refreshAllFeeds();
  }

  void stopAutoPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  /// Refreshes all feeds concurrently from external RSS feeds
  Future<int> refreshAllFeeds() async {
    if (_isIngesting) return 0;
    _isIngesting = true;

    var newCount = 0;
    try {
      final futures = FeedCatalog.feeds.map((feed) async {
        try {
          final items = await _parser.fetchFeed(feed);
          for (final item in items) {
            if (!_articles.containsKey(item.id)) {
              _articles[item.id] = item;
              newCount++;
              _checkAndClusterArticle(item);
            }
          }
        } catch (_) {}
      });

      await Future.wait(futures);
    } finally {
      _isIngesting = false;
    }
    return newCount;
  }

  List<Article> getArticles({
    String? category,
    String? country,
    int limit = 20,
    int offset = 0,
  }) {
    var list = _articles.values.toList();

    if (category != null && category.isNotEmpty && category != 'top' && category != 'all') {
      list = list.where((a) => a.category.toLowerCase() == category.toLowerCase()).toList();
    }

    if (country != null && country.isNotEmpty && country != 'global') {
      list = list.where((a) => a.country?.toLowerCase() == country.toLowerCase()).toList();
    }

    // Sort by publication time (newest first)
    list.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));

    if (offset >= list.length) return [];
    final end = (offset + limit).clamp(0, list.length);
    return list.sublist(offset, end);
  }

  Article? getArticleById(String id) => _articles[id];

  Article? getArticleBySlug(String slug) {
    for (final article in _articles.values) {
      if (article.slug == slug) return article;
    }
    return null;
  }

  List<Article> getBreakingNews({int limit = 5}) {
    final list = _articles.values.where((a) => a.isBreaking).toList()
      ..sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    return list.take(limit).toList();
  }

  List<Article> getTrending({int limit = 10}) {
    final list = _articles.values.toList()
      ..sort((a, b) => (b.viewCount + b.likeCount * 3).compareTo(a.viewCount + a.likeCount * 3));
    return list.take(limit).toList();
  }

  List<Article> getLocalNews({String? city, String? country, int limit = 15}) {
    var list = _articles.values.where((a) {
      if (city != null && a.city != null && a.city!.toLowerCase() == city.toLowerCase()) {
        return true;
      }
      if (country != null && a.country != null && a.country!.toLowerCase() == country.toLowerCase()) {
        return true;
      }
      return a.category == 'local';
    }).toList();

    list.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    if (list.isEmpty) {
      // Return top general news as fallback for local
      return getArticles(limit: limit);
    }
    return list.take(limit).toList();
  }

  List<Article> search(String query, {int limit = 20}) {
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return [];

    final matches = _articles.values.where((a) {
      return a.title.toLowerCase().contains(q) ||
          a.summary.toLowerCase().contains(q) ||
          a.tags.any((t) => t.toLowerCase().contains(q)) ||
          a.source.name.toLowerCase().contains(q);
    }).toList();

    matches.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    return matches.take(limit).toList();
  }

  List<StoryCluster> getClusters({int limit = 10}) {
    final list = _clusters.values.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return list.take(limit).toList();
  }

  StoryCluster? getClusterById(String id) => _clusters[id];

  void incrementViews(String articleId) {
    final art = _articles[articleId];
    if (art != null) {
      _articles[articleId] = art.copyWith(viewCount: art.viewCount + 1);
    }
  }

  void incrementLikes(String articleId) {
    final art = _articles[articleId];
    if (art != null) {
      _articles[articleId] = art.copyWith(likeCount: art.likeCount + 1);
    }
  }

  /// Full Coverage Algorithm: Detects when multiple sources report the same event
  void _checkAndClusterArticle(Article newArticle) {
    for (final existing in _articles.values) {
      if (existing.id == newArticle.id) continue;
      if (existing.source.id == newArticle.source.id) continue;

      final similarity = _calculateJaccardSimilarity(existing.title, newArticle.title);
      if (similarity >= 0.45) {
        // Group into cluster
        final clusterId = existing.clusterId ?? 'cluster_${existing.id}';
        
        final existingCluster = _clusters[clusterId];
        if (existingCluster != null) {
          _clusters[clusterId] = StoryCluster(
            id: clusterId,
            topicHeadline: existingCluster.topicHeadline,
            category: existingCluster.category,
            primaryArticle: existingCluster.primaryArticle,
            alternativePerspectives: [...existingCluster.alternativePerspectives, newArticle],
            updatedAt: DateTime.now(),
          );
        } else {
          _clusters[clusterId] = StoryCluster(
            id: clusterId,
            topicHeadline: existing.title,
            category: existing.category,
            primaryArticle: existing,
            alternativePerspectives: [newArticle],
            updatedAt: DateTime.now(),
          );
        }

        _articles[existing.id] = existing.copyWith(clusterId: clusterId);
        _articles[newArticle.id] = newArticle.copyWith(clusterId: clusterId);
        break;
      }
    }
  }

  double _calculateJaccardSimilarity(String a, String b) {
    final wordsA = a.toLowerCase().split(RegExp(r'\W+')).where((w) => w.length > 3).toSet();
    final wordsB = b.toLowerCase().split(RegExp(r'\W+')).where((w) => w.length > 3).toSet();
    if (wordsA.isEmpty || wordsB.isEmpty) return 0;
    final intersection = wordsA.intersection(wordsB).length;
    final union = wordsA.union(wordsB).length;
    return intersection / union;
  }

  void _seedDefaultArticles() {
    final sampleSources = {
      'bbc': const NewsSource(id: 'bbc', name: 'BBC News', slug: 'bbc', domain: 'bbc.com', iconUrl: 'https://www.google.com/s2/favicons?domain=bbc.com&sz=128'),
      'reuters': const NewsSource(id: 'reuters', name: 'Reuters', slug: 'reuters', domain: 'reuters.com', iconUrl: 'https://www.google.com/s2/favicons?domain=reuters.com&sz=128'),
      'techcrunch': const NewsSource(id: 'techcrunch', name: 'TechCrunch', slug: 'techcrunch', domain: 'techcrunch.com', iconUrl: 'https://www.google.com/s2/favicons?domain=techcrunch.com&sz=128'),
      'espn': const NewsSource(id: 'espn', name: 'ESPN', slug: 'espn', domain: 'espn.com', iconUrl: 'https://www.google.com/s2/favicons?domain=espn.com&sz=128'),
      'variety': const NewsSource(id: 'variety', name: 'Variety', slug: 'variety', domain: 'variety.com', iconUrl: 'https://www.google.com/s2/favicons?domain=variety.com&sz=128'),
    };

    final now = DateTime.now();

    final seeds = [
      Article(
        id: 'seed-top-1',
        title: 'Global Climate Summit Concludes With Historic Accord on Renewable Energy',
        slug: 'global-climate-summit-concludes-with-historic-accord',
        summary: 'Delegates from 195 nations have agreed to ambitious clean energy transition targets in a landmark treaty.',
        originalUrl: 'https://www.reuters.com/environment/summit-agreement-2026',
        imageUrl: 'https://images.unsplash.com/photo-1473341304170-971dccb5ac1e?auto=format&fit=crop&w=800&q=80',
        source: sampleSources['reuters']!,
        category: 'top',
        publishedAt: now.subtract(const Duration(minutes: 15)),
        readTimeMinutes: 4,
        isBreaking: true,
        viewCount: 1420,
        likeCount: 312,
      ),
      Article(
        id: 'seed-tech-1',
        title: 'Autonomous AI Agents Revolutionize Software Engineering Paradigms',
        slug: 'autonomous-ai-agents-revolutionize-software-engineering',
        summary: 'Next-generation reasoning models now orchestrate end-to-end full stack development pipelines autonomously.',
        originalUrl: 'https://techcrunch.com/2026/11/ai-agents-revolution/',
        imageUrl: 'https://images.unsplash.com/photo-1518770660439-4636190af475?auto=format&fit=crop&w=800&q=80',
        source: sampleSources['techcrunch']!,
        category: 'tech',
        publishedAt: now.subtract(const Duration(minutes: 45)),
        readTimeMinutes: 3,
        viewCount: 2890,
        likeCount: 780,
      ),
      Article(
        id: 'seed-sports-1',
        title: 'Champions League Thriller: Dramatic 94th Minute Stunner Secures Quarter-Finals',
        slug: 'champions-league-thriller-dramatic-94th-minute-stunner',
        summary: 'A breathtaking counter-attack in stoppage time delivered one of the greatest comebacks in modern football history.',
        originalUrl: 'https://www.espn.com/soccer/story/_/id/champions-league-thriller',
        imageUrl: 'https://images.unsplash.com/photo-1508098682722-e99c43a406b2?auto=format&fit=crop&w=800&q=80',
        source: sampleSources['espn']!,
        category: 'sports',
        publishedAt: now.subtract(const Duration(hours: 2)),
        readTimeMinutes: 3,
        viewCount: 5120,
        likeCount: 1205,
      ),
      Article(
        id: 'seed-ent-1',
        title: 'Blockbuster Sci-Fi Epic Breaks Global Box Office Records in Opening Weekend',
        slug: 'blockbuster-sci-fi-epic-breaks-global-box-office',
        summary: 'Director hailed for pioneering holographic visual effects that mesmerized cinema audiences worldwide.',
        originalUrl: 'https://variety.com/film/box-office-record-2026',
        imageUrl: 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?auto=format&fit=crop&w=800&q=80',
        source: sampleSources['variety']!,
        category: 'entertainment',
        publishedAt: now.subtract(const Duration(hours: 3)),
        readTimeMinutes: 2,
        viewCount: 3410,
        likeCount: 890,
      ),
    ];

    for (final s in seeds) {
      _articles[s.id] = s;
    }
  }
}
