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
  // Navigation & Filtering
  String _selectedCategory = 'top';
  String _searchQuery = '';
  String _activeView = 'feed'; // 'feed', 'bookmarks', 'read_later'
  bool _isDarkMode = true;

  // Interactive User Collections (End-to-End local state)
  final Set<String> _bookmarkedIds = {'art-hero-1', 'art-tech-1'};
  final Set<String> _readLaterIds = {'art-sci-1'};
  final Set<String> _likedIds = {'art-tech-1'};

  // Active Reader View Modal
  Article? _activeReadingArticle;
  bool _showFullCoverageModal = false;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final isMobile = media.isSmall;
    final isTablet = media.isMedium;

    // Filter articles based on active view, category, and search query
    var displayedArticles = WebMockData.sampleArticles;

    if (_activeView == 'bookmarks') {
      displayedArticles = displayedArticles.where((a) => _bookmarkedIds.contains(a.id)).toList();
    } else if (_activeView == 'read_later') {
      displayedArticles = displayedArticles.where((a) => _readLaterIds.contains(a.id)).toList();
    } else {
      if (_selectedCategory != 'top' && _selectedCategory != 'all') {
        displayedArticles = displayedArticles
            .where((a) => a.category.toLowerCase() == _selectedCategory.toLowerCase())
            .toList();
      }
    }

    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase().trim();
      displayedArticles = displayedArticles.where((a) {
        return a.title.toLowerCase().contains(q) ||
            a.summary.toLowerCase().contains(q) ||
            a.tags.any((t) => t.toLowerCase().contains(q)) ||
            a.source.name.toLowerCase().contains(q);
      }).toList();
    }

    return FDMaterialApp(
      title: 'ReadMore — Next-Gen News & Intelligence',
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
                  // 1. MSN-Style Utility Ribbon (Clock, Weather, Live Stock/Crypto Ticker)
                  _buildUtilityRibbon(isMobile),

                  // 2. Main Brand Header & Navigation
                  _buildMainHeader(isMobile),

                  // 3. Category Horizontal Navigation Ribbon
                  _buildCategoryNavbar(isMobile),

                  // 4. Breaking News Live Ribbon
                  _buildBreakingNewsTicker(isMobile),

                  // 5. Main Content Area
                  FDContainer(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 12 : (isTablet ? 24 : 48),
                      vertical: 24,
                    ),
                    child: _buildMainContentArea(displayedArticles, isMobile, isTablet),
                  ),

                  // 6. Footer
                  _buildFooter(isMobile),
                ],
              ),
            ),

            // Modal / Reader View Overlay
            if (_activeReadingArticle != null)
              _buildReaderViewModal(_activeReadingArticle!, isMobile),

            // Full Coverage Modal Overlay
            if (_showFullCoverageModal)
              _buildFullCoverageModal(isMobile),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // 1. MSN-STYLE UTILITY RIBBON
  // ==========================================
  Widget _buildUtilityRibbon(bool isMobile) {
    return FDContainer(
      decoration: BoxDecoration(
        color: _isDarkMode ? const FlartColor('#05080F') : const FlartColor('#EDE9FE'),
        border: const Border(bottom: BorderSide(color: FlartColor('rgba(255, 255, 255, 0.08)'), width: 1)),
      ),
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 32, vertical: 8),
      child: FDRow(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Live Date & Weather Pill
          FDRow(
            children: [
              FDRawHTML('''
                <div style="display: flex; align-items: center; gap: 8px; font-size: 12px; color: ${_isDarkMode ? '#94A3B8' : '#475569'};">
                  <span>📅 <b>Monday, Nov 23, 2026</b></span>
                  <span style="opacity: 0.4;">|</span>
                  <span style="display: inline-flex; align-items: center; gap: 4px; background: rgba(59, 130, 246, 0.12); padding: 2px 8px; border-radius: 12px; color: #60A5FA; font-weight: 600;">
                    🌤️ New York 22.0°C (Partly Cloudy)
                  </span>
                </div>
              '''),
            ],
          ),

          // Right: Real-time Market Quotes
          if (!isMobile)
            FDRow(
              children: [
                FDRawHTML('''
                  <div style="display: flex; align-items: center; gap: 14px; font-size: 11px; font-family: monospace;">
                    <span style="color: #10B981; font-weight: bold;">▲ S&P 500 5,984.10 (+0.72%)</span>
                    <span style="color: #10B981; font-weight: bold;">▲ BTC \$98,650 (+3.65%)</span>
                    <span style="color: #10B981; font-weight: bold;">▲ NVDA \$148.90 (+2.45%)</span>
                    <span style="color: #EF4444; font-weight: bold;">▼ BRENT \$74.20 (-1.15%)</span>
                  </div>
                '''),
              ],
            ),
        ],
      ),
    );
  }

  // ==========================================
  // 2. MAIN BRAND HEADER
  // ==========================================
  Widget _buildMainHeader(bool isMobile) {
    return FDContainer(
      decoration: BoxDecoration(
        color: _isDarkMode ? const FlartColor('#111827') : const FlartColor('#FFFFFF'),
        border: const Border(bottom: BorderSide(color: FlartColor('rgba(255, 255, 255, 0.1)'), width: 1)),
      ),
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 32, vertical: 14),
      child: FDRow(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo & Tagline
          FDGestureDetector(
            onTap: () {
              setState(() {
                _activeView = 'feed';
                _selectedCategory = 'top';
                _searchQuery = '';
              });
            },
            child: FDRow(
              children: [
                FDRawHTML('''
                  <div style="display: flex; align-items: center; gap: 10px; cursor: pointer;">
                    <div style="width: 36px; height: 36px; background: linear-gradient(135deg, #3B82F6, #8B5CF6); border-radius: 10px; display: flex; align-items: center; justify-content: center; font-size: 20px; font-weight: 900; color: #FFF; box-shadow: 0 4px 14px rgba(59, 130, 246, 0.4);">
                      R
                    </div>
                    <div>
                      <div style="font-size: 22px; font-weight: 800; letter-spacing: -0.04em; color: ${_isDarkMode ? '#F8FAFC' : '#0F172A'};">
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

          // Center: Search Bar (Desktop/Tablet)
          if (!isMobile)
            FDContainer(
              width: 380,
              child: FDTextField(
                placeholder: 'Search breaking stories, topics, or sources...',
                backgroundColor: _isDarkMode ? const FlartColor('#1E293B') : const FlartColor('#F1F5F9'),
                borderColor: const FlartColor('rgba(255, 255, 255, 0.1)'),
                borderRadius: 24,
                prefixIcon: const FDIcon(icon: FDIcons.search, size: 16, color: FlartColors.grey),
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
              ),
            ),

          // Right: Action Badges (Bookmarks, Read Later, Theme Toggle, Profile)
          FDRow(
            children: [
              // Bookmarks View Button
              FDGestureDetector(
                onTap: () {
                  setState(() {
                    _activeView = _activeView == 'bookmarks' ? 'feed' : 'bookmarks';
                  });
                },
                child: FDContainer(
                  decoration: BoxDecoration(
                    color: _activeView == 'bookmarks'
                        ? const FlartColor('rgba(59, 130, 246, 0.25)')
                        : const FlartColor('rgba(255, 255, 255, 0.08)'),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: _activeView == 'bookmarks'
                          ? const FlartColor('#3B82F6')
                          : const FlartColor('rgba(255, 255, 255, 0.12)'),
                      width: 1,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: FDRow(
                    children: [
                      const FDIcon(icon: FDIcons.favorite, size: 16, color: FlartColors.red),
                      const FDSizedBox(width: 6),
                      FDText(
                        '${_bookmarkedIds.length}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const FDSizedBox(width: 10),

              // Read Later View Button
              FDGestureDetector(
                onTap: () {
                  setState(() {
                    _activeView = _activeView == 'read_later' ? 'feed' : 'read_later';
                  });
                },
                child: FDContainer(
                  decoration: BoxDecoration(
                    color: _activeView == 'read_later'
                        ? const FlartColor('rgba(139, 92, 246, 0.25)')
                        : const FlartColor('rgba(255, 255, 255, 0.08)'),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: _activeView == 'read_later'
                          ? const FlartColor('#8B5CF6')
                          : const FlartColor('rgba(255, 255, 255, 0.12)'),
                      width: 1,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: FDRow(
                    children: [
                      const FDIcon(icon: FDIcons.hourglass, size: 16, color: FlartColors.amber),
                      const FDSizedBox(width: 6),
                      FDText(
                        '${_readLaterIds.length}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const FDSizedBox(width: 10),

              // Dark/Light Mode Switcher
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
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 3. CATEGORY NAVBAR (12 SECTIONS)
  // ==========================================
  Widget _buildCategoryNavbar(bool isMobile) {
    return FDContainer(
      decoration: BoxDecoration(
        color: _isDarkMode ? const FlartColor('#0F172A') : const FlartColor('#F1F5F9'),
        border: const Border(bottom: BorderSide(color: FlartColor('rgba(255, 255, 255, 0.08)'), width: 1)),
      ),
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 32, vertical: 8),
      child: FDSingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: FDRow(
          children: NewsCategory.allCategories.map((category) {
            final isSelected = _activeView == 'feed' && _selectedCategory == category.slug;
            return FDGestureDetector(
              onTap: () {
                setState(() {
                  _activeView = 'feed';
                  _selectedCategory = category.slug;
                });
              },
              child: FDContainer(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
                    FDText(
                      _getCategoryEmoji(category.slug),
                      style: const TextStyle(fontSize: 14),
                    ),
                    const FDSizedBox(width: 6),
                    FDText(
                      category.name,
                      style: TextStyle(
                        fontSize: 13,
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
      ),
    );
  }

  // ==========================================
  // 4. BREAKING NEWS TICKER
  // ==========================================
  Widget _buildBreakingNewsTicker(bool isMobile) {
    final breakingArticle = WebMockData.sampleArticles.first;
    return FDContainer(
      decoration: const BoxDecoration(
        color: FlartColor('#1E1B4B'),
        border: Border(bottom: BorderSide(color: FlartColor('rgba(239, 68, 68, 0.3)'), width: 1)),
      ),
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 32, vertical: 8),
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
              onTap: () {
                setState(() {
                  _activeReadingArticle = breakingArticle;
                });
              },
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
                  _activeReadingArticle = breakingArticle;
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
    );
  }

  // ==========================================
  // 5. MAIN CONTENT AREA (BENTO & SIDEBAR)
  // ==========================================
  Widget _buildMainContentArea(List<Article> articles, bool isMobile, bool isTablet) {
    if (articles.isEmpty) {
      return FDContainer(
        padding: const EdgeInsets.symmetric(vertical: 80),
        child: FDCenter(
          child: FDColumn(
            children: [
              const FDIcon(icon: FDIcons.search, size: 48, color: FlartColors.grey),
              const FDSizedBox(height: 16),
              FDText(
                _activeView == 'bookmarks'
                    ? 'No saved bookmarks yet.'
                    : (_activeView == 'read_later'
                        ? 'Your Read Later queue is empty.'
                        : 'No stories found for "$_searchQuery".'),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const FDSizedBox(height: 8),
              const FDText(
                'Explore the Top Stories or choose another category to discover fresh journalism.',
                style: TextStyle(fontSize: 14, color: FlartColors.grey),
              ),
            ],
          ),
        ),
      );
    }

    final heroArticle = articles.first;
    final remainingArticles = articles.length > 1 ? articles.sublist(1) : <Article>[];

    // Responsive Desktop Layout (68% Feed, 32% Sidebar)
    if (!isMobile && !isTablet) {
      return FDRow(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Column (Feed)
          Expanded(
            flex: 68,
            child: FDColumn(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSectionHeader(),
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

          // Right Column (MSN Sidebar Widgets)
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
                _buildNewsletterCard(),
              ],
            ),
          ),
        ],
      );
    }

    // Mobile / Tablet Single Column Stack
    return FDColumn(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionHeader(),
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
    );
  }

  Widget _buildSectionHeader() {
    String title;
    if (_activeView == 'bookmarks') {
      title = 'Your Saved Bookmarks';
    } else if (_activeView == 'read_later') {
      title = 'Your Read Later Queue';
    } else {
      final cat = NewsCategory.findBySlug(_selectedCategory);
      title = cat?.name ?? 'Top Stories';
    }

    return FDRow(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        FDText(
          title,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: _isDarkMode ? FlartColors.white : FlartColors.black,
          ),
        ),
        FDRawHTML('''
          <div style="font-size: 12px; color: #64748B; font-weight: 600;">
            Updated every 15 mins • Live Feeds
          </div>
        '''),
      ],
    );
  }

  // ==========================================
  // SPOTLIGHT HERO CARD
  // ==========================================
  Widget _buildHeroSpotlightCard(Article article) {
    final isBookmarked = _bookmarkedIds.contains(article.id);
    final isReadLater = _readLaterIds.contains(article.id);

    return FDGestureDetector(
      onTap: () {
        setState(() {
          _activeReadingArticle = article;
        });
      },
      child: FDContainer(
        decoration: BoxDecoration(
          color: _isDarkMode ? const FlartColor('#131D2E') : const FlartColor('#FFFFFF'),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const FlartColor('rgba(255, 255, 255, 0.12)'), width: 1),
          boxShadow: const [
            BoxShadow(
              color: FlartColor('rgba(0, 0, 0, 0.3)'),
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: FDColumn(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Big Hero Image with overlay
            if (article.imageUrl != null)
              FDRawHTML('''
                <div style="position: relative; width: 100%; height: 340px; border-radius: 16px 16px 0 0; overflow: hidden;">
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

            // Card Body
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
                    style: const TextStyle(
                      fontSize: 14,
                      color: FlartColor('#94A3B8'),
                    ),
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

  // ==========================================
  // GOOGLE NEWS "FULL COVERAGE" BLOCK
  // ==========================================
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
                onTap: () {
                  setState(() {
                    _activeReadingArticle = persp;
                  });
                },
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

  // ==========================================
  // ARTICLE GRID (BENTO BOX)
  // ==========================================
  Widget _buildArticlesGrid(List<Article> articles, {required int columns}) {
    if (columns == 1) {
      return FDColumn(
        children: articles.map((article) => _buildArticleCard(article)).toList(),
      );
    }

    final leftCol = <Widget>[];
    final rightCol = <Widget>[];

    for (var i = 0; i < articles.length; i++) {
      if (i % 2 == 0) {
        leftCol.add(_buildArticleCard(articles[i]));
      } else {
        rightCol.add(_buildArticleCard(articles[i]));
      }
    }

    return FDRow(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: FDColumn(children: leftCol)),
        const FDSizedBox(width: 20),
        Expanded(child: FDColumn(children: rightCol)),
      ],
    );
  }

  Widget _buildArticleCard(Article article) {
    final isBookmarked = _bookmarkedIds.contains(article.id);
    final isReadLater = _readLaterIds.contains(article.id);
    final isLiked = _likedIds.contains(article.id);

    return FDGestureDetector(
      onTap: () {
        setState(() {
          _activeReadingArticle = article;
        });
      },
      child: FDContainer(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: _isDarkMode ? const FlartColor('#131D2E') : const FlartColor('#FFFFFF'),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const FlartColor('rgba(255, 255, 255, 0.1)'), width: 1),
          boxShadow: const [
            BoxShadow(
              color: FlartColor('rgba(0, 0, 0, 0.2)'),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
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
                    style: const TextStyle(
                      fontSize: 13,
                      color: FlartColor('#94A3B8'),
                    ),
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
    const w = WebMockData.currentWeather;

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
              FDText(
                'Local Weather',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              FDText(
                '📍 New York, US',
                style: TextStyle(fontSize: 12, color: FlartColor('#3B82F6'), fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const FDSizedBox(height: 16),

          FDRow(
            children: [
              FDRawHTML('''
                <div style="font-size: 38px; line-height: 1;">🌤️</div>
              '''),
              const FDSizedBox(width: 14),
              FDColumn(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FDText(
                    '${w.temperatureC.toInt()}°C',
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
                  ),
                  FDText(
                    w.condition,
                    style: const TextStyle(fontSize: 13, color: FlartColor('#94A3B8')),
                  ),
                ],
              ),
            ],
          ),
          const FDSizedBox(height: 14),

          FDRawHTML('''
            <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 8px; border-top: 1px solid rgba(255, 255, 255, 0.08); padding-top: 12px; font-size: 11px; text-align: center;">
              <div>
                <div style="color: #64748B;">Tue</div>
                <div style="font-size: 16px; margin: 2px 0;">☀️</div>
                <div style="font-weight: bold;">24°C</div>
              </div>
              <div>
                <div style="color: #64748B;">Wed</div>
                <div style="font-size: 16px; margin: 2px 0;">🌧️</div>
                <div style="font-weight: bold;">19°C</div>
              </div>
              <div>
                <div style="color: #64748B;">Thu</div>
                <div style="font-size: 16px; margin: 2px 0;">⛅</div>
                <div style="font-weight: bold;">21°C</div>
              </div>
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
              FDText(
                'Financial Markets',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              FDText(
                'Live Ticker',
                style: TextStyle(fontSize: 11, color: FlartColor('#10B981'), fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const FDSizedBox(height: 12),

          FDColumn(
            children: WebMockData.marketTicker.map((m) {
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
                        FDText(
                          m.symbol,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        FDText(
                          m.name,
                          style: const TextStyle(fontSize: 10, color: FlartColors.grey),
                        ),
                      ],
                    ),
                    FDRow(
                      children: [
                        FDText(
                          '\$${m.price.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        const FDSizedBox(width: 8),
                        FDContainer(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: m.isPositive
                                ? const FlartColor('rgba(16, 185, 129, 0.15)')
                                : const FlartColor('rgba(239, 68, 68, 0.15)'),
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
          const FDText(
            'Trending Conversations',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const FDSizedBox(height: 12),

          FDWrap(
            spacing: 8,
            runSpacing: 8,
            children: WebMockData.trendingTags.map((tag) {
              return FDGestureDetector(
                onTap: () {
                  setState(() {
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
          const FDText(
            "Editor's Top Reads",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const FDSizedBox(height: 12),

          FDColumn(
            children: topStories.asMap().entries.map((entry) {
              final rank = entry.key + 1;
              final article = entry.value;

              return FDGestureDetector(
                onTap: () {
                  setState(() {
                    _activeReadingArticle = article;
                  });
                },
                child: FDContainer(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: FDRow(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FDText(
                        '0$rank',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: FlartColor('#3B82F6'),
                        ),
                      ),
                      const FDSizedBox(width: 12),
                      Expanded(
                        child: FDColumn(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FDText(
                              article.title,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                            ),
                            const FDSizedBox(height: 4),
                            FDText(
                              article.source.name,
                              style: const TextStyle(fontSize: 11, color: FlartColors.grey),
                            ),
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
          const FDText(
            'Daily Briefing',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: FlartColors.white),
          ),
          const FDSizedBox(height: 6),
          const FDText(
            'The 5 essential stories you need to know every morning, curated by intelligence algorithms.',
            style: TextStyle(fontSize: 12, color: FlartColor('#C7D2FE')),
          ),
          const FDSizedBox(height: 14),

          FDRawHTML('''
            <div style="display: flex; gap: 8px;">
              <input type="email" placeholder="Enter your email" style="background: rgba(255, 255, 255, 0.1); border: 1px solid rgba(255, 255, 255, 0.2); border-radius: 8px; padding: 8px 12px; color: #FFF; font-size: 12px; width: 100%; outline: none;"/>
              <button style="background: #3B82F6; color: #FFF; border: none; border-radius: 8px; padding: 8px 14px; font-weight: 700; font-size: 12px; cursor: pointer;" onclick="alert('Thank you for subscribing to ReadMore Daily!');">Join</button>
            </div>
          '''),
        ],
      ),
    );
  }

  // ==========================================
  // 6. READER VIEW MODAL
  // ==========================================
  Widget _buildReaderViewModal(Article article, bool isMobile) {
    final isBookmarked = _bookmarkedIds.contains(article.id);
    final isReadLater = _readLaterIds.contains(article.id);

    return FDContainer(
      decoration: const BoxDecoration(
        color: FlartColor('rgba(0, 0, 0, 0.8)'),
      ),
      child: FDCenter(
        child: FDContainer(
          margin: EdgeInsets.all(isMobile ? 12 : 32),
          decoration: BoxDecoration(
            color: _isDarkMode ? const FlartColor('#0F172A') : const FlartColor('#FFFFFF'),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const FlartColor('rgba(255, 255, 255, 0.2)'), width: 1),
            boxShadow: const [
              BoxShadow(color: FlartColor('rgba(0, 0, 0, 0.6)'), blurRadius: 40, offset: Offset(0, 16)),
            ],
          ),
          child: FDConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820, maxHeight: 850),
            child: FDSingleChildScrollView(
              child: FDContainer(
                padding: EdgeInsets.all(isMobile ? 20 : 36),
                child: FDColumn(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
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
                            FDText(
                              '⚡ ${article.readTimeMinutes} min read',
                              style: const TextStyle(fontSize: 12, color: FlartColors.grey),
                            ),
                          ],
                        ),
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
                    const FDSizedBox(height: 18),

                    FDText(
                      article.title,
                      style: TextStyle(
                        fontSize: isMobile ? 22 : 28,
                        fontWeight: FontWeight.w800,
                        color: _isDarkMode ? FlartColors.white : FlartColors.black,
                      ),
                    ),
                    const FDSizedBox(height: 14),

                    FDRow(
                      children: [
                        FDRawHTML('''
                          <div style="display: flex; align-items: center; gap: 8px;">
                            <img src="${article.source.iconUrl}" style="width: 22px; height: 22px; border-radius: 4px;"/>
                            <span style="font-size: 14px; font-weight: 700; color: #3B82F6;">${article.source.name}</span>
                            <span style="color: #64748B; font-size: 13px;">• Published today</span>
                          </div>
                        '''),
                      ],
                    ),
                    const FDSizedBox(height: 20),

                    if (article.imageUrl != null)
                      FDRawHTML('''
                        <img src="${article.imageUrl}" alt="${article.title}" style="width: 100%; max-height: 400px; object-fit: cover; border-radius: 14px; margin-bottom: 24px;"/>
                      '''),

                    // Key Takeaways Box (Google News / MSN Feature)
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
                            '💡 Key Takeaways',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: FlartColor('#60A5FA')),
                          ),
                          FDSizedBox(height: 8),
                          FDText('• Historic treaty signed by 195 nations to triple clean energy transmission.'),
                          FDSizedBox(height: 4),
                          FDText('• \$500 billion annual public-private guarantees for HVDC supergrid deployment.'),
                          FDSizedBox(height: 4),
                          FDText('• Expected to create 12 million clean-tech jobs globally by 2035.'),
                        ],
                      ),
                    ),
                    const FDSizedBox(height: 20),

                    FDText(
                      article.content ?? article.summary,
                      style: TextStyle(
                        fontSize: 16,
                        color: _isDarkMode ? const FlartColor('#CBD5E1') : const FlartColor('#334155'),
                      ),
                    ),
                    const FDSizedBox(height: 32),

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
                          ],
                        ),

                        FDRawHTML('''
                          <a href="${article.originalUrl}" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 6px; background: #3B82F6; color: #FFF; padding: 10px 18px; border-radius: 8px; text-decoration: none; font-size: 13px; font-weight: 700;">
                            Read on ${article.source.name} ↗
                          </a>
                        '''),
                      ],
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
  // FULL COVERAGE MODAL
  // ==========================================
  Widget _buildFullCoverageModal(bool isMobile) {
    final cluster = WebMockData.fullCoverageCluster;

    return FDContainer(
      decoration: const BoxDecoration(color: FlartColor('rgba(0, 0, 0, 0.8)')),
      child: FDCenter(
        child: FDContainer(
          margin: EdgeInsets.all(isMobile ? 12 : 32),
          decoration: BoxDecoration(
            color: _isDarkMode ? const FlartColor('#0F172A') : const FlartColor('#FFFFFF'),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const FlartColor('rgba(59, 130, 246, 0.3)'), width: 1.5),
          ),
          child: FDConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 780, maxHeight: 800),
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
                          'Google News Full Coverage',
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

                    _buildArticleCard(cluster.primaryArticle),
                    const FDSizedBox(height: 16),

                    const FDText(
                      'Alternative Perspectives from Other Outlets:',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: FlartColors.grey),
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
  // FOOTER
  // ==========================================
  Widget _buildFooter(bool isMobile) {
    return FDContainer(
      decoration: BoxDecoration(
        color: _isDarkMode ? const FlartColor('#05080F') : const FlartColor('#F1F5F9'),
        border: const Border(top: BorderSide(color: FlartColor('rgba(255, 255, 255, 0.08)'), width: 1)),
      ),
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 48, vertical: 36),
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
                    'Built with FlartDart • Powered by Dart Frog backend',
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
            '© 2026 ReadMore News Platform. Real-time multi-source aggregation conforming to fair-use and Google News standards.',
            style: TextStyle(fontSize: 11, color: FlartColor('#64748B')),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // HELPERS
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
