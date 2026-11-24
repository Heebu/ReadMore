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
                    // Brand Engraved Crest & Stately Serif Masthead
                    FDContainer(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: vm.isDarkMode ? FlartColors.white : FlartColors.black,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: vm.isDarkMode ? const FlartColor('#C8C6BD') : const FlartColor('#333333'),
                          width: 2,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: FlartColor('rgba(0, 0, 0, 0.2)'),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: FDCenter(
                        child: FDText(
                          'R',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'Cinzel',
                            color: vm.isDarkMode ? FlartColors.black : FlartColors.white,
                          ),
                        ),
                      ),
                    ),
                    const FDSizedBox(width: 12),
                    FDColumn(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FDRow(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          children: [
                            FDText(
                              'ReadMore',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'Cinzel',
                                letterSpacing: 0.04,
                                color: vm.isDarkMode
                                    ? const FlartColor('#F4F3EE')
                                    : const FlartColor('#111111'),
                              ),
                            ),
                            const FDSizedBox(width: 6),
                            FDText(
                              '✦',
                              style: TextStyle(
                                fontSize: 10,
                                color: vm.isDarkMode ? const FlartColor('#8E8C85') : const FlartColor('#6E6C66'),
                              ),
                            ),
                          ],
                        ),
                        const FDText(
                          'THE CHRONICLE OF GLOBAL DISPATCHES',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Space Grotesk',
                            color: AppColors.textMuted,
                            letterSpacing: 0.14,
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
                        ? 'Search archive...'
                        : 'Search historical dispatches, topics, intelligence...',
                    backgroundColor: vm.isDarkMode
                        ? AppColors.darkInput
                        : AppColors.lightInput,
                    borderColor: vm.isDarkMode
                        ? AppColors.borderRegular
                        : const FlartColor('#C8C4B7'),
                    borderRadius: 4,
                    prefixIcon: FDIcon(
                        icon: FDIcons.search,
                        size: 16,
                        color: vm.isDarkMode ? FlartColors.grey : const FlartColor('#555555')),
                    onChanged: (val) => vm.setSearchQuery(val),
                  ),
                ),
              ),

            const FDSizedBox(width: 16),

            // Header Quick Controls (Classic Broadsheet Typesetting)
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
                        color: vm.isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: vm.isDarkMode ? AppColors.borderRegular : const FlartColor('#C8C4B7'),
                          width: 1,
                        ),
                      ),
                      padding: const EdgeInsets.all(7),
                      child: FDStack(
                        children: [
                          FDIcon(
                            icon: FDIcons.notifications,
                            size: 16,
                            color: vm.isDarkMode ? FlartColors.white : FlartColors.black,
                          ),
                          if (vm.hasUnreadNotifications)
                            FDPositioned(
                              top: -2,
                              right: -2,
                              child: FDContainer(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: vm.isDarkMode ? FlartColors.white : FlartColors.black,
                                  shape: BoxShape.circle,
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
                        color: vm.isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: vm.isDarkMode ? AppColors.borderRegular : const FlartColor('#C8C4B7'),
                          width: 1,
                        ),
                      ),
                      padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 8 : 10, vertical: 6),
                      child: FDRow(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const FDText('✦', style: TextStyle(fontSize: 10)),
                          if (!isTablet) ...[
                            const FDSizedBox(width: 5),
                            FDText(
                              'Topics',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Space Grotesk',
                                color: vm.isDarkMode ? FlartColors.white : FlartColors.black,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const FDSizedBox(width: 8),

                  // Theme Switcher (Day / Night Press)
                  FDGestureDetector(
                    onTap: () => vm.toggleDarkMode(),
                    child: FDContainer(
                      decoration: BoxDecoration(
                        color: vm.isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: vm.isDarkMode ? AppColors.borderRegular : const FlartColor('#C8C4B7'),
                          width: 1,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      child: FDText(
                        vm.isDarkMode ? '☼ LIGHT' : '☾ NOIR',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Space Grotesk',
                          letterSpacing: 0.08,
                          color: vm.isDarkMode ? FlartColors.white : FlartColors.black,
                        ),
                      ),
                    ),
                  ),
                  const FDSizedBox(width: 8),

                  // Reading Streak (Letterpress Stamp)
                  FDContainer(
                    id: 'reading-streak-badge',
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                    decoration: BoxDecoration(
                      color: vm.isDarkMode ? const FlartColor('#1E1F25') : const FlartColor('#EFECE4'),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: vm.isDarkMode ? const FlartColor('#444652') : const FlartColor('#B5B1A2'),
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
                        const FDText('✦ ', style: TextStyle(fontSize: 10)),
                        FDText(
                          '${vm.currentUser.readingStreakDays}d STREAK',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Space Grotesk',
                            letterSpacing: 0.06,
                            color: vm.isDarkMode ? FlartColors.white : FlartColors.black,
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
                          color: vm.isDarkMode ? FlartColors.white : FlartColors.black,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: FDRow(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FDText(
                              'PRO ✦',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'Cinzel',
                                letterSpacing: 0.08,
                                color: vm.isDarkMode ? FlartColors.black : FlartColors.white,
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
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: vm.isDarkMode ? AppColors.borderRegular : const FlartColor('#C8C4B7'),
                            width: 1,
                          ),
                        ),
                        child: FDRow(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FDContainer(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: vm.isDarkMode ? FlartColors.white : FlartColors.black,
                                shape: BoxShape.circle,
                              ),
                              child: FDCenter(
                                child: FDText(
                                  vm.currentUser.displayName.isNotEmpty
                                      ? vm.currentUser.displayName[0].toUpperCase()
                                      : 'U',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    fontFamily: 'Cinzel',
                                    color: vm.isDarkMode ? FlartColors.black : FlartColors.white,
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
                                const FDText('✦', style: TextStyle(fontSize: 9)),
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
                          color: vm.isDarkMode ? FlartColors.white : FlartColors.black,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: FDText(
                          'SIGN IN',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Space Grotesk',
                            letterSpacing: 0.08,
                            color: vm.isDarkMode ? FlartColors.black : FlartColors.white,
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
