import 'package:flartdart/flartdart.dart';
import '../../viewmodels/news_app_viewmodel.dart';
import '../constants/app_colors.dart';
import 'centered_shell.dart';

/// Navigation ribbon for primary view modes: Headlines, For You, Local, Markets, Library, Explore.
class PrimaryNavRibbon extends StatelessWidget {
  final NewsAppViewModel vm;
  final bool isMobile;

  const PrimaryNavRibbon({
    required this.vm,
    required this.isMobile,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final navItems = [
      {'id': 'headlines', 'name': 'FRONT PAGE', 'icon': '✦'},
      {'id': 'for_you', 'name': 'CURATED', 'icon': '✦'},
      {'id': 'local', 'name': 'CITY CHRONICLE', 'icon': '✦'},
      {'id': 'markets', 'name': 'FINANCE & TRADE', 'icon': '✦'},
      {'id': 'library', 'name': 'THE ARCHIVE', 'icon': '✦', 'badge': '${vm.bookmarkedIds.length + vm.readLaterIds.length}'},
      {'id': 'explore', 'name': 'TOPICS & SEARCH', 'icon': '✦'},
      {'id': 'profile', 'name': 'SUBSCRIBER DESK', 'icon': '✦'},
    ];

    return FDContainer(
      width: double.infinity,
      decoration: BoxDecoration(
        color: vm.isDarkMode ? AppColors.darkNav : AppColors.lightNav,
        border: Border(
          bottom: BorderSide(
            color: vm.isDarkMode ? const FlartColor('#2A2B33') : const FlartColor('#D4CFBE'),
            width: 1,
          ),
        ),
      ),
      child: CenteredShell(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 28, vertical: 7),
        child: FDSingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: FDRow(
            mainAxisSize: MainAxisSize.min,
            children: navItems.map((item) {
              final isSelected = vm.activeScreen == item['id'];
              final badge = item['badge'];

              return FDGestureDetector(
                onTap: () => vm.setActiveScreen(item['id']!),
                child: FDContainer(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (vm.isDarkMode ? FlartColors.white : FlartColors.black)
                        : (vm.isDarkMode ? const FlartColor('#17181E') : const FlartColor('#FAF9F5')),
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(
                      color: isSelected
                          ? (vm.isDarkMode ? FlartColors.white : FlartColors.black)
                          : (vm.isDarkMode ? const FlartColor('#2D2F38') : const FlartColor('#C8C4B6')),
                      width: 1,
                    ),
                  ),
                  cssStyle: const {
                    'transition': 'all 0.18s ease',
                    'cursor': 'pointer',
                  },
                  child: FDRow(
                    children: [
                      FDText(
                        item['name']!,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                          fontFamily: 'Space Grotesk',
                          letterSpacing: 0.08,
                          color: isSelected
                              ? (vm.isDarkMode ? FlartColors.black : FlartColors.white)
                              : (vm.isDarkMode ? const FlartColor('#EAE8E0') : const FlartColor('#222222')),
                        ),
                      ),
                      if (badge != null && badge != '0') ...[
                        const FDSizedBox(width: 6),
                        FDContainer(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (vm.isDarkMode ? const FlartColor('#E2DFD2') : const FlartColor('#222222'))
                                : (vm.isDarkMode ? const FlartColor('#2A2B33') : const FlartColor('#E2DFD2')),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: FDText(
                            badge,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Space Grotesk',
                              color: isSelected
                                  ? (vm.isDarkMode ? FlartColors.black : FlartColors.white)
                                  : (vm.isDarkMode ? FlartColors.white : FlartColors.black),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
