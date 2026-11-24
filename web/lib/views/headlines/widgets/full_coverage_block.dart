import 'package:flartdart/flartdart.dart';
import '../../../core/constants/app_colors.dart';
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
              return FDGestureDetector(
                onTap: () => vm.openArticleReader(persp),
                child: FDContainer(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: vm.isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.borderSubtle, width: 1),
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
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
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
