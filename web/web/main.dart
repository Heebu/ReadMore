import 'package:flartdart/flartdart.dart';
import 'package:read_more_web/core/utils/web_dom_helper.dart';
import 'package:read_more_web/core/widgets/app_footer.dart';
import 'package:read_more_web/core/widgets/app_header.dart';
import 'package:read_more_web/core/widgets/breaking_ticker.dart';
import 'package:read_more_web/core/widgets/centered_shell.dart';
import 'package:read_more_web/core/widgets/primary_nav_ribbon.dart';
import 'package:read_more_web/core/widgets/utility_ribbon.dart';
import 'package:read_more_web/viewmodels/news_app_viewmodel.dart';
import 'package:read_more_web/views/explore/explore_view.dart';
import 'package:read_more_web/views/for_you/for_you_view.dart';
import 'package:read_more_web/views/headlines/headlines_view.dart';
import 'package:read_more_web/views/library/library_view.dart';
import 'package:read_more_web/views/local/local_news_view.dart';
import 'package:read_more_web/views/markets/markets_view.dart';
import 'package:read_more_web/views/overlays/ad_publisher_modal.dart';
import 'package:read_more_web/views/overlays/auth_modal.dart';
import 'package:read_more_web/views/overlays/edition_modal.dart';
import 'package:read_more_web/views/overlays/full_coverage_modal.dart';
import 'package:read_more_web/views/overlays/interests_modal.dart';
import 'package:read_more_web/views/overlays/notifications_popover.dart';
import 'package:read_more_web/views/overlays/reader_view_modal.dart';
import 'package:read_more_web/views/overlays/sticky_audio_player.dart';
import 'package:read_more_web/views/overlays/subscription_modal.dart';
import 'package:read_more_web/views/profile/user_settings_view.dart';

void main() {
  ScreenUtil.init(width: 1440, height: 900);
  runApp(
    FDChangeNotifierProvider<NewsAppViewModel>(
      create: (_) => NewsAppViewModel(),
      child: const ReadMoreApp(),
    ),
  );
}

/// Clean Flutter MVVM Root Application Widget
class ReadMoreApp extends StatefulWidget {
  const ReadMoreApp({super.key});

  @override
  State<ReadMoreApp> createState() => _ReadMoreAppState();
}

class _ReadMoreAppState extends State<ReadMoreApp> {
  Object? _resizeSub;
  num? _lastWidth;

  @override
  void initState() {
    super.initState();
    _resizeSub = addWindowResizeListener(() {
      final w = MediaQuery.of(context).width;
      if (_lastWidth == null || (_lastWidth! < 600) != (w < 600) || (_lastWidth! < 1024) != (w < 1024)) {
        _lastWidth = w;
        if (mounted) {
          setState(() {});
        }
      }
    });
  }

