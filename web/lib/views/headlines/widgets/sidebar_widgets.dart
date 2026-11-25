import 'package:flartdart/flartdart.dart';
import '../../../core/widgets/filter_chip_pill.dart';
import '../../../core/widgets/ranked_article_tile.dart';
import '../../../viewmodels/news_app_viewmodel.dart';

/// Sidebar Widget: Local Weather Snapshot with 3-day outlook in broadsheet styling.
class WeatherSidebarWidget extends StatelessWidget {
  final NewsAppViewModel vm;

  const WeatherSidebarWidget({required this.vm, super.key});

  @override
  Widget build(BuildContext context) {
    final weather = vm.currentWeather;

    return FDContainer(
      decoration: BoxDecoration(
        color: vm.isDarkMode ? const FlartColor('#15161C') : const FlartColor('#FFFFFF'),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(
          color: vm.isDarkMode ? const FlartColor('#2A2B35') : const FlartColor('#D4CFBE'),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(18),
      child: FDColumn(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FDRow(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FDText(
                'LOCAL WEATHER DISPATCH',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Space Grotesk',
                  letterSpacing: 0.08,
                  color: vm.isDarkMode ? const FlartColor('#C8C6BD') : const FlartColor('#333333'),
                ),
              ),
              FDGestureDetector(
                onTap: () => vm.setActiveScreen('local'),
                child: FDText(
                  '📍 ${vm.selectedCity.toUpperCase()}',
                  style: TextStyle(
                    fontSize: 10,
                    fontFamily: 'Space Grotesk',
                    color: vm.isDarkMode ? FlartColors.white : FlartColors.black,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const FDSizedBox(height: 14),
          FDRow(
            children: [
              const FDText('🌤️', style: TextStyle(fontSize: 32)),
              const FDSizedBox(width: 14),
              FDColumn(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FDText(
                    '${weather.temperatureC.toInt()}°C',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Playfair Display',
                      color: vm.isDarkMode ? const FlartColor('#F4F3EE') : const FlartColor('#111111'),
                    ),
                  ),
                  FDText(
                    weather.condition,
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'Newsreader',
                      fontStyle: FontStyle.italic,
                      color: vm.isDarkMode ? const FlartColor('#A2A096') : const FlartColor('#555555'),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const FDSizedBox(height: 12),
          FDDivider(color: vm.isDarkMode ? const FlartColor('#2A2B35') : const FlartColor('#E2DED2')),
          const FDSizedBox(height: 10),
          FDRow(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weather.forecast.map((f) {
              return _buildForecastDay(
                f.day,
                f.iconCode,
                '${f.temperatureC.toInt()}°C',
                vm.isDarkMode,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  static Widget _buildForecastDay(String day, String icon, String temp, bool isDark) {
    return FDColumn(
      children: [
        FDText(
          day.toUpperCase(),
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            fontFamily: 'Space Grotesk',
            color: isDark ? const FlartColor('#8E8C85') : const FlartColor('#666666'),
          ),
        ),
        const FDSizedBox(height: 3),
        FDText(icon, style: const TextStyle(fontSize: 14)),
        const FDSizedBox(height: 3),
        FDText(
          temp,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            fontFamily: 'Space Grotesk',
            color: isDark ? FlartColors.white : FlartColors.black,
          ),
        ),
      ],
    );
  }
}

/// Sidebar Widget: Real-time financial market quotes in broadsheet format.
class MarketWatchSidebarWidget extends StatelessWidget {
  final NewsAppViewModel vm;

  const MarketWatchSidebarWidget({required this.vm, super.key});

  @override
  Widget build(BuildContext context) {
    return FDContainer(
      decoration: BoxDecoration(
        color: vm.isDarkMode ? const FlartColor('#15161C') : const FlartColor('#FFFFFF'),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(
          color: vm.isDarkMode ? const FlartColor('#2A2B35') : const FlartColor('#D4CFBE'),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(18),
      child: FDColumn(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FDRow(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FDText(
                'FINANCIAL BOURSE & TRADE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Space Grotesk',
                  letterSpacing: 0.08,
                  color: vm.isDarkMode ? const FlartColor('#C8C6BD') : const FlartColor('#333333'),
                ),
              ),
              FDContainer(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: vm.isDarkMode ? const FlartColor('#22242D') : const FlartColor('#E2DED2'),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: FDText(
                  'LIVE TICKER',
                  style: TextStyle(
                    fontSize: 9,
                    fontFamily: 'Space Grotesk',
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.06,
                    color: vm.isDarkMode ? FlartColors.white : FlartColors.black,
                  ),
                ),
              ),
            ],
          ),
          const FDSizedBox(height: 12),
          FDColumn(
            children: vm.marketTickers.take(4).map((m) {
              return FDContainer(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: vm.isDarkMode ? const FlartColor('#1B1D24') : const FlartColor('#F7F5F0'),
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(
                    color: vm.isDarkMode ? const FlartColor('#2A2B35') : const FlartColor('#E6E2D8'),
                    width: 1,
                  ),
                ),
                child: FDRow(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    FDColumn(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FDText(
                          m.symbol,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'Space Grotesk',
                            color: vm.isDarkMode ? FlartColors.white : FlartColors.black,
                          ),
                        ),
                        FDText(
                          m.name,
                          style: TextStyle(
                            fontSize: 10,
                            fontFamily: 'Newsreader',
                            color: vm.isDarkMode ? const FlartColor('#8E8C85') : const FlartColor('#666666'),
                          ),
                        ),
                      ],
                    ),
                    FDRow(
                      children: [
                        FDText(
                          '\$${m.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Space Grotesk',
                            color: vm.isDarkMode ? const FlartColor('#F4F3EE') : const FlartColor('#111111'),
                          ),
                        ),
                        const FDSizedBox(width: 8),
                        FDContainer(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: vm.isDarkMode ? const FlartColor('#262832') : const FlartColor('#E0DCD0'),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: FDText(
                            '${m.isPositive ? '▲ +' : '▼ -'}${m.changePercent.abs()}%',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'Space Grotesk',
                              color: vm.isDarkMode ? FlartColors.white : FlartColors.black,
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
}

/// Sidebar Widget: Trending topic hashtag pills.
class TrendingTopicsSidebarWidget extends StatelessWidget {
  final NewsAppViewModel vm;

  const TrendingTopicsSidebarWidget({required this.vm, super.key});

  @override
  Widget build(BuildContext context) {
    return FDContainer(
      decoration: BoxDecoration(
        color: vm.isDarkMode ? const FlartColor('#15161C') : const FlartColor('#FFFFFF'),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(
          color: vm.isDarkMode ? const FlartColor('#2A2B35') : const FlartColor('#D4CFBE'),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(18),
      child: FDColumn(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FDText(
            'DISPATCH TOPICS & INDEX',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              fontFamily: 'Space Grotesk',
              letterSpacing: 0.08,
              color: vm.isDarkMode ? const FlartColor('#C8C6BD') : const FlartColor('#333333'),
            ),
          ),
          const FDSizedBox(height: 12),
          FDWrap(
            spacing: 6,
            runSpacing: 6,
            children: vm.trendingTags.map((tag) {
              return FilterChipPill(
                label: tag,
                isSelected: false,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                onTap: () {
                  vm.setActiveScreen('explore');
                  vm.setSearchQuery(tag.replaceAll('#', ''));
                },
                isDarkMode: vm.isDarkMode,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

/// Sidebar Widget: Ranked leaderboard of editor's top reads.
class TopReadLeaderboardWidget extends StatelessWidget {
  final NewsAppViewModel vm;

  const TopReadLeaderboardWidget({required this.vm, super.key});

  @override
  Widget build(BuildContext context) {
    final topStories = (vm.trendingArticles.isNotEmpty ? vm.trendingArticles : vm.headlinesArticles)
        .take(4)
        .toList();

    return FDContainer(
      decoration: BoxDecoration(
        color: vm.isDarkMode ? const FlartColor('#15161C') : const FlartColor('#FFFFFF'),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(
          color: vm.isDarkMode ? const FlartColor('#2A2B35') : const FlartColor('#D4CFBE'),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(18),
      child: FDColumn(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FDText(
            'MOST CIRCULATED DISPATCHES',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              fontFamily: 'Space Grotesk',
              letterSpacing: 0.08,
              color: vm.isDarkMode ? const FlartColor('#C8C6BD') : const FlartColor('#333333'),
            ),
          ),
          const FDSizedBox(height: 12),
          FDColumn(
            children: topStories.asMap().entries.map((entry) {
              return RankedArticleTile(
                rank: entry.key + 1,
                article: entry.value,
                vm: vm,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

/// Sidebar Widget: Morning Audio Briefing promo CTA in letterpress styling.
class MorningBriefingPromoWidget extends StatelessWidget {
  final NewsAppViewModel vm;

  const MorningBriefingPromoWidget({required this.vm, super.key});

  @override
  Widget build(BuildContext context) {
    return FDContainer(
      decoration: BoxDecoration(
        color: vm.isDarkMode ? const FlartColor('#1A1B22') : const FlartColor('#111111'),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(
          color: vm.isDarkMode ? const FlartColor('#3A3C4A') : const FlartColor('#000000'),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(18),
      child: FDColumn(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FDRow(
            children: const [
              FDText(
                '✦',
                style: TextStyle(fontSize: 14, color: FlartColors.white),
              ),
              FDSizedBox(width: 8),
              FDText(
                'MORNING AUDIO DISPATCH',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Space Grotesk',
                  letterSpacing: 0.1,
                  color: FlartColors.white,
                ),
              ),
            ],
          ),
          const FDSizedBox(height: 8),
          const FDText(
            'Five-minute spoken intelligence digest of today’s principal geopolitical and economic developments.',
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'Newsreader',
              height: 1.45,
              color: FlartColor('#D4CFBE'),
            ),
          ),
          const FDSizedBox(height: 14),
          FDGestureDetector(
            onTap: () => vm.toggleBottomBriefing(),
            child: FDContainer(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: FlartColors.white,
                borderRadius: BorderRadius.circular(2),
              ),
              child: FDRow(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FDIcon(
                    icon: vm.isBriefingPlaying ? FDIcons.close : FDIcons.play_arrow,
                    size: 14,
                    color: FlartColors.black,
                  ),
                  const FDSizedBox(width: 6),
                  FDText(
                    vm.isBriefingPlaying ? 'PAUSE DISPATCH' : 'LISTEN TO DISPATCH (5M)',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Space Grotesk',
                      letterSpacing: 0.08,
                      color: FlartColors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Sidebar Widget: Executive Daily Newsletter subscribe form in editorial broadsheet styling.
class NewsletterWidget extends StatelessWidget {
  const NewsletterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return FDContainer(
      decoration: BoxDecoration(
        color: const FlartColor('#111111'),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: const FlartColor('#333333'), width: 1),
      ),
      padding: const EdgeInsets.all(18),
      child: FDColumn(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FDText(
            'THE DAILY GAZETTE COLOPHON',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              fontFamily: 'Space Grotesk',
              letterSpacing: 0.1,
              color: FlartColors.white,
            ),
          ),
          const FDSizedBox(height: 6),
          const FDText(
            'Receive verified dispatches delivered to your telegraph box every morning at dawn.',
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'Newsreader',
              height: 1.45,
              color: FlartColor('#C8C6BD'),
            ),
          ),
          const FDSizedBox(height: 14),
          FDRow(
            children: [
              Expanded(
                child: FDTextField(
                  placeholder: 'Your email address...',
                  backgroundColor: const FlartColor('rgba(255, 255, 255, 0.08)'),
                  borderColor: const FlartColor('#444444'),
                  borderRadius: 2,
                ),
              ),
              const FDSizedBox(width: 8),
              FDElevatedButton(
                onPressed: () {},
                style: FDElevatedButton.styleFrom(
                  backgroundColor: FlartColors.white,
                  shape: BorderRadius.circular(2),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
                child: const FDText(
                  'JOIN',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Space Grotesk',
                    letterSpacing: 0.08,
                    color: FlartColors.black,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
