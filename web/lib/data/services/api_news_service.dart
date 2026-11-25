import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:news_models/news_models.dart';
import 'news_service.dart';
import 'token_storage.dart';

/// Production-ready HTTP NewsService that connects to the Dart Frog backend
/// running at [baseUrl] (default http://localhost:8085/api).
///
/// Designed with resilient, self-healing fallbacks:
/// - Provides synchronous cache access for instant, zero-latency FlartDart renders.
/// - Performs asynchronous live HTTP requests across all backend endpoints.
/// - Persists JWT auth tokens in browser storage (via conditional web/stub storage).
/// - Automatically catches network drops or backend offline states and falls
///   back gracefully to [MockNewsService], ensuring the UI never crashes.
class ApiNewsService implements NewsService {
  static const String _tokenKey = 'readmore_jwt_token';
  static const String _signedOutKey = 'readmore_signed_out';

  final String baseUrl;
  final http.Client _client;
  final MockNewsService _fallback = MockNewsService();

  // In-memory caches for instant synchronous rendering
  final Map<String, Article> _articlesById = {};
  List<Article> _cachedArticles = [];
  final Map<String, List<Article>> _articlesByCategory = {};
  List<Article> _cachedForYouArticles = [];
  final Map<String, List<Article>> _cachedLocalByCity = {};
  List<Article> _cachedSearchArticles = [];
  String? _lastSearchQueryKey;
  List<Article> _cachedBreakingArticles = [];
  List<Article> _cachedTrendingArticles = [];
  List<NewsCategory> _cachedCategories = [];
  final Map<String, WeatherSnapshot> _cachedWeatherByCity = {};
  List<MarketTickerItem> _cachedMarketTickers = [];
  final Map<String, List<MarketTickerItem>> _cachedMarketTickersBySector = {};
  List<String> _cachedTrendingTags = [];
  List<AppNotification> _cachedNotifications = [];
  final Map<String, List<ArticleComment>> _cachedCommentsByArticle = {};
  List<SponsoredAd> _cachedAds = [];
  List<StoryCluster> _cachedClusters = [];
  StoryCluster? _cachedCluster;
  List<TimelineEvent>? _cachedTimeline;

  // Backend connectivity & auth state
  bool _isBackendConnected = false;
  bool get isBackendConnected => _isBackendConnected;

  String? _authToken;
  String? get authToken => _authToken;

  void setAuthToken(String? token) {
    _authToken = token;
    if (token != null && token.isNotEmpty) {
      writeStoredValue(_tokenKey, token);
      removeStoredValue(_signedOutKey);
    } else {
      removeStoredValue(_tokenKey);
    }
  }

  bool get wasExplicitlySignedOut => readStoredValue(_signedOutKey) == 'true';

  void markSignedOut() {
    _authToken = null;
    removeStoredValue(_tokenKey);
    writeStoredValue(_signedOutKey, 'true');
  }

