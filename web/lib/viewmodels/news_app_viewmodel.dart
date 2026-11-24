import 'package:flartdart/flartdart.dart';
import 'package:news_models/news_models.dart';
import '../data/mock_data.dart';
import '../data/services/news_service.dart';

/// Central ViewModel managing all ReadMore state, business logic,
/// collection updates, and reactive notifications following MVVM.
class NewsAppViewModel extends ChangeNotifier {
  final NewsService _service;

  NewsAppViewModel({NewsService? service})
      : _service = service ?? MockNewsService() {
    _comments = _service.getComments('default');
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
  }
  void setSelectedCategory(String category) => setCategory(category);

  void setCity(String city) {
    _selectedCity = city;
    notifyListeners();
  }
  void setSelectedCity(String city) => setCity(city);

  void setMarketSector(String sector) {
    _selectedMarketSector = sector;
    notifyListeners();
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
  }

  void setSortBy(String sort) {
    _sortBy = sort;
    notifyListeners();
  }

  void setSourceFilter(String source) {
    _selectedSourceFilter = source;
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
    _comments.insert(
      0,
      ArticleComment(
        id: 'c-${DateTime.now().millisecondsSinceEpoch}',
        author: 'You (Verified Reader)',
        avatarUrl:
            'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=128&q=80',
        text: text.trim(),
        timeAgo: 'Just now',
      ),
    );
    notifyListeners();
  }

  void toggleCommentLike(String commentId) {
    final idx = _comments.indexWhere((c) => c.id == commentId);
    if (idx != -1) {
      final c = _comments[idx];
      c.isLiked = !c.isLiked;
      c.likes += c.isLiked ? 1 : -1;
      notifyListeners();
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
  List<MarketTickerItem> get marketTickers => _service.getMarketTickers();
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
