import 'package:flartdart/flartdart.dart';
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
        color: vm.isDarkMode ? const FlartColor('#15161C') : const FlartColor('#EFECE4'),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(
          color: vm.isDarkMode ? const FlartColor('#33353F') : const FlartColor('#C8C4B7'),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: FDColumn(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FDRow(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FDRow(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FDContainer(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: vm.isDarkMode ? FlartColors.white : FlartColors.black,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: FDText(
                      '❖',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: vm.isDarkMode ? FlartColors.black : FlartColors.white,
                      ),
                    ),
                  ),
                  const FDSizedBox(width: 8),
                  FDText(
                    'COMPREHENSIVE DOSSIER',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Space Grotesk',
                      letterSpacing: 0.1,
                      color: vm.isDarkMode ? const FlartColor('#F4F3EE') : const FlartColor('#111111'),
                    ),
                  ),
                ],
              ),
              FDGestureDetector(
                onTap: () => vm.openFullCoverage(),
                child: FDText(
                  'VIEW ALL 4 PERSPECTIVES →',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Space Grotesk',
                    letterSpacing: 0.08,
                    color: vm.isDarkMode ? const FlartColor('#D4CFBE') : const FlartColor('#333333'),
                  ),
                ),
              ),
            ],
          ),
          const FDSizedBox(height: 12),
          FDText(
            cluster.topicHeadline,
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w900,
              fontFamily: 'Playfair Display',
              letterSpacing: -0.01,
              color: vm.isDarkMode ? const FlartColor('#F4F3EE') : const FlartColor('#111111'),
            ),
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
