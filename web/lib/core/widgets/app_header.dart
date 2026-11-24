import 'package:flartdart/flartdart.dart';
import '../../viewmodels/news_app_viewmodel.dart';
import '../constants/app_colors.dart';
import 'centered_shell.dart';

/// Main brand header with logo, responsive search bar, and interactive controls.
class AppHeader extends StatelessWidget {
  final NewsAppViewModel vm;
  final bool isMobile;
  final bool isTablet;

  const AppHeader({
    required this.vm,
    required this.isMobile,
    required this.isTablet,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FDContainer(
      width: double.infinity,
      decoration: BoxDecoration(
        color: vm.isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
        border: const Border(bottom: BorderSide(color: AppColors.borderSubtle, width: 1)),
      ),
      child: CenteredShell(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 28, vertical: 12),
        child: FDRow(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Brand Logo & Tagline
            FDGestureDetector(
              onTap: () => vm.setActiveScreen('headlines'),
              child: FDRow(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FDContainer(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primaryBlue, AppColors.accentPurple],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(
                          color: FlartColor('rgba(59, 130, 246, 0.4)'),
                          blurRadius: 14,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const FDCenter(
                      child: FDText(
                        'R',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: FlartColors.white,
                        ),
                      ),
                    ),
                  ),
                  const FDSizedBox(width: 10),
                  FDColumn(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FDRichText(
                        text: TextSpan(
                          text: 'Read',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.04,
                            color: vm.isDarkMode ? FlartColors.white : FlartColors.black,
                          ),
                          children: const [
                            TextSpan(
                              text: 'More',
                              style: TextStyle(
                                color: AppColors.primaryBlue,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const FDText(
                        'GLOBAL NEWS & INTELLIGENCE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted,
                          letterSpacing: 0.12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Fluid Responsive Search Bar (Desktop / Tablet)
            if (!isMobile)
              Expanded(
                child: FDContainer(
                  margin: EdgeInsets.symmetric(horizontal: isTablet ? 8 : 24),
                  alignment: Alignment.center,
                  child: FDContainer(
                    width: double.infinity,
                    constraints: BoxConstraints(maxWidth: isTablet ? 260 : 460),
                    child: FDTextField(
                      placeholder: isTablet ? 'Search...' : 'Search stories, topics, sources...',
                      backgroundColor: vm.isDarkMode ? AppColors.darkInput : AppColors.lightInput,
                      borderColor: AppColors.borderRegular,
                      borderRadius: 24,
                      prefixIcon: const FDIcon(icon: FDIcons.search, size: 16, color: FlartColors.grey),
                      onChanged: (val) => vm.setSearchQuery(val),
                    ),
                  ),
                ),
              ),

            // Header Quick Controls
            FDRow(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Notification Bell with Unread Badge
                FDGestureDetector(
                  onTap: () => vm.toggleNotificationsModal(),
                  child: FDContainer(
                    decoration: BoxDecoration(
                      color: AppColors.borderSubtle,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: FDStack(
                      children: [
                        FDIcon(
                          icon: FDIcons.notifications,
                          size: 18,
                          color: vm.hasUnreadNotifications ? FlartColors.amber : FlartColors.grey,
                        ),
                        if (vm.hasUnreadNotifications)
                          FDPositioned(
                            top: -2,
                            right: -2,
                            child: FDContainer(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: AppColors.bearRed,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: vm.isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const FDSizedBox(width: 8),

                // Interests Tuning Button
                FDGestureDetector(
                  onTap: () => vm.openInterestsModal(),
                  child: FDContainer(
                    decoration: BoxDecoration(
                      color: AppColors.borderSubtle,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.borderRegular, width: 1),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: isTablet ? 8 : 10, vertical: 6),
                    child: FDRow(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const FDText('⚡', style: TextStyle(fontSize: 12)),
                        if (!isTablet) ...[
                          const FDSizedBox(width: 4),
                          const FDText('Interests', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ],
                    ),
                  ),
                ),
                const FDSizedBox(width: 8),

                // Theme Switcher
                FDGestureDetector(
                  onTap: () => vm.toggleDarkMode(),
                  child: FDContainer(
                    decoration: BoxDecoration(
                      color: AppColors.borderSubtle,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: FDIcon(
                      icon: vm.isDarkMode ? 'wb_sunny' : 'nightlight',
                      size: 16,
                      color: FlartColors.amber,
                    ),
                  ),
                ),
                const FDSizedBox(width: 8),

                // Reading Streak
                FDContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const FlartColor('rgba(245, 158, 11, 0.15)'),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: const FlartColor('rgba(245, 158, 11, 0.3)'),
                      width: 1,
                    ),
                  ),
                  child: const FDRow(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FDText('🔥 ', style: TextStyle(fontSize: 12)),
                      FDText(
                        '5d',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.accentAmber,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
