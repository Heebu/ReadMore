import 'package:flartdart/flartdart.dart';
import '../../../core/constants/app_colors.dart';
import '../../../viewmodels/news_app_viewmodel.dart';

/// Sidebar Widget: Local Weather Snapshot with 3-day outlook.
class WeatherSidebarWidget extends StatelessWidget {
  final NewsAppViewModel vm;

  const WeatherSidebarWidget({required this.vm, super.key});

  @override
  Widget build(BuildContext context) {
    final weather = vm.currentWeather;

    return FDContainer(
      decoration: BoxDecoration(
        color: vm.isDarkMode ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderRegular, width: 1),
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
                onTap: () => vm.setActiveScreen('local'),
                child: FDText(
                  '📍 ${vm.selectedCity}',
                  style: const TextStyle(fontSize: 12, color: AppColors.primaryBlue, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const FDSizedBox(height: 16),
          FDRow(
            children: [
              const FDText('🌤️', style: TextStyle(fontSize: 36)),
              const FDSizedBox(width: 14),
              FDColumn(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FDText(
                    '${weather.temperatureC.toInt()}°C',
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
                  ),
                  FDText(weather.condition, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                ],
              ),
            ],
          ),
          const FDSizedBox(height: 14),
          const FDDivider(color: AppColors.borderSubtle),
          const FDSizedBox(height: 12),
          FDRow(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              FDColumn(
                children: [
                  FDText('Tue', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  FDSizedBox(height: 2),
                  FDText('☀️', style: TextStyle(fontSize: 16)),
                  FDSizedBox(height: 2),
                  FDText('24°C', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ),
              FDColumn(
                children: [
                  FDText('Wed', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  FDSizedBox(height: 2),
                  FDText('🌧️', style: TextStyle(fontSize: 16)),
                  FDSizedBox(height: 2),
                  FDText('19°C', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ),
              FDColumn(
                children: [
                  FDText('Thu', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  FDSizedBox(height: 2),
                  FDText('⛅', style: TextStyle(fontSize: 16)),
                  FDSizedBox(height: 2),
                  FDText('21°C', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Sidebar Widget: Real-time financial market quotes.
class MarketWatchSidebarWidget extends StatelessWidget {
  final NewsAppViewModel vm;

  const MarketWatchSidebarWidget({required this.vm, super.key});

  @override
  Widget build(BuildContext context) {
    return FDContainer(
      decoration: BoxDecoration(
        color: vm.isDarkMode ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderRegular, width: 1),
      ),
      padding: const EdgeInsets.all(20),
      child: FDColumn(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FDRow(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              FDText('Financial Markets', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              FDText('Live Ticker', style: TextStyle(fontSize: 11, color: AppColors.accentEmerald, fontWeight: FontWeight.bold)),
            ],
          ),
          const FDSizedBox(height: 12),
          FDColumn(
            children: vm.marketTickers.take(4).map((m) {
              return FDContainer(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: vm.isDarkMode ? AppColors.borderSubtle : AppColors.lightBg,
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
                              color: m.isPositive ? AppColors.accentEmerald : AppColors.accentRed,
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
        color: vm.isDarkMode ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderRegular, width: 1),
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
            children: vm.trendingTags.map((tag) {
              return FDGestureDetector(
                onTap: () {
                  vm.setActiveScreen('explore');
                  vm.setSearchQuery(tag.replaceAll('#', ''));
                },
                child: FDContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: vm.isDarkMode ? AppColors.borderSubtle : AppColors.lightNav,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderSubtle, width: 1),
                  ),
                  child: FDText(
                    tag,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primaryBlueLight),
                  ),
                ),
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
    final topStories = vm.headlinesArticles.take(4).toList();

    return FDContainer(
      decoration: BoxDecoration(
        color: vm.isDarkMode ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderRegular, width: 1),
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
                onTap: () => vm.openArticleReader(article),
                child: FDContainer(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: FDRow(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FDText(
                        '0$rank',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.primaryBlue),
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
}

/// Sidebar Widget: Morning Audio Briefing promo CTA.
class MorningBriefingPromoWidget extends StatelessWidget {
  final NewsAppViewModel vm;

  const MorningBriefingPromoWidget({required this.vm, super.key});

  @override
  Widget build(BuildContext context) {
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
            onTap: () => vm.toggleBottomBriefing(),
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
                    icon: vm.isBriefingPlaying ? FDIcons.close : FDIcons.play_arrow,
                    size: 16,
                    color: const FlartColor('#312E81'),
                  ),
                  const FDSizedBox(width: 6),
                  FDText(
                    vm.isBriefingPlaying ? 'Pause Episode' : 'Listen Now (5m)',
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
}

/// Sidebar Widget: Executive Daily Newsletter subscribe form.
class NewsletterWidget extends StatelessWidget {
  const NewsletterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return FDContainer(
      decoration: BoxDecoration(
        color: AppColors.darkBreaking,
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
          FDRow(
            children: [
              Expanded(
                child: FDTextField(
                  placeholder: 'Enter your email',
                  backgroundColor: const FlartColor('rgba(255, 255, 255, 0.1)'),
                  borderColor: const FlartColor('rgba(255, 255, 255, 0.2)'),
                  borderRadius: 8,
                ),
              ),
              const FDSizedBox(width: 8),
              FDElevatedButton(
                onPressed: () {},
                style: FDElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: BorderRadius.circular(8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
                child: const FDText(
                  'Join',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: FlartColors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
