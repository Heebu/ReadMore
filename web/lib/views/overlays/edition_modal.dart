import 'package:flartdart/flartdart.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/web_dom_helper.dart';
import '../../viewmodels/news_app_viewmodel.dart';

/// Modal for choosing edition and geographic region.
class EditionModal extends StatefulWidget {
  final NewsAppViewModel vm;
  final bool isMobile;

  const EditionModal({
    required this.vm,
    required this.isMobile,
    super.key,
  });

  @override
  State<EditionModal> createState() => _EditionModalState();
}

class _EditionModalState extends State<EditionModal> {
  Object? _keySub;

  @override
  void initState() {
    super.initState();
    _keySub = addWindowKeyDownListener((key, _) {
      if (key == 'Escape') {
        widget.vm.closeEditionModal();
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
    final editions = [
      {'name': 'United States', 'code': 'US', 'flag': '🇺🇸'},
      {'name': 'United Kingdom', 'code': 'UK', 'flag': '🇬🇧'},
      {'name': 'Global International', 'code': 'GL', 'flag': '🌐'},
      {'name': 'Nigeria', 'code': 'NG', 'flag': '🇳🇬'},
      {'name': 'Japan', 'code': 'JP', 'flag': '🇯🇵'},
      {'name': 'European Union', 'code': 'EU', 'flag': '🇪🇺'},
    ];

    return FDContainer(
      onClick: () => vm.closeEditionModal(),
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
          id: 'edition-modal-dialog',
          attributes: const {
            'role': 'dialog',
            'aria-modal': 'true',
            'aria-label': 'Select Edition & Region',
          },
          styles: {
            'box-sizing': 'border-box',
            'width': widget.isMobile ? 'calc(100% - 16px)' : 'min(420px, calc(100% - 48px))',
            'max-width': 'calc(100vw - 16px)',
            'min-width': '0',
            'margin': widget.isMobile ? '8px auto' : '24px auto',
            'cursor': 'default',
          },
          events: {
            'click': (dynamic e) => stopEventPropagation(e),
          },
          children: [
            FDContainer(
              decoration: BoxDecoration(
                color: vm.isDarkMode ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderRegular, width: 1),
              ),
              cssStyle: const {'width': '100%', 'max-width': '100%', 'min-width': '0', 'box-sizing': 'border-box'},
              child: FDConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                cssStyle: const {'width': '100%', 'max-width': '100%', 'min-width': '0'},
                child: FDContainer(
                  padding: EdgeInsets.all(widget.isMobile ? 16 : 24),
                  cssStyle: const {
                    'width': '100%',
                    'max-width': '100%',
                    'min-width': '0',
                    'box-sizing': 'border-box',
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
                            child: FDText('Select Edition & Region', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                          const FDSizedBox(width: 8),
                          FDGestureDetector(
                            key: const ValueKey('edition-close-btn'),
                            onTap: () => vm.closeEditionModal(),
                            child: const FDIcon(
                              icon: FDIcons.close,
                              size: 20,
                              color: FlartColors.grey,
                              semanticLabel: 'Close edition selector',
                            ),
                          ),
                        ],
                      ),
                      const FDSizedBox(height: 16),

                      FDColumn(
                        children: editions.map((ed) {
                          final isSelected = vm.selectedEdition == ed['name'];

                          return FDGestureDetector(
                            onTap: () => vm.setSelectedEdition(ed['name']!),
                            child: FDContainer(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primaryBlueSubtle
                                    : (vm.isDarkMode ? AppColors.borderSubtle : AppColors.lightSurface),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected ? AppColors.primaryBlue : AppColors.borderSubtle,
                                  width: 1,
                                ),
                              ),
                              child: FDRow(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  FDRow(
                                    children: [
                                      FDText(ed['flag']!, style: const TextStyle(fontSize: 18)),
                                      const FDSizedBox(width: 10),
                                      FDText(ed['name']!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  if (isSelected)
                                    const FDText(
                                      '✓',
                                      style: TextStyle(fontSize: 14, color: AppColors.primaryBlueLight, fontWeight: FontWeight.bold),
                                    ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
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
