import 'package:flartdart/flartdart.dart';
import '../../viewmodels/news_app_viewmodel.dart';
import '../constants/app_colors.dart';
import 'centered_shell.dart';

/// Top MSN-style utility ribbon for live weather, market quotes, and edition.
class UtilityRibbon extends StatelessWidget {
  final NewsAppViewModel vm;
  final bool isMobile;
  final bool isTablet;

  const UtilityRibbon({
    required this.vm,
    required this.isMobile,
    required this.isTablet,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final weather = vm.currentWeather;

    return FDContainer(
      width: double.infinity,
      decoration: BoxDecoration(
        color: vm.isDarkMode ? AppColors.darkRibbon : AppColors.lightRibbon,
        border: const Border(bottom: BorderSide(color: AppColors.borderSubtle, width: 1)),
      ),
      child: CenteredShell(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 28, vertical: 8),
        child: FDRow(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left: Date & Weather Clickable Pill
            FDGestureDetector(
              onTap: () => vm.setActiveScreen('local'),
              child: FDRow(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FDText(
                    '📅 Monday, Nov 23, 2026',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: vm.isDarkMode ? AppColors.textSecondary : const FlartColor('#475569'),
                    ),
                  ),
                  const FDSizedBox(width: 8),
                  const FDText('|', style: TextStyle(fontSize: 12, color: AppColors.borderRegular)),
                  const FDSizedBox(width: 8),
                  FDContainer(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlueSubtle,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: FDRow(
                      children: [
                        const FDText('📍 ', style: TextStyle(fontSize: 11)),
                        FDText(
                          '${vm.selectedCity} ${weather.temperatureC.toInt()}°C (${weather.condition})',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlueLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Right: Real-time Mini Stock Ticker (Desktop only) & Edition Badge
            if (!isMobile)
              FDRow(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (!isTablet)
                    FDGestureDetector(
                      onTap: () => vm.setActiveScreen('markets'),
                      child: FDContainer(
                        margin: const EdgeInsets.only(right: 14),
                        child: FDRow(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: const [
                            FDText(
                              '▲ S&P 5,984 (+0.72%)',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.bullGreen),
                            ),
                            FDSizedBox(width: 12),
                            FDText(
                              '▲ BTC \$98,650 (+3.65%)',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.bullGreen),
                            ),
                            FDSizedBox(width: 12),
                            FDText(
                              '▲ NVDA \$148.90 (+2.45%)',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.bullGreen),
                            ),
                          ],
                        ),
                      ),
                    ),
                  FDGestureDetector(
                    onTap: () => vm.openEditionModal(),
                    child: FDContainer(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlueSubtle,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.borderHighlighted, width: 1),
                      ),
                      child: FDRow(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const FDText('🌐 ', style: TextStyle(fontSize: 10)),
                          FDText(
                            vm.selectedEdition,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryBlueLight),
                          ),
                        ],
                      ),
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
