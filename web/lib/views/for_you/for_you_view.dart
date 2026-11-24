import 'package:flartdart/flartdart.dart';
import '../../core/constants/app_colors.dart';
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
    final personalizedArticles = vm.sampleArticles.where((a) {
      return a.tags.any((t) => vm.userInterests.any((ui) => ui.toLowerCase().contains(t.toLowerCase()))) ||
          vm.userInterests.any((ui) => a.category.toLowerCase().contains(ui.toLowerCase()));
    }).toList();

    final articlesToShow = personalizedArticles.isNotEmpty ? personalizedArticles : vm.sampleArticles;

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
            borderRadius: const BorderRadius.circular(18),
            border: Border.all(color: AppColors.primaryBlueLight, width: 1.5),
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
                      FDText('✨', style: TextStyle(fontSize: 20)),
                      FDSizedBox(width: 8),
                      FDText(
                        'Your Personalized Intelligence Feed',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: FlartColors.white),
                      ),
                    ],
                  ),
                  FDGestureDetector(
                    onTap: () => vm.openInterestsModal(),
                    child: FDContainer(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue,
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
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const FDSizedBox(height: 16),

              // Active Topics Pills
              FDWrap(
                spacing: 8,
                runSpacing: 8,
                children: vm.userInterests.map((interest) {
                  return FDContainer(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const FlartColor('rgba(255, 255, 255, 0.1)'),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: FDText(
                      '#$interest',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryBlueLight),
                    ),
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

        // Personalized Feed Grid
        ArticlesGrid(
          articles: articlesToShow,
          columns: isMobile ? 1 : (isTablet ? 2 : 3),
          vm: vm,
        ),
      ],
    );
  }
}
