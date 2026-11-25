import 'package:flartdart/flartdart.dart';
import '../../core/constants/app_colors.dart';
import '../../viewmodels/news_app_viewmodel.dart';

/// Notifications popover displaying breaking alerts and live updates.
class NotificationsPopover extends StatelessWidget {
  final NewsAppViewModel vm;
  final bool isMobile;

  const NotificationsPopover({
    required this.vm,
    required this.isMobile,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FDPositioned(
      top: 60,
      right: isMobile ? 12 : 32,
      child: FDContainer(
        width: 360,
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
                  onTap: () => vm.toggleNotificationsModal(),
                  child: const FDIcon(icon: FDIcons.close, size: 16, color: FlartColors.grey),
                ),
              ],
            ),
            const FDSizedBox(height: 12),

            FDColumn(
              children: vm.notifications.map((n) {
                return FDGestureDetector(
                  key: ValueKey('notif-${n.id}'),
                  onTap: () {
                    vm.toggleNotificationsModal();
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
    );
  }
}
