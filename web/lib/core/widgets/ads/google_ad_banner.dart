import 'package:flartdart/flartdart.dart';
import '../../../viewmodels/news_app_viewmodel.dart';
import '../../constants/app_colors.dart';

/// Responsive Google AdSense Leaderboard Banner (728x90 desktop / responsive on mobile).
/// Automatically integrates with NewsAppViewModel to respect Pro ad-free preferences.
class GoogleAdBanner extends StatelessWidget {
  final NewsAppViewModel vm;
  final bool isMobile;
  final String? category;

  const GoogleAdBanner({
    required this.vm,
    required this.isMobile,
    this.category,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (!vm.showAds) {
      return const FDSizedBox.shrink();
    }

    final ad = vm.getLeaderboardAd(category: category);
    if (ad == null) {
      return const FDSizedBox.shrink();
    }

    return FDContainer(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 20,
        vertical: isMobile ? 10 : 12,
      ),
      decoration: BoxDecoration(
        color: vm.isDarkMode
            ? const FlartColor('#15161C')
            : const FlartColor('#FAF9F5'),
        borderRadius: BorderRadius.circular(2),
        border: Border.all(
          color: vm.isDarkMode
              ? const FlartColor('#33353F')
              : const FlartColor('#C8C4B7'),
          width: 1,
        ),
      ),
      child: FDColumn(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Ad Header Label & Google AdChoices Badge
          FDWrap(
            alignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 6,
            cssStyle: const {'width': '100%', 'max-width': '100%'},
            children: [
              FDWrap(
                spacing: 8,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  FDContainer(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: vm.isDarkMode ? const FlartColor('#0D0E11') : const FlartColor('#FFFFFF'),
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(
                        color: vm.isDarkMode ? FlartColors.white : FlartColors.black,
                        width: 1,
                      ),
                    ),
                    child: FDText(
                      '[ COMMERCIAL NOTICE · GOOGLE AD ]',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Space Grotesk',
                        color: vm.isDarkMode ? FlartColors.white : FlartColors.black,
                        letterSpacing: 0.08,
                      ),
                    ),
                  ),
                  FDText(
                    ad.sponsorName.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Space Grotesk',
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              // Ad-Free Pro Shortcut
              FDGestureDetector(
                onTap: () => vm.openSubscriptionModal(),
                child: FDContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  child: FDRow(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const FDText('✦', style: TextStyle(fontSize: 10)),
                      const FDSizedBox(width: 4),
                      FDText(
                        'AD-FREE WITH PRO',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Space Grotesk',
                          letterSpacing: 0.06,
                          color: vm.isDarkMode ? const FlartColor('#A2A096') : const FlartColor('#4A4842'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const FDSizedBox(height: 8),

          // Banner Content: Headline + Description + Call to Action
          FDRow(
            crossAxisAlignment: CrossAxisAlignment.center,
            cssStyle: isMobile ? const {'flex-wrap': 'wrap', 'gap': '10px'} : null,
            children: [
              if (ad.sponsorLogoUrl != null && !isMobile) ...[
                FDContainer(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: vm.isDarkMode
                        ? const FlartColor('#1E293B')
                        : FlartColors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.borderRegular),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: FDImage.network(
                    ad.sponsorLogoUrl!,
                    width: 38,
                    height: 38,
                    fit: BoxFit.contain,
                    cssStyle: const {
                      'width': '38px',
                      'height': '38px',
                      'object-fit': 'contain',
                      'display': 'block',
                    },
                  ),
                ),
                const FDSizedBox(width: 14),
              ],
              Expanded(
                child: FDColumn(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FDText(
                      ad.title,
                      style: TextStyle(
                        fontSize: isMobile ? 13 : 15,
                        fontWeight: FontWeight.w700,
                        color: vm.isDarkMode
                            ? FlartColors.white
                            : FlartColors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const FDSizedBox(height: 2),
                    FDText(
                      ad.description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                      maxLines: isMobile ? 1 : 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const FDSizedBox(width: 14),
              FDGestureDetector(
                onTap: () => vm.recordAdClick(ad.id),
                child: FDContainer(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 10 : 16,
                    vertical: isMobile ? 6 : 8,
                  ),
                  decoration: BoxDecoration(
                    color: vm.isDarkMode ? FlartColors.white : FlartColors.black,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  cssStyle: const {
                    'transition': 'all 0.2s ease',
                    'cursor': 'pointer',
                  },
                  child: FDRow(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FDText(
                        ad.callToAction.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Space Grotesk',
                          letterSpacing: 0.06,
                          color: vm.isDarkMode ? FlartColors.black : FlartColors.white,
                        ),
                      ),
                      const FDSizedBox(width: 4),
                      FDText(
                        '↗',
                        style: TextStyle(
                          fontSize: 11,
                          color: vm.isDarkMode ? FlartColors.black : FlartColors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
