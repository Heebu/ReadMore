import 'package:flartdart/flartdart.dart';
import 'package:news_models/news_models.dart';
import '../data/mock_data.dart';
import '../data/services/news_service.dart';

/// Central ViewModel managing all ReadMore state, business logic,
/// collection updates, backend synchronization, and reactive notifications following MVVM.
class NewsAppViewModel extends ChangeNotifier {
  final NewsService _service;

  NewsAppViewModel({NewsService? service})
      : _service = service ?? ApiNewsService() {
    _comments = _service.getComments('default');
    _ads = _service.getSponsoredAds();
    if (_service is ApiNewsService && (_service as ApiNewsService).wasExplicitlySignedOut) {
      _currentUser = null;
      _isAuthenticated = false;
    } else {
      _currentUser = WebMockData.mockUser;
      _isAuthenticated = true;
    }
    _initApiSync();
  }

  bool get isBackendConnected =>
      _service is ApiNewsService && (_service as ApiNewsService).isBackendConnected;

  void _initApiSync() {
    if (_service is! ApiNewsService) return;
    final api = _service as ApiNewsService;

    // 1. Sync public feeds, widgets, clusters, ads, comments, notifications
    api.syncAllAsync(city: _selectedCity, interests: _userInterests).then((_) {
      _ads = _service.getSponsoredAds();
      final activeId = _activeReadingArticle?.id ?? 'default';
      _comments = _service.getComments(activeId);
      _refreshUnreadBadge();
      notifyListeners();
    });

    // 2. Restore existing session OR bootstrap seeded demo session with real JWT
    _bootstrapAuthSession(api);
  }

  Future<void> _bootstrapAuthSession(ApiNewsService api) async {
    User? user;
    if (api.authToken != null && api.authToken!.isNotEmpty) {
      user = await api.fetchCurrentUserAsync();
    }

    if (user == null && !api.wasExplicitlySignedOut) {
      final res = await api.loginAsync('demo@readmore.com', 'Password123!');
      if (res != null && res['user'] is Map<String, dynamic>) {
        try {
          user = User.fromJson(res['user'] as Map<String, dynamic>);
        } catch (_) {}
      }
    }

    if (user != null) {
      _applyAuthenticatedUser(user);
      await _syncUserCollections(api);
    } else if (api.wasExplicitlySignedOut) {
      _currentUser = null;
      _isAuthenticated = false;
      notifyListeners();
    }
  }

  void _applyAuthenticatedUser(User user) {
    _currentUser = user;
    _isAuthenticated = true;
    _isDarkMode = user.preferences.darkMode;
    final city = user.preferences.locationCity;
    if (city != null && city.isNotEmpty) {
      _selectedCity = city;
    }
    final availableLower = {for (final i in availableInterests) i.toLowerCase(): i};
    final matchedTopics = user.preferences.followedTopics
        .map((t) => availableLower[t.toLowerCase()])
        .whereType<String>()
        .toSet();
    if (matchedTopics.isNotEmpty) {
      _userInterests
        ..clear()
        ..addAll(matchedTopics);
    }
    notifyListeners();
  }

  Future<void> _syncUserCollections(ApiNewsService api) async {
    final results = await Future.wait([
      api.fetchBookmarksAsync(),
      api.fetchReadLaterAsync(),
    ]);
    final bookmarks = results[0];
    final readLater = results[1];
    if (bookmarks != null) {
      _bookmarkedIds
        ..clear()
        ..addAll(bookmarks.map((a) => a.id));
    }
    if (readLater != null) {
      _readLaterIds
        ..clear()
        ..addAll(readLater.map((a) => a.id));
    }
    notifyListeners();
  }

  void _refreshUnreadBadge() {
    _hasUnreadNotifications = notifications.any((n) => !n.isRead);
  }

  Future<void> refreshAllFeeds() async {
    if (_service is ApiNewsService) {
      final api = _service as ApiNewsService;
      await api.refreshFeedsAsync();
      _ads = _service.getSponsoredAds();
      notifyListeners();
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
      if (_service is ApiNewsService) {
        final api = _service as ApiNewsService;
        if (screen == 'for_you') {
          api
              .fetchForYouAsync(
                topics: _userInterests,
                city: _selectedCity,
                country: _selectedEdition,
              )
              .then((_) => notifyListeners());
        } else if (screen == 'local') {
          api.fetchLocalNewsAsync(city: _selectedCity).then((_) => notifyListeners());
        } else if (screen == 'markets') {
          api.fetchMarketTickersAsync(sector: _selectedMarketSector).then((_) => notifyListeners());
        } else if (screen == 'library') {
          _syncUserCollections(api);
        }
      }
    }
  }

