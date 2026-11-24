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
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const FlartColor('rgba(59, 130, 246, 0.35)'),
            width: 1.5,
          ),
          boxShadow: const [
            BoxShadow(
              color: FlartColor('rgba(0, 0, 0, 0.2)'),
              blurRadius: 10,
              offset: Offset(0, 4),
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
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const FDText(
                        'SPONSORED',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: FlartColors.white,
                          letterSpacing: 0.08,
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

                  // Headline
                  FDText(
                    ad.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: vm.isDarkMode ? FlartColors.white : FlartColors.black,
                      height: 1.3,
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
                          color: AppColors.primaryBlue,
                          borderRadius: BorderRadius.circular(8),
                        ),
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
                            const FDText('↗', style: TextStyle(fontSize: 11, color: FlartColors.white)),
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
