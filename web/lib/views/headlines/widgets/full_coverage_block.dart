import 'package:flartdart/flartdart.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/compact_article_tile.dart';
import '../../../viewmodels/news_app_viewmodel.dart';

/// Google News "Full Coverage" block displaying multiple editorial perspectives.
class FullCoverageBlock extends StatelessWidget {
  final NewsAppViewModel vm;

  const FullCoverageBlock({
    required this.vm,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final cluster = vm.fullCoverageCluster;

    return FDContainer(
      decoration: BoxDecoration(
        color: vm.isDarkMode ? AppColors.darkCardSecondary : AppColors.lightNav,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderHighlighted, width: 1.5),
      ),
      padding: const EdgeInsets.all(20),
      child: FDColumn(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FDRow(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FDRow(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FDContainer(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const FDCenter(
                      child: FDText(
                        '❖',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: FlartColors.white),
                      ),
                    ),
                  ),
                  const FDSizedBox(width: 8),
                  const FDText(
                    'FULL COVERAGE',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryBlueLight,
                      letterSpacing: 0.05,
                    ),
                  ),
                ],
              ),
              FDGestureDetector(
                onTap: () => vm.openFullCoverage(),
                child: const FDText(
                  'View All 4 Perspectives ↗',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryBlueLight),
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
              return CompactArticleTile(
                article: persp,
                vm: vm,
                showThumbnail: false,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
