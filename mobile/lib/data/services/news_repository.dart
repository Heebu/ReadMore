import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:news_models/news_models.dart';
import '../../core/config/app_config.dart';
import '../mock/mock_data.dart';
import 'token_storage_service.dart';

/// Paginated response envelope returned by `/api/news` and `/api/news/search`.
class PaginatedArticlesResult {
  final List<Article> articles;
  final int total;
  final bool hasMore;

  const PaginatedArticlesResult({
    required this.articles,
    required this.total,
    required this.hasMore,
  });
}

/// Abstract News Repository contract supporting live Dart Frog backend and mock offline testing.
abstract class NewsRepository {
  bool get isBackendConnected;
  String? get authToken;
  bool get wasExplicitlySignedOut;
  Future<void> setAuthToken(String? token);
  Future<void> markSignedOut();

  List<Article> getCachedArticles({String? category, String? city, String? query});
  Article? getCachedArticleById(String id);

  Future<void> syncAllAsync({String city = 'New York', Set<String>? interests});
  Future<PaginatedArticlesResult> fetchArticlesAsync({
    String? category,
    String? query,
    String? source,
    String? sortBy,
    int limit = 30,
    int offset = 0,
  });
  Future<Article?> fetchArticleByIdAsync(String id);
  Future<List<Article>> fetchForYouAsync({
    Set<String>? topics,
    String? city,
    String? country,
    int limit = 20,
  });
  Future<List<Article>> fetchLocalNewsAsync({
    String? city,
    String? country,
    int limit = 15,
  });
  Future<List<Article>> fetchBreakingAsync();
  Future<List<Article>> fetchTrendingArticlesAsync({int limit = 10});
  Future<int> refreshFeedsAsync();

  Future<List<StoryCluster>> fetchClustersAsync();
  Future<StoryCluster?> fetchClusterByIdAsync(String id);
  Future<List<NewsCategory>> fetchCategoriesAsync();

  Future<WeatherSnapshot> fetchWeatherAsync(String city);
  Future<List<MarketTickerItem>> fetchMarketTickersAsync({String? sector});
  Future<List<String>> fetchTrendingTagsAsync();
  Future<List<AppNotification>> fetchNotificationsAsync();
  Future<bool> markNotificationReadAsync(String id);

  Future<List<ArticleComment>> fetchCommentsAsync(String articleId);
  Future<ArticleComment?> postCommentAsync(
    String articleId, {
    required String author,
    required String avatarUrl,
    required String text,
  });
  Future<bool> toggleCommentLikeAsync(String commentId);

  Future<List<SponsoredAd>> fetchSponsoredAdsAsync({
    String? placement,
    String? category,
  });
  Future<bool> createAdCampaignAsync(SponsoredAd ad);
  Future<void> recordAdClickAsync(String adId);

  Future<User?> fetchCurrentUserAsync();
  Future<Map<String, dynamic>> loginAsync(String email, String password);
  Future<Map<String, dynamic>> loginWithGoogleAsync({
    String? idToken,
    String? email,
    String? displayName,
    String? avatarUrl,
  });
  Future<Map<String, dynamic>> registerAsync(
    String email,
    String password,
    String displayName,
  );
  Future<Map<String, dynamic>> requestPasswordResetAsync(String email);
  Future<Map<String, dynamic>> resetPasswordAsync({
    required String token,
    required String newPassword,
  });
  Future<Map<String, dynamic>> changePasswordAsync({
    required String currentPassword,
    required String newPassword,
  });

  Future<List<Article>> fetchBookmarksAsync();
  Future<bool> saveBookmarkAsync(String articleId);
  Future<bool> removeBookmarkAsync(String articleId);
  Future<List<Article>> fetchReadLaterAsync();
  Future<bool> saveReadLaterAsync(String articleId);
  Future<bool> removeReadLaterAsync(String articleId);
  Future<User?> recordInteractionAsync(
    String articleId,
    String type, {
    int? dwellTimeSeconds,
  });
  Future<User?> updatePreferencesAsync({
    String? displayName,
    List<String>? followedTopics,
    String? locationCity,
    String? locationCountry,
    bool? audioAutoplay,
    bool? enableBreakingAlerts,
    bool? enableDailyBriefing,
    bool? darkMode,
  });
  Future<User?> upgradeSubscriptionAsync({
    String plan = 'annual',
    String paymentMethod = 'Google Pay',
  });
  Future<User?> cancelSubscriptionAsync();
  Future<User?> toggleAdFreeAsync();

