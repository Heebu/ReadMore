import 'package:flartdart/flartdart.dart';
import 'package:news_models/news_models.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/section_header.dart';
import '../../viewmodels/news_app_viewmodel.dart';

/// Comprehensive Personalized User Settings, Reading Analytics,
/// Profile Editor, Security Controls, Pro Subscription Management, and Self-Serve Ad Controls.
class UserSettingsView extends StatefulWidget {
  final NewsAppViewModel vm;
  final bool isMobile;
  final bool isTablet;

  const UserSettingsView({
    required this.vm,
    required this.isMobile,
    required this.isTablet,
    super.key,
  });

  @override
  State<UserSettingsView> createState() => _UserSettingsViewState();
}

class _UserSettingsViewState extends State<UserSettingsView> {
  String _displayNameDraft = '';
  String _currentPasswordDraft = '';
  String _newPasswordDraft = '';

  NewsAppViewModel get vm => widget.vm;
  bool get isMobile => widget.isMobile;
  bool get isTablet => widget.isTablet;

  @override
  void initState() {
    super.initState();
    _displayNameDraft = widget.vm.currentUser.displayName;
  }

  @override
  Widget build(BuildContext context) {
    return FDColumn(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Page Title & Back to Headlines
        FDRow(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FDColumn(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(
                  title: 'Profile & Intelligence Settings',
                  isDarkMode: vm.isDarkMode,
                ),
                const FDSizedBox(height: 4),
                const FDText(
                  'Manage your personalized topics, reading streaks, Pro subscription, and ad publishing.',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
              ],
            ),
            FDGestureDetector(
              onTap: () => vm.setActiveScreen('headlines'),
              child: FDContainer(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: vm.isDarkMode ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.borderRegular),
                ),
                child: const FDRow(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FDText('←', style: TextStyle(fontSize: 14)),
                    FDSizedBox(width: 6),
                    FDText('Back to News', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const FDSizedBox(height: 24),

        // Section 1: User Identity & Reading Analytics
        _buildUserProfileCard(context),
        const FDSizedBox(height: 24),

        // Section 2: ReadMore Pro Membership Card
        _buildProMembershipCard(context),
        const FDSizedBox(height: 24),

        // Section 3: Topic & Interest Personalization
        _buildTopicPersonalizationCard(context),
        const FDSizedBox(height: 24),

        // Section 4: Reading Experience & Audio Controls
        _buildReadingPreferencesCard(context),
        const FDSizedBox(height: 24),

        // Section 5: Self-Serve Ads Publisher & Campaign Controls
        _buildAdCampaignControlsCard(context),
      ],
    );
  }

  Widget _buildUserProfileCard(BuildContext context) {
    final user = vm.currentUser;

    return FDContainer(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: vm.isDarkMode ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderRegular),
      ),
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
                  // User Avatar Monogram Seal
                  FDContainer(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: vm.isDarkMode ? FlartColors.white : FlartColors.black,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: vm.isDarkMode ? const FlartColor('#C8C6BD') : const FlartColor('#333333'),
                        width: 2,
                      ),
                    ),
                    child: FDCenter(
                      child: FDText(
                        user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : 'U',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Cinzel',
                          color: vm.isDarkMode ? FlartColors.black : FlartColors.white,
                        ),
                      ),
                    ),
                  ),
                  const FDSizedBox(width: 16),
                  FDColumn(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FDRow(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FDText(
                            user.displayName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: vm.isDarkMode ? FlartColors.white : FlartColors.black,
                            ),
                          ),
                          const FDSizedBox(width: 8),
                          if (user.isPro)
                            FDContainer(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: vm.isDarkMode ? FlartColors.white : FlartColors.black,
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: FDText(
                                'PRO ✦',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'Space Grotesk',
                                  color: vm.isDarkMode ? FlartColors.black : FlartColors.white,
                                ),
                              ),
                            )
                          else
                            FDContainer(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.borderSubtle,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const FDText(
                                'Free Reader',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textMuted),
                              ),
                            ),
                        ],
                      ),
                      const FDSizedBox(height: 4),
                      FDText(
                        user.email,
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),

              // Sign Out or Sign In Button
              if (vm.isAuthenticated)
                FDGestureDetector(
                  onTap: () => vm.signOut(),
                  child: FDContainer(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const FlartColor('rgba(239, 68, 68, 0.1)'),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const FlartColor('rgba(239, 68, 68, 0.3)')),
                    ),
                    child: const FDRow(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FDIcon(icon: 'logout', size: 14, color: AppColors.bearRed),
                        FDSizedBox(width: 6),
                        FDText('Sign Out', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.bearRed)),
                      ],
                    ),
                  ),
                )
              else
                FDGestureDetector(
                  onTap: () => vm.openAuthModal(),
                  child: FDContainer(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const FDText(
                      'Sign In / Register',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: FlartColors.white),
                    ),
                  ),
                ),
            ],
          ),
          const FDSizedBox(height: 20),
          const FDDivider(color: AppColors.borderSubtle),
          const FDSizedBox(height: 16),

          // Reading Metrics Stat Strip
          FDRow(
            children: [
              _buildStatBox('Reading Streak', '${user.readingStreakDays} Days', '🔥', AppColors.accentAmber),
              const FDSizedBox(width: 12),
              _buildStatBox('Articles Read', '${user.articlesReadCount}', '📖', AppColors.primaryBlueLight),
              const FDSizedBox(width: 12),
              _buildStatBox('Time Invested', '${user.articlesReadCount * 4}m', '⏱️', AppColors.accentEmerald),
              const FDSizedBox(width: 12),
              _buildStatBox('Saved in Library', '${vm.bookmarkedIds.length + vm.readLaterIds.length}', '🔖', AppColors.accentPurple),
            ],
          ),

          if (vm.isAuthenticated) ...[
            const FDSizedBox(height: 20),
            const FDDivider(color: AppColors.borderSubtle),
            const FDSizedBox(height: 16),
            _buildAccountEditorSection(context, user),
          ],
        ],
      ),
    );
  }

  Widget _buildAccountEditorSection(BuildContext context, User user) {
    final cities = ['New York', 'London', 'Tokyo', 'Paris', 'Lagos', 'San Francisco'];
    final activeCity = user.preferences.locationCity ?? vm.selectedCity;

    return FDColumn(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const FDText(
          'Edit Profile & Home Dispatch City',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
        ),
        const FDSizedBox(height: 10),
        FDRow(
          children: [
            Expanded(
              child: FDTextField(
                placeholder: user.displayName,
                backgroundColor: vm.isDarkMode ? AppColors.darkInput : AppColors.lightInput,
                borderColor: AppColors.borderRegular,
                borderRadius: 10,
                onChanged: (val) => _displayNameDraft = val,
              ),
            ),
            const FDSizedBox(width: 10),
            FDGestureDetector(
              onTap: () {
                final nextName = _displayNameDraft.trim().isNotEmpty
                    ? _displayNameDraft.trim()
                    : user.displayName;
                vm.updateUserProfile(displayName: nextName, locationCity: activeCity);
              },
              child: FDContainer(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                decoration: BoxDecoration(
                  color: vm.isDarkMode ? FlartColors.white : FlartColors.black,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FDText(
                  'SAVE PROFILE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Space Grotesk',
                    color: vm.isDarkMode ? FlartColors.black : FlartColors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        const FDSizedBox(height: 12),
        FDWrap(
          spacing: 8,
          runSpacing: 8,
          children: cities.map((city) {
            final selected = activeCity.toLowerCase() == city.toLowerCase();
            return FDGestureDetector(
              onTap: () => vm.updateUserProfile(locationCity: city),
              child: FDContainer(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: selected
                      ? (vm.isDarkMode ? FlartColors.white : FlartColors.black)
                      : (vm.isDarkMode ? AppColors.darkSurface : AppColors.lightSurface),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderRegular),
                ),
                child: FDText(
                  '📍 $city',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    color: selected
                        ? (vm.isDarkMode ? FlartColors.black : FlartColors.white)
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const FDSizedBox(height: 18),
        const FDText(
          'Security & Passphrase',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
        ),
        const FDSizedBox(height: 10),
        FDRow(
          children: [
            Expanded(
              child: FDTextField(
                placeholder: 'Current password',
                backgroundColor: vm.isDarkMode ? AppColors.darkInput : AppColors.lightInput,
                borderColor: AppColors.borderRegular,
                borderRadius: 10,
                onChanged: (val) => _currentPasswordDraft = val,
              ),
            ),
            const FDSizedBox(width: 10),
            Expanded(
              child: FDTextField(
                placeholder: 'New password (6+ chars)',
                backgroundColor: vm.isDarkMode ? AppColors.darkInput : AppColors.lightInput,
                borderColor: AppColors.borderRegular,
                borderRadius: 10,
                onChanged: (val) => _newPasswordDraft = val,
              ),
            ),
            const FDSizedBox(width: 10),
            FDGestureDetector(
              onTap: () => vm.changePassword(_currentPasswordDraft, _newPasswordDraft),
              child: FDContainer(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                decoration: BoxDecoration(
                  color: vm.isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.borderRegular),
                ),
                child: const FDText(
                  'UPDATE PASSWORD',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, fontFamily: 'Space Grotesk'),
                ),
              ),
            ),
          ],
        ),
        if (vm.profileStatusMessage != null) ...[
          const FDSizedBox(height: 10),
          FDText(
            vm.profileStatusMessage!,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: vm.profileStatusMessage!.startsWith('Error:')
                  ? const FlartColor('#EF4444')
                  : const FlartColor('#10B981'),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildProMembershipCard(BuildContext context) {
    final user = vm.currentUser;
    final isPro = user.isPro;

    return FDContainer(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: vm.isDarkMode ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPro ? AppColors.accentPurple : AppColors.borderRegular,
          width: isPro ? 2 : 1,
        ),
      ),
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
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isPro
                          ? const FlartColor('rgba(139, 92, 246, 0.2)')
                          : const FlartColor('rgba(59, 130, 246, 0.15)'),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: FDText(isPro ? '👑' : '⚡', style: const TextStyle(fontSize: 22)),
                  ),
                  const FDSizedBox(width: 14),
                  FDColumn(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FDRow(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FDText(
                            isPro ? 'ReadMore Pro Membership' : 'ReadMore Pro',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                          ),
                          const FDSizedBox(width: 8),
                          FDContainer(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: isPro
                                  ? const FlartColor('rgba(16, 185, 129, 0.2)')
                                  : const FlartColor('rgba(245, 158, 11, 0.2)'),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: FDText(
                              isPro ? 'Active' : 'Upgrade Available',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: isPro ? AppColors.accentEmerald : AppColors.accentAmber,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const FDSizedBox(height: 4),
                      FDText(
                        isPro
                            ? 'Renews automatically on November 20, 2027  ●  Annual Pro Plan'
                            : 'Remove all ads, unlock neural AI audio voice briefings, and access deep market analytics.',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),

              // Action: Upgrade to Pro or Manage
              if (!isPro)
                FDGestureDetector(
                  onTap: () => vm.openSubscriptionModal(),
                  child: FDContainer(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: vm.isDarkMode ? FlartColors.white : FlartColors.black,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: FDRow(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FDText(
                          'UPGRADE TO PRO — \$4.99/MO',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'Space Grotesk',
                            letterSpacing: 0.08,
                            color: vm.isDarkMode ? FlartColors.black : FlartColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                FDRow(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Ad-Free Switch
                    FDGestureDetector(
                      onTap: () => vm.toggleAdFree(),
                      child: FDContainer(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: user.adFreeEnabled
                              ? const FlartColor('rgba(16, 185, 129, 0.15)')
                              : AppColors.borderSubtle,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: user.adFreeEnabled ? AppColors.accentEmerald : AppColors.borderRegular,
                          ),
                        ),
                        child: FDRow(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FDText(
                              user.adFreeEnabled ? '🛡️ Ad-Free: ON' : '🛡️ Ad-Free: OFF',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: user.adFreeEnabled ? AppColors.accentEmerald : AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const FDSizedBox(width: 10),
                    FDGestureDetector(
                      onTap: () => vm.cancelSubscription(),
                      child: FDContainer(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.borderSubtle,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const FDText(
                          'Cancel Pro',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopicPersonalizationCard(BuildContext context) {
    final interests = vm.availableInterests;
    final userInterests = vm.userInterests;

    return FDContainer(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: vm.isDarkMode ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderRegular),
      ),
      child: FDColumn(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FDText('Topic & Intelligence Preferences', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const FDSizedBox(height: 4),
          const FDText(
            'Select the topics that matter most. We tune the For You algorithmic feed based on your choices.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const FDSizedBox(height: 16),

          // Interactive Topics Wrap
          FDWrap(
            spacing: 8,
            runSpacing: 8,
            children: interests.map((topic) {
              final isFollowed = userInterests.contains(topic);

              return FDGestureDetector(
                onTap: () => vm.toggleInterest(topic),
                child: FDContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: isFollowed
                        ? AppColors.primaryBlue
                        : (vm.isDarkMode ? AppColors.darkSurface : AppColors.lightSurface),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isFollowed ? AppColors.primaryBlue : AppColors.borderRegular,
                      width: 1,
                    ),
                  ),
                  child: FDRow(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FDText(
                        isFollowed ? '✓ ' : '+ ',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isFollowed ? FlartColors.white : AppColors.primaryBlueLight,
                        ),
                      ),
                      FDText(
                        topic,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isFollowed ? FontWeight.w800 : FontWeight.w600,
                          color: isFollowed
                              ? FlartColors.white
                              : (vm.isDarkMode ? FlartColors.white : FlartColors.black),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildReadingPreferencesCard(BuildContext context) {
    final prefs = vm.currentUser.preferences;

    return FDContainer(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: vm.isDarkMode ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderRegular),
      ),
      child: FDColumn(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FDText('Reading Experience & Notifications', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const FDSizedBox(height: 4),
          const FDText(
            'Control automated audio narration, alert delivery, and local edition routing.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const FDSizedBox(height: 16),

          _buildToggleRow(
            'Neural Audio Narration Autoplay',
            'Automatically begin spoken audio brief when opening full coverage stories.',
            prefs.audioAutoplay,
            (val) => vm.updateUserProfile(audioAutoplay: val),
          ),
          const FDDivider(color: AppColors.borderSubtle),
          _buildToggleRow(
            'Breaking News Critical Alerts',
            'Receive real-time banners for geopolitical, market, and environmental events.',
            prefs.enableBreakingAlerts,
            (val) => vm.updateUserProfile(breakingAlerts: val),
          ),
          const FDDivider(color: AppColors.borderSubtle),
          _buildToggleRow(
            'Daily Intelligence Briefing',
            'Pin morning summary briefing to the bottom dock at 08:00 AM local time.',
            prefs.enableDailyBriefing,
            (val) => vm.updateUserProfile(dailyBriefing: val),
          ),
        ],
      ),
    );
  }

  Widget _buildAdCampaignControlsCard(BuildContext context) {
    final ads = vm.ads;
    final totalImpressions = ads.fold<int>(0, (sum, a) => sum + a.impressions);
    final totalClicks = ads.fold<int>(0, (sum, a) => sum + a.clicks);
    final avgCtr = totalImpressions > 0 ? (totalClicks / totalImpressions) * 100 : 0.0;

    return FDContainer(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: vm.isDarkMode ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderRegular),
      ),
      child: FDColumn(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FDRow(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FDColumn(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  FDText('Sponsored Campaigns & Publisher Controls', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  FDSizedBox(height: 4),
                  FDText(
                    'Deploy self-serve native in-feed stories and Google Ads directly to the live platform feed.',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
              FDGestureDetector(
                onTap: () => vm.openAdPublisherModal(),
                child: FDContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(
                        color: FlartColor('rgba(59, 130, 246, 0.35)'),
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const FDRow(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FDText('🚀', style: TextStyle(fontSize: 12)),
                      FDSizedBox(width: 6),
                      FDText(
                        'Create Campaign',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: FlartColors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const FDSizedBox(height: 20),

          // Publisher Metrics Bar
          FDRow(
            children: [
              _buildPublisherStat('Active Campaigns', '${ads.length}', '📊'),
              const FDSizedBox(width: 12),
              _buildPublisherStat('Total Impressions', '$totalImpressions', '👁️'),
              const FDSizedBox(width: 12),
              _buildPublisherStat('Total Clicks', '$totalClicks', '🖱️'),
              const FDSizedBox(width: 12),
              _buildPublisherStat('Average CTR', '${avgCtr.toStringAsFixed(2)}%', '📈'),
            ],
          ),
          const FDSizedBox(height: 20),

          // Active Campaigns List
          FDColumn(
            children: ads.take(4).map((ad) {
              return FDContainer(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: vm.isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: FDRow(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FDRow(
                      children: [
                        FDContainer(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: ad.format == AdFormat.googleAdSense
                                ? const FlartColor('rgba(59, 130, 246, 0.15)')
                                : const FlartColor('rgba(139, 92, 246, 0.15)'),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: FDText(
                            ad.format == AdFormat.googleAdSense ? 'Google Ad' : 'Native Story',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: ad.format == AdFormat.googleAdSense ? AppColors.primaryBlueLight : AppColors.accentPurple,
                            ),
                          ),
                        ),
                        const FDSizedBox(width: 12),
                        FDColumn(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FDText(
                              ad.title,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            FDText(
                              'Sponsor: ${ad.sponsorName}  ●  Category: ${ad.targetCategory.toUpperCase()}',
                              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ],
                    ),
                    FDRow(
                      children: [
                        FDColumn(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            FDText(
                              '${ad.impressions} impr  ●  ${ad.clicks} clicks',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            FDText(
                              'CTR: ${ad.clickThroughRate.toStringAsFixed(2)}%  ●  \$${ad.dailyBudget.toInt()}/day',
                              style: const TextStyle(fontSize: 11, color: AppColors.accentEmerald),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(String title, String value, String icon, FlartColor accent) {
    return Expanded(
      child: FDContainer(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: vm.isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: FDColumn(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FDRow(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FDText(title, style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
                FDText(icon, style: const TextStyle(fontSize: 14)),
              ],
            ),
            const FDSizedBox(height: 6),
            FDText(
              value,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: accent),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPublisherStat(String title, String value, String icon) {
    return Expanded(
      child: FDContainer(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: vm.isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: FDColumn(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FDRow(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FDText(title, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                FDText(icon, style: const TextStyle(fontSize: 12)),
              ],
            ),
            const FDSizedBox(height: 4),
            FDText(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primaryBlueLight),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleRow(String title, String subtitle, bool isEnabled, Function(bool) onChanged) {
    return FDPadding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: FDRow(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: FDColumn(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FDText(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                const FDSizedBox(height: 2),
                FDText(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
              ],
            ),
          ),
          FDGestureDetector(
            onTap: () => onChanged(!isEnabled),
            child: FDContainer(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isEnabled ? AppColors.primaryBlue : AppColors.borderSubtle,
                borderRadius: BorderRadius.circular(16),
              ),
              child: FDText(
                isEnabled ? 'ENABLED' : 'DISABLED',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: isEnabled ? FlartColors.white : AppColors.textMuted,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