  Map<String, String> _headers({bool jsonContent = true}) {
    final headers = <String, String>{};
    if (jsonContent) {
      headers['Content-Type'] = 'application/json';
    }
    if (_authToken != null && _authToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  ApiNewsService({
    this.baseUrl = 'http://localhost:8085/api',
    http.Client? client,
  }) : _client = client ?? http.Client() {
    _authToken = readStoredValue(_tokenKey);
    _initializeCachesFromFallback();
  }

  void _initializeCachesFromFallback() {
    _cachedArticles = _fallback.getArticles();
    for (final a in _cachedArticles) {
      _articlesById[a.id] = a;
    }
    _cachedCategories = _fallback.getCategories();
    _cachedMarketTickers = _fallback.getMarketTickers();
    _cachedTrendingTags = _fallback.getTrendingTags();
    _cachedNotifications = _fallback.getNotifications();
    _cachedAds = _fallback.getSponsoredAds();
    _cachedCluster = _fallback.getFullCoverageCluster();
    _cachedTimeline = _fallback.getClusterTimeline();
  }

  void _mergeArticles(List<Article> items) {
    for (final item in items) {
      _articlesById[item.id] = item;
    }
  }

  Article? getCachedArticleById(String id) => _articlesById[id];

  // =========================================================================
  // SYNCHRONOUS CONTRACT (Implements NewsService)
  // =========================================================================

  @override
  List<Article> getArticles({String? category, String? city, String? query, String? source, String? sortBy}) {
    if (query != null && query.trim().isNotEmpty) {
      final qKey = '${query.trim().toLowerCase()}|${source ?? 'all'}|${sortBy ?? 'latest'}';
      if (_lastSearchQueryKey == qKey && _cachedSearchArticles.isNotEmpty) {
        return _cachedSearchArticles;
      }
    }

    if (category != null && category != 'top' && category != 'all') {
      final catKey = '${category.toLowerCase()}|${source ?? 'all'}|${sortBy ?? 'latest'}';
      if (_articlesByCategory.containsKey(catKey) && _articlesByCategory[catKey]!.isNotEmpty) {
        return _articlesByCategory[catKey]!;
      }
    }

    var list = _cachedArticles.isNotEmpty ? _cachedArticles : _fallback.getArticles();

    if (category != null && category != 'top' && category != 'all') {
      list = list.where((a) => a.category.toLowerCase() == category.toLowerCase()).toList();
    }

    if (city != null && city.isNotEmpty) {
      final c = city.toLowerCase();
      list = list.where((a) {
        return (a.city?.toLowerCase() == c) ||
            a.tags.any((t) => t.toLowerCase() == c) ||
            a.title.toLowerCase().contains(c) ||
            a.summary.toLowerCase().contains(c);
      }).toList();
    }

    if (query != null && query.trim().isNotEmpty) {
      final q = query.toLowerCase().trim();
      list = list.where((a) {
        return a.title.toLowerCase().contains(q) ||
            a.summary.toLowerCase().contains(q) ||
            a.tags.any((t) => t.toLowerCase().contains(q)) ||
            a.source.name.toLowerCase().contains(q);
      }).toList();
    }

    if (source != null && source != 'all') {
      list = list.where((a) => a.source.slug == source).toList();
    }

    if (sortBy == 'most_read' || sortBy == 'popular') {
      list = List.from(list)..sort((a, b) => b.likeCount.compareTo(a.likeCount));
    }

    return list;
  }

  @override
  List<Article> getForYouArticles({Set<String>? interests}) {
    if (_cachedForYouArticles.isNotEmpty) {
      return _cachedForYouArticles;
    }
    return _fallback.getForYouArticles(interests: interests);
  }

  @override
  List<Article> getLocalArticles({String? city}) {
    final key = (city ?? 'New York').toLowerCase();
    if (_cachedLocalByCity.containsKey(key) && _cachedLocalByCity[key]!.isNotEmpty) {
      return _cachedLocalByCity[key]!;
    }
    final fromCache = _cachedArticles.where((a) {
      if (city != null && city.isNotEmpty) {
        final c = city.toLowerCase();
        return a.category == 'local' &&
            ((a.city?.toLowerCase() == c) ||
                a.tags.any((t) => t.toLowerCase() == c) ||
                a.title.toLowerCase().contains(c) ||
                a.summary.toLowerCase().contains(c));
      }
      return a.category == 'local';
    }).toList();
    if (fromCache.isNotEmpty) return fromCache;
    return _fallback.getLocalArticles(city: city);
  }

  @override
  List<Article> getBreakingArticles() {
    if (_cachedBreakingArticles.isNotEmpty) return _cachedBreakingArticles;
    final fromCache = _cachedArticles.where((a) => a.isBreaking).toList();
    return fromCache.isNotEmpty ? fromCache : _fallback.getBreakingArticles();
  }

  @override
  List<Article> getTrendingArticles() {
    if (_cachedTrendingArticles.isNotEmpty) return _cachedTrendingArticles;
    return _fallback.getTrendingArticles();
  }

  @override
  List<NewsCategory> getCategories() {
    return _cachedCategories.isNotEmpty ? _cachedCategories : _fallback.getCategories();
  }

  @override
  StoryCluster getFullCoverageCluster() => _cachedCluster ?? _fallback.getFullCoverageCluster();

  @override
  List<TimelineEvent> getClusterTimeline() {
    if (_cachedCluster != null && _cachedCluster!.timeline.isNotEmpty) {
      return _cachedCluster!.timeline;
    }
    return _cachedTimeline ?? _fallback.getClusterTimeline();
  }

  @override
  WeatherSnapshot getWeather(String city) {
    final key = city.toLowerCase();
    if (_cachedWeatherByCity.containsKey(key)) {
      return _cachedWeatherByCity[key]!;
    }
    return _fallback.getWeather(city);
  }

  @override
  List<MarketTickerItem> getMarketTickers({String? sector}) {
    if (sector != null && sector != 'All') {
      final sKey = sector.toLowerCase();
      if (_cachedMarketTickersBySector.containsKey(sKey)) {
        return _cachedMarketTickersBySector[sKey]!;
      }
    }
    return _cachedMarketTickers.isNotEmpty ? _cachedMarketTickers : _fallback.getMarketTickers(sector: sector);
  }

  @override
  List<String> getTrendingTags() {
    return _cachedTrendingTags.isNotEmpty ? _cachedTrendingTags : _fallback.getTrendingTags();
  }

  @override
  List<AppNotification> getNotifications() {
    return _cachedNotifications.isNotEmpty ? _cachedNotifications : _fallback.getNotifications();
  }

  @override
  List<ArticleComment> getComments(String articleId) {
    if (_cachedCommentsByArticle.containsKey(articleId)) {
      return _cachedCommentsByArticle[articleId]!;
    }
    if (_cachedCommentsByArticle.containsKey('default')) {
      return _cachedCommentsByArticle['default']!;
    }
    return _fallback.getComments(articleId);
  }

  @override
  List<String> getAvailableInterests() => _fallback.getAvailableInterests();

  @override
  List<SponsoredAd> getSponsoredAds({String? placement, String? category}) {
    return _cachedAds.isNotEmpty ? _cachedAds : _fallback.getSponsoredAds(placement: placement, category: category);
  }

  // =========================================================================
  // ASYNCHRONOUS LIVE API METHODS (Full Backend Integration)
  // =========================================================================

  /// Proactively synchronizes all core feeds and widgets from the backend.
  Future<void> syncAllAsync({String city = 'New York', Set<String>? interests}) async {
    try {
      await Future.wait([
        fetchArticlesAsync(limit: 50),
        fetchCategoriesAsync(),
        fetchForYouAsync(topics: interests, city: city),
        fetchLocalNewsAsync(city: city),
        fetchBreakingAsync(),
        fetchTrendingArticlesAsync(),
        fetchClustersAsync(),
        fetchWeatherAsync(city),
        fetchMarketTickersAsync(),
        fetchTrendingTagsAsync(),
        fetchNotificationsAsync(),
        fetchSponsoredAdsAsync(),
        fetchCommentsAsync('default'),
      ]).timeout(const Duration(seconds: 6));
    } catch (_) {
      // Backend may be offline or starting; fallback cache remains intact.
    }
  }

  /// Fetches articles from GET /api/news or GET /api/news/search.
  Future<List<Article>> fetchArticlesAsync({
    String? category,
    String? city,
    String? query,
    String? source,
    String? tag,
    String? sortBy,
    int limit = 25,
    int offset = 0,
  }) async {
    try {
      final isSearch = query != null && query.trim().isNotEmpty;
      final endpoint = isSearch ? '$baseUrl/news/search' : '$baseUrl/news';

      final queryParams = <String, String>{
        'limit': limit.toString(),
        'offset': offset.toString(),
      };
      if (category != null && category != 'top' && category != 'all') {
        queryParams['category'] = category;
      }
      if (city != null && city.isNotEmpty) {
        queryParams['city'] = city;
      }
      if (source != null && source != 'all') {
        queryParams['source'] = source;
      }
      if (tag != null && tag.isNotEmpty) {
        queryParams['tag'] = tag;
      }
      if (sortBy != null && sortBy.isNotEmpty) {
        queryParams['sortBy'] = sortBy;
      }
      if (isSearch) {
        queryParams['q'] = query.trim();
      }

      final uri = Uri.parse(endpoint).replace(queryParameters: queryParams);
      final response = await _client.get(uri, headers: _headers(jsonContent: false)).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        _isBackendConnected = true;
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic> && data['articles'] is List) {
          final articles = (data['articles'] as List)
              .map((item) => Article.fromJson(item as Map<String, dynamic>))
              .toList();
          _mergeArticles(articles);

          if (isSearch) {
            _lastSearchQueryKey = '${query.trim().toLowerCase()}|${source ?? 'all'}|${sortBy ?? 'latest'}';
            _cachedSearchArticles = articles;
          } else if (category != null && category != 'top' && category != 'all') {
            final catKey = '${category.toLowerCase()}|${source ?? 'all'}|${sortBy ?? 'latest'}';
            _articlesByCategory[catKey] = articles;
          } else if ((source == null || source == 'all') && city == null && tag == null) {
            _cachedArticles = articles;
          }
          return articles;
        }
      }
    } catch (_) {}
    return getArticles(category: category, city: city, query: query, source: source, sortBy: sortBy);
  }

