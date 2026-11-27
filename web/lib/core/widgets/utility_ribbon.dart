import 'package:flartdart/flartdart.dart';
import '../../viewmodels/news_app_viewmodel.dart';
import '../constants/app_colors.dart';
import '../utils/time_formatter.dart';
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
        border: Border(
          bottom: BorderSide(
            color: vm.isDarkMode ? const FlartColor('#262730') : const FlartColor('#D4CFBE'),
            width: 1,
          ),
        ),
      ),
      child: CenteredShell(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 28, vertical: 6),
        child: FDWrap(
          alignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 6,
          cssStyle: const {
            'width': '100%',
            'max-width': '100%',
            'box-sizing': 'border-box',
          },
          children: [
            // Left: Broadsheet Vol/No & Weather Dateline
            FDContainer(
              cssStyle: const {
                'min-width': '0',
                'max-width': '100%',
                'box-sizing': 'border-box',
              },
              child: FDGestureDetector(
                onTap: () => vm.setActiveScreen('local'),
                child: FDWrap(
                  spacing: isMobile ? 6 : 10,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  cssStyle: const {'max-width': '100%'},
                  children: [
                    FDText(
                      'VOL. CXLII No. 59,820  ✦  ${vm.selectedCity.toUpperCase()}, ${formatMastheadDate(DateTime.now())}',
                      style: TextStyle(
                        fontSize: isMobile ? 9 : 10,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Space Grotesk',
                        letterSpacing: isMobile ? 0.04 : 0.08,
                        color: vm.isDarkMode ? const FlartColor('#A2A096') : const FlartColor('#4A4842'),
                      ),
                    ),
                    if (!isMobile)
                      const FDText('·', style: TextStyle(fontSize: 12, color: AppColors.borderRegular)),
                    FDContainer(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: vm.isDarkMode ? const FlartColor('#191A20') : const FlartColor('#E2DED2'),
                        borderRadius: BorderRadius.circular(2),
                        border: Border.all(
                          color: vm.isDarkMode ? const FlartColor('#33353F') : const FlartColor('#C4BFB0'),
                          width: 1,
                        ),
                      ),
                      child: FDRow(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FDText(
                            '${vm.selectedCity.toUpperCase()}: ${weather.temperatureC.toInt()}°C',
                            style: TextStyle(
                              fontSize: isMobile ? 9 : 10,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'Space Grotesk',
                              letterSpacing: 0.06,
                              color: vm.isDarkMode ? FlartColors.white : FlartColors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Right: Real-time Mini Stock Ticker & Edition Badge
            FDContainer(
              cssStyle: const {
                'min-width': '0',
                'max-width': '100%',
                'box-sizing': 'border-box',
              },
              child: FDWrap(
                spacing: 10,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (!isMobile && !isTablet)
                    FDGestureDetector(
                      onTap: () => vm.setActiveScreen('markets'),
                      child: FDContainer(
                        margin: const EdgeInsets.only(right: 4),
                        child: FDRow(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            FDText(
                              'S&P 5,984 ▲0.72%',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Space Grotesk',
                                color: vm.isDarkMode ? const FlartColor('#C8C6BC') : const FlartColor('#333333'),
                              ),
                            ),
                            const FDSizedBox(width: 12),
                            FDText(
                              'BTC \$98,650 ▲3.65%',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Space Grotesk',
                                color: vm.isDarkMode ? const FlartColor('#C8C6BC') : const FlartColor('#333333'),
                              ),
                            ),
                            const FDSizedBox(width: 12),
                            FDText(
                              'BRENT \$74.20 ▼1.15%',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Space Grotesk',
                                color: vm.isDarkMode ? const FlartColor('#C8C6BC') : const FlartColor('#333333'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  FDGestureDetector(
                    onTap: () => vm.openEditionModal(),
                    child: FDContainer(
                      padding: EdgeInsets.symmetric(horizontal: isMobile ? 6 : 8, vertical: isMobile ? 2 : 3),
                      decoration: BoxDecoration(
                        color: vm.isDarkMode ? const FlartColor('#1A1B22') : const FlartColor('#FAF9F5'),
                        borderRadius: BorderRadius.circular(2),
                        border: Border.all(
                          color: vm.isDarkMode ? const FlartColor('#444652') : const FlartColor('#222222'),
                          width: 1,
                        ),
                      ),
                      child: FDRow(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FDText(
                            '[ ${vm.selectedEdition.toUpperCase()} EDITION · FIVE CENTS ]',
                            style: TextStyle(
                              fontSize: isMobile ? 9 : 10,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'Space Grotesk',
                              letterSpacing: isMobile ? 0.04 : 0.08,
                              color: vm.isDarkMode ? FlartColors.white : FlartColors.black,
                            ),
                          ),
                        ],
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
