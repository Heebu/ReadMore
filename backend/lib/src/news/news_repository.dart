import 'dart:async';
import 'package:news_models/news_models.dart';
import '../storage/database_service.dart';
import 'feed_catalog.dart';
import 'rss_parser.dart';

/// Central store for news articles, clusters, comments, ads, notifications, and background ingestion
class NewsRepository {
  final RssParser _parser;
  final DatabaseService? _db;
  final Map<String, Article> _articles = {};
  final Map<String, StoryCluster> _clusters = {};
  final Map<String, List<ArticleComment>> _comments = {};
  final Map<String, SponsoredAd> _ads = {};
  final List<AppNotification> _notifications = [];

  Timer? _pollingTimer;
  bool _isIngesting = false;

  static const Map<String, String> _legacyIdAliases = {
    'art-hero-1': 'seed-top-1',
    'art-tech-1': 'seed-tech-1',
    'art-bus-1': 'seed-business-1',
    'art-sci-1': 'seed-science-1',
    'art-sport-1': 'seed-sports-1',
    'art-ent-1': 'seed-ent-1',
    'art-local-ny': 'seed-local-1',
    'art-local-london': 'seed-local-london',
    'art-local-tokyo': 'seed-local-tokyo',
    'art-local-lagos': 'seed-local-lagos',
    'art-local-paris': 'seed-local-paris',
    'art-local-sf': 'seed-local-sf',
    'persp-bbc-1': 'cluster-alt-1',
    'persp-bloomberg-1': 'cluster-alt-2',
    'persp-techcrunch-1': 'cluster-alt-3',
  };

  static const Set<String> _stopAndPromoWords = {
    'about', 'after', 'again', 'against', 'almost', 'alone', 'along', 'already',
    'also', 'although', 'always', 'among', 'another', 'around', 'because',
    'before', 'being', 'below', 'between', 'both', 'could', 'doing', 'during',
    'each', 'either', 'enough', 'every', 'first', 'following', 'found', 'from',
    'further', 'great', 'have', 'having', 'here', 'hers', 'herself', 'himself',
    'into', 'itself', 'just', 'large', 'last', 'later', 'least', 'less', 'like',
    'likely', 'made', 'make', 'many', 'might', 'more', 'most', 'much', 'must',
    'neither', 'never', 'news', 'next', 'none', 'nothing', 'often', 'only',
    'other', 'others', 'ourselves', 'over', 'part', 'people', 'perhaps',
    'report', 'reports', 'said', 'same', 'several', 'should', 'since', 'some',
    'something', 'still', 'story', 'such', 'than', 'that', 'their', 'theirs',
    'them', 'themselves', 'then', 'there', 'these', 'they', 'thing', 'things',
    'think', 'this', 'those', 'though', 'through', 'time', 'today', 'under',
    'until', 'very', 'want', 'water', 'well', 'were', 'what', 'when', 'where',
    'whether', 'which', 'while', 'whom', 'whose', 'will', 'with', 'within',
    'without', 'would', 'year', 'years', 'your', 'yours',
    // E-commerce / shopping deal boilerplate
    'best', 'early', 'black', 'friday', 'cyber', 'monday', 'deal', 'deals',
    'sale', 'sales', 'save', 'discount', 'discounts', 'price', 'prices',
    'cheap', 'cheapest', 'promo', 'code', 'codes', 'coupon', 'coupons',
    'amazon', 'walmart', 'target', 'bestbuy', 'buying', 'guide', 'review',
    'reviews', 'worth', 'right', 'grab', 'picks', 'lowest', 'ever', 'ahead',
  };

