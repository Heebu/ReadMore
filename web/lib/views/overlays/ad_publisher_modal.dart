import 'package:flartdart/flartdart.dart';
import 'package:news_models/news_models.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/app_text_field.dart';
import '../../viewmodels/news_app_viewmodel.dart';

/// Modal dialog allowing partners and advertisers to build, preview, and launch dynamic ad campaigns.
class AdPublisherModal extends StatefulWidget {
  final NewsAppViewModel vm;
  final bool isMobile;

  const AdPublisherModal({
    required this.vm,
    required this.isMobile,
    super.key,
  });

  @override
  State<AdPublisherModal> createState() => _AdPublisherModalState();
}

class _AdPublisherModalState extends State<AdPublisherModal> {
  String _title = 'CloudScale: Autonomous GPU Clustering for AI Labs';
  String _description = 'Instant provisioning of H100 and B200 clusters with zero upfront commitment. Slash fine-tuning costs.';
  String _sponsorName = 'CloudScale Infrastructure';
  String _targetUrl = 'https://cloudscale.example';
  String _callToAction = 'Deploy GPUs';
  AdPlacement _placement = AdPlacement.inFeedNative;
  AdFormat _format = AdFormat.sponsoredStory;
  String _targetCategory = 'tech';
  double _dailyBudget = 100.0;
  String _imageUrl = 'https://images.unsplash.com/photo-1558494949-ef010cbdcc31?w=800&auto=format&fit=crop&q=80';