  List<NewsCategory> getFallbackCategories();
  List<MarketTickerItem> getFallbackMarkets();
  WeatherSnapshot getFallbackWeather(String city);
  List<String> getFallbackTrendingTags();
  List<AppNotification> getFallbackNotifications();
  List<SponsoredAd> getFallbackAds();
  StoryCluster getFallbackCluster();
  List<TimelineEvent> getFallbackTimeline();
}

/// Live HTTP implementation talking to ReadMore's Dart Frog API with resilient cache fallback.
class ApiNewsRepository implements NewsRepository {
  final String baseUrl;
  final http.Client _client;
  final TokenStorageService _storage;

  final Map<String, Article> _articlesById = {};
  List<Article> _cachedArticles = List.of(MobileMockData.sampleArticles);
  final Map<String, List<Article>> _cachedLocalByCity = {};
  List<Article> _cachedForYou = const [];
  List<NewsCategory> _cachedCategories = List.of(MobileMockData.categories);
  final Map<String, WeatherSnapshot> _weatherByCity =
      Map.of(MobileMockData.cityWeatherMap);
  List<MarketTickerItem> _cachedMarkets = List.of(MobileMockData.marketTicker);
  List<String> _cachedTags = List.of(MobileMockData.trendingTags);
  List<AppNotification> _cachedNotifications =
      List.of(MobileMockData.notifications);
  final Map<String, List<ArticleComment>> _commentsByArticle = {};
  List<SponsoredAd> _cachedAds = List.of(MobileMockData.initialAds);
  List<StoryCluster> _cachedClusters = [MobileMockData.fullCoverageCluster];

  bool _isBackendConnected = false;
  String? _authToken;

  ApiNewsRepository({
    String? baseUrl,
    http.Client? client,
    TokenStorageService? storage,
  })  : baseUrl = baseUrl ?? AppConfig.apiBaseUrl,
        _client = client ?? http.Client(),
        _storage = storage ?? TokenStorageService() {
    _authToken = _storage.getToken();
    for (final article in _cachedArticles) {
      _articlesById[article.id] = article;
    }
    for (final persp in MobileMockData.fullCoverageCluster.alternativePerspectives) {
      _articlesById[persp.id] = persp;
    }
    _commentsByArticle['seed-top-1'] = List.of(MobileMockData.initialComments);
  }

  @override
  bool get isBackendConnected => _isBackendConnected;

  @override
  String? get authToken => _authToken;

  @override
  bool get wasExplicitlySignedOut => _storage.wasExplicitlySignedOut;

  @override
  Future<void> setAuthToken(String? token) async {
    _authToken = token;
    await _storage.saveToken(token);
  }

