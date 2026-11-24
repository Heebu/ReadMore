import 'package:flartdart/flartdart.dart';
import '../../../viewmodels/news_app_viewmodel.dart';
import '../../constants/app_colors.dart';

/// 300x250 Medium Rectangle Google AdSense card for the right sidebar.
class SidebarAdRectangle extends StatelessWidget {
  final NewsAppViewModel vm;
  final String? category;

  const SidebarAdRectangle({
    required this.vm,
    this.category,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (!vm.showAds) {
      return const FDSizedBox.shrink();
    }

    final ad = vm.getSidebarAd(category: category);
    if (ad == null) {
      return const FDSizedBox.shrink();
    }

    return FDGestureDetector(
      onTap: () => vm.recordAdClick(ad.id),
      child: FDContainer(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: vm.isDarkMode ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: vm.isDarkMode ? AppColors.borderRegular : const FlartColor('#D4CFBE'),
            width: 1,
          ),
        ),
        child: FDColumn(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Ad Badge Bar
            FDPadding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: FDRow(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      '[ GOOGLE AD ]',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Space Grotesk',
                        letterSpacing: 0.08,
                        color: vm.isDarkMode ? FlartColors.white : FlartColors.black,
                      ),
                    ),
                  ),
                  FDText(
                    ad.sponsorName,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),

            // Ad Visual Creative
            if (ad.imageUrl != null)
              FDContainer(
                height: 130,
                width: double.infinity,
                clipBehavior: Clip.antiAlias,
                child: FDImage.network(
                  ad.imageUrl!,
                  height: 130,
                  fit: BoxFit.cover,
                  cssStyle: const {
                    'width': '100%',
                    'height': '130px',
                    'object-fit': 'cover',
                    'display': 'block',
                  },
                ),
              ),

            // Ad Copy & CTA
            FDPadding(
              padding: const EdgeInsets.all(14),
              child: FDColumn(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FDText(
                    ad.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: vm.isDarkMode ? FlartColors.white : FlartColors.black,
                      height: 1.25,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const FDSizedBox(height: 6),
                  FDText(
                    ad.description,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      height: 1.35,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const FDSizedBox(height: 12),
                  FDContainer(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: vm.isDarkMode ? FlartColors.white : FlartColors.black,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: FDCenter(
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