  void setCategory(String category) {
    if (category == 'for_you') {
      _activeScreen = 'for_you';
      notifyListeners();
      if (_service is ApiNewsService) {
        (_service as ApiNewsService)
            .fetchForYouAsync(topics: _userInterests, city: _selectedCity)
            .then((_) => notifyListeners());
      }
      return;
    }
    if (category == 'local') {
      _activeScreen = 'local';
      notifyListeners();
      if (_service is ApiNewsService) {
        (_service as ApiNewsService)
            .fetchLocalNewsAsync(city: _selectedCity)
            .then((_) => notifyListeners());
      }
      return;
    }
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
        api.fetchLocalNewsAsync(city: city),
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
    if (_service is ApiNewsService) {
      (_service as ApiNewsService)
          .fetchArticlesAsync(
            query: query.trim().isNotEmpty ? query : null,
            source: _selectedSourceFilter,
            sortBy: _sortBy,
          )
          .then((_) => notifyListeners());
    }
  }

  void setSortBy(String sort) {
    _sortBy = sort;
    notifyListeners();
    if (_service is ApiNewsService) {
      (_service as ApiNewsService)
          .fetchArticlesAsync(
            category: _activeScreen == 'explore' ? null : _selectedCategory,
            query: _searchQuery.trim().isNotEmpty ? _searchQuery : null,
            source: _selectedSourceFilter,
            sortBy: sort,
          )
          .then((_) => notifyListeners());
    }
  }

  void setSourceFilter(String source) {
    _selectedSourceFilter = source;
    notifyListeners();
    if (_service is ApiNewsService) {
      (_service as ApiNewsService)
          .fetchArticlesAsync(
            category: _activeScreen == 'explore' ? null : _selectedCategory,
            query: _searchQuery.trim().isNotEmpty ? _searchQuery : null,
            source: source,
            sortBy: _sortBy,
          )
          .then((_) => notifyListeners());
    }
  }

  // ==========================================
  // USER AUTHENTICATION & PROFILE
  // ==========================================
  User? _currentUser;
  bool _isAuthenticated = true;
  bool _isAuthLoading = false;
  String? _authError;
  String? _authSuccessMessage;
  String? _devResetCodeHint;
  String? _profileStatusMessage;

  bool get isAuthenticated => _isAuthenticated && _currentUser != null;
  User get currentUser => _currentUser ?? WebMockData.mockUser;
  bool get isAuthLoading => _isAuthLoading;
  String? get authError => _authError;
  String? get authSuccessMessage => _authSuccessMessage;
  String? get devResetCodeHint => _devResetCodeHint;
  String? get profileStatusMessage => _profileStatusMessage;

  void clearAuthFeedback() {
    _authError = null;
    _authSuccessMessage = null;
    _devResetCodeHint = null;
    notifyListeners();
  }

  Future<void> signInWithGoogle() async {
    _isAuthLoading = true;
    _authError = null;
    _authSuccessMessage = null;
    notifyListeners();

    if (_service is ApiNewsService) {
      final api = _service as ApiNewsService;
      final res = await api.loginWithGoogleAsync(
        email: 'alex.rivera@readmore.org',
        displayName: 'Alex Rivera',
        avatarUrl: WebMockData.mockUser.avatarUrl,
      );
      _isAuthLoading = false;
      if (res != null && res['error'] != null) {
        _authError = res['error'] as String;
        notifyListeners();
        return;
      }
      if (res != null && res['user'] is Map<String, dynamic>) {
        try {
          _showAuthModal = false;
          _applyAuthenticatedUser(User.fromJson(res['user'] as Map<String, dynamic>));
          await _syncUserCollections(api);
          return;
        } catch (_) {}
      }
    }

    // Offline fallback
    _isAuthLoading = false;
    _currentUser = WebMockData.mockUser.copyWith(
      displayName: 'Alex Rivera',
      email: 'alex.rivera@readmore.org',
      role: 'user',
    );
    _isAuthenticated = true;
    _showAuthModal = false;
    notifyListeners();
  }