  NewsRepository({RssParser? parser, DatabaseService? db})
      : _parser = parser ?? RssParser(),
        _db = db {
    _seedDefaultArticles();
    _seedDefaultComments();
    _seedDefaultAds();
    _seedDefaultNotifications();
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
      final seenTitles = <String>{
        for (final a in _articles.values) _normalizeTitle(a.title),
      };
      final cutoff = DateTime.now().subtract(const Duration(days: 365));

      final futures = FeedCatalog.feeds.map((feed) async {
        try {
          final items = await _parser.fetchFeed(feed);
          for (final item in items) {
            // Skip stale archive articles older than 1 year
            if (item.publishedAt.isBefore(cutoff)) continue;
            final normTitle = _normalizeTitle(item.title);
            if (!_articles.containsKey(item.id) && seenTitles.add(normTitle)) {
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

  String _normalizeTitle(String title) {
    return title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), ' ').trim();
  }

  // ==========================================
  // ARTICLES QUERYING WITH EXTENDED PARAMETERS
  // ==========================================

  ({List<Article> articles, int total}) getArticlesWithTotal({
    String? category,
    String? country,
    String? city,
    String? source,
    String? tag,
    String sortBy = 'latest',
    int limit = 20,
    int offset = 0,
  }) {
    var list = _articles.values.toList();

    // 1. Category Filter
    if (category != null && category.isNotEmpty && category != 'top' && category != 'all') {
      list = list.where((a) => a.category.toLowerCase() == category.toLowerCase()).toList();
    }

    // 2. Country Filter
    if (country != null && country.isNotEmpty && country != 'global') {
      list = list.where((a) => a.country?.toLowerCase() == country.toLowerCase()).toList();
    }

    // 3. City Filter
    if (city != null && city.isNotEmpty) {
      list = list.where((a) => _matchesCity(a, city)).toList();
    }

    // 4. Source Filter
    if (source != null && source.isNotEmpty && source != 'all') {
      final s = source.toLowerCase();
      list = list.where((a) {
        return a.source.slug.toLowerCase() == s ||
            a.source.id.toLowerCase() == s ||
            a.source.name.toLowerCase().contains(s) ||
            a.source.domain.toLowerCase().contains(s);
      }).toList();
    }

    // 5. Tag Filter
    if (tag != null && tag.isNotEmpty) {
      final t = tag.toLowerCase().replaceAll('#', '');
      list = list.where((a) => a.tags.any((item) => item.toLowerCase() == t)).toList();
    }

    // 6. Sorting
    switch (sortBy.toLowerCase()) {
      case 'most_read':
      case 'popular':
      case 'views':
        list.sort((a, b) => b.viewCount.compareTo(a.viewCount));
      case 'trending':
        list.sort((a, b) => (b.viewCount + b.likeCount * 3).compareTo(a.viewCount + a.likeCount * 3));
      case 'likes':
        list.sort((a, b) => b.likeCount.compareTo(a.likeCount));
      case 'latest':
      default:
        list.sort((a, b) {
          if (category == null || category == 'top' || category == 'all') {
            final aPromo = _isShoppingOrDealTitle(a.title) ? 1 : 0;
            final bPromo = _isShoppingOrDealTitle(b.title) ? 1 : 0;
            if (aPromo != bPromo) return aPromo.compareTo(bPromo);
          }
          return b.publishedAt.compareTo(a.publishedAt);
        });
    }

    // 7. Deduplicate by normalized title while preserving sort order
    final seenTitles = <String>{};
    list = list.where((a) => seenTitles.add(_normalizeTitle(a.title))).toList();

    final total = list.length;
    if (offset >= list.length) {
      return (articles: <Article>[], total: total);
    }
    final end = (offset + limit).clamp(0, list.length);
    return (articles: list.sublist(offset, end), total: total);
  }

  List<Article> getArticles({
    String? category,
    String? country,
    String? city,
    String? source,
    String? tag,
    String sortBy = 'latest',
    int limit = 20,
    int offset = 0,
  }) {
    return getArticlesWithTotal(
      category: category,
      country: country,
      city: city,
      source: source,
      tag: tag,
      sortBy: sortBy,
      limit: limit,
      offset: offset,
    ).articles;
  }

  Article? getArticleById(String id) {
    final direct = _articles[id];
    if (direct != null) return direct;
    final mapped = _legacyIdAliases[id];
    if (mapped != null) return _articles[mapped];
    return null;
  }

  Article? getArticleBySlug(String slug) {
    for (final article in _articles.values) {
      if (article.slug == slug) return article;
    }
    return null;
  }

  List<Article> getBreakingNews({int limit = 5}) {
    final list = _articles.values
        .where((a) => a.isBreaking && !_isShoppingOrDealTitle(a.title))
        .toList()
      ..sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    final seen = <String>{};
    return list.where((a) => seen.add(_normalizeTitle(a.title))).take(limit).toList();
  }

  List<Article> getTrending({int limit = 10}) {
    final list = _articles.values
        .where((a) => !_isShoppingOrDealTitle(a.title))
        .toList()
      ..sort((a, b) => (b.viewCount + b.likeCount * 3).compareTo(a.viewCount + a.likeCount * 3));
    final seen = <String>{};
    return list.where((a) => seen.add(_normalizeTitle(a.title))).take(limit).toList();
  }

  bool _matchesCity(Article a, String city) {
    final c = city.trim().toLowerCase();
    if (c.isEmpty) return true;
    if (a.city?.toLowerCase() == c) return true;
    if (a.tags.any((t) => t.toLowerCase() == c)) return true;
    final wordRegex = RegExp('\\b${RegExp.escape(c)}\\b', caseSensitive: false);
    return wordRegex.hasMatch(a.title) || wordRegex.hasMatch(a.summary);
  }

  List<Article> getLocalNews({String? city, String? country, int limit = 15}) {
    var list = <Article>[];
    if (city != null && city.trim().isNotEmpty) {
      list = _articles.values.where((a) => _matchesCity(a, city)).toList();
      // Prioritize dedicated local-category dispatches, then newest
      list.sort((a, b) {
        final aIsLocal = a.category == 'local' ? 1 : 0;
        final bIsLocal = b.category == 'local' ? 1 : 0;
        if (aIsLocal != bIsLocal) return bIsLocal.compareTo(aIsLocal);
        return b.publishedAt.compareTo(a.publishedAt);
      });
      final seen = <String>{};
      return list.where((a) => seen.add(_normalizeTitle(a.title))).take(limit).toList();
    }

    list = _articles.values.where((a) {
      if (country != null && a.country != null && a.country!.toLowerCase() == country.toLowerCase()) {
        return true;
      }
      return a.category == 'local';
    }).toList();

    list.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    final seen = <String>{};
    return list.where((a) => seen.add(_normalizeTitle(a.title))).take(limit).toList();
  }

  ({List<Article> articles, int total}) searchWithTotal(
    String query, {
    String? category,
    String? source,
    String? country,
    String? city,
    String sortBy = 'relevance',
    int limit = 20,
    int offset = 0,
  }) {
    final raw = query.trim();
    if (raw.isEmpty) {
      return (articles: <Article>[], total: 0);
    }

    // Split hashtag / CamelCase / acronym queries cleanly (e.g. "#AIAgents" -> ["ai", "agents"])
    final cleaned = raw.replaceAll('#', '');
    final camelSplit = cleaned
        .replaceAllMapped(RegExp(r'([A-Z]+)([A-Z][a-z])'), (m) => '${m.group(1)} ${m.group(2)}')
        .replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (m) => '${m.group(1)} ${m.group(2)}')
        .replaceAllMapped(RegExp(r'([A-Za-z])(\d)'), (m) => '${m.group(1)} ${m.group(2)}')
        .toLowerCase();
    final q = cleaned.toLowerCase();
    final qCompact = q.replaceAll(RegExp(r'[^a-z0-9]'), '');
    final tokens = camelSplit
        .split(RegExp(r'[^a-z0-9]+'))
        .where((t) => t.length >= 2)
        .toList();

    var matches = _articles.values.where((a) {
      final titleLower = a.title.toLowerCase();
      final summaryLower = a.summary.toLowerCase();
      final catLower = _categorySearchTerms(a.category);
      final subLower = (a.subcategory ?? '').toLowerCase();
      final sourceLower = a.source.name.toLowerCase();
      final tagsLower = a.tags.map((t) => t.toLowerCase()).toList();

      var matchesQuery = titleLower.contains(q) ||
          summaryLower.contains(q) ||
          catLower.contains(q) ||
          subLower.contains(q) ||
          tagsLower.any((t) => t.contains(q)) ||
          sourceLower.contains(q);

      if (!matchesQuery && qCompact.length >= 3) {
        final combinedCompact = '${a.title} ${a.summary} $catLower ${a.subcategory ?? ''} ${a.tags.join(' ')}'
            .toLowerCase()
            .replaceAll(RegExp(r'[^a-z0-9]'), '');
        if (combinedCompact.contains(qCompact)) {
          matchesQuery = true;
        }
      }

      if (!matchesQuery && tokens.length > 1) {
        final haystack = '$titleLower $summaryLower $catLower $subLower ${tagsLower.join(' ')} $sourceLower';
        matchesQuery = tokens.every((tok) => haystack.contains(tok));
      }

      if (!matchesQuery) return false;

      if (category != null && category.isNotEmpty && category != 'all') {
        if (a.category.toLowerCase() != category.toLowerCase()) return false;
      }

      if (source != null && source.isNotEmpty && source != 'all') {
        final s = source.toLowerCase();
        if (a.source.slug.toLowerCase() != s &&
            a.source.id.toLowerCase() != s &&
            !a.source.name.toLowerCase().contains(s)) {
          return false;
        }
      }

      return true;
    }).toList();

    if (sortBy == 'latest') {
      matches.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    } else if (sortBy == 'popular' || sortBy == 'most_read') {
      matches.sort((a, b) => b.viewCount.compareTo(a.viewCount));
    } else {
      matches.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    }

    final seenTitles = <String>{};
    matches = matches.where((a) => seenTitles.add(_normalizeTitle(a.title))).toList();

    final total = matches.length;
    if (offset >= matches.length) {
      return (articles: <Article>[], total: total);
    }
    final end = (offset + limit).clamp(0, matches.length);
    return (articles: matches.sublist(offset, end), total: total);
  }

  static String _categorySearchTerms(String category) {
    final c = category.toLowerCase();
    switch (c) {
      case 'tech':
        return 'tech technology';
      case 'sci':
      case 'science':
        return 'science sci environment';
      case 'business':
        return 'business finance markets';
      case 'ent':
      case 'entertainment':
        return 'entertainment cinema film music';
      case 'international':
        return 'international world global';
      default:
        return c;
    }
  }

  List<Article> search(String query, {int limit = 20}) {
    return searchWithTotal(query, limit: limit).articles;
  }

  static const Set<String> _ignoredTrendingTokens = {
    'showtypes', 'uncategorized', 'sponsored', 'shopping', 'homepage',
    'newsletter', 'podcast', 'video', 'videos', 'live', 'updates', 'latest',
    'features', 'sections', 'misc', 'general', 'articles', 'archive', 'blog',
    'more', 'read', 'global', 'world', 'top', 'feed', 'rss', 'post', 'posts',
  };

  /// Dynamically extracts trending hashtags from real articles in the repository
  /// so clicking any tag in Search/Explore always resolves to real stories.
  List<String> getDynamicTrendingTopics({int limit = 10}) {
    final counts = <String, int>{};
    final displayLabels = <String, String>{};

    bool isUsableToken(String token) {
      if (token.length < 2 || token.length > 26) return false;
      if (RegExp(r'^\d+$').hasMatch(token)) return false;
      final lower = token.toLowerCase();
      if (_stopAndPromoWords.contains(lower) || _ignoredTrendingTokens.contains(lower)) {
        return false;
      }
      return true;
    }

    // 1. Prefer explicit article tags first
    for (final article in _articles.values) {
      for (final tag in article.tags) {
        final clean = tag.replaceAll('#', '').trim();
        final formatted = clean.replaceAll(RegExp(r'[^A-Za-z0-9]'), '');
        if (!isUsableToken(formatted)) continue;
        final key = formatted.toLowerCase();
        counts[key] = (counts[key] ?? 0) + 3;
        displayLabels.putIfAbsent(key, () => '#$formatted');
      }

      // 2. Also mine strong headline terms from recent articles
      final words = article.title
          .split(RegExp(r'[^A-Za-z0-9]+'))
          .where((w) => w.length >= 4 && isUsableToken(w));
      for (final w in words) {
        final key = w.toLowerCase();
        counts[key] = (counts[key] ?? 0) + 1;
        final capitalized = '${w[0].toUpperCase()}${w.substring(1)}';
        displayLabels.putIfAbsent(key, () => '#$capitalized');
      }
    }

    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final result = <String>[];
    final singleMatchFallback = <String>[];
    for (final entry in sorted) {
      final tag = displayLabels[entry.key]!;
      final queryTerm = tag.replaceAll('#', '');
      final total = searchWithTotal(queryTerm, limit: 2).total;
      if (total >= 2) {
        result.add(tag);
        if (result.length >= limit) break;
      } else if (total == 1 && singleMatchFallback.length < limit) {
        singleMatchFallback.add(tag);
      }
    }

    for (final tag in singleMatchFallback) {
      if (result.length >= limit) break;
      result.add(tag);
    }

    return result.isNotEmpty
        ? result
        : const ['#ClimateAccord2026', '#ArtificialIntelligence', '#QuantumComputing'];
  }

  List<StoryCluster> getClusters({int limit = 10}) {
    final list = _clusters.values.toList()
      ..sort((a, b) {
        // Prioritize rich editorial clusters (e.g., seeded primary dossier or multi-perspective news)
        final aIsFeatured = a.id == 'cluster_climate_2026' ? 1 : 0;
        final bIsFeatured = b.id == 'cluster_climate_2026' ? 1 : 0;
        if (aIsFeatured != bIsFeatured) return bIsFeatured.compareTo(aIsFeatured);
        final aScore = a.alternativePerspectives.length;
        final bScore = b.alternativePerspectives.length;
        if (aScore != bScore) return bScore.compareTo(aScore);
        return b.updatedAt.compareTo(a.updatedAt);
      });
    return list.take(limit).toList();
  }

  StoryCluster? getClusterById(String id) => _clusters[id];

  void incrementViews(String articleId) {
    final resolvedId = _articles.containsKey(articleId)
        ? articleId
        : (_legacyIdAliases[articleId] ?? articleId);
    final art = _articles[resolvedId];
    if (art != null) {
      _articles[resolvedId] = art.copyWith(viewCount: art.viewCount + 1);
    }
  }

  void incrementLikes(String articleId) {
    final resolvedId = _articles.containsKey(articleId)
        ? articleId
        : (_legacyIdAliases[articleId] ?? articleId);
    final art = _articles[resolvedId];
    if (art != null) {
      _articles[resolvedId] = art.copyWith(likeCount: art.likeCount + 1);
    }
  }

  final Set<String> _enrichmentAttempted = {};

  Future<Article?> getAndEnrichArticleById(String id) async {
    final article = getArticleById(id) ?? getArticleBySlug(id);
    if (article == null) return null;

    final currentText = (article.content ?? article.summary).trim();
    if (currentText.length < 450 &&
        article.originalUrl.startsWith('http') &&
        !article.originalUrl.contains('readmore.news') &&
        _enrichmentAttempted.add(article.id)) {
      final enriched = await _parser.fetchReadableContent(article.originalUrl);
      if (enriched != null && enriched.length > currentText.length + 120) {
        final wordCount = enriched.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
        final readTime = (wordCount / 180).ceil().clamp(1, 15);
        final updated = article.copyWith(
          content: enriched,
          readTimeMinutes: readTime,
        );
        _articles[article.id] = updated;
        return updated;
      }
    }
    return article;
  }

  // ==========================================
  // COMMENTS MANAGEMENT
  // ==========================================

  List<ArticleComment> getComments(String articleId) {
    final resolvedId = _legacyIdAliases[articleId] ?? articleId;
    if (_db != null) {
      final dbList = _db.getComments(resolvedId);
      if (dbList.isNotEmpty) {
        _comments[resolvedId] = dbList;
        return List<ArticleComment>.from(dbList);
      }
      if (resolvedId == 'seed-top-1' || resolvedId == 'default') {
        final fallback = _db.getComments('default');
        if (fallback.isNotEmpty) return List<ArticleComment>.from(fallback);
      }
    }
    final direct = _comments[resolvedId];
    if (direct != null) return List<ArticleComment>.from(direct);
    if (resolvedId == 'seed-top-1' || resolvedId == 'default') {
      return List<ArticleComment>.from(_comments['default'] ?? const []);
    }
    return const [];
  }

  ArticleComment addComment(
    String articleId, {
    required String author,
    required String avatarUrl,
    required String text,
  }) {
    final resolvedId = _legacyIdAliases[articleId] ?? articleId;
    final list = _comments.putIfAbsent(resolvedId, () => []);
    final comment = ArticleComment(
      id: 'cmt_${DateTime.now().microsecondsSinceEpoch}',
      articleId: resolvedId,
      author: author,
      avatarUrl: avatarUrl,
      text: text,
      timeAgo: 'Just now',
      createdAt: DateTime.now(),
      likes: 0,
      isLiked: false,
    );
    list.insert(0, comment);
    _db?.insertComment(comment);
    return comment;
  }

  bool toggleCommentLike(String commentId) {
    for (final list in _comments.values) {
      for (var i = 0; i < list.length; i++) {
        if (list[i].id == commentId) {
          final c = list[i];
          c.isLiked = !c.isLiked;
          c.likes += c.isLiked ? 1 : -1;
          _db?.updateCommentLikes(commentId, c.likes);
          return c.isLiked;
        }
      }
    }
    return false;
  }

  // ==========================================
  // SPONSORED ADS MANAGEMENT
  // ==========================================

  List<SponsoredAd> getSponsoredAds({
    AdPlacement? placement,
    String? category,
    AdFormat? format,
  }) {
    var list = _ads.values.where((ad) => ad.isActive).toList();

    if (placement != null) {
      list = list.where((ad) => ad.placement == placement).toList();
    }
    if (category != null && category.isNotEmpty && category != 'all') {
      list = list.where((ad) => ad.targetCategory == 'all' || ad.targetCategory == category).toList();
    }
    if (format != null) {
      list = list.where((ad) => ad.format == format).toList();
    }

    return list;
  }

  SponsoredAd createSponsoredAd(SponsoredAd ad) {
    _ads[ad.id] = ad;
    _db?.upsertAd(ad);
    return ad;
  }

  void recordAdClick(String adId) {
    final ad = _ads[adId];
    if (ad != null) {
      final updated = ad.copyWith(clicks: ad.clicks + 1);
      _ads[adId] = updated;
      _db?.upsertAd(updated);
    }
  }

  void recordAdImpression(String adId) {
    final ad = _ads[adId];
    if (ad != null) {
      final updated = ad.copyWith(impressions: ad.impressions + 1);
      _ads[adId] = updated;
      _db?.upsertAd(updated);
    }
  }

  // ==========================================
  // NOTIFICATIONS
  // ==========================================

  List<AppNotification> getNotifications() => List.unmodifiable(_notifications);

  void markNotificationRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
    }
  }

  // ==========================================
  // FULL COVERAGE CLUSTERING
  // ==========================================

  bool _isShoppingOrDealTitle(String title) {
    final lower = title.toLowerCase();
    return lower.contains('black friday') ||
        lower.contains('cyber monday') ||
        lower.contains(' deals') ||
        lower.contains('best deal') ||
        lower.contains('% off') ||
        lower.contains('coupon');
  }

  void _checkAndClusterArticle(Article newArticle) {
    if (_isShoppingOrDealTitle(newArticle.title)) return;

    for (final existing in _articles.values) {
      if (existing.id == newArticle.id) continue;
      if (existing.source.id == newArticle.source.id) continue;
      if (_isShoppingOrDealTitle(existing.title)) continue;
      if (existing.category != newArticle.category &&
          !(const {'top', 'international', 'business', 'tech', 'science'}.contains(existing.category) &&
              const {'top', 'international', 'business', 'tech', 'science'}.contains(newArticle.category))) {
        continue;
      }

      final match = _calculateTitleMatch(existing.title, newArticle.title);
      if (match.sharedCount >= 3 && match.similarity >= 0.55) {
        final clusterId = existing.clusterId ?? 'cluster_${existing.id}';
        final existingCluster = _clusters[clusterId];

        if (existingCluster != null) {
          if (existingCluster.alternativePerspectives.length >= 4) continue;
          final alreadyHasSource = existingCluster.primaryArticle.source.id == newArticle.source.id ||
              existingCluster.alternativePerspectives.any((p) => p.source.id == newArticle.source.id);
          if (alreadyHasSource) continue;

          final updatedPerspectives = [...existingCluster.alternativePerspectives, newArticle];
          final updatedTimeline = _buildClusterTimeline(existingCluster.primaryArticle, updatedPerspectives);

          _clusters[clusterId] = StoryCluster(
            id: clusterId,
            topicHeadline: existingCluster.topicHeadline,
            category: existingCluster.category,
            primaryArticle: existingCluster.primaryArticle,
            alternativePerspectives: updatedPerspectives,
            timeline: updatedTimeline,
            updatedAt: newArticle.publishedAt.isAfter(existingCluster.updatedAt)
                ? newArticle.publishedAt
                : existingCluster.updatedAt,
          );
        } else {
          final perspectives = [newArticle];
          _clusters[clusterId] = StoryCluster(
            id: clusterId,
            topicHeadline: existing.title,
            category: existing.category,
            primaryArticle: existing,
            alternativePerspectives: perspectives,
            timeline: _buildClusterTimeline(existing, perspectives),
            updatedAt: newArticle.publishedAt.isAfter(existing.publishedAt)
                ? newArticle.publishedAt
                : existing.publishedAt,
          );
        }

        _articles[existing.id] = existing.copyWith(clusterId: clusterId);
        _articles[newArticle.id] = newArticle.copyWith(clusterId: clusterId);
        break;
      }
    }
  }

  List<TimelineEvent> _buildClusterTimeline(Article primary, List<Article> perspectives) {
    final all = [primary, ...perspectives]
      ..sort((a, b) => a.publishedAt.compareTo(b.publishedAt));
    return all.map((art) {
      return TimelineEvent(
        time: _formatEventTimestamp(art.publishedAt),
        title: art.title,
        summary: art.summary,
        sourceName: art.source.name,
      );
    }).toList();
  }

  String _formatEventTimestamp(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final local = dt.toLocal();
    final hh = local.hour.toString().padLeft(2, '0');
    final mm = local.minute.toString().padLeft(2, '0');
    return '${months[local.month - 1]} ${local.day}, $hh:$mm';
  }

  ({double similarity, int sharedCount}) _calculateTitleMatch(String a, String b) {
    final wordsA = a
        .toLowerCase()
        .split(RegExp(r'\W+'))
        .where((w) => w.length >= 4 && !_stopAndPromoWords.contains(w))
        .toSet();
    final wordsB = b
        .toLowerCase()
        .split(RegExp(r'\W+'))
        .where((w) => w.length >= 4 && !_stopAndPromoWords.contains(w))
        .toSet();
    if (wordsA.isEmpty || wordsB.isEmpty) return (similarity: 0, sharedCount: 0);
    final intersection = wordsA.intersection(wordsB).length;
    final union = wordsA.union(wordsB).length;
    return (similarity: intersection / union, sharedCount: intersection);
  }

  // ==========================================
  // SEED DATA
  // ==========================================

  void _seedDefaultArticles() {
    final sampleSources = {
      'bbc': const NewsSource(id: 'bbc', name: 'BBC News', slug: 'bbc', domain: 'bbc.com', iconUrl: 'https://www.google.com/s2/favicons?domain=bbc.com&sz=128'),
      'reuters': const NewsSource(id: 'reuters', name: 'Reuters', slug: 'reuters', domain: 'reuters.com', iconUrl: 'https://www.google.com/s2/favicons?domain=reuters.com&sz=128'),
      'techcrunch': const NewsSource(id: 'techcrunch', name: 'TechCrunch', slug: 'techcrunch', domain: 'techcrunch.com', iconUrl: 'https://www.google.com/s2/favicons?domain=techcrunch.com&sz=128'),
      'espn': const NewsSource(id: 'espn', name: 'ESPN', slug: 'espn', domain: 'espn.com', iconUrl: 'https://www.google.com/s2/favicons?domain=espn.com&sz=128'),
      'variety': const NewsSource(id: 'variety', name: 'Variety', slug: 'variety', domain: 'variety.com', iconUrl: 'https://www.google.com/s2/favicons?domain=variety.com&sz=128'),
      'bloomberg': const NewsSource(id: 'bloomberg', name: 'Bloomberg', slug: 'bloomberg', domain: 'bloomberg.com', iconUrl: 'https://www.google.com/s2/favicons?domain=bloomberg.com&sz=128'),
      'nature': const NewsSource(id: 'nature', name: 'Nature Journal', slug: 'nature', domain: 'nature.com', iconUrl: 'https://www.google.com/s2/favicons?domain=nature.com&sz=128'),
      'vogue': const NewsSource(id: 'vogue', name: 'Vogue', slug: 'vogue', domain: 'vogue.com', iconUrl: 'https://www.google.com/s2/favicons?domain=vogue.com&sz=128'),
    };

    final now = DateTime.now();

    final seeds = [
      Article(
        id: 'seed-top-1',
        title: 'Global Climate Summit Concludes With Historic Accord on Renewable Energy',
        slug: 'global-climate-summit-concludes-with-historic-accord',
        summary: 'Delegates from 195 nations have agreed to ambitious clean energy transition targets in a landmark treaty mandating a 300% expansion in cross-border transmission lines by 2035.',
        content: 'Delegates from 195 nations have ratified an unprecedented binding treaty mandating a 300% expansion in cross-border clean energy transmission lines by 2035.\n\nThe agreement establishes a coordinated regulatory framework across continents, providing \$500 billion in annual public-private guarantees to rapidly deploy high-voltage direct current (HVDC) transmission corridors connecting continental solar, wind, and battery storage hubs.\n\nLeading economic institutes project this accord will generate over 12 million clean-technology jobs while synchronizing international power grids and slashing industrial carbon intensity.',
        originalUrl: 'https://www.reuters.com/environment/summit-agreement-2026',
        imageUrl: 'https://images.unsplash.com/photo-1473341304170-971dccb5ac1e?auto=format&fit=crop&w=800&q=80',
        source: sampleSources['reuters']!,
        category: 'top',
        tags: const ['ClimateAccord2026', 'RenewableEnergy', 'GlobalTreaty'],
        publishedAt: now.subtract(const Duration(minutes: 15)),
        readTimeMinutes: 4,
        isBreaking: true,
        country: 'United States',
        city: 'New York',
        viewCount: 1420,
        likeCount: 312,
      ),
      Article(
        id: 'seed-tech-1',
        title: 'Autonomous AI Agents Revolutionize Software Engineering Paradigms',
        slug: 'autonomous-ai-agents-revolutionize-software-engineering',
        summary: 'Next-generation reasoning models now orchestrate end-to-end full stack development pipelines autonomously.',
        content: 'Software development is experiencing its most significant architectural shift in four decades.\n\nEnterprise research labs have unveiled recursive multi-agent swarms capable of inspecting legacy codebases, refactoring monolithic architectures into verified microservices, and executing automated zero-trust security audits.\n\nEngineering teams report up to four-fold faster release cycles while human reviewers focus on system boundaries, reliability, and product design.',
        originalUrl: 'https://techcrunch.com/2026/11/ai-agents-revolution/',
        imageUrl: 'https://images.unsplash.com/photo-1518770660439-4636190af475?auto=format&fit=crop&w=800&q=80',
        source: sampleSources['techcrunch']!,
        category: 'tech',
        tags: const ['ArtificialIntelligence', 'AutonomousDev', 'SoftwareTech'],
        publishedAt: now.subtract(const Duration(minutes: 45)),
        readTimeMinutes: 3,
        viewCount: 2890,
        likeCount: 780,
      ),
      Article(
        id: 'seed-business-1',
        title: 'Global Central Banks Announce Coordinated Real-Time Digital Settlement Corridors',
        slug: 'global-central-banks-announce-coordinated-real-time-digital-settlement',
        summary: 'A new multi-lateral atomic settlement network promises instant cross-border liquidity without intermediate clearing fees.',
        content: 'Central banking authorities across major financial centers unveiled a unified real-time cross-border settlement corridor today.\n\nThe multi-lateral network compresses multi-day correspondent banking transfers into sub-second atomic settlements, eliminating trapped liquidity and reducing foreign exchange friction for institutional treasuries.',
        originalUrl: 'https://www.bloomberg.com/markets/settlement-corridors-2026',
        imageUrl: 'https://images.unsplash.com/photo-1611974789855-9c2a0a7236a3?auto=format&fit=crop&w=800&q=80',
        source: sampleSources['bloomberg']!,
        category: 'business',
        tags: const ['Finance', 'CentralBanks', 'DigitalCorridors'],
        publishedAt: now.subtract(const Duration(hours: 1, minutes: 10)),
        readTimeMinutes: 3,
        viewCount: 3820,
        likeCount: 640,
      ),
      Article(
        id: 'seed-science-1',
        title: 'Breakthrough Quantum Annealing Processor Achieves Practical Materials Simulation',
        slug: 'breakthrough-quantum-annealing-processor-materials-simulation',
        summary: 'Physicists simulate complex room-temperature superconducting crystal lattices for the first time with high precision.',
        content: 'Physicists operating next-generation fault-tolerant quantum processors have demonstrated high-precision simulations of superconducting crystal lattices.\n\nBy combining active syndrome decoding with cryogenically stabilized qubit arrays, researchers modeled molecular catalyst interactions that previously exceeded classical supercomputer memory limits.',
        originalUrl: 'https://www.nature.com/articles/quantum-materials-2026',
        imageUrl: 'https://images.unsplash.com/photo-1635070041078-e363dbe005cb?auto=format&fit=crop&w=800&q=80',
        source: sampleSources['nature']!,
        category: 'science',
        tags: const ['QuantumComputing', 'Superconductivity', 'MaterialsScience'],
        publishedAt: now.subtract(const Duration(hours: 2)),
        readTimeMinutes: 5,
        viewCount: 4210,
        likeCount: 1104,
      ),
      Article(
        id: 'seed-sports-1',
        title: 'Champions League Thriller: Dramatic 94th Minute Stunner Secures Quarter-Finals',
        slug: 'champions-league-thriller-dramatic-94th-minute-stunner',
        summary: 'A breathtaking counter-attack in stoppage time delivered one of the greatest comebacks in modern football history.',
        content: 'In an unforgettable European football night, a 94th-minute stoppage-time volley sealed an extraordinary second-half turnaround and booked a coveted berth in the semi-final draw.\n\nTrailing by two goals on aggregate with five minutes left, the visiting squad pressed high and capitalized on a sweeping counter-attack that sent traveling supporters into raptures.',
        originalUrl: 'https://www.espn.com/soccer/story/_/id/champions-league-thriller',
        imageUrl: 'https://images.unsplash.com/photo-1508098682722-e99c43a406b2?auto=format&fit=crop&w=800&q=80',
        source: sampleSources['espn']!,
        category: 'sports',
        tags: const ['ChampionsLeague', 'Football', 'Sports'],
        publishedAt: now.subtract(const Duration(hours: 2, minutes: 30)),
        readTimeMinutes: 3,
        viewCount: 5120,
        likeCount: 1205,
      ),
      Article(
        id: 'seed-ent-1',
        title: 'Blockbuster Sci-Fi Epic Breaks Global Box Office Records in Opening Weekend',
        slug: 'blockbuster-sci-fi-epic-breaks-global-box-office',
        summary: 'Director hailed for pioneering holographic visual effects that mesmerized cinema audiences worldwide.',
        content: 'Audiences flocked to premier large-format cinemas across North America, Europe, and Asia this weekend, propelling the visionary sci-fi odyssey past \$400 million globally.\n\nCritics praised the production’s blend of tactile practical miniatures, sweeping orchestral scoring, and spatial audio engineering.',
        originalUrl: 'https://variety.com/film/box-office-record-2026',
        imageUrl: 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?auto=format&fit=crop&w=800&q=80',
        source: sampleSources['variety']!,
        category: 'entertainment',
        tags: const ['HoloCinema', 'Movies', 'Entertainment'],
        publishedAt: now.subtract(const Duration(hours: 3)),
        readTimeMinutes: 2,
        viewCount: 3410,
        likeCount: 890,
      ),
      Article(
        id: 'seed-local-1',
        title: 'Metropolitan Transit Authority Completes High-Speed Cross-Town Rail Interconnect',
        slug: 'metropolitan-transit-authority-completes-high-speed-rail',
        summary: 'The infrastructure project cuts commuter transit times across the New York metropolitan corridor by forty percent.',
        content: 'New York city planners and regional transit authorities celebrated the ribbon-cutting of the cross-town high-speed express interconnect today.\n\nFeaturing zero-emission rolling stock and universal contactless fare gates, the corridor is projected to cut peak commuter travel times by forty percent across Manhattan and outer-borough hubs.',
        originalUrl: 'https://www.bbc.com/news/local-transit-2026',
        imageUrl: 'https://images.unsplash.com/photo-1517649763962-0c623266ddc0?auto=format&fit=crop&w=800&q=80',
        source: sampleSources['bbc']!,
        category: 'local',
        city: 'New York',
        country: 'United States',
        tags: const ['New York', 'Transit', 'Infrastructure'],
        publishedAt: now.subtract(const Duration(hours: 4)),
        readTimeMinutes: 3,
        viewCount: 1840,
        likeCount: 420,
      ),
      Article(
        id: 'seed-local-london',
        title: 'Thames Clean Energy Corridor Initiates First Hydro-Turbine Array Beneath Tower Bridge',
        slug: 'thames-clean-energy-hydro-turbine-tower-bridge',
        summary: 'Sub-surface tidal power generators begin feeding clean electrical power directly into the London Underground network.',
        content: 'In a fusion of centuries-old maritime engineering and zero-emission technology, underwater tidal turbines anchored in the Thames now supply steady baseload electricity for London’s Underground stations.\n\nTransport for London engineers confirmed the array already powers three central interchange hubs during peak morning demand.',
        originalUrl: 'https://www.bbc.com/news/uk-england-london-thames-hydro',
        imageUrl: 'https://images.unsplash.com/photo-1513635269975-59663e0ac1ad?auto=format&fit=crop&w=800&q=80',
        source: sampleSources['bbc']!,
        category: 'local',
        city: 'London',
        country: 'UK',
        tags: const ['London', 'CleanEnergy', 'Thames'],
        publishedAt: now.subtract(const Duration(hours: 3)),
        readTimeMinutes: 3,
        viewCount: 2140,
        likeCount: 510,
      ),
      Article(
        id: 'seed-local-tokyo',
        title: 'Tokyo Unveils Multi-Level Vertical Forest District in Shibuya',
        slug: 'tokyo-vertical-forest-district-shibuya',
        summary: 'Biophilic towers incorporate over 250,000 indigenous trees, cooling local Shibuya street temperatures by 4 degrees.',
        content: 'Shibuya’s newest skyline district blends hyper-dense urban architecture with lush mountainous biodiversity.\n\nAutomated misting arrays, rainwater retention terraces, and elevated pedestrian sky-bridges create a climate-resilient model for Tokyo neighborhoods.',
        originalUrl: 'https://www.reuters.com/world/asia-pacific/tokyo-shibuya-vertical-forest',
        imageUrl: 'https://images.unsplash.com/photo-1503899036084-c55cdd92da26?auto=format&fit=crop&w=800&q=80',
        source: sampleSources['reuters']!,
        category: 'local',
        city: 'Tokyo',
        country: 'Japan',
        tags: const ['Tokyo', 'Architecture', 'UrbanGreen'],
        publishedAt: now.subtract(const Duration(hours: 4)),
        readTimeMinutes: 4,
        viewCount: 2480,
        likeCount: 620,
      ),
      Article(
        id: 'seed-local-lagos',
        title: 'Lagos Tech Ecosystem Celebrates Launch of West Africa’s Largest Undersea Fiber Hub',
        slug: 'lagos-undersea-fiber-landing-hub-launched',
        summary: 'New high-capacity subsea terminal in Lekki multiplies regional cloud bandwidth tenfold, accelerating Lagos fintech innovation.',
        content: 'Founders, cloud architects, and state officials gathered at the Lekki Free Trade Zone in Lagos for the commissioning of the next-generation trans-Atlantic subsea fiber landing hub.\n\nThe facility lowers latency across West African enterprise networks and expands local data center capacity for Lagos’s rapidly growing fintech and engineering ecosystem.',
        originalUrl: 'https://techcrunch.com/2026/11/lagos-undersea-fiber-hub/',
        imageUrl: 'https://images.unsplash.com/photo-1542296332-2e4473faf563?auto=format&fit=crop&w=800&q=80',
        source: sampleSources['techcrunch']!,
        category: 'local',
        city: 'Lagos',
        country: 'Nigeria',
        tags: const ['Lagos', 'Nigeria', 'Fintech', 'Infrastructure'],
        publishedAt: now.subtract(const Duration(hours: 2)),
        readTimeMinutes: 3,
        viewCount: 2950,
        likeCount: 740,
      ),
      Article(
        id: 'seed-local-paris',
        title: 'Seine Swimming Program Expands Permanent Public Waterways Along Latin Quarter',
        slug: 'paris-seine-swimming-latin-quarter',
        summary: 'Following historic ecological restoration, Paris opens four permanent riverside swimming basins for public recreation.',
        content: 'Parisians celebrated today as newly monitored stretches of the Seine along the Latin Quarter opened with floating sun decks, botanical water-filtration gardens, and riverside cultural pavilions.',
        originalUrl: 'https://www.vogue.com/article/paris-seine-waterways',
        imageUrl: 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?auto=format&fit=crop&w=800&q=80',
        source: sampleSources['vogue']!,
        category: 'local',
        city: 'Paris',
        country: 'France',
        tags: const ['Paris', 'Seine', 'Ecology'],
        publishedAt: now.subtract(const Duration(hours: 5)),
        readTimeMinutes: 2,
        viewCount: 1920,
        likeCount: 480,
      ),
      Article(
        id: 'seed-local-sf',
        title: 'San Francisco Waterfront Greenway Connects Presidio with Mission Bay in 10-Mile Park',
        slug: 'sf-waterfront-greenway-presidio-mission-bay',
        summary: 'Continuous San Francisco waterfront promenade features protected bicycle corridors, public art, and restored wetlands.',
        content: 'The completion of the Embarcadero green corridor unites the northern and southern edges of San Francisco into a continuous 10-mile coastal park with protected cycling lanes and restored bayfront marshland.',
        originalUrl: 'https://www.reuters.com/world/us/san-francisco-waterfront-greenway',
        imageUrl: 'https://images.unsplash.com/photo-1501594907352-04cda38ebc29?auto=format&fit=crop&w=800&q=80',
        source: sampleSources['reuters']!,
        category: 'local',
        city: 'San Francisco',
        country: 'US',
        tags: const ['San Francisco', 'Parks', 'BayArea'],
        publishedAt: now.subtract(const Duration(hours: 6)),
        readTimeMinutes: 3,
        viewCount: 1760,
        likeCount: 390,
      ),
      Article(
        id: 'art-tech-2',
        title: 'Commercial Fault-Tolerant Quantum Processor Achieves Real-Time Error Correction',
        slug: 'commercial-fault-tolerant-quantum-processor',
        summary: 'Physicists demonstrate 10,000 logical qubits operating under active syndrome decoding, solving complex molecular simulation challenges in seconds.',
        content: 'The long-standing holy grail of quantum physics—fault-tolerant active error correction—has officially crossed into commercial viability.\n\nThe breakthrough paves the way for catalyst discovery and next-generation battery chemistries previously impossible to model on classical supercomputers.',
        originalUrl: 'https://www.nature.com/articles/fault-tolerant-quantum-milestone',
        imageUrl: 'https://images.unsplash.com/photo-1635070041078-e363dbe005cb?auto=format&fit=crop&w=800&q=80',
        source: sampleSources['nature']!,
        category: 'tech',
        tags: const ['Quantum', 'Hardware', 'Physics'],
        publishedAt: now.subtract(const Duration(hours: 2, minutes: 15)),
        readTimeMinutes: 5,
        viewCount: 9400,
        likeCount: 2100,
      ),
      Article(
        id: 'art-food-1',
        title: 'The Fermentation Renaissance: How Ancient Techniques are Reimagining Fine Dining',
        slug: 'fermentation-renaissance-reimagining-fine-dining',
        summary: 'Master chefs worldwide are embracing centuries-old koji, garum, and wild lacto-fermentation to unlock unprecedented umami depths.',
        content: 'In Michelin-starred kitchens from Tokyo to Copenhagen and San Francisco, the newest revolution isn’t molecular foam—it is centuries-old microbial craft.\n\nChefs are building custom fermentation chambers yielding intensely complex, savory culinary experiences.',
        originalUrl: 'https://www.vogue.com/article/fermentation-trends-2026',
        imageUrl: 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=800&q=80',
        source: sampleSources['vogue']!,
        category: 'food',
        tags: const ['Food', 'FineDining', 'Culinary'],
        publishedAt: now.subtract(const Duration(hours: 6, minutes: 30)),
        readTimeMinutes: 3,
        viewCount: 7800,
        likeCount: 1950,
      ),
      Article(
        id: 'art-life-1',
        title: 'Architectural Biophilia: Why Living Spaces Designed Around Circadian Light Transform Health',
        slug: 'architectural-biophilia-circadian-light',
        summary: 'New clinical studies demonstrate a 40% reduction in chronic stress markers for residents living in homes with dynamic spectral sunlighting.',
        content: 'Modern urban design is experiencing an overdue transformation toward biophilic living.\n\nBy integrating living green walls, natural cross-ventilation corridors, and full-spectrum circadian glass, homes are evolving into restorative sanctuaries.',
        originalUrl: 'https://www.vogue.com/lifestyle/biophilic-home-design-2026',
        imageUrl: 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&w=800&q=80',
        source: sampleSources['vogue']!,
        category: 'lifestyle',
        tags: const ['Design', 'Wellness', 'Architecture'],
        publishedAt: now.subtract(const Duration(hours: 7)),
        readTimeMinutes: 3,
        viewCount: 11200,
        likeCount: 2900,
      ),
      Article(
        id: 'art-gist-1',
        title: 'Viral Wholesome Moment: City Chorus Unites Commuters in Spontaneous Subway Harmony',
        slug: 'city-chorus-unites-commuters-subway-harmony',
        summary: 'A 20-second acoustic performance during evening rush hour has captured over 85 million views across social platforms.',
        content: 'A spontaneous acapella arrangement echoing through a bustling train concourse brought thousands of hurried commuters to an enchanted standstill, reminding the internet of the shared joy in unexpected communal art.',
        originalUrl: 'https://www.bbc.com/news/viral-subway-harmony',
        imageUrl: 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?auto=format&fit=crop&w=800&q=80',
        source: sampleSources['bbc']!,
        category: 'gists',
        tags: const ['Viral', 'Music', 'Community'],
        publishedAt: now.subtract(const Duration(hours: 8)),
        readTimeMinutes: 2,
        viewCount: 45600,
        likeCount: 14200,
      ),
    ];

    for (final s in seeds) {
      _articles[s.id] = s;
    }

    // Seed default story cluster
    _clusters['cluster_climate_2026'] = StoryCluster(
      id: 'cluster_climate_2026',
      topicHeadline: 'Global Climate Summit 2026: Historic Renewable Energy Treaty',
      category: 'top',
      primaryArticle: seeds[0],
      alternativePerspectives: [
        Article(
          id: 'cluster-alt-1',
          title: 'European Union Pledges €150 Billion for Clean Energy Interconnects with MENA Region',
          slug: 'eu-pledges-150-billion-clean-energy-interconnects',
          summary: 'The investment will fund high-voltage direct-current submarine cables connecting solar arrays in North Africa to European grids.',
          originalUrl: 'https://www.bbc.com/news/world-europe-energy-plan',
          source: sampleSources['bbc']!,
          category: 'top',
          publishedAt: now.subtract(const Duration(minutes: 40)),
          readTimeMinutes: 3,
        ),
        Article(
          id: 'cluster-alt-2',
          title: 'Energy Commodities React: Solar Grid Expansion Mandate Strains Copper Supply Chains',
          slug: 'energy-commodities-react-solar-grid-expansion-mandate',
          summary: 'Global copper futures jump 4.2% following the announcement of international transmission grid targets.',
          originalUrl: 'https://www.bloomberg.com/markets/commodities/copper-surge',
          source: sampleSources['bloomberg']!,
          category: 'business',
          publishedAt: now.subtract(const Duration(minutes: 55)),
          readTimeMinutes: 4,
        ),
        Article(
          id: 'cluster-alt-3',
          title: 'African Union Commission Welcomes Energy Deal: Calls for Just Transition Financing',
          slug: 'african-union-commission-welcomes-energy-deal',
          summary: 'Ministers emphasize the need for technology transfers and local manufacturing hubs alongside grid expansion.',
          originalUrl: 'https://www.reuters.com/world/africa/au-energy-statement',
          source: sampleSources['reuters']!,
          category: 'international',
          publishedAt: now.subtract(const Duration(hours: 1, minutes: 20)),
          readTimeMinutes: 3,
        ),
      ],
      timeline: const [
        TimelineEvent(
          time: '07:30 EST',
          title: 'Draft Declaration Finalized',
          summary: 'Working groups reach agreement on transmission grid targets.',
          sourceName: 'Reuters',
        ),
        TimelineEvent(
          time: '09:15 EST',
          title: 'Formal Plenary Ratification',
          summary: '195 nation delegates formally sign the binding energy accord.',
          sourceName: 'BBC News',
        ),
        TimelineEvent(
          time: '11:00 EST',
          title: 'Market Reaction & Commitments',
          summary: 'Financial institutions pledge \$450B in matching transition credit.',
          sourceName: 'Bloomberg',
        ),
      ],
      updatedAt: now,
    );

    // Also ensure cluster alternative articles are resolvable by ID if clicked
    for (final alt in _clusters['cluster_climate_2026']!.alternativePerspectives) {
      _articles[alt.id] = alt;
    }
  }

  void _seedDefaultComments() {
    if (_db != null && _db.getCommentCount() > 0) {
      final dbDefault = _db.getComments('default');
      if (dbDefault.isNotEmpty) {
        _comments['default'] = dbDefault;
      }
      final dbSeedTop = _db.getComments('seed-top-1');
      if (dbSeedTop.isNotEmpty) {
        _comments['seed-top-1'] = dbSeedTop;
      }
      return;
    }

    final climateComments = [
      ArticleComment(
        id: 'cmt-1',
        articleId: 'seed-top-1',
        author: 'Dr. Evelyn Vance',
        avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&h=100&fit=crop',
        text: 'The transmission line provisions are the critical breakthrough here. Generation has outpaced interconnect capacity for a decade — this treaty directly addresses the true bottleneck.',
        timeAgo: '18m ago',
        likes: 24,
      ),
      ArticleComment(
        id: 'cmt-2',
        articleId: 'seed-top-1',
        author: 'Marcus Sterling',
        avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop',
        text: 'Watching the commodity markets react to this in real time. Copper and aluminum suppliers will need to ramp up extraction drastically to fulfill these 2035 targets.',
        timeAgo: '34m ago',
        likes: 15,
      ),
      ArticleComment(
        id: 'cmt-3',
        articleId: 'seed-top-1',
        author: 'Sofia Chen',
        avatarUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=100&h=100&fit=crop',
        text: 'Excellent dispatch. The corroboration across European and African perspectives highlights the diplomatic compromise achieved.',
        timeAgo: '1h ago',
        likes: 9,
      ),
    ];
    _comments['seed-top-1'] = climateComments;
    _comments['default'] = climateComments;
    for (final c in climateComments) {
      _db?.insertComment(c);
    }

    final techComments = [
      ArticleComment(
        id: 'cmt-tech-1',
        articleId: 'seed-tech-1',
        author: 'Devon Patel',
        avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100&h=100&fit=crop',
        text: 'Automated test generation and architecture verification are where multi-agent workflows deliver real reliability gains in production.',
        timeAgo: '28m ago',
        likes: 14,
      ),
    ];
    _comments['seed-tech-1'] = techComments;
    for (final c in techComments) {
      _db?.insertComment(c);
    }
  }

  void _seedDefaultAds() {
    if (_db != null) {
      final existing = _db.getAds();
      if (existing.isNotEmpty) {
        for (final ad in existing) {
          _ads[ad.id] = ad;
        }
        return;
      }
    }

    final now = DateTime.now();
    final sampleAds = [
      SponsoredAd(
        id: 'ad-google-1',
        title: 'Google Cloud Vertex AI — Enterprise Foundation Models at Scale',
        description: 'Deploy fine-tuned enterprise models on global infrastructure with zero maintenance overhead.',
        sponsorName: 'Google Cloud',
        sponsorLogoUrl: 'https://www.google.com/favicon.ico',
        imageUrl: 'https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=1200&h=400&fit=crop',
        targetUrl: 'https://cloud.google.com/vertex-ai',
        callToAction: 'START FREE TRIAL',
        placement: AdPlacement.leaderboardBanner,
        format: AdFormat.googleAdSense,
        targetCategory: 'all',
        dailyBudget: 150.0,
        impressions: 4820,
        clicks: 342,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      SponsoredAd(
        id: 'ad-native-1',
        title: 'The Modern Ledger: Automating Cross-Border Enterprise Reconciliation',
        description: 'Discover how institutional finance leaders cut treasury overhead by seventy percent with automated settlement.',
        sponsorName: 'Stripe Treasury',
        sponsorLogoUrl: 'https://stripe.com/favicon.ico',
        imageUrl: 'https://images.unsplash.com/photo-1559526324-4b87b5e36e44?w=800&h=400&fit=crop',
        targetUrl: 'https://stripe.com/treasury',
        callToAction: 'READ SPECIAL REPORT',
        placement: AdPlacement.inFeedNative,
        format: AdFormat.sponsoredStory,
        targetCategory: 'business',
        dailyBudget: 100.0,
        impressions: 2940,
        clicks: 215,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      SponsoredAd(
        id: 'ad-sidebar-1',
        title: 'Terminal Pro: Institutional Market Intelligence & News Telemetry',
        description: 'Sub-second real-time quotes, global trade alerts, and breaking news terminal access.',
        sponsorName: 'Alpha Intelligence',
        sponsorLogoUrl: 'https://www.google.com/favicon.ico',
        imageUrl: 'https://images.unsplash.com/photo-1642543492481-44e81e3914a7?w=600&h=400&fit=crop',
        targetUrl: 'https://example.com/terminal-pro',
        callToAction: 'REQUEST ACCESS',
        placement: AdPlacement.sidebarRectangle,
        format: AdFormat.sponsoredStory,
        targetCategory: 'all',
        dailyBudget: 80.0,
        impressions: 3120,
        clicks: 198,
        createdAt: now.subtract(const Duration(hours: 12)),
      ),
    ];

    for (final ad in sampleAds) {
      _ads[ad.id] = ad;
      _db?.upsertAd(ad);
    }
  }

  void _seedDefaultNotifications() {
    final now = DateTime.now();
    _notifications.addAll([
      AppNotification(
        id: 'notif-1',
        title: 'SPECIAL DISPATCH: Global Climate Summit Ratifies Energy Accord',
        timeAgo: '15m ago',
        isBreaking: true,
        articleId: 'seed-top-1',
        createdAt: now.subtract(const Duration(minutes: 15)),
      ),
      AppNotification(
        id: 'notif-2',
        title: 'TECH ALERT: Quantum Annealing Simulation Breakthrough',
        timeAgo: '2h ago',
        isBreaking: false,
        articleId: 'seed-science-1',
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      AppNotification(
        id: 'notif-3',
        title: 'FINANCIAL NOTICE: Multi-Lateral Settlement Corridors Approved',
        timeAgo: '3h ago',
        isBreaking: false,
        articleId: 'seed-business-1',
        createdAt: now.subtract(const Duration(hours: 3)),
      ),
    ]);
  }
}