  @override
  Widget build(BuildContext context) {
    final vm = widget.vm;

    return FDContainer(
      decoration: const BoxDecoration(
        color: FlartColor('rgba(0, 0, 0, 0.85)'),
      ),
      child: FDCenter(
        child: FDContainer(
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: vm.isDarkMode ? AppColors.darkCard : AppColors.lightCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primaryBlue, width: 1.5),
            boxShadow: const [
              BoxShadow(
                color: FlartColor('rgba(0, 0, 0, 0.6)'),
                blurRadius: 32,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: FDConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: FDContainer(
              padding: const EdgeInsets.all(28),
              child: FDSingleChildScrollView(
                child: FDColumn(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Bar
                    FDRow(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FDRow(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FDContainer(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlue,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const FDText(
                                'ADS PUBLISHER',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  color: FlartColors.white,
                                  letterSpacing: 0.1,
                                ),
                              ),
                            ),
                            const FDSizedBox(width: 10),
                            FDText(
                              'Launch Sponsored Campaign',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: vm.isDarkMode ? FlartColors.white : FlartColors.black,
                              ),
                            ),
                          ],
                        ),
                        FDGestureDetector(
                          onTap: () => vm.closeAdPublisherModal(),
                          child: const FDIcon(icon: FDIcons.close, size: 20, color: FlartColors.grey),
                        ),
                      ],
                    ),
                    const FDSizedBox(height: 8),

                    const FDText(
                      'Target verified ReadMore readers across desktop, tablet, and mobile with dynamic high-impact placements.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const FDSizedBox(height: 20),

                    // Placement Selector
                    const FDText(
                      'Campaign Format & Placement',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                    ),
                    const FDSizedBox(height: 8),
                    FDRow(
                      children: [
                        _buildPlacementOption(
                          AdPlacement.inFeedNative,
                          'In-Feed Native',
                          '📰 Seamless article card',
                        ),
                        const FDSizedBox(width: 8),
                        _buildPlacementOption(
                          AdPlacement.leaderboardBanner,
                          'Google Banner',
                          '🏷️ 728x90 Leaderboard',
                        ),
                        const FDSizedBox(width: 8),
                        _buildPlacementOption(
                          AdPlacement.sidebarRectangle,
                          'Sidebar Box',
                          '📐 300x250 Rectangle',
                        ),
                      ],
                    ),
                    const FDSizedBox(height: 16),

                    // Campaign Headline
                    const FDText(
                      'Campaign Headline',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                    ),
                    const FDSizedBox(height: 6),
                    AppTextField(
                      key: const ValueKey('ad-title-input'),
                      value: _title,
                      placeholder: 'e.g. Next-Gen AI Infrastructure for Teams',
                      backgroundColor: vm.isDarkMode ? AppColors.darkInput : AppColors.lightInput,
                      borderColor: AppColors.borderRegular,
                      borderRadius: 10,
                      onChanged: (val) => _title = val,
                    ),
                    const FDSizedBox(height: 14),

                    // Campaign Description
                    const FDText(
                      'Description & Value Proposition',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                    ),
                    const FDSizedBox(height: 6),
                    AppTextField(
                      key: const ValueKey('ad-desc-input'),
                      value: _description,
                      placeholder: 'Highlight your product or service benefits...',
                      backgroundColor: vm.isDarkMode ? AppColors.darkInput : AppColors.lightInput,
                      borderColor: AppColors.borderRegular,
                      borderRadius: 10,
                      onChanged: (val) => _description = val,
                    ),
                    const FDSizedBox(height: 14),

                    // Sponsor Name & CTA in a Row
                    FDRow(
                      children: [
                        Expanded(
                          flex: 6,
                          child: FDColumn(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const FDText(
                                'Sponsor / Brand Name',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                              ),
                              const FDSizedBox(height: 6),
                              AppTextField(
                                key: const ValueKey('ad-sponsor-input'),
                                value: _sponsorName,
                                placeholder: 'e.g. Datadog / Acme Corp',
                                backgroundColor: vm.isDarkMode ? AppColors.darkInput : AppColors.lightInput,
                                borderColor: AppColors.borderRegular,
                                borderRadius: 10,
                                onChanged: (val) => _sponsorName = val,
                              ),
                            ],
                          ),
                        ),
                        const FDSizedBox(width: 12),
                        Expanded(
                          flex: 4,
                          child: FDColumn(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const FDText(
                                'Button CTA',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                              ),
                              const FDSizedBox(height: 6),
                              AppTextField(
                                key: const ValueKey('ad-cta-input'),
                                value: _callToAction,
                                placeholder: 'e.g. Learn More',
                                backgroundColor: vm.isDarkMode ? AppColors.darkInput : AppColors.lightInput,
                                borderColor: AppColors.borderRegular,
                                borderRadius: 10,
                                onChanged: (val) => _callToAction = val,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const FDSizedBox(height: 14),

                    // Target URL & Target Category
                    FDRow(
                      children: [
                        Expanded(
                          flex: 6,
                          child: FDColumn(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const FDText(
                                'Destination URL',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                              ),
                              const FDSizedBox(height: 6),
                              AppTextField(
                                key: const ValueKey('ad-url-input'),
                                value: _targetUrl,
                                placeholder: 'https://...',
                                keyboardType: TextInputType.url,
                                backgroundColor: vm.isDarkMode ? AppColors.darkInput : AppColors.lightInput,
                                borderColor: AppColors.borderRegular,
                                borderRadius: 10,
                                onChanged: (val) => _targetUrl = val,
                              ),
                            ],
                          ),
                        ),
                        const FDSizedBox(width: 12),
                        Expanded(
                          flex: 4,
                          child: FDColumn(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const FDText(
                                'Target Category',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                              ),
                              const FDSizedBox(height: 6),
                              AppTextField(
                                key: const ValueKey('ad-category-input'),
                                value: _targetCategory,
                                placeholder: 'all / tech / business',
                                backgroundColor: vm.isDarkMode ? AppColors.darkInput : AppColors.lightInput,
                                borderColor: AppColors.borderRegular,
                                borderRadius: 10,
                                onChanged: (val) => _targetCategory = val,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const FDSizedBox(height: 18),

                    // Budget & Reach Calculator
                    FDContainer(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: vm.isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderRegular),
                      ),
                      child: FDRow(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          FDColumn(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const FDText(
                                'Daily Budget & Estimated Reach',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                              ),
                              const FDSizedBox(height: 4),
                              FDText(
                                '\$${_dailyBudget.toInt()} / day  ●  ~${(_dailyBudget * 65).toInt()} est. impressions',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.accentEmerald),
                              ),
                            ],
                          ),
                          FDRow(
                            children: [50.0, 100.0, 250.0].map((b) {
                              final isSel = _dailyBudget == b;
                              return FDGestureDetector(
                                onTap: () => setState(() => _dailyBudget = b),
                                child: FDContainer(
                                  margin: const EdgeInsets.only(left: 6),
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isSel ? AppColors.primaryBlue : AppColors.borderSubtle,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: FDText(
                                    '\$${b.toInt()}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: isSel ? FlartColors.white : AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    const FDSizedBox(height: 22),

                    // Launch Campaign Action Button
                    FDGestureDetector(
                      onTap: () {
                        final newAd = SponsoredAd(
                          id: 'ad-custom-${DateTime.now().millisecondsSinceEpoch}',
                          title: _title.isNotEmpty ? _title : 'Sponsored Innovation',
                          description: _description.isNotEmpty ? _description : 'Accelerate performance with verified partner intelligence.',
                          sponsorName: _sponsorName.isNotEmpty ? _sponsorName : 'Partner Sponsor',
                          sponsorLogoUrl: 'https://www.google.com/s2/favicons?domain=example.com&sz=128',
                          imageUrl: _imageUrl,
                          targetUrl: _targetUrl.isNotEmpty ? _targetUrl : 'https://readmore.org',
                          callToAction: _callToAction.isNotEmpty ? _callToAction : 'Learn More',
                          placement: _placement,
                          format: _format,
                          targetCategory: _targetCategory.isNotEmpty ? _targetCategory : 'all',
                          dailyBudget: _dailyBudget,
                          impressions: 1,
                          clicks: 0,
                          createdAt: DateTime.now(),
                        );
                        vm.publishNewAdCampaign(newAd);
                      },
                      child: FDContainer(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: vm.isDarkMode ? FlartColors.white : FlartColors.black,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        cssStyle: const {
                          'cursor': 'pointer',
                          'transition': 'all 0.2s ease',
                        },
                        child: FDCenter(
                          child: FDText(
                            'COMMENCE DISPATCH CAMPAIGN',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'Space Grotesk',
                              letterSpacing: 0.08,
                              color: vm.isDarkMode ? FlartColors.black : FlartColors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlacementOption(AdPlacement placement, String title, String subtitle) {
    final isSelected = _placement == placement;

    return Expanded(
      child: FDGestureDetector(
        onTap: () => setState(() => _placement = placement),
        child: FDContainer(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryBlueSubtle
                : (widget.vm.isDarkMode ? AppColors.darkSurface : AppColors.lightSurface),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppColors.primaryBlue : AppColors.borderRegular,
              width: 1.5,
            ),
          ),
          child: FDColumn(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FDText(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: isSelected
                      ? AppColors.primaryBlueLight
                      : (widget.vm.isDarkMode ? FlartColors.white : FlartColors.black),
                ),
              ),
              const FDSizedBox(height: 2),
              FDText(
                subtitle,
                style: const TextStyle(fontSize: 9, color: AppColors.textMuted),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
