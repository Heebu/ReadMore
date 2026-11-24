import 'package:flartdart/flartdart.dart';
import 'package:news_models/news_models.dart';
import '../data/mock_data.dart';
import '../data/services/news_service.dart';

/// Central ViewModel managing all ReadMore state, business logic,
/// collection updates, and reactive notifications following MVVM.
class NewsAppViewModel extends ChangeNotifier {
  final NewsService _service;

  NewsAppViewModel({NewsService? service})
      : _service = service ?? ApiNewsService() {
    _comments = _service.getComments('default');
    _currentUser = WebMockData.mockUser;
    _ads = _service.getSponsoredAds();
    _initApiSync();
  }

  void _initApiSync() {
    if (_service is ApiNewsService) {
      final api = _service as ApiNewsService;
      api.syncAllAsync().then((_) {
        _ads = _service.getSponsoredAds();
        _comments = _service.getComments('default');
        notifyListeners();
      });
    }
  }

  // ==========================================
  // NAVIGATION & ROUTING
  // ==========================================
  String _activeScreen = 'headlines';
  String get activeScreen => _activeScreen;

  String _selectedCategory = 'top';
  String get selectedCategory => _selectedCategory;

  String _selectedCity = 'New York';
  String get selectedCity => _selectedCity;

  String _selectedMarketSector = 'All';
  String get selectedMarketSector => _selectedMarketSector;

  String _libraryTab = 'bookmarks';
  String get libraryTab => _libraryTab;

  void setActiveScreen(String screen) {
    if (_activeScreen != screen) {
      _activeScreen = screen;
      if (screen == 'headlines') {
        _selectedCategory = 'top';
      }
      notifyListeners();
    }
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
    if (_service is ApiNewsService) {
      (_service as ApiNewsService).fetchArticlesAsync(category: category).then((_) {
        notifyListeners();
      });
    }
  }
  void setSelectedCategory(String category) => setCategory(category);

  void setCity(String city) {
    _selectedCity = city;
    notifyListeners();
    if (_service is ApiNewsService) {
      final api = _service as ApiNewsService;
      Future.wait([
        api.fetchWeatherAsync(city),
        api.fetchArticlesAsync(city: city),
      ]).then((_) {
        notifyListeners();
      });
    }
  }
  void setSelectedCity(String city) => setCity(city);

  void setMarketSector(String sector) {
    _selectedMarketSector = sector;
    notifyListeners();
    if (_service is ApiNewsService) {
      (_service as ApiNewsService).fetchMarketTickersAsync(sector: sector).then((_) {
        notifyListeners();
      });
    }
  }
  void setSelectedMarketSector(String sector) => setMarketSector(sector);

  void setLibraryTab(String tab) {
    _libraryTab = tab;
    notifyListeners();
  }

  // ==========================================
  // SEARCH & EXPLORE
  // ==========================================
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  String _selectedSourceFilter = 'all';
  String get selectedSourceFilter => _selectedSourceFilter;

  String _sortBy = 'latest';
  String get sortBy => _sortBy;

  void setSearchQuery(String query) {
    _searchQuery = query;
    if (query.trim().isNotEmpty && _activeScreen != 'explore') {
      _activeScreen = 'explore';
    }
    notifyListeners();
    if (_service is ApiNewsService && query.trim().isNotEmpty) {
      (_service as ApiNewsService).fetchArticlesAsync(query: query, sortBy: _sortBy).then((_) {
        notifyListeners();
      });
    }
  }

  void setSortBy(String sort) {
    _sortBy = sort;
    notifyListeners();
    if (_service is ApiNewsService) {
      (_service as ApiNewsService).fetchArticlesAsync(
        category: _selectedCategory,
        query: _searchQuery.isNotEmpty ? _searchQuery : null,
        sortBy: sort,
      ).then((_) {
        notifyListeners();
      });
    }
  }

  void setSourceFilter(String source) {
    _selectedSourceFilter = source;
    notifyListeners();
  }

  // ==========================================
  // USER AUTHENTICATION & PROFILE
  // ==========================================
  User? _currentUser;
  bool _isAuthenticated = true;