  /// Fetches single article (and increments backend views) via GET /api/news/$id.
  Future<Article?> fetchArticleByIdAsync(String id) async {
    try {
      final uri = Uri.parse('$baseUrl/news/$id');
      final response = await _client.get(uri, headers: _headers(jsonContent: false)).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        _isBackendConnected = true;
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final rawArticle = (data['article'] as Map<String, dynamic>?) ?? data;
        final article = Article.fromJson(rawArticle);
        _articlesById[article.id] = article;
        final idx = _cachedArticles.indexWhere((a) => a.id == article.id);
        if (idx != -1) {
          _cachedArticles[idx] = article;
        }
        return article;
      }
    } catch (_) {}
    return getCachedArticleById(id);
  }

  /// Fetches personalized For You feed via GET /api/news/for_you.
  Future<List<Article>> fetchForYouAsync({
    Set<String>? topics,
    String? city,
    String? country,
    int limit = 25,
  }) async {
    try {
      final params = <String, String>{'limit': limit.toString()};
      if (topics != null && topics.isNotEmpty) {
        params['topics'] = topics.join(',');
      }
      if (city != null && city.isNotEmpty) {
        params['city'] = city;
      }
      if (country != null && country.isNotEmpty) {
        params['country'] = country;
      }

      final uri = Uri.parse('$baseUrl/news/for_you').replace(queryParameters: params);
      final response = await _client.get(uri, headers: _headers(jsonContent: false)).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        _isBackendConnected = true;
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic> && data['articles'] is List) {
          final articles = (data['articles'] as List)
              .map((item) => Article.fromJson(item as Map<String, dynamic>))
              .toList();
          _mergeArticles(articles);
          _cachedForYouArticles = articles;
          return articles;
        }
      }
    } catch (_) {}
    return getForYouArticles(interests: topics);
  }

  /// Fetches local news feed via GET /api/news/local.
  Future<List<Article>> fetchLocalNewsAsync({String? city, String? country, int limit = 15}) async {
    try {
      final params = <String, String>{'limit': limit.toString()};
      if (city != null && city.isNotEmpty) params['city'] = city;
      if (country != null && country.isNotEmpty) params['country'] = country;

      final uri = Uri.parse('$baseUrl/news/local').replace(queryParameters: params);
      final response = await _client.get(uri, headers: _headers(jsonContent: false)).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        _isBackendConnected = true;
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic> && data['articles'] is List) {
          final articles = (data['articles'] as List)
              .map((item) => Article.fromJson(item as Map<String, dynamic>))
              .toList();
          _mergeArticles(articles);
          _cachedLocalByCity[(city ?? 'New York').toLowerCase()] = articles;
          return articles;
        }
      }
    } catch (_) {}
    return getLocalArticles(city: city);
  }

  /// Fetches breaking news via GET /api/news/breaking.
  Future<List<Article>> fetchBreakingAsync() async {
    try {
      final uri = Uri.parse('$baseUrl/news/breaking');
      final response = await _client.get(uri, headers: _headers(jsonContent: false)).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        _isBackendConnected = true;
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic> && data['articles'] is List) {
          final articles = (data['articles'] as List)
              .map((item) => Article.fromJson(item as Map<String, dynamic>))
              .toList();
          _mergeArticles(articles);
          _cachedBreakingArticles = articles;
          return articles;
        }
      }
    } catch (_) {}
    return getBreakingArticles();
  }

  /// Fetches trending articles via GET /api/news/trending.
  Future<List<Article>> fetchTrendingArticlesAsync({int limit = 10}) async {
    try {
      final uri = Uri.parse('$baseUrl/news/trending').replace(queryParameters: {'limit': limit.toString()});
      final response = await _client.get(uri, headers: _headers(jsonContent: false)).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        _isBackendConnected = true;
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic> && data['articles'] is List) {
          final articles = (data['articles'] as List)
              .map((item) => Article.fromJson(item as Map<String, dynamic>))
              .toList();
          _mergeArticles(articles);
          _cachedTrendingArticles = articles;
          return articles;
        }
      }
    } catch (_) {}
    return getTrendingArticles();
  }

  /// Triggers backend RSS ingestion via POST /api/news/refresh.
  Future<int> refreshFeedsAsync() async {
    try {
      final uri = Uri.parse('$baseUrl/news/refresh');
      final response = await _client.post(uri, headers: _headers(jsonContent: false)).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        _isBackendConnected = true;
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        await syncAllAsync();
        return (data['newArticlesIngested'] as num?)?.toInt() ?? 0;
      }
    } catch (_) {}
    return 0;
  }

  /// Fetches Google News Full Coverage story clusters via GET /api/news/clusters.
  Future<List<StoryCluster>> fetchClustersAsync() async {
    try {
      final uri = Uri.parse('$baseUrl/news/clusters');
      final response = await _client.get(uri, headers: _headers(jsonContent: false)).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        _isBackendConnected = true;
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic> && data['clusters'] is List) {
          final clusters = (data['clusters'] as List)
              .map((c) => StoryCluster.fromJson(c as Map<String, dynamic>))
              .toList();
          if (clusters.isNotEmpty) {
            _cachedClusters = clusters;
            _cachedCluster = clusters.first;
            if (clusters.first.timeline.isNotEmpty) {
              _cachedTimeline = clusters.first.timeline;
            }
          }
          return clusters;
        }
      }
    } catch (_) {}
    return _cachedClusters.isNotEmpty ? _cachedClusters : [getFullCoverageCluster()];
  }

  /// Fetches a specific story cluster via GET /api/news/clusters/$id.
  Future<StoryCluster?> fetchClusterByIdAsync(String id) async {
    try {
      final uri = Uri.parse('$baseUrl/news/clusters/$id');
      final response = await _client.get(uri, headers: _headers(jsonContent: false)).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        _isBackendConnected = true;
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final rawCluster = (data['cluster'] as Map<String, dynamic>?) ?? data;
        final cluster = StoryCluster.fromJson(rawCluster);
        _cachedCluster = cluster;
        if (cluster.timeline.isNotEmpty) {
          _cachedTimeline = cluster.timeline;
        }
        return cluster;
      }
    } catch (_) {}
    return getFullCoverageCluster();
  }

  /// Fetches categories catalog via GET /api/categories.
  Future<List<NewsCategory>> fetchCategoriesAsync() async {
    try {
      final uri = Uri.parse('$baseUrl/categories');
      final response = await _client.get(uri, headers: _headers(jsonContent: false)).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        _isBackendConnected = true;
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic> && data['categories'] is List) {
          final cats = (data['categories'] as List)
              .map((c) => NewsCategory.fromJson(c as Map<String, dynamic>))
              .toList();
          if (cats.isNotEmpty) {
            _cachedCategories = cats;
          }
          return cats;
        }
      }
    } catch (_) {}
    return getCategories();
  }

  /// Fetches weather from GET /api/widgets/weather?city=...
  /// Note: Backend responds with { "weather": { ... } }.
  Future<WeatherSnapshot> fetchWeatherAsync(String city) async {
    try {
      final uri = Uri.parse('$baseUrl/widgets/weather').replace(queryParameters: {'city': city});
      final response = await _client.get(uri, headers: _headers(jsonContent: false)).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        _isBackendConnected = true;
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final payload = (data['weather'] as Map<String, dynamic>?) ?? data;
        final snapshot = WeatherSnapshot.fromJson(payload);
        _cachedWeatherByCity[city.toLowerCase()] = snapshot;
        return snapshot;
      }
    } catch (_) {}
    return getWeather(city);
  }

  /// Fetches financial market tickers from GET /api/widgets/markets?sector=...
  /// Note: Backend responds with { "sector": ..., "count": ..., "markets": [ ... ] }.
  Future<List<MarketTickerItem>> fetchMarketTickersAsync({String? sector}) async {
    try {
      final params = <String, String>{};
      if (sector != null && sector != 'All' && sector.isNotEmpty) {
        params['sector'] = sector;
      }
      final uri = Uri.parse('$baseUrl/widgets/markets').replace(queryParameters: params);
      final response = await _client.get(uri, headers: _headers(jsonContent: false)).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        _isBackendConnected = true;
        final data = jsonDecode(response.body);
        final listRaw = data is Map<String, dynamic> ? (data['markets'] ?? data['items']) : data;
        if (listRaw is List) {
          final tickers = listRaw
              .map((e) => MarketTickerItem.fromJson(e as Map<String, dynamic>))
              .toList();
          if (sector != null && sector != 'All') {
            _cachedMarketTickersBySector[sector.toLowerCase()] = tickers;
          } else {
            _cachedMarketTickers = tickers;
          }
          return tickers;
        }
      }
    } catch (_) {}
    return getMarketTickers(sector: sector);
  }

  /// Fetches trending tags from GET /api/widgets/trending
  /// Note: Backend responds with { "trendingTopics": [ ... ] }.
  Future<List<String>> fetchTrendingTagsAsync() async {
    try {
      final uri = Uri.parse('$baseUrl/widgets/trending');
      final response = await _client.get(uri, headers: _headers(jsonContent: false)).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        _isBackendConnected = true;
        final data = jsonDecode(response.body);
        final rawList = data is Map<String, dynamic> ? (data['trendingTopics'] ?? data['tags']) : data;
        if (rawList is List) {
          final tags = rawList.cast<String>();
          _cachedTrendingTags = tags;
          return tags;
        }
      }
    } catch (_) {}
    return getTrendingTags();
  }

  /// Fetches notifications from GET /api/notifications
  Future<List<AppNotification>> fetchNotificationsAsync() async {
    try {
      final uri = Uri.parse('$baseUrl/notifications');
      final response = await _client.get(uri, headers: _headers(jsonContent: false)).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        _isBackendConnected = true;
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic> && data['notifications'] is List) {
          final notifications = (data['notifications'] as List)
              .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
              .toList();
          _cachedNotifications = notifications;
          return notifications;
        }
      }
    } catch (_) {}
    return getNotifications();
  }

  /// Marks a notification as read via POST /api/notifications
  Future<bool> markNotificationReadAsync(String id) async {
    try {
      final uri = Uri.parse('$baseUrl/notifications');
      final response = await _client
          .post(uri, headers: _headers(), body: jsonEncode({'id': id}))
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final idx = _cachedNotifications.indexWhere((n) => n.id == id);
        if (idx != -1) {
          _cachedNotifications[idx] = _cachedNotifications[idx].copyWith(isRead: true);
        }
        return true;
      }
    } catch (_) {}
    return false;
  }

  /// Fetches article comments from GET /api/news/[id]/comments
  /// Note: Backend responds with { "articleId": id, "count": n, "comments": [ ... ] }.
  Future<List<ArticleComment>> fetchCommentsAsync(String articleId) async {
    try {
      final uri = Uri.parse('$baseUrl/news/$articleId/comments');
      final response = await _client.get(uri, headers: _headers(jsonContent: false)).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        _isBackendConnected = true;
        final data = jsonDecode(response.body);
        final rawList = data is Map<String, dynamic> ? data['comments'] : data;
        if (rawList is List) {
          final comments = rawList
              .map((c) => ArticleComment.fromJson(c as Map<String, dynamic>))
              .toList();
          _cachedCommentsByArticle[articleId] = comments;
          return comments;
        }
      }
    } catch (_) {}
    return getComments(articleId);
  }

  /// Posts a new comment via POST /api/news/[id]/comments
  /// Note: Backend responds with { "message": ..., "comment": { ... } }.
  Future<ArticleComment?> postCommentAsync(
    String articleId, {
    required String author,
    required String avatarUrl,
    required String text,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/news/$articleId/comments');
      final response = await _client
          .post(
            uri,
            headers: _headers(),
            body: jsonEncode({
              'author': author,
              'avatarUrl': avatarUrl,
              'text': text,
            }),
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final rawComment = (data['comment'] as Map<String, dynamic>?) ?? data;
        final newComment = ArticleComment.fromJson(rawComment);
        final list = _cachedCommentsByArticle.putIfAbsent(articleId, () => []);
        list.insert(0, newComment);
        return newComment;
      }
    } catch (_) {}
    return null;
  }

  /// Toggles like on a comment via POST /api/comments/like
  Future<bool> toggleCommentLikeAsync(String commentId) async {
    try {
      final uri = Uri.parse('$baseUrl/comments/like');
      final response = await _client
          .post(uri, headers: _headers(), body: jsonEncode({'commentId': commentId}))
          .timeout(const Duration(seconds: 3));

      return response.statusCode == 200;
    } catch (_) {}
    return false;
  }

  /// Fetches sponsored ads from GET /api/ads
  Future<List<SponsoredAd>> fetchSponsoredAdsAsync({
    String? placement,
    String? category,
    String? format,
  }) async {
    try {
      final params = <String, String>{};
      if (placement != null) params['placement'] = placement;
      if (category != null && category != 'all') params['category'] = category;
      if (format != null) params['format'] = format;

      final uri = Uri.parse('$baseUrl/ads').replace(queryParameters: params);
      final response = await _client.get(uri, headers: _headers(jsonContent: false)).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        _isBackendConnected = true;
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic> && data['ads'] is List) {
          final ads = (data['ads'] as List)
              .map((e) => SponsoredAd.fromJson(e as Map<String, dynamic>))
              .toList();
          if (placement == null && category == null && format == null) {
            _cachedAds = ads;
          }
          return ads;
        }
      }
    } catch (_) {}
    return getSponsoredAds(placement: placement, category: category);
  }

  /// Submits a new ad campaign via POST /api/ads
  Future<bool> createAdCampaignAsync(SponsoredAd ad) async {
    try {
      final uri = Uri.parse('$baseUrl/ads');
      final response = await _client
          .post(uri, headers: _headers(), body: jsonEncode(ad.toJson()))
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 201) {
        _cachedAds.insert(0, ad);
        return true;
      }
    } catch (_) {}
    _cachedAds.insert(0, ad);
    return false;
  }

  /// Records ad click telemetry via POST /api/ads/click
  Future<void> recordAdClickAsync(String adId) async {
    try {
      final uri = Uri.parse('$baseUrl/ads/click');
      await _client
          .post(uri, headers: _headers(), body: jsonEncode({'adId': adId}))
          .timeout(const Duration(seconds: 2));
    } catch (_) {}
  }

  // =========================================================================
  // AUTHENTICATION, USER PROFILE & PERSISTENCE API
  // =========================================================================

  /// Validates existing JWT token and loads user profile via GET /api/auth/me
  Future<User?> fetchCurrentUserAsync() async {
    if (_authToken == null || _authToken!.isEmpty) return null;
    try {
      final uri = Uri.parse('$baseUrl/auth/me');
      final response = await _client.get(uri, headers: _headers(jsonContent: false)).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        _isBackendConnected = true;
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final rawUser = (data['user'] as Map<String, dynamic>?) ?? data;
        return User.fromJson(rawUser);
      } else if (response.statusCode == 401) {
        setAuthToken(null);
      }
    } catch (_) {}
    return null;
  }

  /// Authenticates user via POST /api/auth/login
  Future<Map<String, dynamic>?> loginAsync(String email, String password) async {
    try {
      final uri = Uri.parse('$baseUrl/auth/login');
      final response = await _client
          .post(
            uri,
            headers: _headers(),
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        _isBackendConnected = true;
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        setAuthToken(data['token'] as String?);
        return data;
      }
    } catch (_) {}
    return null;
  }

  /// Authenticates / registers via Google 1-Tap OAuth endpoint POST /api/auth/google
  Future<Map<String, dynamic>?> loginWithGoogleAsync({
    String email = 'alex.rivera@readmore.org',
    String displayName = 'Alex Rivera',
    String? avatarUrl,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/auth/google');
      final response = await _client
          .post(
            uri,
            headers: _headers(),
            body: jsonEncode({
              'email': email,
              'displayName': displayName,
              if (avatarUrl != null) 'avatarUrl': avatarUrl,
            }),
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        _isBackendConnected = true;
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        setAuthToken(data['token'] as String?);
        return data;
      }
    } catch (_) {}
    return null;
  }

  /// Registers user via POST /api/auth/register
  Future<Map<String, dynamic>?> registerAsync(
    String email,
    String password,
    String displayName,
  ) async {
    try {
      final uri = Uri.parse('$baseUrl/auth/register');
      final response = await _client
          .post(
            uri,
            headers: _headers(),
            body: jsonEncode({
              'email': email,
              'password': password,
              'displayName': displayName,
            }),
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 201) {
        _isBackendConnected = true;
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        setAuthToken(data['token'] as String?);
        return data;
      }
    } catch (_) {}
    return null;
  }

  /// Fetches saved bookmarks via GET /api/user/bookmarks
  Future<List<Article>?> fetchBookmarksAsync() async {
    if (_authToken == null) return null;
    try {
      final uri = Uri.parse('$baseUrl/user/bookmarks');
      final response = await _client.get(uri, headers: _headers(jsonContent: false)).timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final raw = data['bookmarks'] as List<dynamic>? ?? const [];
        final articles = raw.map((e) => Article.fromJson(e as Map<String, dynamic>)).toList();
        _mergeArticles(articles);
        return articles;
      }
    } catch (_) {}
    return null;
  }

  /// Saves bookmark via POST /api/user/bookmarks
  Future<bool> saveBookmarkAsync(String articleId) async {
    if (_authToken == null) return false;
    try {
      final uri = Uri.parse('$baseUrl/user/bookmarks');
      final response = await _client
          .post(uri, headers: _headers(), body: jsonEncode({'articleId': articleId}))
          .timeout(const Duration(seconds: 3));
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (_) {}
    return false;
  }

  /// Removes bookmark via DELETE /api/user/bookmarks?articleId=...
  Future<bool> removeBookmarkAsync(String articleId) async {
    if (_authToken == null) return false;
    try {
      final uri = Uri.parse('$baseUrl/user/bookmarks').replace(queryParameters: {'articleId': articleId});
      final response = await _client.delete(uri, headers: _headers(jsonContent: false)).timeout(const Duration(seconds: 3));
      return response.statusCode == 200;
    } catch (_) {}
    return false;
  }

  /// Fetches Read Later queue via GET /api/user/read_later
  Future<List<Article>?> fetchReadLaterAsync() async {
    if (_authToken == null) return null;
    try {
      final uri = Uri.parse('$baseUrl/user/read_later');
      final response = await _client.get(uri, headers: _headers(jsonContent: false)).timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final raw = data['readLater'] as List<dynamic>? ?? const [];
        final articles = raw.map((e) => Article.fromJson(e as Map<String, dynamic>)).toList();
        _mergeArticles(articles);
        return articles;
      }
    } catch (_) {}
    return null;
  }

  /// Saves Read Later via POST /api/user/read_later
  Future<bool> saveReadLaterAsync(String articleId) async {
    if (_authToken == null) return false;
    try {
      final uri = Uri.parse('$baseUrl/user/read_later');
      final response = await _client
          .post(uri, headers: _headers(), body: jsonEncode({'articleId': articleId}))
          .timeout(const Duration(seconds: 3));
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (_) {}
    return false;
  }

  /// Removes Read Later via DELETE /api/user/read_later?articleId=...
  Future<bool> removeReadLaterAsync(String articleId) async {
    if (_authToken == null) return false;
    try {
      final uri = Uri.parse('$baseUrl/user/read_later').replace(queryParameters: {'articleId': articleId});
      final response = await _client.delete(uri, headers: _headers(jsonContent: false)).timeout(const Duration(seconds: 3));
      return response.statusCode == 200;
    } catch (_) {}
    return false;
  }

  /// Records user telemetry interaction via POST /api/user/interaction
  Future<bool> recordInteractionAsync(
    String articleId,
    String type, {
    int dwellTimeSeconds = 0,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/user/interaction');
      final response = await _client
          .post(
            uri,
            headers: _headers(),
            body: jsonEncode({
              'articleId': articleId,
              'type': type,
              'dwellTimeSeconds': dwellTimeSeconds,
            }),
          )
          .timeout(const Duration(seconds: 3));
      return response.statusCode == 200;
    } catch (_) {}
    return false;
  }

  /// Updates user preferences and/or displayName via PUT /api/user/preferences
  Future<User?> updatePreferencesAsync({
    String? displayName,
    List<String>? followedTopics,
    String? locationCity,
    String? locationCountry,
    bool? enableBreakingAlerts,
    bool? enableDailyBriefing,
    bool? audioAutoplay,
  }) async {
    if (_authToken == null) return null;
    try {
      final uri = Uri.parse('$baseUrl/user/preferences');
      final body = <String, dynamic>{};
      if (displayName != null) body['displayName'] = displayName;
      if (followedTopics != null) body['followedTopics'] = followedTopics;
      if (locationCity != null) body['locationCity'] = locationCity;
      if (locationCountry != null) body['locationCountry'] = locationCountry;
      if (enableBreakingAlerts != null) body['enableBreakingAlerts'] = enableBreakingAlerts;
      if (enableDailyBriefing != null) body['enableDailyBriefing'] = enableDailyBriefing;
      if (audioAutoplay != null) body['audioAutoplay'] = audioAutoplay;

      final response = await _client
          .put(uri, headers: _headers(), body: jsonEncode(body))
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['user'] is Map<String, dynamic>) {
          return User.fromJson(data['user'] as Map<String, dynamic>);
        }
      }
    } catch (_) {}
    return null;
  }

  /// Upgrades subscription via POST /api/user/subscription
  Future<bool> upgradeSubscriptionAsync({
    required String plan,
    required String paymentMethod,
  }) async {
    if (_authToken == null) return false;
    try {
      final uri = Uri.parse('$baseUrl/user/subscription');
      final response = await _client
          .post(
            uri,
            headers: _headers(),
            body: jsonEncode({'plan': plan, 'paymentMethod': paymentMethod}),
          )
          .timeout(const Duration(seconds: 4));

      return response.statusCode == 200;
    } catch (_) {}
    return false;
  }

  /// Cancels subscription via DELETE /api/user/subscription
  Future<bool> cancelSubscriptionAsync() async {
    if (_authToken == null) return false;
    try {
      final uri = Uri.parse('$baseUrl/user/subscription');
      final response = await _client.delete(uri, headers: _headers(jsonContent: false)).timeout(const Duration(seconds: 4));
      return response.statusCode == 200;
    } catch (_) {}
    return false;
  }

  /// Toggles ad-free preference via POST /api/user/toggle_ad_free
  Future<bool> toggleAdFreeAsync() async {
    if (_authToken == null) return false;
    try {
      final uri = Uri.parse('$baseUrl/user/toggle_ad_free');
      final response = await _client.post(uri, headers: _headers(jsonContent: false)).timeout(const Duration(seconds: 3));
      return response.statusCode == 200;
    } catch (_) {}
    return false;
  }
}
