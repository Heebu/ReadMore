import 'package:flartdart/flartdart.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/web_dom_helper.dart';
import '../../viewmodels/news_app_viewmodel.dart';

/// Modal for tuning user interests and topics to steer algorithmic feed personalization.
class InterestsModal extends StatefulWidget {
  final NewsAppViewModel vm;
  final bool isMobile;

  const InterestsModal({
    required this.vm,
    required this.isMobile,
    super.key,
  });

  @override
  State<InterestsModal> createState() => _InterestsModalState();
}

class _InterestsModalState extends State<InterestsModal> {
  Object? _keySub;

  @override
  void initState() {
    super.initState();
    _keySub = addWindowKeyDownListener((key, _) {
      if (key == 'Escape') {
        widget.vm.closeInterestsModal();
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

    return FDContainer(
      onClick: () => vm.closeInterestsModal(),
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
          id: 'interests-modal-dialog',
          attributes: const {
            'role': 'dialog',
            'aria-modal': 'true',
            'aria-label': 'Tune Your Intelligence Feed',
          },
          styles: {
            'box-sizing': 'border-box',
            'width': isMobile ? 'calc(100% - 16px)' : 'min(600px, calc(100% - 48px))',
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
                border: Border.all(color: AppColors.borderRegular, width: 1),
              ),
              cssStyle: const {'width': '100%', 'max-width': '100%', 'min-width': '0', 'box-sizing': 'border-box'},
              child: FDConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600, maxHeight: 600),
                cssStyle: const {'width': '100%', 'max-width': '100%', 'min-width': '0'},
                child: FDSingleChildScrollView(
                  cssStyle: {
                    'max-height': isMobile ? 'calc(100vh - 20px)' : 'min(600px, calc(100vh - 48px))',
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
                                'Tune Your Intelligence Feed',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const FDSizedBox(width: 8),
                            FDGestureDetector(
                              key: const ValueKey('interests-close-btn'),
                              onTap: () => vm.closeInterestsModal(),
                              child: const FDIcon(
                                icon: FDIcons.close,
                                size: 24,
                                color: FlartColors.grey,
                                semanticLabel: 'Close topics selector',
                              ),
                            ),
                          ],
                        ),
                        const FDSizedBox(height: 8),
                        const FDText(
                          'Select topics to weight algorithmic recommendations in your "For You" stream.',
                          style: TextStyle(fontSize: 12, color: FlartColors.grey),
                        ),
                        const FDSizedBox(height: 20),

                        FDWrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: vm.allAvailableInterests.map((interest) {
                            final isSelected = vm.userInterests.contains(interest);

                            return FDGestureDetector(
                              onTap: () => vm.toggleInterest(interest),
                              child: FDContainer(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primaryBlue
                                      : (vm.isDarkMode ? AppColors.borderSubtle : AppColors.lightInput),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected ? AppColors.primaryBlue : AppColors.borderRegular,
                                    width: 1,
                                  ),
                                ),
                                child: FDRow(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (isSelected) const FDText('✓ ', style: TextStyle(fontSize: 12, color: FlartColors.white)),
                                    FDText(
                                      interest,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                        color: isSelected ? FlartColors.white : (vm.isDarkMode ? FlartColors.white : FlartColors.black),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const FDSizedBox(height: 20),

                        FDGestureDetector(
                          onTap: () => vm.closeInterestsModal(),
                          child: FDContainer(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const FDCenter(
                              child: FDText(
                                'Save & Update Feed',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: FlartColors.white),
                              ),
                            ),
                          ),
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
