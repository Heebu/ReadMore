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
      decoration: BoxDecoration(
        color: vm.isDarkMode ? AppColors.darkRibbon : AppColors.lightRibbon,
        border: const Border(bottom: BorderSide(color: AppColors.borderSubtle, width: 1)),
      ),
      child: CenteredShell(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 28, vertical: 8),
        child: FDRow(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left: Date & Weather Clickable Pill
            FDGestureDetector(
              onTap: () => vm.setActiveScreen('local'),
              child: FDRow(
                children: [
                  FDRawHTML('''
                    <div style="display: flex; align-items: center; gap: 8px; font-size: 12px; color: ${vm.isDarkMode ? '#94A3B8' : '#475569'};">
                      <span>📅 <b>Monday, Nov 23, 2026</b></span>
                      <span style="opacity: 0.4;">|</span>
                      <span style="display: inline-flex; align-items: center; gap: 4px; background: rgba(59, 130, 246, 0.12); padding: 2px 8px; border-radius: 12px; color: #60A5FA; font-weight: 600; cursor: pointer; white-space: nowrap;">
                        📍 ${vm.selectedCity} ${weather.temperatureC.toInt()}°C (${weather.condition})
                      </span>
                    </div>
                  '''),
                ],
              ),
            ),

            // Right: Real-time Mini Stock Ticker (Desktop only) & Edition Badge
            if (!isMobile)
              FDRow(
                children: [
                  if (!isTablet)
                    FDGestureDetector(
                      onTap: () => vm.setActiveScreen('markets'),
                      child: FDRawHTML('''
                        <div style="display: flex; align-items: center; gap: 12px; font-size: 11px; font-family: monospace; cursor: pointer; margin-right: 14px; white-space: nowrap; overflow: hidden;">
                          <span style="color: #10B981; font-weight: bold;">▲ S&P 5,984 (+0.72%)</span>
                          <span style="color: #10B981; font-weight: bold;">▲ BTC \$98,650 (+3.65%)</span>
                          <span style="color: #10B981; font-weight: bold;">▲ NVDA \$148.90 (+2.45%)</span>
                        </div>
                      '''),
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
