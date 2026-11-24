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
      {'id': 'headlines', 'name': 'Headlines', 'icon': '📰'},
      {'id': 'for_you', 'name': 'For You', 'icon': '✨'},
      {'id': 'local', 'name': 'Local News', 'icon': '📍'},
      {'id': 'markets', 'name': 'Markets', 'icon': '📈'},
      {'id': 'library', 'name': 'My Library', 'icon': '🔖', 'badge': '${vm.bookmarkedIds.length + vm.readLaterIds.length}'},
      {'id': 'explore', 'name': 'Explore', 'icon': '🔍'},
    ];

    return FDContainer(
      width: double.infinity,
      decoration: BoxDecoration(
        color: vm.isDarkMode ? AppColors.darkNav : AppColors.lightNav,
        border: const Border(bottom: BorderSide(color: AppColors.borderSubtle, width: 1)),
      ),
      child: CenteredShell(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 28, vertical: 8),
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
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryBlue
                        : (vm.isDarkMode ? AppColors.borderSubtle : AppColors.lightSurface),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? AppColors.primaryBlue : AppColors.borderRegular,
                      width: 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            const BoxShadow(
                              color: FlartColor('rgba(59, 130, 246, 0.4)'),
                              blurRadius: 10,
                              offset: Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  cssStyle: const {
                    'transition': 'all 0.22s cubic-bezier(0.16, 1, 0.3, 1)',
                    'cursor': 'pointer',
                  },
                  child: FDRow(
                    children: [
                      FDText(item['icon']!, style: const TextStyle(fontSize: 14)),
                      const FDSizedBox(width: 6),
                      FDText(
                        item['name']!,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected ? FlartColors.white : (vm.isDarkMode ? FlartColors.white : FlartColors.black),
                        ),
                      ),
                      if (badge != null && badge != '0') ...[
                        const FDSizedBox(width: 6),
                        FDContainer(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primaryBlueDark : AppColors.primaryBlueSubtle,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: FDText(
                            badge,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? FlartColors.white : AppColors.primaryBlueLight,
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
