import 'package:flartdart/flartdart.dart';
import '../../core/widgets/empty_state_widget.dart';
import '../../core/widgets/filter_chip_pill.dart';
import '../../viewmodels/news_app_viewmodel.dart';
import '../headlines/widgets/articles_grid.dart';

/// For You view presenting AI-personalized recommendations based on user interests
/// and reading habits, with topic tuning controls and serendipity metrics.
class ForYouView extends StatelessWidget {
  final NewsAppViewModel vm;
  final bool isMobile;
  final bool isTablet;

  const ForYouView({
    required this.vm,
    required this.isMobile,
    required this.isTablet,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final articlesToShow = vm.personalizedArticles;

    return FDColumn(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Personalized Header Banner in Broadsheet Dispatch Styling
        FDContainer(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: vm.isDarkMode ? const FlartColor('#15161C') : const FlartColor('#111111'),
            borderRadius: BorderRadius.circular(3),
            border: Border.all(
              color: vm.isDarkMode ? const FlartColor('#33353F') : const FlartColor('#000000'),
              width: 1,
            ),
          ),
          child: FDColumn(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FDRow(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FDRow(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const [
                      FDText(
                        '✦',
                        style: TextStyle(fontSize: 16, color: FlartColors.white),
                      ),
                      FDSizedBox(width: 8),
                      FDText(
                        'YOUR PERSONALIZED INTELLIGENCE FEED',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Space Grotesk',
                          letterSpacing: 0.1,
                          color: FlartColors.white,
                        ),
                      ),
                    ],
                  ),
                  FDGestureDetector(
                    onTap: () => vm.openInterestsModal(),
                    child: FDContainer(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: FlartColors.white,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: const FDText(
                        'CUSTOMIZE TOPICS +',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Space Grotesk',
                          letterSpacing: 0.08,
                          color: FlartColors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const FDSizedBox(height: 8),
              const FDText(
                'Synthesized from your curated reading interests, historical dispatches, and syndication velocity.',
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'Newsreader',
                  color: FlartColor('#D4CFBE'),
                ),
              ),
              const FDSizedBox(height: 16),

              // Active Topics Pills
              FDWrap(
                spacing: 8,
                runSpacing: 8,
                children: vm.userInterests.map((interest) {
                  return FilterChipPill(
                    label: '#$interest',
                    isSelected: false,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    onTap: () => vm.openInterestsModal(),
                    isDarkMode: true,
                  );
                }).toList(),
              ),
              const FDSizedBox(height: 14),

              // Serendipity Level Indicator
              FDRow(
                children: [
                  FDText(
                    'Serendipity Discovery: ${(vm.serendipityLevel * 100).toInt()}% • Algorithmic Diversity Enabled',
                    style: const TextStyle(fontSize: 11, color: FlartColors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
        const FDSizedBox(height: 24),

        // Personalized Feed Grid or Empty State Fallback
        if (articlesToShow.isEmpty)
          EmptyStateWidget(
            emoji: '✨',
            title: 'No curated stories matching your current topics',
            description: 'Add more topics or explore Top Global Headlines while we gather personalized dispatches.',
            actionLabel: 'Customize Topics',
            onAction: () => vm.openInterestsModal(),
          )
        else
          ArticlesGrid(
            articles: articlesToShow,
            columns: isMobile ? 1 : (isTablet ? 2 : 3),
            vm: vm,
          ),
      ],
    );
  }
}
