import 'package:flartdart/flartdart.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/web_dom_helper.dart';
import '../../viewmodels/news_app_viewmodel.dart';

/// Notifications popover displaying breaking alerts and live updates.
class NotificationsPopover extends StatefulWidget {
  final NewsAppViewModel vm;
  final bool isMobile;

  const NotificationsPopover({
    required this.vm,
    required this.isMobile,
    super.key,
  });

  @override
  State<NotificationsPopover> createState() => _NotificationsPopoverState();
}

class _NotificationsPopoverState extends State<NotificationsPopover> {
  Object? _keySub;

  @override
  void initState() {
    super.initState();
    _keySub = addWindowKeyDownListener((key, _) {
      if (key == 'Escape') {
        widget.vm.closeNotificationsModal();
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
      onClick: () => vm.closeNotificationsModal(),
      cssStyle: const {
        'position': 'fixed',
        'top': '0',
        'left': '0',
        'right': '0',
        'bottom': '0',
        'z-index': '950',
        'background': 'transparent',
        'cursor': 'default',
      },
      child: FDStack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: [
          FDPositioned(
            top: isMobile ? 96 : 104,
            right: isMobile ? 8 : 32,
            child: FDElement(
              tag: 'div',
              id: 'notifications-popover-dialog',
              attributes: const {
                'role': 'dialog',
                'aria-modal': 'false',
                'aria-label': 'Notifications',
              },
              styles: const {
                'box-sizing': 'border-box',
                'max-width': 'calc(100vw - 16px)',
                'cursor': 'default',
              },
              events: {
                'click': (dynamic e) => stopEventPropagation(e),
              },
              children: [
                FDContainer(
                  width: isMobile ? null : 360,
                  cssStyle: {
                    'width': isMobile ? 'calc(100vw - 16px)' : '360px',
                    'max-width': 'calc(100vw - 16px)',
                    'max-height': 'calc(100vh - 120px)',
                    'overflow-y': 'auto',
                    'box-sizing': 'border-box',
                  },
                  decoration: BoxDecoration(
                    color: vm.isDarkMode ? AppColors.darkCard : AppColors.lightCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderRegular, width: 1),
                    boxShadow: const [
                      BoxShadow(color: FlartColor('rgba(0, 0, 0, 0.5)'), blurRadius: 25, offset: Offset(0, 10)),
                    ],
                  ),
                  padding: const EdgeInsets.all(18),
                  child: FDColumn(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FDRow(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const FDText('Notifications', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                          FDGestureDetector(
                            key: const ValueKey('notifications-close-btn'),
                            onTap: () => vm.closeNotificationsModal(),
                            child: const FDIcon(
                              icon: FDIcons.close,
                              size: 16,
                              color: FlartColors.grey,
                              semanticLabel: 'Close notifications',
                            ),
                          ),
                        ],
                      ),
                      const FDSizedBox(height: 12),

                      FDColumn(
                        children: vm.notifications.map((n) {
                          return FDGestureDetector(
                            key: ValueKey('notif-${n.id}'),
                            onTap: () {
                              vm.closeNotificationsModal();
                              vm.openArticleById(n.articleId);
                            },
                            child: FDContainer(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: vm.isDarkMode ? AppColors.borderSubtle : AppColors.lightSurface,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: FDColumn(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  FDRow(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      if (n.isBreaking)
                                        FDContainer(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.bearRed,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: const FDText(
                                            'BREAKING',
                                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: FlartColors.white),
                                          ),
                                        ),
                                      FDText(n.timeAgo, style: const TextStyle(fontSize: 10, color: FlartColors.grey)),
                                    ],
                                  ),
                                  const FDSizedBox(height: 6),
                                  FDText(n.title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