  bool get isAuthenticated => _isAuthenticated && _currentUser != null;
  User get currentUser => _currentUser ?? WebMockData.mockUser;

  void signInWithGoogle() {
    _currentUser = WebMockData.mockUser.copyWith(
      displayName: 'Alex Rivera',
      email: 'alex.rivera@readmore.org',
      role: 'user',
    );
    _isAuthenticated = true;
    _showAuthModal = false;
    notifyListeners();
  }

  void signInWithEmail(String email, String password) {
    final name = email.contains('@') ? email.split('@').first : 'Reader';
    _currentUser = User(
      id: 'usr-${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      displayName: name.isNotEmpty ? name[0].toUpperCase() + name.substring(1) : 'Reader',
      role: 'user',
      createdAt: DateTime.now(),
      subscriptionTier: 'free',
      adFreeEnabled: false,
      readingStreakDays: 1,
      articlesReadCount: 1,
    );
    _isAuthenticated = true;
    _showAuthModal = false;
    notifyListeners();
    if (_service is ApiNewsService) {
      (_service as ApiNewsService).loginAsync(email, password).then((res) {
        if (res != null && res['user'] != null) {
          try {
            _currentUser = User.fromJson(res['user'] as Map<String, dynamic>);
            notifyListeners();
          } catch (_) {}
        }
      });
    }
  }

  void signUp(String name, String email, String password) {
    _currentUser = User(
      id: 'usr-${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      displayName: name.isNotEmpty ? name : 'New Reader',
      role: 'user',
      createdAt: DateTime.now(),
      subscriptionTier: 'free',
      adFreeEnabled: false,
      readingStreakDays: 1,
      articlesReadCount: 0,
    );
    _isAuthenticated = true;
    _showAuthModal = false;
    notifyListeners();
    if (_service is ApiNewsService) {
      (_service as ApiNewsService).registerAsync(email, password, name).then((res) {
        if (res != null && res['user'] != null) {
          try {
            _currentUser = User.fromJson(res['user'] as Map<String, dynamic>);
            notifyListeners();
          } catch (_) {}
        }
      });
    }
  }

  void signOut() {
    _isAuthenticated = false;
    _currentUser = null;
    notifyListeners();
  }

  void updateUserProfile({
    String? displayName,
    String? locationCity,
    bool? audioAutoplay,
    bool? breakingAlerts,
    bool? dailyBriefing,
  }) {
    if (_currentUser == null) return;
    final curPrefs = _currentUser!.preferences;
    final updatedPrefs = curPrefs.copyWith(
      locationCity: locationCity,
      audioAutoplay: audioAutoplay,
      enableBreakingAlerts: breakingAlerts,
      enableDailyBriefing: dailyBriefing,
    );
    _currentUser = _currentUser!.copyWith(
      displayName: displayName,
      preferences: updatedPrefs,
    );
    notifyListeners();
  }

  // ==========================================
  // PRO SUBSCRIPTION SYSTEM
  // ==========================================
  void upgradeToPro({String plan = 'annual', String paymentMethod = 'Google Pay'}) {
    _currentUser = currentUser.copyWith(
      subscriptionTier: 'pro',
      adFreeEnabled: true,
    );
    _isAuthenticated = true;
    _showSubscriptionModal = false;
    notifyListeners();
    if (_service is ApiNewsService) {
      (_service as ApiNewsService).upgradeSubscriptionAsync(
        plan: plan,
        paymentMethod: paymentMethod,
      );
    }
  }

  void cancelSubscription() {
    _currentUser = currentUser.copyWith(
      subscriptionTier: 'free',
      adFreeEnabled: false,
    );
    notifyListeners();
  }

  void toggleAdFree() {
    if (currentUser.isPro) {
      _currentUser = currentUser.copyWith(
        adFreeEnabled: !currentUser.adFreeEnabled,
      );
      notifyListeners();
      if (_service is ApiNewsService) {
        (_service as ApiNewsService).toggleAdFreeAsync();
      }
    }
  }