  @override
  Future<void> markSignedOut() async {
    _authToken = null;
    _cachedForYou = const [];
    await _storage.markSignedOut();
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

  void _mergeArticles(List<Article> items) {
    for (final a in items) {
      _articlesById[a.id] = a;
    }
  }

  @override
  Article? getCachedArticleById(String id) => _articlesById[id];

  @override
  List<Article> getCachedArticles({
    String? category,
    String? city,
    String? query,
  }) {
    if (query != null && query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      return _cachedArticles
          .where((a) =>
              a.title.toLowerCase().contains(q) ||
              a.summary.toLowerCase().contains(q) ||
              a.category.toLowerCase().contains(q) ||
              a.source.name.toLowerCase().contains(q) ||
              a.tags.any((t) => t.toLowerCase().contains(q)))
          .toList();
    }
    if (city != null && city.isNotEmpty) {
      final cached = _cachedLocalByCity[city];
      if (cached != null && cached.isNotEmpty) return cached;
      return _cachedArticles
          .where((a) => (a.city ?? '').toLowerCase() == city.toLowerCase())
          .toList();
    }
    if (category != null &&
        category.isNotEmpty &&
        category.toLowerCase() != 'top') {
      if (category.toLowerCase() == 'for_you' ||
          category.toLowerCase() == 'for-you') {
        return _cachedForYou.isNotEmpty ? _cachedForYou : _cachedArticles;
      }
      return _cachedArticles
          .where((a) => a.category.toLowerCase() == category.toLowerCase())
          .toList();
    }
    return _cachedArticles;
  }

  @override
  Future<void> syncAllAsync({
    String city = 'New York',
    Set<String>? interests,
  }) async {
    await Future.wait([
      fetchArticlesAsync(),
      fetchCategoriesAsync(),
      fetchWeatherAsync(city),
      fetchMarketTickersAsync(),
      fetchTrendingTagsAsync(),
      fetchNotificationsAsync(),
      fetchSponsoredAdsAsync(),
      fetchClustersAsync(),
      fetchForYouAsync(topics: interests, city: city),
      fetchLocalNewsAsync(city: city),
    ]);
  }

  @override
  Future<PaginatedArticlesResult> fetchArticlesAsync({
    String? category,
    String? query,
    String? source,
    String? sortBy,
    int limit = 30,
    int offset = 0,
  }) async {
    try {
      final hasQuery = query != null && query.trim().isNotEmpty;
      final endpoint = hasQuery ? '/news/search' : '/news';
      final params = <String, String>{
        'limit': '$limit',
        'offset': '$offset',
        if (hasQuery) 'q': query.trim(),
        if (category != null && category.isNotEmpty) 'category': category,
        if (source != null && source.isNotEmpty) 'source': source,
        if (sortBy != null && sortBy.isNotEmpty) 'sortBy': sortBy,
      };
      final uri = Uri.parse('$baseUrl$endpoint').replace(queryParameters: params);
      final resp = await _client
          .get(uri, headers: _headers(jsonContent: false))
          .timeout(const Duration(seconds: 6));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final raw = data['articles'] as List<dynamic>? ?? const [];
        final parsed =
            raw.map((e) => Article.fromJson(e as Map<String, dynamic>)).toList();
        _isBackendConnected = true;
        _mergeArticles(parsed);
        if (!hasQuery &&
            (category == null || category == 'top') &&
            offset == 0 &&
            parsed.isNotEmpty) {
          _cachedArticles = parsed;
        }
        return PaginatedArticlesResult(
          articles: parsed,
          total: (data['total'] as num?)?.toInt() ?? parsed.length,
          hasMore: data['hasMore'] as bool? ?? false,
        );
      }
    } catch (_) {}

    final fallback = getCachedArticles(category: category, query: query);
    return PaginatedArticlesResult(
      articles: fallback,
      total: fallback.length,
      hasMore: false,
    );
  }

