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
              FDRawHTML('''<div style="font-size: 38px; line-height: 1;">🌤️</div>'''),
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
}