  // ==========================================
  // DYNAMIC ADS SYSTEM
  // ==========================================
  late List<SponsoredAd> _ads;
  List<SponsoredAd> get ads => List.unmodifiable(_ads);

  bool get showAds => !(isAuthenticated && currentUser.isPro && currentUser.adFreeEnabled);

  SponsoredAd? getLeaderboardAd({String? category}) {
    final active = _ads.where((a) => a.isActive && a.placement == AdPlacement.leaderboardBanner).toList();
    if (active.isEmpty) return null;
    if (category != null && category != 'top' && category != 'all') {
      final matched = active.where((a) => a.targetCategory == 'all' || a.targetCategory == category).toList();
      if (matched.isNotEmpty) return matched.first;
    }
    return active.first;
  }

  SponsoredAd? getInFeedNativeAd({String? category}) {
    final active = _ads.where((a) => a.isActive && a.placement == AdPlacement.inFeedNative).toList();
    if (active.isEmpty) return null;
    if (category != null && category != 'top' && category != 'all') {
      final matched = active.where((a) => a.targetCategory == 'all' || a.targetCategory == category).toList();
      if (matched.isNotEmpty) return matched.first;
    }
    return active.first;
  }

  SponsoredAd? getSidebarAd({String? category}) {
    final active = _ads.where((a) => a.isActive && a.placement == AdPlacement.sidebarRectangle).toList();
    if (active.isEmpty) return null;
    if (category != null && category != 'top' && category != 'all') {
      final matched = active.where((a) => a.targetCategory == 'all' || a.targetCategory == category).toList();
      if (matched.isNotEmpty) return matched.first;
    }
    return active.first;
  }

  void recordAdClick(String adId) {
    final idx = _ads.indexWhere((a) => a.id == adId);
    if (idx != -1) {
      final old = _ads[idx];
      _ads[idx] = old.copyWith(clicks: old.clicks + 1);
      notifyListeners();
    }
    if (_service is ApiNewsService) {
      (_service as ApiNewsService).recordAdClickAsync(adId);
    }
  }

  void publishNewAdCampaign(SponsoredAd ad) {
    _ads.insert(0, ad);
    _showAdPublisherModal = false;
    notifyListeners();
    if (_service is ApiNewsService) {
      (_service as ApiNewsService).createAdCampaignAsync(ad);
    }
  }

  // ==========================================
  // MODALS & OVERLAYS CONTROLS
  // ==========================================
  bool _showAuthModal = false;
  String _authModalTab = 'signin';
  bool get showAuthModal => _showAuthModal;
  String get authModalTab => _authModalTab;

  void openAuthModal({String tab = 'signin'}) {
    _authModalTab = tab;
    _showAuthModal = true;
    notifyListeners();
  }

  void closeAuthModal() {
    _showAuthModal = false;
    notifyListeners();
  }

  bool _showSubscriptionModal = false;
  bool get showSubscriptionModal => _showSubscriptionModal;

  void openSubscriptionModal() {
    _showSubscriptionModal = true;
    notifyListeners();
  }

  void closeSubscriptionModal() {
    _showSubscriptionModal = false;
    notifyListeners();
  }

  bool _showAdPublisherModal = false;
  bool get showAdPublisherModal => _showAdPublisherModal;

  void openAdPublisherModal() {
    _showAdPublisherModal = true;
    notifyListeners();
  }

  void closeAdPublisherModal() {
    _showAdPublisherModal = false;
    notifyListeners();
  }

  // ==========================================
  // PERSONALIZATION & USER PROFILE
  // ==========================================
  final double _serendipityLevel = 0.3;
  double get serendipityLevel => _serendipityLevel;

  final Set<String> _userInterests = {
    'Artificial Intelligence',
    'Clean Energy',
    'Wall Street',
    'Space Exploration',
    'Cryptocurrency',
  };
  Set<String> get userInterests => Set.unmodifiable(_userInterests);

  void toggleInterest(String interest) {
    if (_userInterests.contains(interest)) {
      _userInterests.remove(interest);
    } else {
      _userInterests.add(interest);
    }
    notifyListeners();
  }

