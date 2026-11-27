import 'package:flartdart/flartdart.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/web_dom_helper.dart';
import '../../viewmodels/news_app_viewmodel.dart';
import '../headlines/widgets/article_card.dart';

/// Full Coverage Deep Dive modal inspired by Google News, presenting a chronological
/// event timeline and diverse perspectives from multiple global publishers.
class FullCoverageModal extends StatefulWidget {
  final NewsAppViewModel vm;
  final bool isMobile;

  const FullCoverageModal({
    required this.vm,
    required this.isMobile,
    super.key,
  });

  @override
  State<FullCoverageModal> createState() => _FullCoverageModalState();
}

class _FullCoverageModalState extends State<FullCoverageModal> {
  Object? _keySub;

  @override
  void initState() {
    super.initState();
    _keySub = addWindowKeyDownListener((key, _) {
      if (key == 'Escape') {
        widget.vm.closeFullCoverageModal();
      }
    });
  }

  @override
  void dispose() {
    removeWindowKeyDownListener(_keySub);
    _keySub = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.vm;
    final isMobile = widget.isMobile;
    final cluster = vm.fullCoverageCluster;

    return FDContainer(
      onClick: () => vm.closeFullCoverageModal(),
      decoration: const BoxDecoration(color: FlartColor('rgba(0, 0, 0, 0.85)')),
      cssStyle: const {
        'position': 'fixed',
        'top': '0',
        'left': '0',
        'right': '0',
        'bottom': '0',
        'z-index': '1000',
        'overflow-y': 'auto',
      },
      child: FDCenter(
        cssStyle: const {
          'height': 'auto',
          'min-height': '100%',
          'align-items': 'safe center',
        },
        child: FDElement(
          tag: 'div',
          id: 'full-coverage-modal-dialog',
          attributes: {
            'role': 'dialog',
            'aria-modal': 'true',
            'aria-label': cluster.topicHeadline,
          },
          styles: {
            'box-sizing': 'border-box',
            'width': isMobile ? 'calc(100% - 16px)' : 'min(820px, calc(100% - 48px))',
            'max-width': 'calc(100vw - 16px)',
            'min-width': '0',
            'margin': isMobile ? '8px auto' : '24px auto',
            'cursor': 'default',
          },
          events: {
            'click': (dynamic e) => stopEventPropagation(e),
          },
          children: [
            FDContainer(
              decoration: BoxDecoration(
                color: vm.isDarkMode ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primaryBlueLight, width: 1.5),
              ),
              cssStyle: const {
                'width': '100%',
                'max-width': '100%',
                'min-width': '0',
                'box-sizing': 'border-box',
              },
              child: FDConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 820, maxHeight: 820),
                cssStyle: const {
                  'width': '100%',
                  'max-width': '100%',
                  'min-width': '0',
                },
                child: FDSingleChildScrollView(
                  cssStyle: {
                    'max-height': isMobile ? 'calc(100vh - 20px)' : 'calc(100vh - 72px)',
                  },
                  child: FDContainer(
                    padding: EdgeInsets.all(isMobile ? 16 : 28),
                    cssStyle: const {
                      'width': '100%',
                      'max-width': '100%',
                      'min-width': '0',
                      'box-sizing': 'border-box',
                      'overflow-wrap': 'break-word',
                    },
                    child: FDColumn(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      cssStyle: const {'width': '100%', 'min-width': '0', 'max-width': '100%'},
                      children: [
                        FDRow(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Expanded(
                              child: FDText(
                                'Full Coverage Deep Dive',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primaryBlueLight),
                              ),
                            ),
                            const FDSizedBox(width: 8),
                            FDGestureDetector(
                              key: const ValueKey('full-coverage-close-btn'),
                              onTap: () => vm.closeFullCoverageModal(),
                              child: const FDIcon(
                                icon: FDIcons.close,
                                size: 24,
                                color: FlartColors.grey,
                                semanticLabel: 'Close full coverage',
                              ),
                            ),
                          ],
                        ),
                        const FDSizedBox(height: 12),
                        FDText(
                          cluster.topicHeadline,
                          style: TextStyle(fontSize: isMobile ? 18 : 22, fontWeight: FontWeight.w800),
                        ),
                        const FDSizedBox(height: 18),

                        // Primary Anchor Article
                        ArticleCard(article: cluster.primaryArticle, vm: vm),
                        const FDSizedBox(height: 20),

                        // Chronological Timeline
                        const FDText(
                          'Chronological Timeline of Key Events:',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        const FDSizedBox(height: 12),
                        FDColumn(
                          children: vm.clusterTimeline.map((ev) {
                            return FDContainer(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: vm.isDarkMode ? AppColors.borderSubtle : AppColors.lightSurface,
                                borderRadius: BorderRadius.circular(10),
                                border: const Border(left: BorderSide(color: AppColors.primaryBlue, width: 3)),
                              ),
                              cssStyle: const {'width': '100%', 'max-width': '100%', 'box-sizing': 'border-box'},
                              child: FDColumn(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  FDWrap(
                                    alignment: MainAxisAlignment.spaceBetween,
                                    spacing: 8,
                                    runSpacing: 4,
                                    cssStyle: const {'width': '100%', 'max-width': '100%'},
                                    children: [
                                      FDText(ev.time, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryBlueLight)),
                                      FDText(ev.sourceName, style: const TextStyle(fontSize: 11, color: FlartColors.grey)),
                                    ],
                                  ),
                                  const FDSizedBox(height: 4),
                                  FDText(ev.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                  const FDSizedBox(height: 4),
                                  FDText(ev.summary, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
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
                            return ArticleCard(article: persp, vm: vm);
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