  @override
  void dispose() {
    removeWindowResizeListener(_resizeSub);
    _resizeSub = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FDConsumer<NewsAppViewModel>(
      builder: (context, vm, _) {
        final media = MediaQuery.of(context);
        _lastWidth = media.width;
        final isMobile = media.isSmall;
        final isTablet = media.isMedium;

        return FDMaterialApp(
          title: 'ReadMore — Global News & Intelligence',
          favicon:
              'data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32"><circle cx="16" cy="16" r="16" fill="%23111111"/><text x="16" y="22" text-anchor="middle" fill="%23F4F3EE" font-size="18" font-family="Georgia,serif" font-weight="bold">R</text></svg>',
          debugShowCheckedModeBanner: false,
          home: FDScaffold(
            cssStyle: {
              'background': vm.isDarkMode ? '#0D0E11' : '#F7F5F0',
              'color': vm.isDarkMode ? '#F4F3EE' : '#111111',
              'width': '100%',
              'max-width': '100%',
            },
            body: FDStack(
              children: [
                // Scrollable Application Shell
                FDSingleChildScrollView(
                  child: FDColumn(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    cssStyle: const {'width': '100%', 'min-width': '0', 'max-width': '100%'},
                    children: [
                      // 1. MSN-Style Utility Ribbon
                      UtilityRibbon(vm: vm, isMobile: isMobile, isTablet: isTablet),

                      // 2. Main Brand Header & Navigation
                      AppHeader(vm: vm, isMobile: isMobile, isTablet: isTablet),

                      // 3. Primary Screen Flow Navigation Tabs
                      PrimaryNavRibbon(vm: vm, isMobile: isMobile),

                      // 4. Breaking News Live Ribbon (Shown on Headlines & For You)
                      if (vm.activeScreen == 'headlines' || vm.activeScreen == 'for_you')
                        BreakingTicker(vm: vm, isMobile: isMobile),

                      // 5. Active View (Responsive Centered Shell with 1400px Max-Width)
                      CenteredShell(
                        maxWidth: 1400,
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 12 : (isTablet ? 20 : 28),
                          vertical: 24,
                        ),
                        child: _buildActiveView(vm, isMobile, isTablet),
                      ),

                      // 6. Technology-free Editorial Footer
                      AppFooter(isMobile: isMobile, isDarkMode: vm.isDarkMode),

                      // Bottom spacing for sticky audio briefing player
                      if (vm.showBottomBriefing) const FDSizedBox(height: 72),
                    ],
                  ),
                ),

                // Persistent Bottom Audio Briefing Player
                if (vm.showBottomBriefing)
                  StickyAudioPlayer(vm: vm, isMobile: isMobile),

                // Modal Overlays
                if (vm.activeReadingArticle != null)
                  ReaderViewModal(
                    key: const ValueKey('overlay-reader'),
                    vm: vm,
                    isMobile: isMobile,
                  ),

                if (vm.showFullCoverageModal)
                  FullCoverageModal(
                    key: const ValueKey('overlay-full-coverage'),
                    vm: vm,
                    isMobile: isMobile,
                  ),

                if (vm.showInterestsModal)
                  InterestsModal(
                    key: const ValueKey('overlay-interests'),
                    vm: vm,
                    isMobile: isMobile,
                  ),

                if (vm.showNotificationsModal)
                  NotificationsPopover(
                    key: const ValueKey('overlay-notifications'),
                    vm: vm,
                    isMobile: isMobile,
                  ),

                if (vm.showEditionModal)
                  EditionModal(
                    key: const ValueKey('overlay-edition'),
                    vm: vm,
                    isMobile: isMobile,
                  ),

                if (vm.showAuthModal)
                  AuthModal(
                    key: const ValueKey('overlay-auth'),
                    vm: vm,
                    isMobile: isMobile,
                  ),

                if (vm.showSubscriptionModal)
                  SubscriptionModal(
                    key: const ValueKey('overlay-subscription'),
                    vm: vm,
                    isMobile: isMobile,
                  ),

                if (vm.showAdPublisherModal)
                  AdPublisherModal(
                    key: const ValueKey('overlay-ad-publisher'),
                    vm: vm,
                    isMobile: isMobile,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActiveView(NewsAppViewModel vm, bool isMobile, bool isTablet) {
    switch (vm.activeScreen) {
      case 'for_you':
        return ForYouView(vm: vm, isMobile: isMobile, isTablet: isTablet);
      case 'local':
        return LocalNewsView(vm: vm, isMobile: isMobile, isTablet: isTablet);
      case 'markets':
        return MarketsView(vm: vm, isMobile: isMobile, isTablet: isTablet);
      case 'library':
        return LibraryView(vm: vm, isMobile: isMobile, isTablet: isTablet);
      case 'explore':
        return ExploreView(vm: vm, isMobile: isMobile, isTablet: isTablet);
      case 'profile':
        return UserSettingsView(vm: vm, isMobile: isMobile, isTablet: isTablet);
      case 'headlines':
      default:
        return HeadlinesView(vm: vm, isMobile: isMobile, isTablet: isTablet);
    }
  }
}