  // ==========================================
  // USER COLLECTIONS (END-TO-END REACTIVE STATE)
  // ==========================================
  final Set<String> _bookmarkedIds = {'art-hero-1', 'art-tech-1', 'art-bus-1'};
  Set<String> get bookmarkedIds => Set.unmodifiable(_bookmarkedIds);

  final Set<String> _readLaterIds = {'art-sci-1', 'art-food-1'};
  Set<String> get readLaterIds => Set.unmodifiable(_readLaterIds);

  final Set<String> _likedIds = {'art-tech-1', 'art-hero-1'};
  Set<String> get likedIds => Set.unmodifiable(_likedIds);

  final List<String> _readingHistoryIds = ['art-hero-1', 'art-tech-1'];
  List<String> get readingHistoryIds => List.unmodifiable(_readingHistoryIds);

  final Set<String> _marketWatchlist = {'BTC/USD', 'NVDA', 'AAPL'};
  Set<String> get marketWatchlist => Set.unmodifiable(_marketWatchlist);

  bool isBookmarked(String id) => _bookmarkedIds.contains(id);
  bool isReadLater(String id) => _readLaterIds.contains(id);
  bool isLiked(String id) => _likedIds.contains(id);
  bool isWatched(String symbol) => _marketWatchlist.contains(symbol);

  void toggleBookmark(String id) {
    if (_bookmarkedIds.contains(id)) {
      _bookmarkedIds.remove(id);
    } else {
      _bookmarkedIds.add(id);
    }
    notifyListeners();
  }

  void toggleReadLater(String id) {
    if (_readLaterIds.contains(id)) {
      _readLaterIds.remove(id);
    } else {
      _readLaterIds.add(id);
    }
    notifyListeners();
  }

  void toggleLike(String id) {
    if (_likedIds.contains(id)) {
      _likedIds.remove(id);
    } else {
      _likedIds.add(id);
    }
    notifyListeners();
  }

  void toggleWatchlist(String symbol) {
    if (_marketWatchlist.contains(symbol)) {
      _marketWatchlist.remove(symbol);
    } else {
      _marketWatchlist.add(symbol);
    }
    notifyListeners();
  }

  void clearReadingHistory() {
    _readingHistoryIds.clear();
    notifyListeners();
  }

  // ==========================================
  // ACTIVE READER VIEW & AUDIO TTS
  // ==========================================
  Article? _activeReadingArticle;
  Article? get activeReadingArticle => _activeReadingArticle;

  double _readerFontSize = 16.0;
  double get readerFontSize => _readerFontSize;

  bool _isAudioPlaying = false;
  bool get isAudioPlaying => _isAudioPlaying;

  double _audioProgress = 0.35;
  double get audioProgress => _audioProgress;

  double _audioSpeed = 1.0;
  double get audioSpeed => _audioSpeed;

  late List<ArticleComment> _comments;
  List<ArticleComment> get comments => List.unmodifiable(_comments);

  void openArticleReader(Article article) {
    _activeReadingArticle = article;
    _isAudioPlaying = false;
    _audioProgress = 0.0;
    if (!_readingHistoryIds.contains(article.id)) {
      _readingHistoryIds.insert(0, article.id);
    }
    notifyListeners();
  }

  void closeArticleReader() {
    _activeReadingArticle = null;
    _isAudioPlaying = false;
    notifyListeners();
  }

  void nextArticle() {
    if (_activeReadingArticle == null) return;
    final allArticles = _service.getArticles();
    final currentIndex = allArticles.indexWhere((a) => a.id == _activeReadingArticle!.id);
    if (currentIndex != -1 && currentIndex < allArticles.length - 1) {
      openArticleReader(allArticles[currentIndex + 1]);
    } else if (allArticles.isNotEmpty) {
      openArticleReader(allArticles.first);
    }
  }

  void prevArticle() {
    if (_activeReadingArticle == null) return;
    final allArticles = _service.getArticles();
    final currentIndex = allArticles.indexWhere((a) => a.id == _activeReadingArticle!.id);
    if (currentIndex > 0) {
      openArticleReader(allArticles[currentIndex - 1]);
    } else if (allArticles.isNotEmpty) {
      openArticleReader(allArticles.last);
    }
  }

