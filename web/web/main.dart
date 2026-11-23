import 'package:flartdart/flartdart.dart';
import 'package:news_models/news_models.dart';
import 'mock_data.dart';

void main() {
  ScreenUtil.init(width: 1440, height: 900);
  runApp(const ReadMoreWebApp());
}

class ReadMoreWebApp extends StatefulWidget {
  const ReadMoreWebApp({super.key});

  @override
  State<ReadMoreWebApp> createState() => _ReadMoreWebAppState();
}

class _ReadMoreWebAppState extends State<ReadMoreWebApp> {
  // Navigation & Primary Screen Flow:
  // 'headlines', 'for_you', 'local', 'markets', 'library', 'explore'
  String _activeScreen = 'headlines';

  // Category filter for headlines
  String _selectedCategory = 'top';

  // Local News city selection
  String _selectedCity = 'New York';

  // Market sector selection
  String _selectedMarketSector = 'All';

  // Library sub-tab: 'bookmarks', 'read_later', 'history'
  String _libraryTab = 'bookmarks';

  // Explore / Search filters
  String _searchQuery = '';
  String _selectedSourceFilter = 'all';
  String _sortBy = 'latest';

  // For You Personalization Settings
  double _serendipityLevel = 0.3;
  final Set<String> _userInterests = {
    'Artificial Intelligence',
    'Clean Energy',
    'Wall Street',
    'Space Exploration',
    'Cryptocurrency',
  };

  // User State & Collections (End-to-End local state)
  final Set<String> _bookmarkedIds = {'art-hero-1', 'art-tech-1', 'art-bus-1'};
  final Set<String> _readLaterIds = {'art-sci-1', 'art-food-1'};
  final Set<String> _likedIds = {'art-tech-1', 'art-hero-1'};
  final List<String> _readingHistoryIds = ['art-hero-1', 'art-tech-1'];
  final Set<String> _marketWatchlist = {'BTC/USD', 'NVDA', 'AAPL'};

  // Reader View State
  Article? _activeReadingArticle;
  double _readerFontSize = 16.0;
  bool _isAudioPlaying = false;
  double _audioProgress = 0.35;
  double _audioSpeed = 1.0;

  // Dynamic comments state
  late List<ArticleComment> _comments;
  String _newCommentDraft = '';

  // Modals & Popovers
  bool _showFullCoverageModal = false;
  bool _showInterestsModal = false;
  bool _showNotificationsModal = false;
  bool _showEditionModal = false;
  String _selectedEdition = 'United States';
  bool _hasUnreadNotifications = true;

  // Persistent Bottom Audio Briefing Player
  bool _showBottomBriefing = true;
  bool _isBriefingPlaying = false;

  // Theme
  bool _isDarkMode = true;

  @override
  void initState() {
    super.initState();
    _comments = List.from(WebMockData.initialComments);
  }

