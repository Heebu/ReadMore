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
      decoration: BoxDecoration(
        color: vm.isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
        border: const Border(bottom: BorderSide(color: AppColors.borderSubtle, width: 1)),
      ),
      child: CenteredShell(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 28, vertical: 12),
        child: FDRow(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Brand Logo & Tagline
            FDGestureDetector(
              onTap: () => vm.setActiveScreen('headlines'),
              child: FDRow(
                children: [
                  FDRawHTML('''
                    <div style="display: flex; align-items: center; gap: 10px; cursor: pointer; white-space: nowrap;">
                      <div style="width: 38px; height: 38px; min-width: 38px; background: linear-gradient(135deg, #3B82F6, #8B5CF6); border-radius: 10px; display: flex; align-items: center; justify-content: center; font-size: 20px; font-weight: 900; color: #FFF; box-shadow: 0 4px 14px rgba(59, 130, 246, 0.4);">
                        R
                      </div>
                      <div>
                        <div style="font-size: 22px; font-weight: 800; letter-spacing: -0.04em; color: ${vm.isDarkMode ? '#F8FAFC' : '#0F172A'}; line-height: 1.1;">
                          Read<span style="color: #3B82F6;">More</span>
                        </div>
                        <div style="font-size: 10px; font-weight: 600; text-transform: uppercase; letter-spacing: 0.12em; color: #64748B;">
                          Global News & Intelligence
                        </div>
                      </div>
                    </div>
                  '''),
                ],
              ),
            ),

            // Fluid Responsive Search Bar (Desktop / Tablet)
            if (!isMobile)
              Expanded(
                child: FDContainer(
                  margin: EdgeInsets.symmetric(horizontal: isTablet ? 8 : 16),
                  child: FDCenter(
                    child: FDConstrainedBox(
                      constraints: BoxConstraints(maxWidth: isTablet ? 240 : 420),
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
              ),

            // Header Quick Controls
            FDRow(
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
                          FDRawHTML('''
                            <div style="position: absolute; top: -2px; right: -2px; width: 8px; height: 8px; background: #EF4444; border-radius: 50%; border: 1.5px solid #111827;"></div>
                          '''),
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
                FDRawHTML('''
                  <div style="display: flex; align-items: center; gap: 6px; background: rgba(245, 158, 11, 0.15); border: 1px solid rgba(245, 158, 11, 0.3); padding: 4px 10px; border-radius: 18px; font-size: 12px; font-weight: 800; color: #F59E0B;" title="5-day reading streak!">
                    🔥 5d
                  </div>
                '''),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