  int get activeArticleIndex {
    if (_activeReadingArticle == null) return -1;
    final all = _service.getArticles();
    return all.indexWhere((a) => a.id == _activeReadingArticle!.id);
  }

  int get totalArticlesCount => _service.getArticles().length;

  void adjustReaderFontSize(double delta) {
    final next = _readerFontSize + delta;
    if (next >= 12.0 && next <= 26.0) {
      _readerFontSize = next;
      notifyListeners();
    }
  }

  void toggleArticleAudio() {
    _isAudioPlaying = !_isAudioPlaying;
    notifyListeners();
  }

  void cycleAudioSpeed() {
    if (_audioSpeed == 1.0) {
      _audioSpeed = 1.25;
    } else if (_audioSpeed == 1.25) {
      _audioSpeed = 1.5;
    } else {
      _audioSpeed = 1.0;
    }
    notifyListeners();
  }

  void addComment(String text) {
    if (text.trim().isEmpty) return;
    final articleId = _activeReadingArticle?.id ?? 'default';
    final authorName = _currentUser?.displayName ?? 'You (Verified Reader)';
    final avatar = _currentUser?.avatarUrl ??
        'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=128&q=80';

    final localComment = ArticleComment(
      id: 'c-${DateTime.now().millisecondsSinceEpoch}',
      author: authorName,
      avatarUrl: avatar,
      text: text.trim(),
      timeAgo: 'Just now',
    );
    _comments.insert(0, localComment);
    notifyListeners();

    if (_service is ApiNewsService) {
      (_service as ApiNewsService).postCommentAsync(
        articleId,
        author: authorName,
        avatarUrl: avatar,
        text: text.trim(),
      );
    }
  }

  void toggleCommentLike(String commentId) {
    final idx = _comments.indexWhere((c) => c.id == commentId);
    if (idx != -1) {
      final c = _comments[idx];
      c.isLiked = !c.isLiked;
      c.likes += c.isLiked ? 1 : -1;
      notifyListeners();
    }
    if (_service is ApiNewsService) {
      (_service as ApiNewsService).toggleCommentLikeAsync(commentId);
    }
  }

  // ==========================================
  // MODALS & OVERLAYS STATE
  // ==========================================
  bool _showFullCoverageModal = false;
  bool get showFullCoverageModal => _showFullCoverageModal;

  bool _showInterestsModal = false;
  bool get showInterestsModal => _showInterestsModal;

  bool _showNotificationsModal = false;
  bool get showNotificationsModal => _showNotificationsModal;

  bool _showEditionModal = false;
  bool get showEditionModal => _showEditionModal;

  String _selectedEdition = 'United States';
  String get selectedEdition => _selectedEdition;

  bool _hasUnreadNotifications = true;
  bool get hasUnreadNotifications => _hasUnreadNotifications;

  void openFullCoverage() {
    _showFullCoverageModal = true;
    notifyListeners();
  }
  void openFullCoverageModal() => openFullCoverage();

  void closeFullCoverage() {
    _showFullCoverageModal = false;
    notifyListeners();
  }
  void closeFullCoverageModal() => closeFullCoverage();

  void openInterestsModal() {
    _showInterestsModal = true;
    notifyListeners();
  }

  void closeInterestsModal() {
    _showInterestsModal = false;
    notifyListeners();
  }

  void toggleNotificationsModal() {
    _showNotificationsModal = !_showNotificationsModal;
    if (_showNotificationsModal) {
      _hasUnreadNotifications = false;
      if (_service is ApiNewsService) {
        final api = _service as ApiNewsService;
        for (final n in api.getNotifications().where((n) => !n.isRead)) {
          api.markNotificationReadAsync(n.id);
        }
      }
    }
    notifyListeners();
  }

  void openEditionModal() {
    _showEditionModal = true;
    notifyListeners();
  }

  void closeEditionModal() {
    _showEditionModal = false;
    notifyListeners();
  }

  void setEdition(String edition) {
    _selectedEdition = edition;
    _showEditionModal = false;
    notifyListeners();
  }
  void setSelectedEdition(String edition) => setEdition(edition);

