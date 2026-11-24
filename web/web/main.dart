import 'package:flartdart/flartdart.dart';
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
class ReadMoreApp extends StatelessWidget {
  const ReadMoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FDConsumer<NewsAppViewModel>(
      builder: (context, vm, _) {
        final media = MediaQuery.of(context);
        final isMobile = media.isSmall;
        final isTablet = media.isMedium;

        return FDMaterialApp(
          title: 'ReadMore — Global News & Intelligence',
          debugShowCheckedModeBanner: false,
          home: FDScaffold(
            cssStyle: {
              'background': vm.isDarkMode ? '#090D16' : '#F8FAFC',
              'color': vm.isDarkMode ? '#F8FAFC' : '#0F172A',
            },
            body: FDStack(
              children: [
                // Scrollable Application Shell
                FDSingleChildScrollView(
                  child: FDColumn(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    cssStyle: const {'width': '100%'},
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
                  ReaderViewModal(vm: vm, isMobile: isMobile),

                if (vm.showFullCoverageModal)
                  FullCoverageModal(vm: vm, isMobile: isMobile),

                if (vm.showInterestsModal)
                  InterestsModal(vm: vm, isMobile: isMobile),

                if (vm.showNotificationsModal)
                  NotificationsPopover(vm: vm, isMobile: isMobile),

                if (vm.showEditionModal)
                  EditionModal(vm: vm, isMobile: isMobile),

                if (vm.showAuthModal)
                  AuthModal(vm: vm, isMobile: isMobile),

                if (vm.showSubscriptionModal)
                  SubscriptionModal(vm: vm, isMobile: isMobile),

                if (vm.showAdPublisherModal)
                  AdPublisherModal(vm: vm, isMobile: isMobile),
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
