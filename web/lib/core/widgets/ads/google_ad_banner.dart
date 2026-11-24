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
            ? const FlartColor('#0D1524')
            : const FlartColor('#F1F5F9'),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: vm.isDarkMode
              ? const FlartColor('rgba(255, 255, 255, 0.08)')
              : const FlartColor('rgba(0, 0, 0, 0.08)'),
          width: 1,
        ),
      ),
      child: FDColumn(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Ad Header Label & Google AdChoices Badge
          FDRow(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FDRow(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FDContainer(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const FlartColor('rgba(59, 130, 246, 0.15)'),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const FDText(
                      'Ad · by Google',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryBlueLight,
                        letterSpacing: 0.04,
                      ),
                    ),
                  ),
                  const FDSizedBox(width: 8),
                  FDText(
                    ad.sponsorName,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
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
                    children: const [
                      FDText('⚡', style: TextStyle(fontSize: 10)),
                      FDSizedBox(width: 4),
                      FDText(
                        'Hide ads with Pro',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accentAmber,
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
                    color: AppColors.primaryBlue,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                      BoxShadow(
                        color: FlartColor('rgba(59, 130, 246, 0.3)'),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  cssStyle: const {
                    'transition': 'all 0.2s ease',
                    'cursor': 'pointer',
                  },
                  child: FDRow(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FDText(
                        ad.callToAction,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: FlartColors.white,
                        ),
                      ),
                      const FDSizedBox(width: 4),
                      const FDText(
                        '↗',
                        style: TextStyle(
                          fontSize: 12,
                          color: FlartColors.white,
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