  // ==========================================
  // STICKY BOTTOM AUDIO BRIEFING
  // ==========================================
  bool _showBottomBriefing = true;
  bool get showBottomBriefing => _showBottomBriefing;

  bool _isBriefingPlaying = false;
  bool get isBriefingPlaying => _isBriefingPlaying;

  void toggleBottomBriefing() {
    _showBottomBriefing = true;
    _isBriefingPlaying = !_isBriefingPlaying;
    notifyListeners();
  }
  void toggleBriefingPlaying() => toggleBottomBriefing();

  void closeBottomBriefing() {
    _showBottomBriefing = false;
    _isBriefingPlaying = false;
    notifyListeners();
  }

  void closeReaderModal() => closeArticleReader();
  void increaseReaderFontSize() => adjustReaderFontSize(2.0);
  void decreaseReaderFontSize() => adjustReaderFontSize(-2.0);
  void toggleAudioPlaying() => toggleArticleAudio();

  String _newCommentDraft = '';
  String get newCommentDraft => _newCommentDraft;
  void setNewCommentDraft(String text) {
    _newCommentDraft = text;
  }
  void postComment() {
    if (_newCommentDraft.trim().isNotEmpty) {
      addComment(_newCommentDraft);
      _newCommentDraft = '';
    }
  }

  // ==========================================
  // THEME
  // ==========================================
  bool _isDarkMode = true;
  bool get isDarkMode => _isDarkMode;

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  // ==========================================
  // COMPUTED / FILTERED DOMAIN GETTERS
  // ==========================================
  WeatherSnapshot get currentWeather => _service.getWeather(_selectedCity);
  List<MarketTickerItem> get marketTickers => _service.getMarketTickers(sector: _selectedMarketSector);
  List<String> get trendingTags => _service.getTrendingTags();
  List<AppNotification> get notifications => _service.getNotifications();
  StoryCluster get fullCoverageCluster => _service.getFullCoverageCluster();
  List<TimelineEvent> get clusterTimeline => _service.getClusterTimeline();
  List<String> get availableInterests => _service.getAvailableInterests();
  List<String> get allAvailableInterests => availableInterests;

  List<NewsCategory> get categories => NewsCategory.allCategories;
  List<Article> get sampleArticles => _service.getArticles();
  List<Article> get filteredArticles => headlinesArticles;

  List<Article> get headlinesArticles {
    return _service.getArticles(category: _selectedCategory);
  }

  List<Article> get personalizedArticles {
    final all = _service.getArticles();
    final matched = all.where((a) {
      return a.tags.any((t) => _userInterests.any((ui) => ui.toLowerCase().contains(t.toLowerCase()))) ||
          _userInterests.any((ui) => a.category.toLowerCase().contains(ui.toLowerCase()));
    }).toList();
    return matched.isNotEmpty ? matched : all;
  }

  List<Article> get localArticles {
    return _service.getArticles(city: _selectedCity);
  }

  List<Article> get marketArticles {
    final all = _service.getArticles();
    return all.where((a) => a.category == 'business' || a.category == 'tech').toList();
  }

  List<Article> get libraryArticles {
    final all = _service.getArticles();
    if (_libraryTab == 'bookmarks') {
      return all.where((a) => _bookmarkedIds.contains(a.id)).toList();
    } else if (_libraryTab == 'read_later') {
      return all.where((a) => _readLaterIds.contains(a.id)).toList();
    } else {
      return all.where((a) => _readingHistoryIds.contains(a.id)).toList();
    }
  }

  int get totalQueueReadingMinutes {
    return libraryArticles.fold<int>(0, (sum, a) => sum + a.readTimeMinutes);
  }

  List<Article> get exploreArticles {
    var list = _service.getArticles(query: _searchQuery);
    if (_selectedSourceFilter != 'all') {
      list = list.where((a) => a.source.slug == _selectedSourceFilter).toList();
    }
    if (_sortBy == 'most_read') {
      list = List.from(list)..sort((a, b) => b.likeCount.compareTo(a.likeCount));
    }
    return list;
  }
}