  @override
  Future<Article?> fetchArticleByIdAsync(String id) async {
    try {
      final uri = Uri.parse('$baseUrl/news/${Uri.encodeComponent(id)}');
      final resp = await _client
          .get(uri, headers: _headers(jsonContent: false))
          .timeout(const Duration(seconds: 6));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final raw = data['article'] as Map<String, dynamic>?;
        if (raw != null) {
          final article = Article.fromJson(raw);
          _articlesById[article.id] = article;
          _isBackendConnected = true;
          return article;
        }
      }
    } catch (_) {}
    return _articlesById[id];
  }

  @override
  Future<List<Article>> fetchForYouAsync({
    Set<String>? topics,
    String? city,
    String? country,
    int limit = 20,
  }) async {
    try {
      final params = <String, String>{
        'limit': '$limit',
        if (topics != null && topics.isNotEmpty) 'topics': topics.join(','),
        if (city != null && city.isNotEmpty) 'city': city,
        if (country != null && country.isNotEmpty) 'country': country,
      };
      final uri =
          Uri.parse('$baseUrl/news/for_you').replace(queryParameters: params);
      final resp = await _client
          .get(uri, headers: _headers(jsonContent: false))
          .timeout(const Duration(seconds: 6));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final raw = data['articles'] as List<dynamic>? ?? const [];
        final parsed =
            raw.map((e) => Article.fromJson(e as Map<String, dynamic>)).toList();
        _isBackendConnected = true;
        _mergeArticles(parsed);
        _cachedForYou = parsed;
        return parsed;
      }
    } catch (_) {}
    return _cachedForYou.isNotEmpty ? _cachedForYou : _cachedArticles;
  }

  @override
  Future<List<Article>> fetchLocalNewsAsync({
    String? city,
    String? country,
    int limit = 15,
  }) async {
    try {
      final params = <String, String>{
        'limit': '$limit',
        if (city != null && city.isNotEmpty) 'city': city,
        if (country != null && country.isNotEmpty) 'country': country,
      };
      final uri =
          Uri.parse('$baseUrl/news/local').replace(queryParameters: params);
      final resp = await _client
          .get(uri, headers: _headers(jsonContent: false))
          .timeout(const Duration(seconds: 6));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final raw = data['articles'] as List<dynamic>? ?? const [];
        final parsed =
            raw.map((e) => Article.fromJson(e as Map<String, dynamic>)).toList();
        _isBackendConnected = true;
        _mergeArticles(parsed);
        if (city != null && city.isNotEmpty) {
          _cachedLocalByCity[city] = parsed;
        }
        return parsed;
      }
    } catch (_) {}
    return getCachedArticles(city: city);
  }

  @override
  Future<List<Article>> fetchBreakingAsync() async {
    try {
      final uri = Uri.parse('$baseUrl/news/breaking');
      final resp = await _client
          .get(uri, headers: _headers(jsonContent: false))
          .timeout(const Duration(seconds: 5));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final raw = data['articles'] as List<dynamic>? ?? const [];
        final parsed =
            raw.map((e) => Article.fromJson(e as Map<String, dynamic>)).toList();
        _mergeArticles(parsed);
        return parsed;
      }
    } catch (_) {}
    return _cachedArticles.where((a) => a.isBreaking).toList();
  }

  @override
  Future<List<Article>> fetchTrendingArticlesAsync({int limit = 10}) async {
    try {
      final uri = Uri.parse('$baseUrl/news/trending?limit=$limit');
      final resp = await _client
          .get(uri, headers: _headers(jsonContent: false))
          .timeout(const Duration(seconds: 5));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final raw = data['articles'] as List<dynamic>? ?? const [];
        final parsed =
            raw.map((e) => Article.fromJson(e as Map<String, dynamic>)).toList();
        _mergeArticles(parsed);
        return parsed;
      }
    } catch (_) {}
    return _cachedArticles.take(limit).toList();
  }

  @override
  Future<int> refreshFeedsAsync() async {
    try {
      final uri = Uri.parse('$baseUrl/news/refresh');
      final resp = await _client
          .post(uri, headers: _headers())
          .timeout(const Duration(seconds: 10));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        await syncAllAsync();
        return (data['newArticlesIngested'] as num?)?.toInt() ?? 0;
      }
    } catch (_) {}
    return 0;
  }

  @override
  Future<List<StoryCluster>> fetchClustersAsync() async {
    try {
      final uri = Uri.parse('$baseUrl/news/clusters');
      final resp = await _client
          .get(uri, headers: _headers(jsonContent: false))
          .timeout(const Duration(seconds: 5));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final raw = data['clusters'] as List<dynamic>? ?? const [];
        final parsed = raw
            .map((e) => StoryCluster.fromJson(e as Map<String, dynamic>))
            .toList();
        if (parsed.isNotEmpty) {
          _cachedClusters = parsed;
          for (final c in parsed) {
            _articlesById[c.primaryArticle.id] = c.primaryArticle;
            _mergeArticles(c.alternativePerspectives);
          }
        }
        return _cachedClusters;
      }
    } catch (_) {}
    return _cachedClusters;
  }

  @override
  Future<StoryCluster?> fetchClusterByIdAsync(String id) async {
    try {
      final uri = Uri.parse('$baseUrl/news/clusters/${Uri.encodeComponent(id)}');
      final resp = await _client
          .get(uri, headers: _headers(jsonContent: false))
          .timeout(const Duration(seconds: 5));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final raw = data['cluster'] as Map<String, dynamic>?;
        if (raw != null) return StoryCluster.fromJson(raw);
      }
    } catch (_) {}
    return _cachedClusters.isNotEmpty ? _cachedClusters.first : null;
  }

  @override
  Future<List<NewsCategory>> fetchCategoriesAsync() async {
    try {
      final uri = Uri.parse('$baseUrl/categories');
      final resp = await _client
          .get(uri, headers: _headers(jsonContent: false))
          .timeout(const Duration(seconds: 5));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final raw = data['categories'] as List<dynamic>? ?? const [];
        final parsed = raw
            .map((e) => NewsCategory.fromJson(e as Map<String, dynamic>))
            .toList();
        if (parsed.isNotEmpty) {
          _cachedCategories = parsed;
        }
        return _cachedCategories;
      }
    } catch (_) {}
    return _cachedCategories;
  }

  @override
  Future<WeatherSnapshot> fetchWeatherAsync(String city) async {
    try {
      final uri = Uri.parse('$baseUrl/widgets/weather')
          .replace(queryParameters: {'city': city});
      final resp = await _client
          .get(uri, headers: _headers(jsonContent: false))
          .timeout(const Duration(seconds: 5));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final raw = data['weather'] as Map<String, dynamic>?;
        if (raw != null) {
          final parsed = WeatherSnapshot.fromJson(raw);
          _weatherByCity[city] = parsed;
          return parsed;
        }
      }
    } catch (_) {}
    return _weatherByCity[city] ??
        MobileMockData.cityWeatherMap[city] ??
        MobileMockData.cityWeatherMap['New York']!;
  }

  @override
  Future<List<MarketTickerItem>> fetchMarketTickersAsync({String? sector}) async {
    try {
      final params = <String, String>{
        if (sector != null && sector.isNotEmpty && sector != 'All')
          'sector': sector,
      };
      final uri =
          Uri.parse('$baseUrl/widgets/markets').replace(queryParameters: params);
      final resp = await _client
          .get(uri, headers: _headers(jsonContent: false))
          .timeout(const Duration(seconds: 5));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final raw = data['markets'] as List<dynamic>? ?? const [];
        final parsed = raw
            .map((e) => MarketTickerItem.fromJson(e as Map<String, dynamic>))
            .toList();
        if ((sector == null || sector == 'All') && parsed.isNotEmpty) {
          _cachedMarkets = parsed;
        }
        return parsed;
      }
    } catch (_) {}
    if (sector != null && sector.isNotEmpty && sector != 'All') {
      return _cachedMarkets
          .where((m) => m.sector.toLowerCase() == sector.toLowerCase())
          .toList();
    }
    return _cachedMarkets;
  }

  @override
  Future<List<String>> fetchTrendingTagsAsync() async {
    try {
      final uri = Uri.parse('$baseUrl/widgets/trending');
      final resp = await _client
          .get(uri, headers: _headers(jsonContent: false))
          .timeout(const Duration(seconds: 5));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final raw = data['trendingTopics'] as List<dynamic>? ?? const [];
        final parsed = raw.map((e) => e.toString()).toList();
        if (parsed.isNotEmpty) {
          _cachedTags = parsed;
        }
        return _cachedTags;
      }
    } catch (_) {}
    return _cachedTags;
  }

  @override
  Future<List<AppNotification>> fetchNotificationsAsync() async {
    try {
      final uri = Uri.parse('$baseUrl/notifications');
      final resp = await _client
          .get(uri, headers: _headers(jsonContent: false))
          .timeout(const Duration(seconds: 5));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final raw = data['notifications'] as List<dynamic>? ?? const [];
        final parsed = raw
            .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
            .toList();
        _cachedNotifications = parsed;
        return parsed;
      }
    } catch (_) {}
    return _cachedNotifications;
  }

  @override
  Future<bool> markNotificationReadAsync(String id) async {
    try {
      final uri = Uri.parse('$baseUrl/notifications');
      final resp = await _client
          .post(uri, headers: _headers(), body: jsonEncode({'id': id}))
          .timeout(const Duration(seconds: 5));
      return resp.statusCode == 200;
    } catch (_) {}
    return false;
  }

  @override
  Future<List<ArticleComment>> fetchCommentsAsync(String articleId) async {
    try {
      final uri =
          Uri.parse('$baseUrl/news/${Uri.encodeComponent(articleId)}/comments');
      final resp = await _client
          .get(uri, headers: _headers(jsonContent: false))
          .timeout(const Duration(seconds: 5));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final raw = data['comments'] as List<dynamic>? ?? const [];
        final parsed = raw
            .map((e) => ArticleComment.fromJson(e as Map<String, dynamic>))
            .toList();
        _commentsByArticle[articleId] = parsed;
        return parsed;
      }
    } catch (_) {}
    return _commentsByArticle[articleId] ?? const [];
  }

  @override
  Future<ArticleComment?> postCommentAsync(
    String articleId, {
    required String author,
    required String avatarUrl,
    required String text,
  }) async {
    try {
      final uri =
          Uri.parse('$baseUrl/news/${Uri.encodeComponent(articleId)}/comments');
      final resp = await _client
          .post(
            uri,
            headers: _headers(),
            body: jsonEncode({
              'author': author,
              'avatarUrl': avatarUrl,
              'text': text,
            }),
          )
          .timeout(const Duration(seconds: 6));
      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final raw = data['comment'] as Map<String, dynamic>?;
        if (raw != null) {
          return ArticleComment.fromJson(raw);
        }
      }
    } catch (_) {}
    return null;
  }

  @override
  Future<bool> toggleCommentLikeAsync(String commentId) async {
    try {
      final uri = Uri.parse('$baseUrl/comments/like');
      final resp = await _client
          .post(
            uri,
            headers: _headers(),
            body: jsonEncode({'commentId': commentId}),
          )
          .timeout(const Duration(seconds: 5));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        return data['isLiked'] as bool? ?? true;
      }
    } catch (_) {}
    return false;
  }

  @override
  Future<List<SponsoredAd>> fetchSponsoredAdsAsync({
    String? placement,
    String? category,
  }) async {
    try {
      final params = <String, String>{
        'placement': ?placement,
        'category': ?category,
      };
      final uri = Uri.parse('$baseUrl/ads').replace(queryParameters: params);
      final resp = await _client
          .get(uri, headers: _headers(jsonContent: false))
          .timeout(const Duration(seconds: 5));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final raw = data['ads'] as List<dynamic>? ?? const [];
        final parsed = raw
            .map((e) => SponsoredAd.fromJson(e as Map<String, dynamic>))
            .toList();
        if (placement == null && category == null && parsed.isNotEmpty) {
          _cachedAds = parsed;
        }
        return parsed;
      }
    } catch (_) {}
    return _cachedAds;
  }

  @override
  Future<bool> createAdCampaignAsync(SponsoredAd ad) async {
    try {
      final uri = Uri.parse('$baseUrl/ads');
      final resp = await _client
          .post(uri, headers: _headers(), body: jsonEncode(ad.toJson()))
          .timeout(const Duration(seconds: 6));
      return resp.statusCode == 200 || resp.statusCode == 201;
    } catch (_) {}
    return false;
  }

  @override
  Future<void> recordAdClickAsync(String adId) async {
    try {
      final uri = Uri.parse('$baseUrl/ads/click');
      await _client
          .post(uri, headers: _headers(), body: jsonEncode({'adId': adId}))
          .timeout(const Duration(seconds: 4));
    } catch (_) {}
  }

  @override
  Future<User?> fetchCurrentUserAsync() async {
    if (_authToken == null || _authToken!.isEmpty) return null;
    try {
      final uri = Uri.parse('$baseUrl/auth/me');
      final resp = await _client
          .get(uri, headers: _headers(jsonContent: false))
          .timeout(const Duration(seconds: 5));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final raw = data['user'] as Map<String, dynamic>?;
        if (raw != null) return User.fromJson(raw);
      } else if (resp.statusCode == 401) {
        await setAuthToken(null);
      }
    } catch (_) {}
    return null;
  }

  @override
  Future<Map<String, dynamic>> loginAsync(String email, String password) async {
    try {
      final uri = Uri.parse('$baseUrl/auth/login');
      final resp = await _client
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 6));
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      if (resp.statusCode == 200 && data['token'] is String) {
        await setAuthToken(data['token'] as String);
        _isBackendConnected = true;
      }
      return data;
    } catch (_) {
      return {'error': 'Unable to reach ReadMore server. Check your connection.'};
    }
  }

  @override
  Future<Map<String, dynamic>> loginWithGoogleAsync({
    String? idToken,
    String? email,
    String? displayName,
    String? avatarUrl,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/auth/google');
      final body = <String, dynamic>{
        'idToken': ?idToken,
        'email': ?email,
        'displayName': ?displayName,
        'avatarUrl': ?avatarUrl,
      };
      final resp = await _client
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 6));
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      if (resp.statusCode == 200 && data['token'] is String) {
        await setAuthToken(data['token'] as String);
        _isBackendConnected = true;
      }
      return data;
    } catch (_) {
      return {'error': 'Google sign-in could not connect to the backend.'};
    }
  }

  @override
  Future<Map<String, dynamic>> registerAsync(
    String email,
    String password,
    String displayName,
  ) async {
    try {
      final uri = Uri.parse('$baseUrl/auth/register');
      final resp = await _client
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email,
              'password': password,
              'displayName': displayName,
            }),
          )
          .timeout(const Duration(seconds: 6));
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      if ((resp.statusCode == 200 || resp.statusCode == 201) &&
          data['token'] is String) {
        await setAuthToken(data['token'] as String);
        _isBackendConnected = true;
      }
      return data;
    } catch (_) {
      return {'error': 'Registration failed due to network error.'};
    }
  }

  @override
  Future<Map<String, dynamic>> requestPasswordResetAsync(String email) async {
    try {
      final uri = Uri.parse('$baseUrl/auth/forgot_password');
      final resp = await _client
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email}),
          )
          .timeout(const Duration(seconds: 6));
      return jsonDecode(resp.body) as Map<String, dynamic>;
    } catch (_) {
      return {'error': 'Could not send reset code.'};
    }
  }

  @override
  Future<Map<String, dynamic>> resetPasswordAsync({
    required String token,
    required String newPassword,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/auth/reset_password');
      final resp = await _client
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'token': token, 'newPassword': newPassword}),
          )
          .timeout(const Duration(seconds: 6));
      return jsonDecode(resp.body) as Map<String, dynamic>;
    } catch (_) {
      return {'error': 'Could not reset passphrase.'};
    }
  }

  @override
  Future<Map<String, dynamic>> changePasswordAsync({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/auth/change_password');
      final resp = await _client
          .post(
            uri,
            headers: _headers(),
            body: jsonEncode({
              'currentPassword': currentPassword,
              'newPassword': newPassword,
            }),
          )
          .timeout(const Duration(seconds: 6));
      return jsonDecode(resp.body) as Map<String, dynamic>;
    } catch (_) {
      return {'error': 'Could not update passphrase.'};
    }
  }

  @override
  Future<List<Article>> fetchBookmarksAsync() async {
    if (_authToken == null) return const [];
    try {
      final uri = Uri.parse('$baseUrl/user/bookmarks');
      final resp = await _client
          .get(uri, headers: _headers(jsonContent: false))
          .timeout(const Duration(seconds: 5));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final raw = data['bookmarks'] as List<dynamic>? ?? const [];
        final parsed =
            raw.map((e) => Article.fromJson(e as Map<String, dynamic>)).toList();
        _mergeArticles(parsed);
        return parsed;
      }
    } catch (_) {}
    return const [];
  }

  @override
  Future<bool> saveBookmarkAsync(String articleId) async {
    if (_authToken == null) return false;
    try {
      final uri = Uri.parse('$baseUrl/user/bookmarks');
      final resp = await _client
          .post(
            uri,
            headers: _headers(),
            body: jsonEncode({'articleId': articleId}),
          )
          .timeout(const Duration(seconds: 5));
      return resp.statusCode == 200 || resp.statusCode == 201;
    } catch (_) {}
    return false;
  }

  @override
  Future<bool> removeBookmarkAsync(String articleId) async {
    if (_authToken == null) return false;
    try {
      final uri = Uri.parse('$baseUrl/user/bookmarks')
          .replace(queryParameters: {'articleId': articleId});
      final resp = await _client
          .delete(uri, headers: _headers(jsonContent: false))
          .timeout(const Duration(seconds: 5));
      return resp.statusCode == 200;
    } catch (_) {}
    return false;
  }

  @override
  Future<List<Article>> fetchReadLaterAsync() async {
    if (_authToken == null) return const [];
    try {
      final uri = Uri.parse('$baseUrl/user/read_later');
      final resp = await _client
          .get(uri, headers: _headers(jsonContent: false))
          .timeout(const Duration(seconds: 5));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final raw = data['readLater'] as List<dynamic>? ?? const [];
        final parsed =
            raw.map((e) => Article.fromJson(e as Map<String, dynamic>)).toList();
        _mergeArticles(parsed);
        return parsed;
      }
    } catch (_) {}
    return const [];
  }

  @override
  Future<bool> saveReadLaterAsync(String articleId) async {
    if (_authToken == null) return false;
    try {
      final uri = Uri.parse('$baseUrl/user/read_later');
      final resp = await _client
          .post(
            uri,
            headers: _headers(),
            body: jsonEncode({'articleId': articleId}),
          )
          .timeout(const Duration(seconds: 5));
      return resp.statusCode == 200 || resp.statusCode == 201;
    } catch (_) {}
    return false;
  }

  @override
  Future<bool> removeReadLaterAsync(String articleId) async {
    if (_authToken == null) return false;
    try {
      final uri = Uri.parse('$baseUrl/user/read_later')
          .replace(queryParameters: {'articleId': articleId});
      final resp = await _client
          .delete(uri, headers: _headers(jsonContent: false))
          .timeout(const Duration(seconds: 5));
      return resp.statusCode == 200;
    } catch (_) {}
    return false;
  }

  @override
  Future<User?> recordInteractionAsync(
    String articleId,
    String type, {
    int? dwellTimeSeconds,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/user/interaction');
      final resp = await _client
          .post(
            uri,
            headers: _headers(),
            body: jsonEncode({
              'articleId': articleId,
              'type': type,
              'dwellTimeSeconds': ?dwellTimeSeconds,
            }),
          )
          .timeout(const Duration(seconds: 5));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final raw = data['user'] as Map<String, dynamic>?;
        if (raw != null) return User.fromJson(raw);
      }
    } catch (_) {}
    return null;
  }

  @override
  Future<User?> updatePreferencesAsync({
    String? displayName,
    List<String>? followedTopics,
    String? locationCity,
    String? locationCountry,
    bool? audioAutoplay,
    bool? enableBreakingAlerts,
    bool? enableDailyBriefing,
    bool? darkMode,
  }) async {
    if (_authToken == null) return null;
    try {
      final uri = Uri.parse('$baseUrl/user/preferences');
      final payload = <String, dynamic>{
        'displayName': ?displayName,
        'followedTopics': ?followedTopics,
        'locationCity': ?locationCity,
        'locationCountry': ?locationCountry,
        'audioAutoplay': ?audioAutoplay,
        'enableBreakingAlerts': ?enableBreakingAlerts,
        'enableDailyBriefing': ?enableDailyBriefing,
        'darkMode': ?darkMode,
      };
      final resp = await _client
          .put(uri, headers: _headers(), body: jsonEncode(payload))
          .timeout(const Duration(seconds: 6));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final raw = data['user'] as Map<String, dynamic>?;
        if (raw != null) return User.fromJson(raw);
      }
    } catch (_) {}
    return null;
  }

  @override
  Future<User?> upgradeSubscriptionAsync({
    String plan = 'annual',
    String paymentMethod = 'Google Pay',
  }) async {
    if (_authToken == null) return null;
    try {
      final uri = Uri.parse('$baseUrl/user/subscription');
      final resp = await _client
          .post(
            uri,
            headers: _headers(),
            body: jsonEncode({'plan': plan, 'paymentMethod': paymentMethod}),
          )
          .timeout(const Duration(seconds: 6));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final raw = data['user'] as Map<String, dynamic>?;
        if (raw != null) return User.fromJson(raw);
      }
    } catch (_) {}
    return null;
  }

  @override
  Future<User?> cancelSubscriptionAsync() async {
    if (_authToken == null) return null;
    try {
      final uri = Uri.parse('$baseUrl/user/subscription');
      final resp = await _client
          .delete(uri, headers: _headers(jsonContent: false))
          .timeout(const Duration(seconds: 6));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final raw = data['user'] as Map<String, dynamic>?;
        if (raw != null) return User.fromJson(raw);
      }
    } catch (_) {}
    return null;
  }

  @override
  Future<User?> toggleAdFreeAsync() async {
    if (_authToken == null) return null;
    try {
      final uri = Uri.parse('$baseUrl/user/toggle_ad_free');
      final resp = await _client
          .post(uri, headers: _headers())
          .timeout(const Duration(seconds: 6));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final raw = data['user'] as Map<String, dynamic>?;
        if (raw != null) return User.fromJson(raw);
      }
    } catch (_) {}
    return null;
  }

  @override
  List<NewsCategory> getFallbackCategories() => _cachedCategories;

  @override
  List<MarketTickerItem> getFallbackMarkets() => _cachedMarkets;

  @override
  WeatherSnapshot getFallbackWeather(String city) =>
      _weatherByCity[city] ?? MobileMockData.cityWeatherMap['New York']!;

  @override
  List<String> getFallbackTrendingTags() => _cachedTags;

  @override
  List<AppNotification> getFallbackNotifications() => _cachedNotifications;

  @override
  List<SponsoredAd> getFallbackAds() => _cachedAds;

  @override
  StoryCluster getFallbackCluster() => _cachedClusters.first;

  @override
  List<TimelineEvent> getFallbackTimeline() => MobileMockData.clusterTimeline;
}
