import 'dart:async';
import 'package:news_models/news_models.dart';
import 'feed_catalog.dart';
import 'rss_parser.dart';

/// Central store for news articles, clusters, comments, ads, notifications, and background ingestion
class NewsRepository {
  final RssParser _parser;
  final Map<String, Article> _articles = {};
  final Map<String, StoryCluster> _clusters = {};
  final Map<String, List<ArticleComment>> _comments = {};
  final Map<String, SponsoredAd> _ads = {};
  final List<AppNotification> _notifications = [];

  Timer? _pollingTimer;
  bool _isIngesting = false;

  NewsRepository({RssParser? parser}) : _parser = parser ?? RssParser() {
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
      final c = city.toLowerCase();
      list = list.where((a) {
        return (a.city?.toLowerCase() == c) ||
            a.tags.any((t) => t.toLowerCase() == c) ||
            a.title.toLowerCase().contains(c) ||
            a.summary.toLowerCase().contains(c);
      }).toList();
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
      case 'popular':
      case 'views':
        list.sort((a, b) => b.viewCount.compareTo(a.viewCount));
      case 'trending':
        list.sort((a, b) => (b.viewCount + b.likeCount * 3).compareTo(a.viewCount + a.likeCount * 3));
      case 'likes':
        list.sort((a, b) => b.likeCount.compareTo(a.likeCount));
      case 'latest':
      default:
        list.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    }

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
      return getArticles(city: city, country: country, limit: limit);
    }
    return list.take(limit).toList();
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
    final q = query.toLowerCase().trim();
    if (q.isEmpty) {
      return (articles: <Article>[], total: 0);
    }

    var matches = _articles.values.where((a) {
      final matchesQuery = a.title.toLowerCase().contains(q) ||
          a.summary.toLowerCase().contains(q) ||
          a.tags.any((t) => t.toLowerCase().contains(q)) ||
          a.source.name.toLowerCase().contains(q);

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
    } else if (sortBy == 'popular') {
      matches.sort((a, b) => b.viewCount.compareTo(a.viewCount));
    }

    final total = matches.length;
    if (offset >= matches.length) {
      return (articles: <Article>[], total: total);
    }
    final end = (offset + limit).clamp(0, matches.length);
    return (articles: matches.sublist(offset, end), total: total);
  }

  List<Article> search(String query, {int limit = 20}) {
    return searchWithTotal(query, limit: limit).articles;
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

  // ==========================================
  // COMMENTS MANAGEMENT
  // ==========================================

  List<ArticleComment> getComments(String articleId) {
    return _comments[articleId] ?? _comments['default'] ?? [];
  }

  ArticleComment addComment(
    String articleId, {
    required String author,
    required String avatarUrl,
    required String text,
  }) {
    final list = _comments.putIfAbsent(articleId, () => []);
    final comment = ArticleComment(
      id: 'cmt_${DateTime.now().millisecondsSinceEpoch}',
      articleId: articleId,
      author: author,
      avatarUrl: avatarUrl,
      text: text,
      timeAgo: 'Just now',
      createdAt: DateTime.now(),
      likes: 0,
      isLiked: false,
    );
    list.insert(0, comment);
    return comment;
  }

  bool toggleCommentLike(String commentId) {
    for (final list in _comments.values) {
      for (var i = 0; i < list.length; i++) {
        if (list[i].id == commentId) {
          final c = list[i];
          c.isLiked = !c.isLiked;
          c.likes += c.isLiked ? 1 : -1;
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
    return ad;
  }

  void recordAdClick(String adId) {
    final ad = _ads[adId];
    if (ad != null) {
      _ads[adId] = ad.copyWith(clicks: ad.clicks + 1);
    }
  }

  void recordAdImpression(String adId) {
    final ad = _ads[adId];
    if (ad != null) {
      _ads[adId] = ad.copyWith(impressions: ad.impressions + 1);
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

  void _checkAndClusterArticle(Article newArticle) {
    for (final existing in _articles.values) {
      if (existing.id == newArticle.id) continue;
      if (existing.source.id == newArticle.source.id) continue;

      final similarity = _calculateJaccardSimilarity(existing.title, newArticle.title);
      if (similarity >= 0.45) {
        final clusterId = existing.clusterId ?? 'cluster_${existing.id}';

        final existingCluster = _clusters[clusterId];
        if (existingCluster != null) {
          _clusters[clusterId] = StoryCluster(
            id: clusterId,
            topicHeadline: existingCluster.topicHeadline,
            category: existingCluster.category,
            primaryArticle: existingCluster.primaryArticle,
            alternativePerspectives: [...existingCluster.alternativePerspectives, newArticle],
            timeline: existingCluster.timeline,
            updatedAt: DateTime.now(),
          );
        } else {
          _clusters[clusterId] = StoryCluster(
            id: clusterId,
            topicHeadline: existing.title,
            category: existing.category,
            primaryArticle: existing,
            alternativePerspectives: [newArticle],
            timeline: [
              TimelineEvent(
                time: '08:00 EST',
                title: 'Initial Dispatch Wire',
                summary: existing.summary,
                sourceName: existing.source.name,
              ),
              TimelineEvent(
                time: '09:30 EST',
                title: 'Cross-Agency Corroboration',
                summary: newArticle.summary,
                sourceName: newArticle.source.name,
              ),
            ],
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
    };

    final now = DateTime.now();

    final seeds = [
      Article(
        id: 'seed-top-1',
        title: 'Global Climate Summit Concludes With Historic Accord on Renewable Energy',
        slug: 'global-climate-summit-concludes-with-historic-accord',
        summary: 'Delegates from 195 nations have agreed to ambitious clean energy transition targets in a landmark treaty mandating a 300% expansion in cross-border transmission lines by 2035.',
        content: 'Delegates from 195 nations have ratified an unprecedented binding treaty mandating a 300% expansion in cross-border clean energy transmission lines by 2035. The agreement establishes a coordinated regulatory framework across continents, accelerating capital deployment and synchronizing international power grids.',
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
        content: 'Advanced multi-agent swarms with self-correcting validation harnesses have demonstrated ninety-eight percent automated task execution across production enterprise software systems.',
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
        summary: 'The infrastructure project cuts commuter transit times across the metropolitan corridor by forty percent.',
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
          category: 'world',
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
  }

  void _seedDefaultComments() {
    final commentsList = [
      ArticleComment(
        id: 'cmt-1',
        articleId: 'default',
        author: 'Dr. Evelyn Vance',
        avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&h=100&fit=crop',
        text: 'The transmission line provisions are the critical breakthrough here. Generation has outpaced interconnect capacity for a decade — this treaty directly addresses the true bottleneck.',
        timeAgo: '18m ago',
        likes: 24,
      ),
      ArticleComment(
        id: 'cmt-2',
        articleId: 'default',
        author: 'Marcus Sterling',
        avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop',
        text: 'Watching the commodity markets react to this in real time. Copper and aluminum suppliers will need to ramp up extraction drastically to fulfill these 2035 targets.',
        timeAgo: '34m ago',
        likes: 15,
      ),
      ArticleComment(
        id: 'cmt-3',
        articleId: 'default',
        author: 'Sofia Chen',
        avatarUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=100&h=100&fit=crop',
        text: 'Excellent dispatch. The corroboration across European and African perspectives highlights the diplomatic compromise achieved.',
        timeAgo: '1h ago',
        likes: 9,
      ),
    ];
    _comments['default'] = commentsList;
  }

  void _seedDefaultAds() {
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