  Future<void> signInWithEmail(String email, String password) async {
    if (email.trim().isEmpty || !email.contains('@')) {
      _authError = 'Please enter a valid email address.';
      notifyListeners();
      return;
    }
    if (password.isEmpty) {
      _authError = 'Please enter your password.';
      notifyListeners();
      return;
    }

    _isAuthLoading = true;
    _authError = null;
    _authSuccessMessage = null;
    notifyListeners();

    if (_service is ApiNewsService) {
      final api = _service as ApiNewsService;
      final res = await api.loginAsync(email.trim(), password);
      _isAuthLoading = false;

      if (res != null && res['error'] != null) {
        _authError = res['error'] as String;
        notifyListeners();
        return;
      }

      if (res != null && res['user'] is Map<String, dynamic>) {
        try {
          _showAuthModal = false;
          _applyAuthenticatedUser(User.fromJson(res['user'] as Map<String, dynamic>));
          await _syncUserCollections(api);
          return;
        } catch (_) {}
      }
    }

    // Offline fallback when backend is unreachable
    _isAuthLoading = false;
    final name = email.contains('@') ? email.split('@').first : 'Reader';
    _currentUser = User(
      id: 'usr-${DateTime.now().millisecondsSinceEpoch}',
      email: email.trim(),
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
  }

  Future<void> signUp(String name, String email, String password) async {
    if (name.trim().isEmpty) {
      _authError = 'Please enter your full name.';
      notifyListeners();
      return;
    }
    if (email.trim().isEmpty || !email.contains('@')) {
      _authError = 'Please enter a valid email address.';
      notifyListeners();
      return;
    }
    if (password.length < 6) {
      _authError = 'Password must be at least 6 characters long.';
      notifyListeners();
      return;
    }

    _isAuthLoading = true;
    _authError = null;
    _authSuccessMessage = null;
    notifyListeners();

    if (_service is ApiNewsService) {
      final api = _service as ApiNewsService;
      final res = await api.registerAsync(email.trim(), password, name.trim());
      _isAuthLoading = false;

      if (res != null && res['error'] != null) {
        _authError = res['error'] as String;
        notifyListeners();
        return;
      }

      if (res != null && res['user'] is Map<String, dynamic>) {
        try {
          _showAuthModal = false;
          _applyAuthenticatedUser(User.fromJson(res['user'] as Map<String, dynamic>));
          await _syncUserCollections(api);
          return;
        } catch (_) {}
      }
    }

    // Offline fallback
    _isAuthLoading = false;
    _currentUser = User(
      id: 'usr-${DateTime.now().millisecondsSinceEpoch}',
      email: email.trim(),
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
  }

  Future<bool> requestPasswordReset(String email) async {
    if (email.trim().isEmpty || !email.contains('@')) {
      _authError = 'Please enter a valid account email address.';
      notifyListeners();
      return false;
    }

    _isAuthLoading = true;
    _authError = null;
    _authSuccessMessage = null;
    _devResetCodeHint = null;
    notifyListeners();

    if (_service is ApiNewsService) {
      final res = await (_service as ApiNewsService).requestPasswordResetAsync(email.trim());
      _isAuthLoading = false;
      if (res == null) {
        _authError = 'Backend unreachable. Start server on port 8085 to reset password.';
        notifyListeners();
        return false;
      }
      if (res['error'] != null) {
        _authError = res['error'] as String;
        notifyListeners();
        return false;
      }
      _authSuccessMessage = res['message'] as String? ?? 'Reset code issued.';
      _devResetCodeHint = res['devResetCode'] as String?;
      notifyListeners();
      return true;
    }

    _isAuthLoading = false;
    _authError = 'Password reset requires active backend connection.';
    notifyListeners();
    return false;
  }

  Future<bool> confirmPasswordReset(String code, String newPassword) async {
    if (code.trim().isEmpty || newPassword.length < 6) {
      _authError = 'Enter your 6-digit code and a new password (6+ characters).';
      notifyListeners();
      return false;
    }

    _isAuthLoading = true;
    _authError = null;
    _authSuccessMessage = null;
    notifyListeners();

    if (_service is ApiNewsService) {
      final res = await (_service as ApiNewsService).resetPasswordAsync(
        token: code.trim(),
        newPassword: newPassword,
      );
      _isAuthLoading = false;
      if (res == null) {
        _authError = 'Backend unreachable.';
        notifyListeners();
        return false;
      }
      if (res['error'] != null) {
        _authError = res['error'] as String;
        notifyListeners();
        return false;
      }
      _authSuccessMessage = res['message'] as String? ?? 'Password reset! Please sign in.';
      _devResetCodeHint = null;
      notifyListeners();
      return true;
    }

    _isAuthLoading = false;
    return false;
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    if (newPassword.length < 6) {
      _profileStatusMessage = 'Error: New password must be at least 6 characters.';
      notifyListeners();
      return;
    }
    if (_service is ApiNewsService) {
      final res = await (_service as ApiNewsService).changePasswordAsync(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      if (res == null) {
        _profileStatusMessage = 'Error: Could not reach backend server.';
      } else if (res['error'] != null) {
        _profileStatusMessage = 'Error: ${res['error']}';
      } else {
        _profileStatusMessage = '✓ ${res['message'] ?? 'Password updated cleanly.'}';
      }
      notifyListeners();
    }
  }

  void signOut() {
    _isAuthenticated = false;
    _currentUser = null;
    _bookmarkedIds.clear();
    _readLaterIds.clear();
    _profileStatusMessage = null;
    if (_service is ApiNewsService) {
      (_service as ApiNewsService).markSignedOut();
    }
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
    if (locationCity != null && locationCity.isNotEmpty) {
      _selectedCity = locationCity;
    }
    if (displayName != null) {
      _profileStatusMessage = '✓ Profile & preferences saved to SQLite.';
    }
    notifyListeners();

    if (_service is ApiNewsService) {
      final api = _service as ApiNewsService;
      api
          .updatePreferencesAsync(
            displayName: displayName,
            locationCity: locationCity,
            audioAutoplay: audioAutoplay,
            enableBreakingAlerts: breakingAlerts,
            enableDailyBriefing: dailyBriefing,
          )
          .then((serverUser) {
        if (serverUser != null) {
          _currentUser = serverUser;
          notifyListeners();
        }
      });
      if (locationCity != null && locationCity.isNotEmpty) {
        api.fetchWeatherAsync(locationCity).then((_) => notifyListeners());
        api.fetchForYouAsync(topics: _userInterests, city: locationCity).then((_) => notifyListeners());
      }
    }
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
    if (_service is ApiNewsService) {
      (_service as ApiNewsService).cancelSubscriptionAsync();
    }
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
    _authError = null;
    _authSuccessMessage = null;
    _devResetCodeHint = null;
    _showAuthModal = true;
    notifyListeners();
  }

  void closeAuthModal() {
    _showAuthModal = false;
    _authError = null;
    _authSuccessMessage = null;
    _devResetCodeHint = null;
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

    if (_service is ApiNewsService) {
      final api = _service as ApiNewsService;
      api.updatePreferencesAsync(followedTopics: _userInterests.toList());
      api.fetchForYouAsync(topics: _userInterests, city: _selectedCity).then((_) => notifyListeners());
    }
  }

  // ==========================================
  // USER COLLECTIONS (END-TO-END REACTIVE STATE)
  // ==========================================
  final Set<String> _bookmarkedIds = {'seed-top-1', 'seed-tech-1', 'seed-business-1', 'art-hero-1', 'art-tech-1', 'art-bus-1'};
  Set<String> get bookmarkedIds => Set.unmodifiable(_bookmarkedIds);

  final Set<String> _readLaterIds = {'seed-science-1', 'art-sci-1', 'art-food-1'};
  Set<String> get readLaterIds => Set.unmodifiable(_readLaterIds);

  final Set<String> _likedIds = {'seed-tech-1', 'seed-top-1', 'art-tech-1', 'art-hero-1'};
  Set<String> get likedIds => Set.unmodifiable(_likedIds);

  final List<String> _readingHistoryIds = ['seed-top-1', 'seed-tech-1', 'art-hero-1', 'art-tech-1'];
  List<String> get readingHistoryIds => List.unmodifiable(_readingHistoryIds);

  final Set<String> _marketWatchlist = {'BTC/USD', 'NVDA', 'AAPL'};
  Set<String> get marketWatchlist => Set.unmodifiable(_marketWatchlist);

  bool isBookmarked(String id) => _bookmarkedIds.contains(id);
  bool isReadLater(String id) => _readLaterIds.contains(id);
  bool isLiked(String id) => _likedIds.contains(id);
  bool isWatched(String symbol) => _marketWatchlist.contains(symbol);

  void toggleBookmark(String id) {
    final wasBookmarked = _bookmarkedIds.contains(id);
    if (wasBookmarked) {
      _bookmarkedIds.remove(id);
    } else {
      _bookmarkedIds.add(id);
    }
    notifyListeners();
    if (_service is ApiNewsService) {
      final api = _service as ApiNewsService;
      if (wasBookmarked) {
        api.removeBookmarkAsync(id);
      } else {
        api.saveBookmarkAsync(id);
      }
    }
  }

  void toggleReadLater(String id) {
    final wasInQueue = _readLaterIds.contains(id);
    if (wasInQueue) {
      _readLaterIds.remove(id);
    } else {
      _readLaterIds.add(id);
    }
    notifyListeners();
    if (_service is ApiNewsService) {
      final api = _service as ApiNewsService;
      if (wasInQueue) {
        api.removeReadLaterAsync(id);
      } else {
        api.saveReadLaterAsync(id);
      }
    }
  }

  void toggleLike(String id) {
    final isNowLiked = !_likedIds.contains(id);
    if (isNowLiked) {
      _likedIds.add(id);
    } else {
      _likedIds.remove(id);
    }
    notifyListeners();
    if (_service is ApiNewsService && isNowLiked) {
      (_service as ApiNewsService).recordInteractionAsync(id, 'like');
    }
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
    _comments = _service.getComments(article.id);
    notifyListeners();

    if (_service is ApiNewsService) {
      final api = _service as ApiNewsService;
      api.recordInteractionAsync(article.id, 'click', dwellTimeSeconds: 30).then((updatedUser) {
        if (updatedUser != null && _currentUser != null) {
          _currentUser = updatedUser;
          notifyListeners();
        }
      });
      api.fetchArticleByIdAsync(article.id).then((fresh) {
        if (fresh != null && _activeReadingArticle?.id == article.id) {
          _activeReadingArticle = fresh;
          notifyListeners();
        }
      });
      api.fetchCommentsAsync(article.id).then((fetchedComments) {
        if (_activeReadingArticle?.id == article.id) {
          _comments = fetchedComments;
          notifyListeners();
        }
      });
    }
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
      articleId: articleId,
      author: authorName,
      avatarUrl: avatar,
      text: text.trim(),
      timeAgo: 'Just now',
    );
    _comments.insert(0, localComment);
    notifyListeners();

    if (_service is ApiNewsService) {
      (_service as ApiNewsService)
          .postCommentAsync(
            articleId,
            author: authorName,
            avatarUrl: avatar,
            text: text.trim(),
          )
          .then((saved) {
        if (saved != null) {
          final idx = _comments.indexWhere((c) => c.id == localComment.id);
          if (idx != -1) {
            _comments[idx] = saved;
            notifyListeners();
          }
        }
      });
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
    if (_service is ApiNewsService) {
      (_service as ApiNewsService).fetchClustersAsync().then((_) => notifyListeners());
    }
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
    if (_service is ApiNewsService) {
      final api = _service as ApiNewsService;
      api.updatePreferencesAsync(locationCountry: edition);
      api.fetchForYouAsync(topics: _userInterests, city: _selectedCity, country: edition).then((_) => notifyListeners());
    }
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
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        preferences: _currentUser!.preferences.copyWith(darkMode: _isDarkMode),
      );
    }
    notifyListeners();
    if (_service is ApiNewsService) {
      (_service as ApiNewsService).updatePreferencesAsync(darkMode: _isDarkMode);
    }
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

  List<NewsCategory> get categories => _service.getCategories();
  List<Article> get sampleArticles => _service.getArticles();
  List<Article> get filteredArticles => headlinesArticles;
  List<Article> get breakingArticles => _service.getBreakingArticles();
  List<Article> get trendingArticles => _service.getTrendingArticles();

  List<Article> get headlinesArticles {
    return _service.getArticles(category: _selectedCategory);
  }

  List<Article> get personalizedArticles {
    return _service.getForYouArticles(interests: _userInterests);
  }

  List<Article> get localArticles {
    return _service.getLocalArticles(city: _selectedCity);
  }

  List<Article> get marketArticles {
    final all = _service.getArticles();
    return all.where((a) => a.category == 'business' || a.category == 'tech').toList();
  }

  List<Article> get libraryArticles {
    final ids = _libraryTab == 'bookmarks'
        ? _bookmarkedIds
        : _libraryTab == 'read_later'
            ? _readLaterIds
            : _readingHistoryIds;
    final all = _service.getArticles();
    final map = <String, Article>{for (final a in all) a.id: a};
    if (_service is ApiNewsService) {
      final api = _service as ApiNewsService;
      for (final id in ids) {
        final cached = api.getCachedArticleById(id);
        if (cached != null) map[id] = cached;
      }
    }
    return ids.map((id) => map[id]).whereType<Article>().toList();
  }

  int get totalQueueReadingMinutes {
    return libraryArticles.fold<int>(0, (sum, a) => sum + a.readTimeMinutes);
  }

  List<Article> get exploreArticles {
    return _service.getArticles(
      query: _searchQuery,
      source: _selectedSourceFilter,
      sortBy: _sortBy,
    );
  }
}
