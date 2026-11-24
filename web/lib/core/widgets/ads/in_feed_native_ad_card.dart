import 'package:flartdart/flartdart.dart';
import 'package:news_models/news_models.dart';
import '../../../viewmodels/news_app_viewmodel.dart';
import '../../constants/app_colors.dart';

/// In-Feed Native Sponsored Story card that seamlessly harmonizes with editorial article cards.
class InFeedNativeAdCard extends StatelessWidget {
  final SponsoredAd ad;
  final NewsAppViewModel vm;
  final double imageHeight;

  const InFeedNativeAdCard({
    required this.ad,
    required this.vm,
    this.imageHeight = 180,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (!vm.showAds) {
      return const FDSizedBox.shrink();
    }

    return FDGestureDetector(
      onTap: () => vm.recordAdClick(ad.id),
      child: FDContainer(
        id: 'ad-native-${ad.id}',
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: vm.isDarkMode ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: vm.isDarkMode ? AppColors.borderRegular : const FlartColor('#D4CFBE'),
            width: 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: FlartColor('rgba(0, 0, 0, 0.08)'),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        cssStyle: const {
          'transition': 'transform 0.28s cubic-bezier(0.16, 1, 0.3, 1), box-shadow 0.28s cubic-bezier(0.16, 1, 0.3, 1)',
          'cursor': 'pointer',
        },
        child: FDColumn(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Sponsored Cover Image
            if (ad.imageUrl != null)
              FDStack(
                children: [
                  FDContainer(
                    height: imageHeight,
                    width: double.infinity,
                    clipBehavior: Clip.antiAlias,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.vertical(top: 14),
                    ),
                    child: FDImage.network(
                      ad.imageUrl!,
                      height: imageHeight,
                      fit: BoxFit.cover,
                      cssStyle: {
                        'width': '100%',
                        'height': '${imageHeight}px',
                        'object-fit': 'cover',
                        'display': 'block',
                      },
                    ),
                  ),
                  FDPositioned(
                    top: 10,
                    left: 10,
                    child: FDContainer(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: vm.isDarkMode ? const FlartColor('#0D0E11') : const FlartColor('#FFFFFF'),
                        borderRadius: BorderRadius.circular(2),
                        border: Border.all(
                          color: vm.isDarkMode ? FlartColors.white : FlartColors.black,
                          width: 1,
                        ),
                      ),
                      child: FDText(
                        '[ SPONSORED DISPATCH ]',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Space Grotesk',
                          letterSpacing: 0.08,
                          color: vm.isDarkMode ? FlartColors.white : FlartColors.black,
                        ),
                      ),
                    ),
                  ),
                  FDPositioned(
                    top: 10,
                    right: 10,
                    child: FDContainer(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.darkSurface,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const FDText(
                        'Verified Partner',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.accentEmerald,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

            // Card Body
            FDPadding(
              padding: const EdgeInsets.all(16),
              child: FDColumn(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sponsor Byline
                  FDRow(
                    children: [
                      if (ad.sponsorLogoUrl != null) ...[
                        FDContainer(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: FDImage.network(
                            ad.sponsorLogoUrl!,
                            width: 18,
                            height: 18,
                            fit: BoxFit.contain,
                            cssStyle: const {
                              'width': '18px',
                              'height': '18px',
                              'object-fit': 'contain',
                            },
                          ),
                        ),
                        const FDSizedBox(width: 6),
                      ],
                      FDText(
                        ad.sponsorName,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryBlueLight,
                        ),
                      ),
                      const FDSizedBox(width: 8),
                      const FDText(
                        '● Promoted Story',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const FDSizedBox(height: 10),

                  // Headline in Historic Broadsheet Editorial Serif
                  FDText(
                    ad.title,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Playfair Display',
                      color: vm.isDarkMode ? const FlartColor('#F4F3EE') : const FlartColor('#111111'),
                      height: 1.25,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const FDSizedBox(height: 8),

                  // Description
                  FDText(
                    ad.description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const FDSizedBox(height: 14),

                  // CTA Button Bar
                  FDRow(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FDContainer(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const FlartColor('rgba(59, 130, 246, 0.12)'),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: FDText(
                          'Target: ${ad.targetCategory.toUpperCase()}',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryBlueLight,
                          ),
                        ),
                      ),
                      FDContainer(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: vm.isDarkMode ? FlartColors.white : FlartColors.black,
                          borderRadius: BorderRadius.circular(2),
                        ),
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
                            FDText('↗', style: TextStyle(fontSize: 11, color: vm.isDarkMode ? FlartColors.black : FlartColors.white)),
                          ],
                        ),
                      ),
                    ],
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
