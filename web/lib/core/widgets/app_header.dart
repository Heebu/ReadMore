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
        border: const Border(
            bottom: BorderSide(color: AppColors.borderSubtle, width: 1)),
      ),
      child: CenteredShell(
        padding:
            EdgeInsets.symmetric(horizontal: isMobile ? 12 : 28, vertical: 12),
        child: FDRow(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Brand Logo & Tagline
            FDGestureDetector(
              onTap: () => vm.setActiveScreen('headlines'),
              child: FDContainer(
                cssStyle: const {'flex-shrink': '0'},
                child: FDRow(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    FDContainer(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.primaryBlue,
                            AppColors.accentPurple
                          ],
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
                              color: vm.isDarkMode
                                  ? FlartColors.white
                                  : FlartColors.black,
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
            ),

            // Stretched Full-Width Search Bar (Desktop / Tablet)
            if (!isMobile)
              Expanded(
                child: FDContainer(
                  id: 'header-search-container',
                  margin: EdgeInsets.symmetric(horizontal: isTablet ? 12 : 30),
                  child: FDTextField(
                    placeholder: isTablet
                        ? 'Search news...'
                        : 'Search stories, topics, sources, locations...',
                    backgroundColor: vm.isDarkMode
                        ? AppColors.darkInput
                        : AppColors.lightInput,
                    borderColor: vm.isDarkMode
                        ? AppColors.borderRegular
                        : const FlartColor('#E2E8F0'),
                    borderRadius: 24,
                    prefixIcon: const FDIcon(
                        icon: FDIcons.search,
                        size: 16,
                        color: FlartColors.grey),
                    onChanged: (val) => vm.setSearchQuery(val),
                  ),
                ),
              ),

           const SizedBox(width: 100),

            // Header Quick Controls
            FDContainer(
              cssStyle: const {'flex-shrink': '0'},
              child: FDRow(
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
                            color: vm.hasUnreadNotifications
                                ? FlartColors.amber
                                : FlartColors.grey,
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
                                    color: vm.isDarkMode
                                        ? AppColors.darkSurface
                                        : AppColors.lightSurface,
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
                        border: Border.all(
                            color: AppColors.borderRegular, width: 1),
                      ),
                      padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 8 : 10, vertical: 6),
                      child: FDRow(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const FDText('⚡', style: TextStyle(fontSize: 12)),
                          if (!isTablet) ...[
                            const FDSizedBox(width: 4),
                            const FDText('Interests',
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold)),
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
                    id: 'reading-streak-badge',
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const FlartColor('rgba(245, 158, 11, 0.15)'),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: const FlartColor('rgba(245, 158, 11, 0.3)'),
                        width: 1,
                      ),
                    ),
                    cssStyle: const {
                      'transition': 'transform 0.2s ease',
                      'cursor': 'default',
                    },
                    child: FDRow(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const FDText('🔥 ', style: TextStyle(fontSize: 12)),
                        FDText(
                          '${vm.currentUser.readingStreakDays}d',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.accentAmber,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const FDSizedBox(width: 8),

                  // Pro Upgrade CTA (if not pro)
                  if (!vm.currentUser.isPro) ...[
                    FDGestureDetector(
                      onTap: () => vm.openSubscriptionModal(),
                      child: FDContainer(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.accentPurple, AppColors.primaryBlue],
                          ),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: const [
                            BoxShadow(
                              color: FlartColor('rgba(139, 92, 246, 0.35)'),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const FDRow(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FDText('⚡', style: TextStyle(fontSize: 11)),
                            FDSizedBox(width: 4),
                            FDText(
                              'Go Pro',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: FlartColors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const FDSizedBox(width: 8),
                  ],

                  // User Avatar Pill (Opens Profile & Personalization)
                  if (vm.isAuthenticated)
                    FDGestureDetector(
                      onTap: () => vm.setActiveScreen('profile'),
                      child: FDContainer(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: vm.isDarkMode ? AppColors.darkCard : AppColors.lightCard,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: vm.currentUser.isPro ? AppColors.accentPurple : AppColors.borderRegular,
                            width: vm.currentUser.isPro ? 1.5 : 1,
                          ),
                        ),
                        child: FDRow(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FDContainer(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [AppColors.primaryBlue, AppColors.accentPurple],
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: FDCenter(
                                child: FDText(
                                  vm.currentUser.displayName.isNotEmpty
                                      ? vm.currentUser.displayName[0].toUpperCase()
                                      : 'U',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    color: FlartColors.white,
                                  ),
                                ),
                              ),
                            ),
                            if (!isTablet && !isMobile) ...[
                              const FDSizedBox(width: 6),
                              FDText(
                                vm.currentUser.displayName.split(' ').first,
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                              ),
                              if (vm.currentUser.isPro) ...[
                                const FDSizedBox(width: 4),
                                const FDText('★', style: TextStyle(fontSize: 10, color: AppColors.accentAmber)),
                              ],
                            ],
                          ],
                        ),
                      ),
                    )
                  else
                    FDGestureDetector(
                      onTap: () => vm.openAuthModal(),
                      child: FDContainer(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const FDText(
                          'Sign In',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: FlartColors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