  void _openArticleReader(Article article) {
    setState(() {
      _activeReadingArticle = article;
      _isAudioPlaying = false;
      _audioProgress = 0.0;
      if (!_readingHistoryIds.contains(article.id)) {
        _readingHistoryIds.insert(0, article.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final isMobile = media.isSmall;
    final isTablet = media.isMedium;

    return FDMaterialApp(
      title: 'ReadMore — Global News & Intelligence',
      debugShowCheckedModeBanner: false,
      home: FDScaffold(
        cssStyle: {
          'background': _isDarkMode ? '#090D16' : '#F8FAFC',
          'color': _isDarkMode ? '#F8FAFC' : '#0F172A',
        },
        body: FDStack(
          children: [
            FDSingleChildScrollView(
              child: FDColumn(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. MSN-Style Utility Ribbon
                  _buildUtilityRibbon(isMobile, isTablet),

                  // 2. Main Brand Header & Navigation
                  _buildMainHeader(isMobile, isTablet),

                  // 3. Primary Screen Flow Navigation Tabs
                  _buildPrimaryNavRibbon(isMobile),

                  // 4. Breaking News Live Ribbon (Shown on Headlines & For You)
                  if (_activeScreen == 'headlines' || _activeScreen == 'for_you')
                    _buildBreakingNewsTicker(isMobile),

                  // 5. Active Screen Content Body (Centered Max-Width Container)
                  FDCenter(
                    child: FDConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1400),
                      child: FDContainer(
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 12 : (isTablet ? 20 : 28),
                          vertical: 24,
                        ),
                        child: _buildCurrentScreenContent(isMobile, isTablet),
                      ),
                    ),
                  ),

                  // 6. Footer (Completely unbranded of internal technologies)
                  _buildFooter(isMobile),

                  // Space for bottom sticky player
                  if (_showBottomBriefing) const FDSizedBox(height: 72),
                ],
              ),
            ),

            // Persistent Sticky Bottom Audio Player
            if (_showBottomBriefing)
              _buildStickyBottomAudioPlayer(isMobile),

            // Modal: Reader View Overlay
            if (_activeReadingArticle != null)
              _buildReaderViewModal(_activeReadingArticle!, isMobile),

            // Modal: Full Coverage Overlay
            if (_showFullCoverageModal)
              _buildFullCoverageModal(isMobile),

            // Modal: Topic & Interest Manager
            if (_showInterestsModal)
              _buildInterestsManagerModal(isMobile),

            // Modal: Notifications Popover
            if (_showNotificationsModal)
              _buildNotificationsPopover(isMobile),

            // Modal: Edition / Region Selector
            if (_showEditionModal)
              _buildEditionSelectorModal(isMobile),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // 1. UTILITY RIBBON
  // ==========================================
  Widget _buildUtilityRibbon(bool isMobile, bool isTablet) {
    final weather = WebMockData.cityWeatherMap[_selectedCity] ?? WebMockData.currentWeather;

    return FDContainer(
      decoration: BoxDecoration(
        color: _isDarkMode ? const FlartColor('#05080F') : const FlartColor('#EDE9FE'),
        border: const Border(bottom: BorderSide(color: FlartColor('rgba(255, 255, 255, 0.08)'), width: 1)),
      ),
      child: FDCenter(
        child: FDConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: FDContainer(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 28, vertical: 8),
            child: FDRow(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left: Date & Weather Clickable Pill
                FDGestureDetector(
                  onTap: () {
                    setState(() {
                      _activeScreen = 'local';
                    });
                  },
                  child: FDRow(
                    children: [
                      FDRawHTML('''
                        <div style="display: flex; align-items: center; gap: 8px; font-size: 12px; color: ${_isDarkMode ? '#94A3B8' : '#475569'};">
                          <span>📅 <b>Monday, Nov 23, 2026</b></span>
                          <span style="opacity: 0.4;">|</span>
                          <span style="display: inline-flex; align-items: center; gap: 4px; background: rgba(59, 130, 246, 0.12); padding: 2px 8px; border-radius: 12px; color: #60A5FA; font-weight: 600; cursor: pointer; white-space: nowrap;">
                            📍 ${_selectedCity} ${weather.temperatureC.toInt()}°C (${weather.condition})
                          </span>
                        </div>
                      '''),
                    ],
                  ),
                ),

                // Right: Real-time Mini Stock Ticker (Desktop only) & Edition Badge
                if (!isMobile)
                  FDRow(
                    children: [
                      if (!isTablet)
                        FDGestureDetector(
                          onTap: () {
                            setState(() {
                              _activeScreen = 'markets';
                            });
                          },
                          child: FDRawHTML('''
                            <div style="display: flex; align-items: center; gap: 14px; font-size: 11px; font-family: monospace; cursor: pointer; margin-right: 14px;">
                              <span style="color: #10B981; font-weight: bold;">▲ S&P 5,984 (+0.72%)</span>
                              <span style="color: #10B981; font-weight: bold;">▲ BTC \$98,650 (+3.65%)</span>
                              <span style="color: #10B981; font-weight: bold;">▲ NVDA \$148.90 (+2.45%)</span>
                              <span style="color: #EF4444; font-weight: bold;">▼ BRENT \$74.20 (-1.15%)</span>
                            </div>
                          '''),
                        ),
                      FDGestureDetector(
                        onTap: () {
                          setState(() {
                            _showEditionModal = true;
                          });
                        },
                        child: FDContainer(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const FlartColor('rgba(59, 130, 246, 0.15)'),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const FlartColor('rgba(59, 130, 246, 0.3)'), width: 1),
                          ),
                          child: FDRow(
                            children: [
                              const FDText('🌐 ', style: TextStyle(fontSize: 10)),
                              FDText(
                                _selectedEdition,
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: FlartColor('#60A5FA')),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 2. MAIN BRAND HEADER
  // ==========================================
  Widget _buildMainHeader(bool isMobile, bool isTablet) {
    return FDContainer(
      decoration: BoxDecoration(
        color: _isDarkMode ? const FlartColor('#111827') : const FlartColor('#FFFFFF'),
        border: const Border(bottom: BorderSide(color: FlartColor('rgba(255, 255, 255, 0.1)'), width: 1)),
      ),
      child: FDCenter(
        child: FDConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: FDContainer(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 28, vertical: 12),
            child: FDRow(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Brand Logo & Tagline
                FDGestureDetector(
                  onTap: () {
                    setState(() {
                      _activeScreen = 'headlines';
                      _selectedCategory = 'top';
                      _searchQuery = '';
                    });
                  },
                  child: FDRow(
                    children: [
                      FDRawHTML('''
                        <div style="display: flex; align-items: center; gap: 10px; cursor: pointer; white-space: nowrap;">
                          <div style="width: 38px; height: 38px; min-width: 38px; background: linear-gradient(135deg, #3B82F6, #8B5CF6); border-radius: 10px; display: flex; align-items: center; justify-content: center; font-size: 20px; font-weight: 900; color: #FFF; box-shadow: 0 4px 14px rgba(59, 130, 246, 0.4);">
                            R
                          </div>
                          <div>
                            <div style="font-size: 22px; font-weight: 800; letter-spacing: -0.04em; color: ${_isDarkMode ? '#F8FAFC' : '#0F172A'}; line-height: 1.1;">
                              Read<span style="color: #3B82F6;">More</span>
                            </div>
                            <div style="font-size: 10px; font-weight: 600; text-transform: uppercase; letter-spacing: 0.12em; color: #64748B;">
                              Global News & Intelligence
                            </div>
                          </div>
                        </div>
                      '''),
                    ],
                  ),
                ),

                // Fluid Responsive Search Bar (Desktop / Tablet)
                if (!isMobile)
                  Expanded(
                    child: FDContainer(
                      margin: EdgeInsets.symmetric(horizontal: isTablet ? 12 : 24),
                      child: FDCenter(
                        child: FDConstrainedBox(
                          constraints: BoxConstraints(maxWidth: isTablet ? 280 : 380),
                          child: FDTextField(
                            placeholder: isTablet ? 'Search stories...' : 'Search breaking stories, topics, sources...',
                            backgroundColor: _isDarkMode ? const FlartColor('#1E293B') : const FlartColor('#F1F5F9'),
                            borderColor: const FlartColor('rgba(255, 255, 255, 0.1)'),
                            borderRadius: 24,
                            prefixIcon: const FDIcon(icon: FDIcons.search, size: 16, color: FlartColors.grey),
                            onChanged: (val) {
                              setState(() {
                                _searchQuery = val;
                                if (val.trim().isNotEmpty && _activeScreen != 'explore') {
                                  _activeScreen = 'explore';
                                }
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ),

                // Header Quick Controls
                FDRow(
                  children: [
                    // Notification Bell with Unread Badge
                    FDGestureDetector(
                      onTap: () {
                        setState(() {
                          _showNotificationsModal = !_showNotificationsModal;
                          _hasUnreadNotifications = false;
                        });
                      },
                      child: FDContainer(
                        decoration: BoxDecoration(
                          color: const FlartColor('rgba(255, 255, 255, 0.08)'),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: FDStack(
                          children: [
                            FDIcon(
                              icon: FDIcons.notifications,
                              size: 18,
                              color: _hasUnreadNotifications ? FlartColors.amber : FlartColors.grey,
                            ),
                            if (_hasUnreadNotifications)
                              FDRawHTML('''
                                <div style="position: absolute; top: -2px; right: -2px; width: 8px; height: 8px; background: #EF4444; border-radius: 50%; border: 1.5px solid #111827;"></div>
                              '''),
                          ],
                        ),
                      ),
                    ),
                    const FDSizedBox(width: 8),

                    // Interests Tuning Button
                    FDGestureDetector(
                      onTap: () {
                        setState(() {
                          _showInterestsModal = true;
                        });
                      },
                      child: FDContainer(
                        decoration: BoxDecoration(
                          color: const FlartColor('rgba(255, 255, 255, 0.08)'),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const FlartColor('rgba(255, 255, 255, 0.1)'), width: 1),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        child: FDRow(
                          children: const [
                            FDText('⚡', style: TextStyle(fontSize: 12)),
                            FDSizedBox(width: 4),
                            FDText('Interests', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                    const FDSizedBox(width: 8),

                    // Theme Switcher
                    FDGestureDetector(
                      onTap: () {
                        setState(() {
                          _isDarkMode = !_isDarkMode;
                        });
                      },
                      child: FDContainer(
                        decoration: BoxDecoration(
                          color: const FlartColor('rgba(255, 255, 255, 0.08)'),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: FDIcon(
                          icon: _isDarkMode ? 'wb_sunny' : 'nightlight',
                          size: 16,
                          color: FlartColors.amber,
                        ),
                      ),
                    ),
                    const FDSizedBox(width: 8),

                    // Reading Streak / User Avatar
                    FDRawHTML('''
                      <div style="display: flex; align-items: center; gap: 6px; background: rgba(245, 158, 11, 0.15); border: 1px solid rgba(245, 158, 11, 0.3); padding: 4px 10px; border-radius: 18px; font-size: 12px; font-weight: 800; color: #F59E0B;" title="5-day reading streak!">
                        🔥 5d
                      </div>
                    '''),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 3. PRIMARY NAVIGATION RIBBON
  // ==========================================
  Widget _buildPrimaryNavRibbon(bool isMobile) {
    final navItems = [
      {'id': 'headlines', 'name': 'Headlines', 'icon': '📰'},
      {'id': 'for_you', 'name': 'For You', 'icon': '✨'},
      {'id': 'local', 'name': 'Local News', 'icon': '📍'},
      {'id': 'markets', 'name': 'Markets', 'icon': '📈'},
      {'id': 'library', 'name': 'My Library', 'icon': '🔖', 'badge': '${_bookmarkedIds.length + _readLaterIds.length}'},
      {'id': 'explore', 'name': 'Explore', 'icon': '🔍'},
    ];

    return FDContainer(
      decoration: BoxDecoration(
        color: _isDarkMode ? const FlartColor('#0D1424') : const FlartColor('#F1F5F9'),
        border: const Border(bottom: BorderSide(color: FlartColor('rgba(255, 255, 255, 0.08)'), width: 1)),
      ),
      child: FDCenter(
        child: FDConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: FDContainer(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 28, vertical: 8),
            child: FDSingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: FDRow(
                children: navItems.map((item) {
                  final isSelected = _activeScreen == item['id'];
                  final badge = item['badge'];

                  return FDGestureDetector(
                    onTap: () {
                      setState(() {
                        _activeScreen = item['id']!;
                        if (_activeScreen == 'headlines') {
                          _selectedCategory = 'top';
                        }
                      });
                    },
                    child: FDContainer(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const FlartColor('#3B82F6')
                            : (_isDarkMode ? const FlartColor('rgba(255, 255, 255, 0.06)') : const FlartColor('#FFFFFF')),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? const FlartColor('#3B82F6') : const FlartColor('rgba(255, 255, 255, 0.1)'),
                          width: 1,
                        ),
                      ),
                      child: FDRow(
                        children: [
                          FDText(item['icon']!, style: const TextStyle(fontSize: 14)),
                          const FDSizedBox(width: 6),
                          FDText(
                            item['name']!,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                              color: isSelected ? FlartColors.white : (_isDarkMode ? FlartColors.white : FlartColors.black),
                            ),
                          ),
                          if (badge != null && badge != '0') ...[
                            const FDSizedBox(width: 6),
                            FDContainer(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: isSelected ? const FlartColor('#1D4ED8') : const FlartColor('rgba(59, 130, 246, 0.2)'),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: FDText(
                                badge,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? FlartColors.white : const FlartColor('#60A5FA'),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 4. BREAKING NEWS LIVE RIBBON
  // ==========================================
  Widget _buildBreakingNewsTicker(bool isMobile) {
    final breakingArticle = WebMockData.sampleArticles.first;

    return FDContainer(
      decoration: const BoxDecoration(
        color: FlartColor('#1E1B4B'),
        border: Border(bottom: BorderSide(color: FlartColor('rgba(239, 68, 68, 0.3)'), width: 1)),
      ),
      child: FDCenter(
        child: FDConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: FDContainer(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 28, vertical: 8),
            child: FDRow(
              children: [
                FDRawHTML('''
                  <div style="display: flex; align-items: center; gap: 8px;">
                    <span class="live-dot"></span>
                    <span style="background: #EF4444; color: #FFF; font-size: 11px; font-weight: 800; padding: 2px 6px; border-radius: 4px; text-transform: uppercase;">
                      BREAKING
                    </span>
                  </div>
                '''),
                const FDSizedBox(width: 12),
                Expanded(
                  child: FDGestureDetector(
                    onTap: () => _openArticleReader(breakingArticle),
                    child: FDText(
                      breakingArticle.title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: FlartColor('#E0E7FF'),
                      ),
                    ),
                  ),
                ),
                if (!isMobile)
                  FDGestureDetector(
                    onTap: () {
                      setState(() {
                        _showFullCoverageModal = true;
                      });
                    },
                    child: FDRow(
                      children: const [
                        FDText(
                          'Full Coverage',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: FlartColor('#818CF8')),
                        ),
                        FDSizedBox(width: 4),
                        FDIcon(icon: FDIcons.arrow_forward, size: 14, color: FlartColor('#818CF8')),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 5. SCREEN DISPATCHER
  // ==========================================
  Widget _buildCurrentScreenContent(bool isMobile, bool isTablet) {
    switch (_activeScreen) {
      case 'for_you':
        return _buildForYouScreen(isMobile, isTablet);
      case 'local':
        return _buildLocalNewsScreen(isMobile, isTablet);
      case 'markets':
        return _buildMarketsScreen(isMobile, isTablet);
      case 'library':
        return _buildLibraryScreen(isMobile, isTablet);
      case 'explore':
        return _buildExploreScreen(isMobile, isTablet);
      case 'headlines':
      default:
        return _buildHeadlinesScreen(isMobile, isTablet);
    }
  }

  // ==========================================
  // SCREEN 1: HEADLINES (PRIMARY FEED)
  // ==========================================
  Widget _buildHeadlinesScreen(bool isMobile, bool isTablet) {
    var articles = WebMockData.sampleArticles;
    if (_selectedCategory != 'top' && _selectedCategory != 'all') {
      articles = articles
          .where((a) => a.category.toLowerCase() == _selectedCategory.toLowerCase())
          .toList();
    }

    final heroArticle = articles.isNotEmpty ? articles.first : WebMockData.sampleArticles.first;
    final remainingArticles = articles.length > 1 ? articles.sublist(1) : <Article>[];

    return FDColumn(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 12-Category Pill Filter Ribbon
        _buildCategoryPillNavbar(isMobile),
        const FDSizedBox(height: 20),

        if (!isMobile && !isTablet)
          FDRow(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main Editorial Column (68%)
              Expanded(
                flex: 68,
                child: FDColumn(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSectionHeader('Top Global Headlines'),
                    const FDSizedBox(height: 16),
                    _buildHeroSpotlightCard(heroArticle),
                    const FDSizedBox(height: 28),
                    _buildGoogleNewsFullCoverageBlock(),
                    const FDSizedBox(height: 28),
                    _buildArticlesGrid(remainingArticles, columns: 2),
                  ],
                ),
              ),
              const FDSizedBox(width: 32),

              // MSN Sidebar Column (32%)
              Expanded(
                flex: 32,
                child: FDColumn(
                  children: [
                    _buildWeatherWidget(),
                    const FDSizedBox(height: 20),
                    _buildMarketWatchWidget(),
                    const FDSizedBox(height: 20),
                    _buildTrendingTopicsWidget(),
                    const FDSizedBox(height: 20),
                    _buildTopReadLeaderboard(),
                    const FDSizedBox(height: 20),
                    _buildMorningBriefingPromoCard(),
                    const FDSizedBox(height: 20),
                    _buildNewsletterCard(),
                  ],
                ),
              ),
            ],
          )
        else
          FDColumn(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionHeader('Top Global Headlines'),
              const FDSizedBox(height: 16),
              _buildHeroSpotlightCard(heroArticle),
              const FDSizedBox(height: 20),
              _buildGoogleNewsFullCoverageBlock(),
              const FDSizedBox(height: 20),
              _buildArticlesGrid(remainingArticles, columns: isTablet ? 2 : 1),
              const FDSizedBox(height: 32),
              _buildWeatherWidget(),
              const FDSizedBox(height: 20),
              _buildMarketWatchWidget(),
              const FDSizedBox(height: 20),
              _buildTrendingTopicsWidget(),
            ],
          ),
      ],
    );
  }

  Widget _buildCategoryPillNavbar(bool isMobile) {
    return FDSingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: FDRow(
        children: NewsCategory.allCategories.map((category) {
          final isSelected = _selectedCategory == category.slug;
          return FDGestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = category.slug;
              });
            },
            child: FDContainer(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? const FlartColor('#3B82F6')
                    : (_isDarkMode ? const FlartColor('rgba(255, 255, 255, 0.06)') : const FlartColor('#FFFFFF')),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? const FlartColor('#3B82F6') : const FlartColor('rgba(255, 255, 255, 0.08)'),
                  width: 1,
                ),
              ),
              child: FDRow(
                children: [
                  FDText(_getCategoryEmoji(category.slug), style: const TextStyle(fontSize: 13)),
                  const FDSizedBox(width: 6),
                  FDText(
                    category.name,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? FlartColors.white : (_isDarkMode ? FlartColors.white : FlartColors.black),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ==========================================
  // SCREEN 2: FOR YOU (PERSONALIZED FEED)
  // ==========================================
  Widget _buildForYouScreen(bool isMobile, bool isTablet) {
    // Filter personalized recommendations based on active user interests
    final personalizedArticles = WebMockData.sampleArticles.where((a) {
      return a.tags.any((t) => _userInterests.any((ui) => ui.toLowerCase().contains(t.toLowerCase()))) ||
          _userInterests.any((ui) => a.category.toLowerCase().contains(ui.toLowerCase()));
    }).toList();

    return FDColumn(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Personalized Header Banner
        FDContainer(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [FlartColor('#1E1B4B'), FlartColor('#1E293B')],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const FlartColor('rgba(99, 102, 241, 0.3)'), width: 1.5),
          ),
          child: FDColumn(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FDRow(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FDRow(
                    children: const [
                      FDText('✨', style: TextStyle(fontSize: 20)),
                      FDSizedBox(width: 8),
                      FDText(
                        'Your Personalized Intelligence Feed',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: FlartColors.white),
                      ),
                    ],
                  ),
                  FDGestureDetector(
                    onTap: () {
                      setState(() {
                        _showInterestsModal = true;
                      });
                    },
                    child: FDContainer(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const FlartColor('#3B82F6'),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const FDText(
                        'Customize Topics +',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: FlartColors.white),
                      ),
                    ),
                  ),
                ],
              ),
              const FDSizedBox(height: 8),
              const FDText(
                'Synthesized from your active interests, reading velocity, and fresh global reporting.',
                style: TextStyle(fontSize: 13, color: FlartColor('#CBD5E1')),
              ),
              const FDSizedBox(height: 16),

              // Active Topics Pills
              FDWrap(
                spacing: 8,
                runSpacing: 8,
                children: _userInterests.map((interest) {
                  return FDContainer(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const FlartColor('rgba(255, 255, 255, 0.1)'),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: FDText(
                      '#$interest',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: FlartColor('#93C5FD')),
                    ),
                  );
                }).toList(),
              ),
              const FDSizedBox(height: 14),

              // Serendipity Level Indicator
              FDRow(
                children: [
                  FDText(
                    'Serendipity Discovery: ${(_serendipityLevel * 100).toInt()}% • Algorithmic Diversity Enabled',
                    style: const TextStyle(fontSize: 11, color: FlartColor('#94A3B8')),
                  ),
                ],
              ),
            ],
          ),
        ),
        const FDSizedBox(height: 24),

        // Personalized Feed Grid
        _buildArticlesGrid(
          personalizedArticles.isNotEmpty ? personalizedArticles : WebMockData.sampleArticles,
          columns: isMobile ? 1 : (isTablet ? 2 : 3),
        ),
      ],
    );
  }

  // ==========================================
  // SCREEN 3: LOCAL NEWS EXPLORER
  // ==========================================
  Widget _buildLocalNewsScreen(bool isMobile, bool isTablet) {
    final cities = ['New York', 'London', 'Tokyo', 'Lagos', 'Paris', 'San Francisco'];
    final weather = WebMockData.cityWeatherMap[_selectedCity] ?? WebMockData.currentWeather;

    // Filter local articles matching the city
    final localArticles = WebMockData.sampleArticles.where((a) {
      return a.category == 'local' && (a.tags.any((t) => t.toLowerCase() == _selectedCity.toLowerCase()) ||
          a.title.toLowerCase().contains(_selectedCity.toLowerCase()) ||
          a.summary.toLowerCase().contains(_selectedCity.toLowerCase()));
    }).toList();

    return FDColumn(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // City Selector Navigation Tabs
        FDSingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: FDRow(
            children: cities.map((city) {
              final isSelected = _selectedCity == city;
              return FDGestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCity = city;
                  });
                },
                child: FDContainer(
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const FlartColor('#3B82F6')
                        : (_isDarkMode ? const FlartColor('rgba(255, 255, 255, 0.08)') : const FlartColor('#FFFFFF')),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? const FlartColor('#3B82F6') : const FlartColor('rgba(255, 255, 255, 0.1)'),
                      width: 1,
                    ),
                  ),
                  child: FDRow(
                    children: [
                      FDText(_getCityEmoji(city), style: const TextStyle(fontSize: 16)),
                      const FDSizedBox(width: 6),
                      FDText(
                        city,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected ? FlartColors.white : (_isDarkMode ? FlartColors.white : FlartColors.black),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const FDSizedBox(height: 24),

        // Local Weather Hero Spotlight Card
        FDContainer(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [FlartColor('#0284C7'), FlartColor('#0369A1')],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(color: FlartColor('rgba(2, 132, 199, 0.3)'), blurRadius: 20, offset: Offset(0, 8)),
            ],
          ),
          child: FDRow(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FDColumn(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FDRow(
                    children: [
                      const FDText('📍 ', style: TextStyle(fontSize: 18)),
                      FDText(
                        '$_selectedCity, ${weather.country}',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: FlartColors.white),
                      ),
                    ],
                  ),
                  const FDSizedBox(height: 6),
                  FDText(
                    weather.condition,
                    style: const TextStyle(fontSize: 16, color: FlartColor('#E0F2FE'), fontWeight: FontWeight.w600),
                  ),
                  const FDSizedBox(height: 12),
                  FDRawHTML('''
                    <div style="display: flex; gap: 16px; font-size: 13px; color: #BAE6FD;">
                      <span>💧 Humidity: <b>${weather.humidity}%</b></span>
                      <span>💨 Wind: <b>${weather.windSpeedKmh} km/h</b></span>
                      <span>🌿 Air Quality: <b>Good (AQI 32)</b></span>
                    </div>
                  '''),
                ],
              ),
              FDText(
                '${weather.temperatureC.toInt()}°C',
                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: FlartColors.white),
              ),
            ],
          ),
        ),
        const FDSizedBox(height: 28),

        // City Local Articles Grid
        _buildSectionHeader('Top News from $_selectedCity'),
        const FDSizedBox(height: 16),
        _buildArticlesGrid(
          localArticles.isNotEmpty ? localArticles : WebMockData.sampleArticles.where((a) => a.category == 'local').toList(),
          columns: isMobile ? 1 : 2,
        ),
      ],
    );
  }

  String _getCityEmoji(String city) {
    switch (city) {
      case 'New York':
        return '🗽';
      case 'London':
        return '🎡';
      case 'Tokyo':
        return '🗼';
      case 'Lagos':
        return '🌴';
      case 'Paris':
        return '🥐';
      case 'San Francisco':
        return '🌁';
      default:
        return '📍';
    }
  }

  // ==========================================
  // SCREEN 4: MARKETS & FINANCIAL HUB (MSN STYLE)
  // ==========================================
  Widget _buildMarketsScreen(bool isMobile, bool isTablet) {
    final sectorTabs = ['All', 'Indices', 'Crypto', 'Tech Equities', 'Commodities'];
    final items = WebMockData.marketTicker;

    return FDColumn(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Sector Switcher Ribbon
        FDSingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: FDRow(
            children: sectorTabs.map((sector) {
              final isSelected = _selectedMarketSector == sector;
              return FDGestureDetector(
                onTap: () {
                  setState(() {
                    _selectedMarketSector = sector;
                  });
                },
                child: FDContainer(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const FlartColor('#10B981')
                        : (_isDarkMode ? const FlartColor('rgba(255, 255, 255, 0.08)') : const FlartColor('#FFFFFF')),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected ? const FlartColor('#10B981') : const FlartColor('rgba(255, 255, 255, 0.1)'),
                      width: 1,
                    ),
                  ),
                  child: FDText(
                    sector,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected ? FlartColors.white : (_isDarkMode ? FlartColors.white : FlartColors.black),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const FDSizedBox(height: 24),

        // Live Market Movers Cards Grid
        FDWrap(
          spacing: 16,
          runSpacing: 16,
          children: items.map((m) {
            final isWatched = _marketWatchlist.contains(m.symbol);

            return FDContainer(
              width: isMobile ? 320 : (isTablet ? 280 : 320),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: _isDarkMode ? const FlartColor('#131D2E') : const FlartColor('#FFFFFF'),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const FlartColor('rgba(255, 255, 255, 0.1)'), width: 1),
              ),
              child: FDColumn(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FDRow(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FDColumn(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FDText(m.symbol, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                          FDText(m.name, style: const TextStyle(fontSize: 11, color: FlartColors.grey)),
                        ],
                      ),
                      FDGestureDetector(
                        onTap: () {
                          setState(() {
                            if (isWatched) {
                              _marketWatchlist.remove(m.symbol);
                            } else {
                              _marketWatchlist.add(m.symbol);
                            }
                          });
                        },
                        child: FDIcon(
                          icon: FDIcons.star,
                          size: 18,
                          color: isWatched ? FlartColors.amber : FlartColors.grey,
                        ),
                      ),
                    ],
                  ),
                  const FDSizedBox(height: 14),

                  FDRow(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FDText(
                        '\$${m.price.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                      ),
                      FDContainer(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: m.isPositive
                              ? const FlartColor('rgba(16, 185, 129, 0.15)')
                              : const FlartColor('rgba(239, 68, 68, 0.15)'),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: FDText(
                          '${m.isPositive ? '+' : ''}${m.changePercent}%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: m.isPositive ? const FlartColor('#10B981') : const FlartColor('#EF4444'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        const FDSizedBox(height: 32),

        // Financial News Feed
        _buildSectionHeader('Financial & Business Intelligence'),
        const FDSizedBox(height: 16),
        _buildArticlesGrid(
          WebMockData.sampleArticles.where((a) => a.category == 'business' || a.category == 'tech').toList(),
          columns: isMobile ? 1 : 2,
        ),
      ],
    );
  }

  // ==========================================
  // SCREEN 5: MY LIBRARY (BOOKMARKS, READ LATER, HISTORY)
  // ==========================================
  Widget _buildLibraryScreen(bool isMobile, bool isTablet) {
    final tabs = [
      {'id': 'bookmarks', 'name': 'Bookmarks', 'count': _bookmarkedIds.length, 'icon': '📌'},
      {'id': 'read_later', 'name': 'Read Later Queue', 'count': _readLaterIds.length, 'icon': '⏳'},
      {'id': 'history', 'name': 'Reading History', 'count': _readingHistoryIds.length, 'icon': '🕒'},
    ];

    List<Article> displayed;
    if (_libraryTab == 'bookmarks') {
      displayed = WebMockData.sampleArticles.where((a) => _bookmarkedIds.contains(a.id)).toList();
    } else if (_libraryTab == 'read_later') {
      displayed = WebMockData.sampleArticles.where((a) => _readLaterIds.contains(a.id)).toList();
    } else {
      displayed = WebMockData.sampleArticles.where((a) => _readingHistoryIds.contains(a.id)).toList();
    }

    // Calculate total queue reading time
    final totalReadingMinutes = displayed.fold<int>(0, (sum, a) => sum + a.readTimeMinutes);

    return FDColumn(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Sub-tabs Header
        FDRow(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FDRow(
              children: tabs.map((t) {
                final isSelected = _libraryTab == t['id'];
                return FDGestureDetector(
                  onTap: () {
                    setState(() {
                      _libraryTab = t['id'] as String;
                    });
                  },
                  child: FDContainer(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const FlartColor('#3B82F6')
                          : (_isDarkMode ? const FlartColor('rgba(255, 255, 255, 0.08)') : const FlartColor('#FFFFFF')),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isSelected ? const FlartColor('#3B82F6') : const FlartColor('rgba(255, 255, 255, 0.1)'),
                        width: 1,
                      ),
                    ),
                    child: FDRow(
                      children: [
                        FDText(t['icon'] as String, style: const TextStyle(fontSize: 14)),
                        const FDSizedBox(width: 6),
                        FDText(
                          t['name'] as String,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: isSelected ? FlartColors.white : (_isDarkMode ? FlartColors.white : FlartColors.black),
                          ),
                        ),
                        const FDSizedBox(width: 6),
                        FDContainer(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: isSelected ? const FlartColor('#1D4ED8') : const FlartColor('rgba(255, 255, 255, 0.1)'),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: FDText(
                            '${t['count']}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            if (_libraryTab == 'history' && _readingHistoryIds.isNotEmpty)
              FDGestureDetector(
                onTap: () {
                  setState(() {
                    _readingHistoryIds.clear();
                  });
                },
                child: const FDText(
                  'Clear History',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: FlartColor('#EF4444')),
                ),
              ),
          ],
        ),
        const FDSizedBox(height: 20),

        // Read Later Time Calculator Banner
        if (_libraryTab == 'read_later' && displayed.isNotEmpty)
          FDContainer(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const FlartColor('rgba(139, 92, 246, 0.15)'),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const FlartColor('rgba(139, 92, 246, 0.3)'), width: 1),
            ),
            child: FDRow(
              children: [
                const FDText('⏱️ ', style: TextStyle(fontSize: 16)),
                FDText(
                  'Estimated Total Reading Time: ~$totalReadingMinutes minutes across ${displayed.length} articles.',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: FlartColor('#C4B5FD')),
                ),
              ],
            ),
          ),
        const FDSizedBox(height: 20),

        // Items Grid or Empty State
        if (displayed.isEmpty)
          FDContainer(
            padding: const EdgeInsets.symmetric(vertical: 80),
            child: FDCenter(
              child: FDColumn(
                children: [
                  const FDText('📭', style: TextStyle(fontSize: 48)),
                  const FDSizedBox(height: 16),
                  FDText(
                    _libraryTab == 'bookmarks'
                        ? 'No bookmarks saved yet'
                        : (_libraryTab == 'read_later' ? 'Your Read Later queue is empty' : 'No reading history yet'),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const FDSizedBox(height: 8),
                  const FDText(
                    'Save articles while browsing to read them anytime, anywhere.',
                    style: TextStyle(fontSize: 13, color: FlartColors.grey),
                  ),
                  const FDSizedBox(height: 20),
                  FDGestureDetector(
                    onTap: () {
                      setState(() {
                        _activeScreen = 'headlines';
                      });
                    },
                    child: FDContainer(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: const FlartColor('#3B82F6'),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const FDText(
                        'Explore Top Stories',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: FlartColors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          _buildArticlesGrid(displayed, columns: isMobile ? 1 : 2),
      ],
    );
  }

  // ==========================================
  // SCREEN 6: EXPLORE / SEARCH
  // ==========================================
  Widget _buildExploreScreen(bool isMobile, bool isTablet) {
    var results = WebMockData.sampleArticles;

    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase().trim();
      results = results.where((a) {
        return a.title.toLowerCase().contains(q) ||
            a.summary.toLowerCase().contains(q) ||
            a.tags.any((t) => t.toLowerCase().contains(q)) ||
            a.source.name.toLowerCase().contains(q);
      }).toList();
    }

    if (_selectedSourceFilter != 'all') {
      results = results.where((a) => a.source.slug == _selectedSourceFilter).toList();
    }

    if (_sortBy == 'most_read') {
      results = List.from(results)..sort((a, b) => b.likeCount.compareTo(a.likeCount));
    }

    return FDColumn(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Large Search Bar
        FDContainer(
          child: FDTextField(
            placeholder: 'Search topics, breaking events, entities, or authors...',
            backgroundColor: _isDarkMode ? const FlartColor('#1E293B') : const FlartColor('#FFFFFF'),
            borderColor: const FlartColor('rgba(255, 255, 255, 0.15)'),
            borderRadius: 16,
            prefixIcon: const FDIcon(icon: FDIcons.search, size: 20, color: FlartColors.grey),
            onChanged: (val) {
              setState(() {
                _searchQuery = val;
              });
            },
          ),
        ),
        const FDSizedBox(height: 16),

        // Trending Topic Pills
        FDRow(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const FDText('Trending: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: FlartColors.grey)),
            const FDSizedBox(width: 8),
            Expanded(
              child: FDSingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: FDRow(
                  children: WebMockData.trendingTags.map((t) {
                    return FDGestureDetector(
                      onTap: () {
                        setState(() {
                          _searchQuery = t.replaceAll('#', '');
                        });
                      },
                      child: FDContainer(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const FlartColor('rgba(59, 130, 246, 0.15)'),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const FlartColor('rgba(59, 130, 246, 0.3)'), width: 1),
                        ),
                        child: FDText(
                          t,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: FlartColor('#60A5FA')),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
        const FDSizedBox(height: 24),

        // Results Header with Sort Switcher
        FDRow(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FDText(
              'Showing ${results.length} stories ${(_searchQuery.isNotEmpty) ? "for \"$_searchQuery\"" : ""}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            FDRow(
              children: [
                FDGestureDetector(
                  onTap: () {
                    setState(() {
                      _sortBy = 'latest';
                    });
                  },
                  child: FDContainer(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _sortBy == 'latest' ? const FlartColor('#3B82F6') : const FlartColor('rgba(255, 255, 255, 0.08)'),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const FDText('Latest', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ),
                const FDSizedBox(width: 6),
                FDGestureDetector(
                  onTap: () {
                    setState(() {
                      _sortBy = 'most_read';
                    });
                  },
                  child: FDContainer(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _sortBy == 'most_read' ? const FlartColor('#3B82F6') : const FlartColor('rgba(255, 255, 255, 0.08)'),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const FDText('Most Read', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
        const FDSizedBox(height: 16),

        // Results Grid
        _buildArticlesGrid(results, columns: isMobile ? 1 : (isTablet ? 2 : 3)),
      ],
    );
  }

  // ==========================================
  // SHARED EDITORIAL COMPONENTS
  // ==========================================
  Widget _buildSectionHeader(String title) {
    return FDRow(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        FDText(
          title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: _isDarkMode ? FlartColors.white : FlartColors.black,
          ),
        ),
        FDRawHTML('''
          <div style="font-size: 12px; color: #64748B; font-weight: 600;">
            Live Feeds • Syndicated
          </div>
        '''),
      ],
    );
  }

  Widget _buildHeroSpotlightCard(Article article) {
    final isBookmarked = _bookmarkedIds.contains(article.id);
    final isReadLater = _readLaterIds.contains(article.id);

    return FDGestureDetector(
      onTap: () => _openArticleReader(article),
      child: FDContainer(
        decoration: BoxDecoration(
          color: _isDarkMode ? const FlartColor('#131D2E') : const FlartColor('#FFFFFF'),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const FlartColor('rgba(255, 255, 255, 0.12)'), width: 1),
          boxShadow: const [
            BoxShadow(color: FlartColor('rgba(0, 0, 0, 0.3)'), blurRadius: 20, offset: Offset(0, 8)),
          ],
        ),
        child: FDColumn(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (article.imageUrl != null)
              FDRawHTML('''
                <div style="position: relative; width: 100%; height: clamp(260px, 28vw, 400px); border-radius: 16px 16px 0 0; overflow: hidden;">
                  <img src="${article.imageUrl}" alt="${article.title}" style="width: 100%; height: 100%; object-fit: cover; transition: transform 0.5s ease;" onmouseover="this.style.transform='scale(1.03)'" onmouseout="this.style.transform='scale(1)'"/>
                  <div style="position: absolute; bottom: 0; left: 0; right: 0; height: 120px; background: linear-gradient(to top, rgba(9, 13, 22, 0.95), transparent);"></div>
                  <div style="position: absolute; top: 16px; left: 16px; display: flex; gap: 8px;">
                    <span style="background: rgba(59, 130, 246, 0.9); backdrop-filter: blur(8px); color: #FFF; font-size: 11px; font-weight: 800; padding: 4px 10px; border-radius: 12px; text-transform: uppercase;">
                      ${article.category}
                    </span>
                    <span style="background: rgba(15, 23, 42, 0.85); backdrop-filter: blur(8px); color: #94A3B8; font-size: 11px; font-weight: 700; padding: 4px 10px; border-radius: 12px;">
                      ⚡ ${article.readTimeMinutes} min read
                    </span>
                  </div>
                </div>
              '''),
            FDContainer(
              padding: const EdgeInsets.all(24),
              child: FDColumn(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FDRow(
                    children: [
                      FDRawHTML('''
                        <div style="display: flex; align-items: center; gap: 8px;">
                          <img src="${article.source.iconUrl}" style="width: 18px; height: 18px; border-radius: 4px;"/>
                          <span style="font-size: 13px; font-weight: 700; color: #3B82F6;">${article.source.name}</span>
                          <span style="color: #64748B; font-size: 12px;">• 25m ago</span>
                        </div>
                      '''),
                    ],
                  ),
                  const FDSizedBox(height: 12),
                  FDText(
                    article.title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: _isDarkMode ? FlartColors.white : FlartColors.black,
                    ),
                  ),
                  const FDSizedBox(height: 10),
                  FDText(
                    article.summary,
                    style: const TextStyle(fontSize: 14, color: FlartColor('#94A3B8')),
                  ),
                  const FDSizedBox(height: 18),
                  FDRow(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FDRow(
                        children: [
                          _buildInteractionPill(
                            icon: FDIcons.favorite,
                            label: isBookmarked ? 'Saved' : 'Save',
                            color: isBookmarked ? FlartColors.red : FlartColors.grey,
                            onTap: () {
                              setState(() {
                                if (isBookmarked) {
                                  _bookmarkedIds.remove(article.id);
                                } else {
                                  _bookmarkedIds.add(article.id);
                                }
                              });
                            },
                          ),
                          const FDSizedBox(width: 8),
                          _buildInteractionPill(
                            icon: FDIcons.hourglass,
                            label: isReadLater ? 'In Queue' : 'Read Later',
                            color: isReadLater ? FlartColors.amber : FlartColors.grey,
                            onTap: () {
                              setState(() {
                                if (isReadLater) {
                                  _readLaterIds.remove(article.id);
                                } else {
                                  _readLaterIds.add(article.id);
                                }
                              });
                            },
                          ),
                        ],
                      ),
                      FDRow(
                        children: const [
                          FDText(
                            'Read Full Story',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: FlartColor('#3B82F6')),
                          ),
                          FDSizedBox(width: 4),
                          FDIcon(icon: FDIcons.arrow_forward, size: 16, color: FlartColor('#3B82F6')),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoogleNewsFullCoverageBlock() {
    final cluster = WebMockData.fullCoverageCluster;

    return FDContainer(
      decoration: BoxDecoration(
        color: _isDarkMode ? const FlartColor('#161F33') : const FlartColor('#F1F5F9'),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const FlartColor('rgba(59, 130, 246, 0.3)'), width: 1.5),
      ),
      padding: const EdgeInsets.all(20),
      child: FDColumn(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FDRow(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FDRow(
                children: [
                  FDRawHTML('''
                    <div style="display: flex; align-items: center; gap: 8px;">
                      <div style="background: #3B82F6; width: 20px; height: 20px; border-radius: 6px; display: flex; align-items: center; justify-content: center; font-size: 11px; font-weight: bold; color: #FFF;">
                        ❖
                      </div>
                      <span style="font-size: 14px; font-weight: 800; color: #60A5FA; text-transform: uppercase; letter-spacing: 0.05em;">
                        Full Coverage
                      </span>
                    </div>
                  '''),
                ],
              ),
              FDGestureDetector(
                onTap: () {
                  setState(() {
                    _showFullCoverageModal = true;
                  });
                },
                child: const FDText(
                  'View All 4 Perspectives ↗',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: FlartColor('#60A5FA')),
                ),
              ),
            ],
          ),
          const FDSizedBox(height: 12),
          FDText(
            cluster.topicHeadline,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const FDSizedBox(height: 14),
          FDColumn(
            children: cluster.alternativePerspectives.map((persp) {
              return FDGestureDetector(
                onTap: () => _openArticleReader(persp),
                child: FDContainer(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _isDarkMode ? const FlartColor('#0F172A') : const FlartColor('#FFFFFF'),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const FlartColor('rgba(255, 255, 255, 0.08)'), width: 1),
                  ),
                  child: FDRow(
                    children: [
                      FDRawHTML('''
                        <img src="${persp.source.iconUrl}" style="width: 18px; height: 18px; border-radius: 4px;"/>
                      '''),
                      const FDSizedBox(width: 10),
                      Expanded(
                        child: FDText(
                          persp.title,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const FDSizedBox(width: 8),
                      FDText(
                        persp.source.name,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: FlartColor('#3B82F6')),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildArticlesGrid(List<Article> articles, {required int columns}) {
    if (columns == 1) {
      return FDColumn(
        children: articles.map((article) => _buildArticleCard(article)).toList(),
      );
    }

    final cols = List.generate(columns, (_) => <Widget>[]);
    for (var i = 0; i < articles.length; i++) {
      cols[i % columns].add(_buildArticleCard(articles[i]));
    }

    return FDRow(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: cols
          .map((c) => Expanded(child: FDColumn(children: c)))
          .expand((w) => [w, const FDSizedBox(width: 20)])
          .take(columns * 2 - 1)
          .toList(),
    );
  }

  Widget _buildArticleCard(Article article) {
    final isBookmarked = _bookmarkedIds.contains(article.id);
    final isReadLater = _readLaterIds.contains(article.id);
    final isLiked = _likedIds.contains(article.id);

    return FDGestureDetector(
      onTap: () => _openArticleReader(article),
      child: FDContainer(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: _isDarkMode ? const FlartColor('#131D2E') : const FlartColor('#FFFFFF'),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const FlartColor('rgba(255, 255, 255, 0.1)'), width: 1),
          boxShadow: const [
            BoxShadow(color: FlartColor('rgba(0, 0, 0, 0.2)'), blurRadius: 10, offset: Offset(0, 4)),
          ],
        ),
        child: FDColumn(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (article.imageUrl != null)
              FDRawHTML('''
                <div style="position: relative; width: 100%; height: 180px; border-radius: 14px 14px 0 0; overflow: hidden;">
                  <img src="${article.imageUrl}" alt="${article.title}" style="width: 100%; height: 100%; object-fit: cover;"/>
                  <span style="position: absolute; top: 10px; left: 10px; background: rgba(15, 23, 42, 0.85); backdrop-filter: blur(8px); color: #60A5FA; font-size: 10px; font-weight: 800; padding: 2px 8px; border-radius: 8px; text-transform: uppercase;">
                    ${article.category}
                  </span>
                  <span style="position: absolute; top: 10px; right: 10px; background: rgba(15, 23, 42, 0.85); backdrop-filter: blur(8px); color: #94A3B8; font-size: 10px; font-weight: 700; padding: 2px 8px; border-radius: 8px;">
                    ⚡ ${article.readTimeMinutes}m
                  </span>
                </div>
              '''),
            FDContainer(
              padding: const EdgeInsets.all(16),
              child: FDColumn(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FDRow(
                    children: [
                      FDRawHTML('''
                        <div style="display: flex; align-items: center; gap: 6px;">
                          <img src="${article.source.iconUrl}" style="width: 14px; height: 14px; border-radius: 3px;"/>
                          <span style="font-size: 11px; font-weight: 700; color: #3B82F6;">${article.source.name}</span>
                          <span style="color: #64748B; font-size: 11px;">• 1h ago</span>
                        </div>
                      '''),
                    ],
                  ),
                  const FDSizedBox(height: 8),
                  FDText(
                    article.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _isDarkMode ? FlartColors.white : FlartColors.black,
                    ),
                  ),
                  const FDSizedBox(height: 8),
                  FDText(
                    article.summary,
                    style: const TextStyle(fontSize: 13, color: FlartColor('#94A3B8')),
                  ),
                  const FDSizedBox(height: 14),
                  FDRow(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FDRow(
                        children: [
                          FDGestureDetector(
                            onTap: () {
                              setState(() {
                                if (isBookmarked) {
                                  _bookmarkedIds.remove(article.id);
                                } else {
                                  _bookmarkedIds.add(article.id);
                                }
                              });
                            },
                            child: FDIcon(
                              icon: FDIcons.favorite,
                              size: 16,
                              color: isBookmarked ? FlartColors.red : FlartColors.grey,
                            ),
                          ),
                          const FDSizedBox(width: 12),
                          FDGestureDetector(
                            onTap: () {
                              setState(() {
                                if (isReadLater) {
                                  _readLaterIds.remove(article.id);
                                } else {
                                  _readLaterIds.add(article.id);
                                }
                              });
                            },
                            child: FDIcon(
                              icon: FDIcons.hourglass,
                              size: 16,
                              color: isReadLater ? FlartColors.amber : FlartColors.grey,
                            ),
                          ),
                        ],
                      ),
                      FDRow(
                        children: [
                          FDText(
                            '${article.likeCount + (isLiked ? 1 : 0)}',
                            style: const TextStyle(fontSize: 11, color: FlartColors.grey),
                          ),
                          const FDSizedBox(width: 4),
                          FDGestureDetector(
                            onTap: () {
                              setState(() {
                                if (isLiked) {
                                  _likedIds.remove(article.id);
                                } else {
                                  _likedIds.add(article.id);
                                }
                              });
                            },
                            child: FDIcon(
                              icon: FDIcons.star,
                              size: 14,
                              color: isLiked ? FlartColors.amber : FlartColors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // MSN SIDEBAR WIDGETS
  // ==========================================
  Widget _buildWeatherWidget() {
    final weather = WebMockData.cityWeatherMap[_selectedCity] ?? WebMockData.currentWeather;

    return FDContainer(
      decoration: BoxDecoration(
        color: _isDarkMode ? const FlartColor('#131D2E') : const FlartColor('#FFFFFF'),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const FlartColor('rgba(255, 255, 255, 0.12)'), width: 1),
      ),
      padding: const EdgeInsets.all(20),
      child: FDColumn(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FDRow(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const FDText('Local Weather', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              FDGestureDetector(
                onTap: () {
                  setState(() {
                    _activeScreen = 'local';
                  });
                },
                child: FDText(
                  '📍 $_selectedCity',
                  style: const TextStyle(fontSize: 12, color: FlartColor('#3B82F6'), fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const FDSizedBox(height: 16),
          FDRow(
            children: [
              FDRawHTML('''<div style="font-size: 38px; line-height: 1;">🌤️</div>'''),
              const FDSizedBox(width: 14),
              FDColumn(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FDText(
                    '${weather.temperatureC.toInt()}°C',
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
                  ),
                  FDText(weather.condition, style: const TextStyle(fontSize: 13, color: FlartColor('#94A3B8'))),
                ],
              ),
            ],
          ),
          const FDSizedBox(height: 14),
          FDRawHTML('''
            <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 8px; border-top: 1px solid rgba(255, 255, 255, 0.08); padding-top: 12px; font-size: 11px; text-align: center;">
              <div><div style="color: #64748B;">Tue</div><div style="font-size: 16px; margin: 2px 0;">☀️</div><div style="font-weight: bold;">24°C</div></div>
              <div><div style="color: #64748B;">Wed</div><div style="font-size: 16px; margin: 2px 0;">🌧️</div><div style="font-weight: bold;">19°C</div></div>
              <div><div style="color: #64748B;">Thu</div><div style="font-size: 16px; margin: 2px 0;">⛅</div><div style="font-weight: bold;">21°C</div></div>
            </div>
          '''),
        ],
      ),
    );
  }

  Widget _buildMarketWatchWidget() {
    return FDContainer(
      decoration: BoxDecoration(
        color: _isDarkMode ? const FlartColor('#131D2E') : const FlartColor('#FFFFFF'),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const FlartColor('rgba(255, 255, 255, 0.12)'), width: 1),
      ),
      padding: const EdgeInsets.all(20),
      child: FDColumn(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FDRow(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              FDText('Financial Markets', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              FDText('Live Ticker', style: TextStyle(fontSize: 11, color: FlartColor('#10B981'), fontWeight: FontWeight.bold)),
            ],
          ),
          const FDSizedBox(height: 12),
          FDColumn(
            children: WebMockData.marketTicker.take(4).map((m) {
              return FDContainer(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: _isDarkMode ? const FlartColor('rgba(255, 255, 255, 0.06)') : const FlartColor('#F8FAFC'),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: FDRow(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FDColumn(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FDText(m.symbol, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        FDText(m.name, style: const TextStyle(fontSize: 10, color: FlartColors.grey)),
                      ],
                    ),
                    FDRow(
                      children: [
                        FDText('\$${m.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        const FDSizedBox(width: 8),
                        FDContainer(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: m.isPositive ? const FlartColor('rgba(16, 185, 129, 0.15)') : const FlartColor('rgba(239, 68, 68, 0.15)'),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: FDText(
                            '${m.isPositive ? '+' : ''}${m.changePercent}%',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: m.isPositive ? const FlartColor('#10B981') : const FlartColor('#EF4444'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingTopicsWidget() {
    return FDContainer(
      decoration: BoxDecoration(
        color: _isDarkMode ? const FlartColor('#131D2E') : const FlartColor('#FFFFFF'),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const FlartColor('rgba(255, 255, 255, 0.12)'), width: 1),
      ),
      padding: const EdgeInsets.all(20),
      child: FDColumn(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const FDText('Trending Conversations', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const FDSizedBox(height: 12),
          FDWrap(
            spacing: 8,
            runSpacing: 8,
            children: WebMockData.trendingTags.map((tag) {
              return FDGestureDetector(
                onTap: () {
                  setState(() {
                    _activeScreen = 'explore';
                    _searchQuery = tag.replaceAll('#', '');
                  });
                },
                child: FDContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _isDarkMode ? const FlartColor('rgba(255, 255, 255, 0.08)') : const FlartColor('#F1F5F9'),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const FlartColor('rgba(255, 255, 255, 0.08)'), width: 1),
                  ),
                  child: FDText(
                    tag,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: FlartColor('#60A5FA')),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTopReadLeaderboard() {
    final topStories = WebMockData.sampleArticles.take(4).toList();

    return FDContainer(
      decoration: BoxDecoration(
        color: _isDarkMode ? const FlartColor('#131D2E') : const FlartColor('#FFFFFF'),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const FlartColor('rgba(255, 255, 255, 0.12)'), width: 1),
      ),
      padding: const EdgeInsets.all(20),
      child: FDColumn(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const FDText("Editor's Top Reads", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const FDSizedBox(height: 12),
          FDColumn(
            children: topStories.asMap().entries.map((entry) {
              final rank = entry.key + 1;
              final article = entry.value;

              return FDGestureDetector(
                onTap: () => _openArticleReader(article),
                child: FDContainer(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: FDRow(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FDText(
                        '0$rank',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: FlartColor('#3B82F6')),
                      ),
                      const FDSizedBox(width: 12),
                      Expanded(
                        child: FDColumn(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FDText(article.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                            const FDSizedBox(height: 4),
                            FDText(article.source.name, style: const TextStyle(fontSize: 11, color: FlartColors.grey)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMorningBriefingPromoCard() {
    return FDContainer(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [FlartColor('#312E81'), FlartColor('#4338CA')],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(18),
      child: FDColumn(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FDRow(
            children: const [
              FDText('🎙️', style: TextStyle(fontSize: 16)),
              FDSizedBox(width: 6),
              FDText(
                'Morning Audio Briefing',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: FlartColors.white),
              ),
            ],
          ),
          const FDSizedBox(height: 6),
          const FDText(
            '5-minute AI audio intelligence digest of today’s top geopolitical & tech shifts.',
            style: TextStyle(fontSize: 12, color: FlartColor('#E0E7FF')),
          ),
          const FDSizedBox(height: 12),
          FDGestureDetector(
            onTap: () {
              setState(() {
                _showBottomBriefing = true;
                _isBriefingPlaying = !_isBriefingPlaying;
              });
            },
            child: FDContainer(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: FlartColors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: FDRow(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FDIcon(
                    icon: _isBriefingPlaying ? FDIcons.close : FDIcons.play_arrow,
                    size: 16,
                    color: const FlartColor('#312E81'),
                  ),
                  const FDSizedBox(width: 6),
                  FDText(
                    _isBriefingPlaying ? 'Pause Episode' : 'Listen Now (5m)',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: FlartColor('#312E81')),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsletterCard() {
    return FDContainer(
      decoration: BoxDecoration(
        color: const FlartColor('#1E1B4B'),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const FlartColor('rgba(99, 102, 241, 0.3)'), width: 1),
      ),
      padding: const EdgeInsets.all(20),
      child: FDColumn(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FDText('Daily Executive Digest', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: FlartColors.white)),
          const FDSizedBox(height: 6),
          const FDText('Get verified global intelligence delivered to your inbox every morning at 06:00.', style: TextStyle(fontSize: 12, color: FlartColor('#C7D2FE'))),
          const FDSizedBox(height: 14),
          FDRawHTML('''
            <div style="display: flex; gap: 8px;">
              <input type="email" placeholder="Enter your email" style="background: rgba(255, 255, 255, 0.1); border: 1px solid rgba(255, 255, 255, 0.2); border-radius: 8px; padding: 8px 12px; color: #FFF; font-size: 12px; width: 100%; outline: none;"/>
              <button style="background: #3B82F6; color: #FFF; border: none; border-radius: 8px; padding: 8px 14px; font-weight: 700; font-size: 12px; cursor: pointer;" onclick="alert('Thank you for subscribing to ReadMore Executive Digest!');">Join</button>
            </div>
          '''),
        ],
      ),
    );
  }

  // ==========================================
  // STICKY BOTTOM AUDIO BRIEFING BAR
  // ==========================================
  Widget _buildStickyBottomAudioPlayer(bool isMobile) {
    return FDPositioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: FDContainer(
        decoration: BoxDecoration(
          color: _isDarkMode ? const FlartColor('#0D1526') : const FlartColor('#FFFFFF'),
          border: const Border(top: BorderSide(color: FlartColor('rgba(59, 130, 246, 0.4)'), width: 1.5)),
          boxShadow: const [
            BoxShadow(color: FlartColor('rgba(0, 0, 0, 0.5)'), blurRadius: 20, offset: Offset(0, -4)),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: FDRow(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FDRow(
              children: [
                FDGestureDetector(
                  onTap: () {
                    setState(() {
                      _isBriefingPlaying = !_isBriefingPlaying;
                    });
                  },
                  child: FDContainer(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const FlartColor('#3B82F6'),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: FDCenter(
                      child: FDIcon(
                        icon: _isBriefingPlaying ? FDIcons.close : FDIcons.play_arrow,
                        size: 20,
                        color: FlartColors.white,
                      ),
                    ),
                  ),
                ),
                const FDSizedBox(width: 14),
                FDColumn(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    FDText(
                      'ReadMore Morning Intelligence Briefing',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    FDText(
                      'Episode #142 • 5 mins • AI Voice Synthesized',
                      style: TextStyle(fontSize: 11, color: FlartColors.grey),
                    ),
                  ],
                ),
              ],
            ),
            if (!isMobile)
              FDRawHTML('''
                <div style="display: flex; align-items: center; gap: 10px; width: 340px;">
                  <span style="font-size: 11px; color: #94A3B8;">01:45</span>
                  <div style="flex: 1; height: 4px; background: rgba(255, 255, 255, 0.2); border-radius: 2px; overflow: hidden;">
                    <div style="width: 35%; height: 100%; background: #3B82F6;"></div>
                  </div>
                  <span style="font-size: 11px; color: #94A3B8;">05:00</span>
                </div>
              '''),
            FDGestureDetector(
              onTap: () {
                setState(() {
                  _showBottomBriefing = false;
                  _isBriefingPlaying = false;
                });
              },
              child: const FDIcon(icon: FDIcons.close, size: 20, color: FlartColors.grey),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // MODAL 1: ADVANCED READER VIEW
  // ==========================================
  Widget _buildReaderViewModal(Article article, bool isMobile) {
    final isBookmarked = _bookmarkedIds.contains(article.id);
    final isReadLater = _readLaterIds.contains(article.id);
    final isLiked = _likedIds.contains(article.id);

    return FDContainer(
      decoration: const BoxDecoration(color: FlartColor('rgba(0, 0, 0, 0.85)')),
      child: FDCenter(
        child: FDContainer(
          margin: EdgeInsets.all(isMobile ? 8 : 24),
          decoration: BoxDecoration(
            color: _isDarkMode ? const FlartColor('#0F172A') : const FlartColor('#FFFFFF'),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const FlartColor('rgba(255, 255, 255, 0.2)'), width: 1),
            boxShadow: const [
              BoxShadow(color: FlartColor('rgba(0, 0, 0, 0.6)'), blurRadius: 40, offset: Offset(0, 16)),
            ],
          ),
          child: FDConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860, maxHeight: 880),
            child: FDSingleChildScrollView(
              child: FDContainer(
                padding: EdgeInsets.all(isMobile ? 18 : 36),
                child: FDColumn(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top Modal Toolbar: Category, Font Size Controller, Close
                    FDRow(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FDRow(
                          children: [
                            FDContainer(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const FlartColor('rgba(59, 130, 246, 0.15)'),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: FDText(
                                article.category.toUpperCase(),
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: FlartColor('#3B82F6')),
                              ),
                            ),
                            const FDSizedBox(width: 8),
                            FDText('⚡ ${article.readTimeMinutes} min read', style: const TextStyle(fontSize: 12, color: FlartColors.grey)),
                          ],
                        ),
                        FDRow(
                          children: [
                            // Font Size Controls (A- / A+)
                            FDGestureDetector(
                              onTap: () {
                                setState(() {
                                  if (_readerFontSize > 14) _readerFontSize -= 2;
                                });
                              },
                              child: FDContainer(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const FlartColor('rgba(255, 255, 255, 0.08)'),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const FDText('A-', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              ),
                            ),
                            const FDSizedBox(width: 6),
                            FDGestureDetector(
                              onTap: () {
                                setState(() {
                                  if (_readerFontSize < 24) _readerFontSize += 2;
                                });
                              },
                              child: FDContainer(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const FlartColor('rgba(255, 255, 255, 0.08)'),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const FDText('A+', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              ),
                            ),
                            const FDSizedBox(width: 14),
                            FDGestureDetector(
                              onTap: () {
                                setState(() {
                                  _activeReadingArticle = null;
                                });
                              },
                              child: const FDIcon(icon: FDIcons.close, size: 24, color: FlartColors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const FDSizedBox(height: 18),

                    // Title
                    FDText(
                      article.title,
                      style: TextStyle(
                        fontSize: isMobile ? 22 : 28,
                        fontWeight: FontWeight.w800,
                        color: _isDarkMode ? FlartColors.white : FlartColors.black,
                      ),
                    ),
                    const FDSizedBox(height: 14),

                    // Source & Meta
                    FDRow(
                      children: [
                        FDRawHTML('''
                          <div style="display: flex; align-items: center; gap: 8px;">
                            <img src="${article.source.iconUrl}" style="width: 22px; height: 22px; border-radius: 4px;"/>
                            <span style="font-size: 14px; font-weight: 700; color: #3B82F6;">${article.source.name}</span>
                            <span style="color: #64748B; font-size: 13px;">• Published today • Author: Syndicated News Desk</span>
                          </div>
                        '''),
                      ],
                    ),
                    const FDSizedBox(height: 20),

                    // Image
                    if (article.imageUrl != null)
                      FDRawHTML('''
                        <img src="${article.imageUrl}" alt="${article.title}" style="width: 100%; max-height: 400px; object-fit: cover; border-radius: 14px; margin-bottom: 20px;"/>
                      '''),

                    // TTS Audio Player Bar
                    FDContainer(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const FlartColor('#1E293B'),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const FlartColor('rgba(59, 130, 246, 0.3)'), width: 1),
                      ),
                      child: FDRow(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          FDRow(
                            children: [
                              FDGestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isAudioPlaying = !_isAudioPlaying;
                                  });
                                },
                                child: FDContainer(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: const FlartColor('#3B82F6'),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: FDCenter(
                                    child: FDIcon(
                                      icon: _isAudioPlaying ? FDIcons.close : FDIcons.play_arrow,
                                      size: 18,
                                      color: FlartColors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const FDSizedBox(width: 12),
                              FDColumn(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  FDText(
                                    _isAudioPlaying ? 'Playing Article Audio...' : 'Listen to this article (3m)',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: FlartColors.white),
                                  ),
                                  FDText(
                                    'High-fidelity AI voice • ${(_audioProgress * 100).toInt()}% completed',
                                    style: const TextStyle(fontSize: 10, color: FlartColors.grey),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          FDGestureDetector(
                            onTap: () {
                              setState(() {
                                _audioSpeed = _audioSpeed == 1.0 ? 1.25 : (_audioSpeed == 1.25 ? 1.5 : 1.0);
                              });
                            },
                            child: FDContainer(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const FlartColor('rgba(255, 255, 255, 0.1)'),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: FDText(
                                '${_audioSpeed}x',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: FlartColor('#60A5FA')),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const FDSizedBox(height: 20),

                    // AI Key Takeaways Box
                    FDContainer(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: _isDarkMode ? const FlartColor('rgba(59, 130, 246, 0.12)') : const FlartColor('rgba(59, 130, 246, 0.08)'),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const FlartColor('rgba(59, 130, 246, 0.25)'), width: 1),
                      ),
                      child: FDColumn(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          FDText(
                            '💡 Executive Takeaways',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: FlartColor('#60A5FA')),
                          ),
                          FDSizedBox(height: 8),
                          FDText('• Critical global developments corroborated by 3+ independent news organizations.'),
                          FDSizedBox(height: 4),
                          FDText('• Policy shift includes long-term infrastructure funding and automated synchronization.'),
                          FDSizedBox(height: 4),
                          FDText('• Market participants anticipate significant cross-border economic impacts over the next decade.'),
                        ],
                      ),
                    ),
                    const FDSizedBox(height: 20),

                    // Article Content
                    FDText(
                      article.content ?? article.summary,
                      style: TextStyle(
                        fontSize: _readerFontSize,
                        color: _isDarkMode ? const FlartColor('#CBD5E1') : const FlartColor('#334155'),
                      ),
                    ),
                    const FDSizedBox(height: 28),

                    // Action Buttons Bar
                    FDRow(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FDRow(
                          children: [
                            _buildInteractionPill(
                              icon: FDIcons.favorite,
                              label: isBookmarked ? 'Saved' : 'Bookmark',
                              color: isBookmarked ? FlartColors.red : FlartColors.grey,
                              onTap: () {
                                setState(() {
                                  if (isBookmarked) {
                                    _bookmarkedIds.remove(article.id);
                                  } else {
                                    _bookmarkedIds.add(article.id);
                                  }
                                });
                              },
                            ),
                            const FDSizedBox(width: 8),
                            _buildInteractionPill(
                              icon: FDIcons.hourglass,
                              label: isReadLater ? 'In Queue' : 'Read Later',
                              color: isReadLater ? FlartColors.amber : FlartColors.grey,
                              onTap: () {
                                setState(() {
                                  if (isReadLater) {
                                    _readLaterIds.remove(article.id);
                                  } else {
                                    _readLaterIds.add(article.id);
                                  }
                                });
                              },
                            ),
                            const FDSizedBox(width: 8),
                            _buildInteractionPill(
                              icon: FDIcons.star,
                              label: '${article.likeCount + (isLiked ? 1 : 0)} Likes',
                              color: isLiked ? FlartColors.amber : FlartColors.grey,
                              onTap: () {
                                setState(() {
                                  if (isLiked) {
                                    _likedIds.remove(article.id);
                                  } else {
                                    _likedIds.add(article.id);
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                        FDRawHTML('''
                          <a href="${article.originalUrl}" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 6px; background: #3B82F6; color: #FFF; padding: 10px 18px; border-radius: 8px; text-decoration: none; font-size: 13px; font-weight: 700;">
                            Read on ${article.source.name} ↗
                          </a>
                        '''),
                      ],
                    ),
                    const FDSizedBox(height: 32),
                    const FDDivider(color: FlartColor('rgba(255, 255, 255, 0.1)')),
                    const FDSizedBox(height: 24),

                    // Comments Section
                    _buildCommentsSection(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCommentsSection() {
    return FDColumn(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FDText(
          'Reader Comments (${_comments.length})',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const FDSizedBox(height: 14),

        // Add Comment Input
        FDRow(
          children: [
            Expanded(
              child: FDTextField(
                placeholder: 'Share your perspective on this development...',
                backgroundColor: _isDarkMode ? const FlartColor('#1E293B') : const FlartColor('#F1F5F9'),
                borderColor: const FlartColor('rgba(255, 255, 255, 0.1)'),
                borderRadius: 12,
                onChanged: (val) {
                  _newCommentDraft = val;
                },
              ),
            ),
            const FDSizedBox(width: 10),
            FDGestureDetector(
              onTap: () {
                if (_newCommentDraft.trim().isNotEmpty) {
                  setState(() {
                    _comments.insert(
                      0,
                      ArticleComment(
                        id: 'c-${DateTime.now().millisecondsSinceEpoch}',
                        author: 'You (Verified Reader)',
                        avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=128&q=80',
                        text: _newCommentDraft.trim(),
                        timeAgo: 'Just now',
                      ),
                    );
                    _newCommentDraft = '';
                  });
                }
              },
              child: FDContainer(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const FlartColor('#3B82F6'),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const FDText(
                  'Post',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: FlartColors.white),
                ),
              ),
            ),
          ],
        ),
        const FDSizedBox(height: 20),

        // Existing Comments List
        FDColumn(
          children: _comments.map((c) {
            return FDContainer(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _isDarkMode ? const FlartColor('rgba(255, 255, 255, 0.04)') : const FlartColor('#F8FAFC'),
                borderRadius: BorderRadius.circular(12),
              ),
              child: FDColumn(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FDRow(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FDRow(
                        children: [
                          FDRawHTML('''
                            <img src="${c.avatarUrl}" style="width: 24px; height: 24px; border-radius: 50%;"/>
                          '''),
                          const FDSizedBox(width: 8),
                          FDText(c.author, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          const FDSizedBox(width: 8),
                          FDText(c.timeAgo, style: const TextStyle(fontSize: 11, color: FlartColors.grey)),
                        ],
                      ),
                      FDGestureDetector(
                        onTap: () {
                          setState(() {
                            c.isLiked = !c.isLiked;
                            c.likes += c.isLiked ? 1 : -1;
                          });
                        },
                        child: FDRow(
                          children: [
                            FDText('${c.likes}', style: const TextStyle(fontSize: 11, color: FlartColors.grey)),
                            const FDSizedBox(width: 4),
                            FDIcon(
                              icon: FDIcons.favorite,
                              size: 13,
                              color: c.isLiked ? FlartColors.red : FlartColors.grey,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const FDSizedBox(height: 8),
                  FDText(
                    c.text,
                    style: TextStyle(
                      fontSize: 13,
                      color: _isDarkMode ? const FlartColor('#CBD5E1') : const FlartColor('#334155'),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ==========================================
  // MODAL 2: FULL COVERAGE DEEP DIVE
  // ==========================================
  Widget _buildFullCoverageModal(bool isMobile) {
    final cluster = WebMockData.fullCoverageCluster;

    return FDContainer(
      decoration: const BoxDecoration(color: FlartColor('rgba(0, 0, 0, 0.85)')),
      child: FDCenter(
        child: FDContainer(
          margin: EdgeInsets.all(isMobile ? 12 : 32),
          decoration: BoxDecoration(
            color: _isDarkMode ? const FlartColor('#0F172A') : const FlartColor('#FFFFFF'),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const FlartColor('rgba(59, 130, 246, 0.3)'), width: 1.5),
          ),
          child: FDConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820, maxHeight: 820),
            child: FDSingleChildScrollView(
              child: FDContainer(
                padding: const EdgeInsets.all(28),
                child: FDColumn(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FDRow(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const FDText(
                          'Full Coverage Deep Dive',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: FlartColor('#60A5FA')),
                        ),
                        FDGestureDetector(
                          onTap: () {
                            setState(() {
                              _showFullCoverageModal = false;
                            });
                          },
                          child: const FDIcon(icon: FDIcons.close, size: 24, color: FlartColors.grey),
                        ),
                      ],
                    ),
                    const FDSizedBox(height: 12),
                    FDText(
                      cluster.topicHeadline,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                    ),
                    const FDSizedBox(height: 18),

                    // Primary Anchor Article
                    _buildArticleCard(cluster.primaryArticle),
                    const FDSizedBox(height: 20),

                    // Chronological Timeline
                    const FDText(
                      'Chronological Timeline of Key Events:',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const FDSizedBox(height: 12),
                    FDColumn(
                      children: WebMockData.clusterTimeline.map((ev) {
                        return FDContainer(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _isDarkMode ? const FlartColor('rgba(255, 255, 255, 0.04)') : const FlartColor('#F8FAFC'),
                            borderRadius: BorderRadius.circular(10),
                            border: const Border(left: BorderSide(color: FlartColor('#3B82F6'), width: 3)),
                          ),
                          child: FDColumn(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FDRow(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  FDText(ev.time, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: FlartColor('#60A5FA'))),
                                  FDText(ev.sourceName, style: const TextStyle(fontSize: 11, color: FlartColors.grey)),
                                ],
                              ),
                              const FDSizedBox(height: 4),
                              FDText(ev.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                              const FDSizedBox(height: 4),
                              FDText(ev.summary, style: const TextStyle(fontSize: 12, color: FlartColor('#94A3B8'))),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const FDSizedBox(height: 20),

                    // Perspectives
                    const FDText(
                      'Multi-Source Perspectives & Analysis:',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const FDSizedBox(height: 12),
                    FDColumn(
                      children: cluster.alternativePerspectives.map((persp) {
                        return _buildArticleCard(persp);
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // MODAL 3: TOPICS & INTERESTS MANAGER
  // ==========================================
  Widget _buildInterestsManagerModal(bool isMobile) {
    return FDContainer(
      decoration: const BoxDecoration(color: FlartColor('rgba(0, 0, 0, 0.85)')),
      child: FDCenter(
        child: FDContainer(
          margin: EdgeInsets.all(isMobile ? 12 : 32),
          decoration: BoxDecoration(
            color: _isDarkMode ? const FlartColor('#0F172A') : const FlartColor('#FFFFFF'),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const FlartColor('rgba(255, 255, 255, 0.15)'), width: 1),
          ),
          child: FDConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600, maxHeight: 600),
            child: FDContainer(
              padding: const EdgeInsets.all(28),
              child: FDColumn(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FDRow(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const FDText(
                        'Tune Your Intelligence Feed',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      FDGestureDetector(
                        onTap: () {
                          setState(() {
                            _showInterestsModal = false;
                          });
                        },
                        child: const FDIcon(icon: FDIcons.close, size: 24, color: FlartColors.grey),
                      ),
                    ],
                  ),
                  const FDSizedBox(height: 8),
                  const FDText(
                    'Select topics to weight algorithmic recommendations in your "For You" stream.',
                    style: TextStyle(fontSize: 12, color: FlartColors.grey),
                  ),
                  const FDSizedBox(height: 20),

                  Expanded(
                    child: FDSingleChildScrollView(
                      child: FDWrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: WebMockData.allAvailableInterests.map((interest) {
                          final isSelected = _userInterests.contains(interest);

                          return FDGestureDetector(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _userInterests.remove(interest);
                                } else {
                                  _userInterests.add(interest);
                                }
                              });
                            },
                            child: FDContainer(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const FlartColor('#3B82F6')
                                    : (_isDarkMode ? const FlartColor('rgba(255, 255, 255, 0.08)') : const FlartColor('#F1F5F9')),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected ? const FlartColor('#3B82F6') : const FlartColor('rgba(255, 255, 255, 0.1)'),
                                  width: 1,
                                ),
                              ),
                              child: FDRow(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (isSelected) const FDText('✓ ', style: TextStyle(fontSize: 12, color: FlartColors.white)),
                                  FDText(
                                    interest,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                      color: isSelected ? FlartColors.white : (_isDarkMode ? FlartColors.white : FlartColors.black),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const FDSizedBox(height: 20),

                  FDGestureDetector(
                    onTap: () {
                      setState(() {
                        _showInterestsModal = false;
                      });
                    },
                    child: FDContainer(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: const FlartColor('#3B82F6'),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const FDCenter(
                        child: FDText(
                          'Save & Update Feed',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: FlartColors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // MODAL 4: NOTIFICATIONS POPOVER
  // ==========================================
  Widget _buildNotificationsPopover(bool isMobile) {
    return FDPositioned(
      top: 60,
      right: isMobile ? 12 : 32,
      child: FDContainer(
        width: 360,
        decoration: BoxDecoration(
          color: _isDarkMode ? const FlartColor('#111827') : const FlartColor('#FFFFFF'),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const FlartColor('rgba(255, 255, 255, 0.15)'), width: 1),
          boxShadow: const [
            BoxShadow(color: FlartColor('rgba(0, 0, 0, 0.5)'), blurRadius: 25, offset: Offset(0, 10)),
          ],
        ),
        padding: const EdgeInsets.all(18),
        child: FDColumn(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FDRow(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const FDText('Notifications', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                FDGestureDetector(
                  onTap: () {
                    setState(() {
                      _showNotificationsModal = false;
                    });
                  },
                  child: const FDIcon(icon: FDIcons.close, size: 16, color: FlartColors.grey),
                ),
              ],
            ),
            const FDSizedBox(height: 12),

            FDColumn(
              children: WebMockData.notifications.map((n) {
                return FDGestureDetector(
                  onTap: () {
                    setState(() {
                      _showNotificationsModal = false;
                      final art = WebMockData.sampleArticles.firstWhere(
                        (a) => a.id == n.articleId,
                        orElse: () => WebMockData.sampleArticles.first,
                      );
                      _openArticleReader(art);
                    });
                  },
                  child: FDContainer(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _isDarkMode ? const FlartColor('rgba(255, 255, 255, 0.05)') : const FlartColor('#F8FAFC'),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: FDColumn(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FDRow(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (n.isBreaking)
                              FDContainer(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const FlartColor('#EF4444'),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const FDText(
                                  'BREAKING',
                                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: FlartColors.white),
                                ),
                              ),
                            FDText(n.timeAgo, style: const TextStyle(fontSize: 10, color: FlartColors.grey)),
                          ],
                        ),
                        const FDSizedBox(height: 6),
                        FDText(n.title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // MODAL 5: EDITION / REGION SELECTOR
  // ==========================================
  Widget _buildEditionSelectorModal(bool isMobile) {
    final editions = [
      {'name': 'United States', 'code': 'US', 'flag': '🇺🇸'},
      {'name': 'United Kingdom', 'code': 'UK', 'flag': '🇬🇧'},
      {'name': 'Global International', 'code': 'GL', 'flag': '🌐'},
      {'name': 'Nigeria', 'code': 'NG', 'flag': '🇳🇬'},
      {'name': 'European Union', 'code': 'EU', 'flag': '🇪🇺'},
    ];

    return FDContainer(
      decoration: const BoxDecoration(color: FlartColor('rgba(0, 0, 0, 0.85)')),
      child: FDCenter(
        child: FDContainer(
          margin: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _isDarkMode ? const FlartColor('#111827') : const FlartColor('#FFFFFF'),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const FlartColor('rgba(255, 255, 255, 0.15)'), width: 1),
          ),
          child: FDConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: FDContainer(
              padding: const EdgeInsets.all(24),
              child: FDColumn(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FDRow(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const FDText('Select Edition & Region', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      FDGestureDetector(
                        onTap: () {
                          setState(() {
                            _showEditionModal = false;
                          });
                        },
                        child: const FDIcon(icon: FDIcons.close, size: 20, color: FlartColors.grey),
                      ),
                    ],
                  ),
                  const FDSizedBox(height: 16),

                  FDColumn(
                    children: editions.map((ed) {
                      final isSelected = _selectedEdition == ed['name'];

                      return FDGestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedEdition = ed['name']!;
                            _showEditionModal = false;
                          });
                        },
                        child: FDContainer(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const FlartColor('rgba(59, 130, 246, 0.2)')
                                : (_isDarkMode ? const FlartColor('rgba(255, 255, 255, 0.05)') : const FlartColor('#F8FAFC')),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected ? const FlartColor('#3B82F6') : const FlartColor('rgba(255, 255, 255, 0.08)'),
                              width: 1,
                            ),
                          ),
                          child: FDRow(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              FDRow(
                                children: [
                                  FDText(ed['flag']!, style: const TextStyle(fontSize: 18)),
                                  const FDSizedBox(width: 10),
                                  FDText(ed['name']!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              if (isSelected) const FDText('✓', style: TextStyle(fontSize: 14, color: FlartColor('#60A5FA'), fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // FOOTER (CLEAN OF ANY INTERNAL TECH NAMES)
  // ==========================================
  Widget _buildFooter(bool isMobile) {
    return FDContainer(
      decoration: BoxDecoration(
        color: _isDarkMode ? const FlartColor('#05080F') : const FlartColor('#F1F5F9'),
        border: const Border(top: BorderSide(color: FlartColor('rgba(255, 255, 255, 0.08)'), width: 1)),
      ),
      child: FDCenter(
        child: FDConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: FDContainer(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 28, vertical: 36),
            child: FDColumn(
              children: [
                FDRow(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FDColumn(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FDText(
                          'ReadMore',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: _isDarkMode ? FlartColors.white : FlartColors.black,
                          ),
                        ),
                        const FDSizedBox(height: 4),
                        const FDText(
                          'Global News & Real-Time Intelligence Syndication',
                          style: TextStyle(fontSize: 12, color: FlartColors.grey),
                        ),
                      ],
                    ),
                    FDRawHTML('''
                      <div style="display: flex; gap: 16px; font-size: 13px; color: #94A3B8;">
                        <a href="/sitemap.xml" style="color: inherit; text-decoration: none;">Sitemap</a>
                        <a href="/sitemap_news.xml" style="color: inherit; text-decoration: none;">Google News XML</a>
                        <a href="/rss.xml" style="color: inherit; text-decoration: none;">RSS 2.0</a>
                      </div>
                    '''),
                  ],
                ),
                const FDSizedBox(height: 24),
                const FDDivider(color: FlartColor('rgba(255, 255, 255, 0.08)')),
                const FDSizedBox(height: 16),
                const FDText(
                  '© 2026 ReadMore News Platform. Real-time multi-source aggregation conforming to fair-use and Google News syndication standards.',
                  style: TextStyle(fontSize: 11, color: FlartColor('#64748B')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // SHARED INTERACTION PILL
  // ==========================================
  Widget _buildInteractionPill({
    required dynamic icon,
    required String label,
    required FlartColor color,
    required VoidCallback onTap,
  }) {
    return FDGestureDetector(
      onTap: onTap,
      child: FDContainer(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: _isDarkMode ? const FlartColor('rgba(255, 255, 255, 0.08)') : const FlartColor('#F1F5F9'),
          borderRadius: BorderRadius.circular(16),
        ),
        child: FDRow(
          children: [
            FDIcon(icon: icon, size: 14, color: color),
            const FDSizedBox(width: 4),
            FDText(
              label,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
            ),
          ],
        ),
      ),
    );
  }

  String _getCategoryEmoji(String slug) {
    switch (slug) {
      case 'top':
        return '🔥';
      case 'for-you':
        return '✨';
      case 'local':
        return '📍';
      case 'international':
        return '🌐';
      case 'tech':
        return '💻';
      case 'business':
        return '📈';
      case 'sports':
        return '🏆';
      case 'entertainment':
        return '🎬';
      case 'gists':
        return '💬';
      case 'food':
        return '🍳';
      case 'lifestyle':
        return '🌿';
      case 'science':
        return '⚛️';
      default:
        return '📰';
    }
  }
}
