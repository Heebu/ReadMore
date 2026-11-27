import 'package:flartdart/flartdart.dart';
import 'package:news_models/news_models.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/time_formatter.dart';
import '../../../core/widgets/article_meta_bar.dart';
import '../../../core/widgets/interaction_pill.dart';
import '../../../viewmodels/news_app_viewmodel.dart';

/// Hero spotlight card for the top lead headline.
class HeroSpotlightCard extends StatelessWidget {
  final Article article;
  final NewsAppViewModel vm;

  const HeroSpotlightCard({
    required this.article,
    required this.vm,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).isSmall;
    final isBookmarked = vm.isBookmarked(article.id);
    final isReadLater = vm.isReadLater(article.id);

    return FDGestureDetector(
      onTap: () => vm.openArticleReader(article),
      child: FDContainer(
        id: 'hero-card-${article.id}',
        decoration: BoxDecoration(
          color: vm.isDarkMode ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: vm.isDarkMode ? AppColors.borderRegular : const FlartColor('#D4CFBE'),
            width: 1,
          ),
          boxShadow: const [
            BoxShadow(color: FlartColor('rgba(0, 0, 0, 0.1)'), blurRadius: 12, offset: Offset(0, 4)),
          ],
        ),
        cssStyle: const {
          'width': '100%',
          'max-width': '100%',
          'min-width': '0',
          'box-sizing': 'border-box',
          'overflow-wrap': 'break-word',
          'transition': 'transform 0.28s cubic-bezier(0.16, 1, 0.3, 1), box-shadow 0.28s cubic-bezier(0.16, 1, 0.3, 1), border-color 0.28s ease',
          'cursor': 'pointer',
        },
        child: FDColumn(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          cssStyle: const {'width': '100%', 'min-width': '0', 'max-width': '100%'},
          children: [
            if (article.imageUrl != null)
              FDContainer(
                width: double.infinity,
                cssStyle: const {
                  'width': '100%',
                  'max-width': '100%',
                  'display': 'block',
                },
                child: FDStack(
                  children: [
                    FDContainer(
                      height: isMobile ? 220 : 340,
                      width: double.infinity,
                      clipBehavior: Clip.antiAlias,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.vertical(top: 4),
                      ),
                      cssStyle: {
                        'width': '100%',
                        'max-width': '100%',
                        'height': '${isMobile ? 220 : 340}px',
                        'display': 'block',
                      },
                      child: FDImage.network(
                        article.imageUrl!,
                        height: isMobile ? 220 : 340,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        cssStyle: {
                          'width': '100%',
                          'max-width': '100%',
                          'height': '${isMobile ? 220 : 340}px',
                          'object-fit': 'cover',
                          'display': 'block',
                        },
                      ),
                    ),
                    FDPositioned(
                      top: isMobile ? 12 : 16,
                      left: isMobile ? 12 : 16,
                      right: isMobile ? 12 : 16,
                      child: FDWrap(
                        spacing: 8,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          FDContainer(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: vm.isDarkMode ? const FlartColor('#0D0E11') : const FlartColor('#FFFFFF'),
                              borderRadius: BorderRadius.circular(2),
                              border: Border.all(
                                color: vm.isDarkMode ? FlartColors.white : FlartColors.black,
                                width: 1,
                              ),
                            ),
                            child: FDText(
                              '[ ${article.category.toUpperCase()} DISPATCH ]',
                              style: TextStyle(
                                color: vm.isDarkMode ? FlartColors.white : FlartColors.black,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'Space Grotesk',
                                letterSpacing: 0.08,
                              ),
                            ),
                          ),
                          FDContainer(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: vm.isDarkMode
                                  ? const FlartColor('rgba(255, 255, 255, 0.12)')
                                  : const FlartColor('rgba(0, 0, 0, 0.75)'),
                              borderRadius: BorderRadius.circular(2),
                              border: Border.all(
                                color: vm.isDarkMode ? const FlartColor('#444444') : const FlartColor('#000000'),
                                width: 1,
                              ),
                            ),
                            child: FDText(
                              '✦ ${article.readTimeMinutes} MIN READ',
                              style: const TextStyle(
                                color: FlartColors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                fontFamily: 'Space Grotesk',
                                letterSpacing: 0.08,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            FDContainer(
              padding: EdgeInsets.all(isMobile ? 16 : 24),
              cssStyle: const {
                'width': '100%',
                'max-width': '100%',
                'min-width': '0',
                'box-sizing': 'border-box',
                'overflow-wrap': 'break-word',
              },
              child: FDColumn(
                crossAxisAlignment: CrossAxisAlignment.start,
                cssStyle: const {'width': '100%', 'min-width': '0', 'max-width': '100%'},
                children: [
                  ArticleMetaBar(
                    source: article.source,
                    timestamp: formatRelativeTime(article.publishedAt),
                    isDarkMode: vm.isDarkMode,
                  ),
                  const FDSizedBox(height: 12),
                  FDText(
                    article.title,
                    style: TextStyle(
                      fontSize: isMobile ? 21 : 26,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Playfair Display',
                      height: 1.2,
                      letterSpacing: -0.02,
                      color: vm.isDarkMode ? const FlartColor('#F4F3EE') : const FlartColor('#111111'),
                    ),
                  ),
                  const FDSizedBox(height: 10),
                  FDText(
                    article.summary,
                    style: TextStyle(
                      fontSize: isMobile ? 13.5 : 14,
                      fontFamily: 'Newsreader',
                      height: 1.5,
                      color: vm.isDarkMode ? const FlartColor('#A2A098') : const FlartColor('#4A4842'),
                    ),
                  ),
                  const FDSizedBox(height: 18),
                  FDWrap(
                    alignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 10,
                    runSpacing: 10,
                    cssStyle: const {'width': '100%', 'max-width': '100%'},
                    children: [
                      FDWrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          InteractionPill(
                            icon: FDIcons.favorite,
                            label: isBookmarked ? 'Saved' : 'Save',
                            color: isBookmarked ? FlartColors.red : FlartColors.grey,
                            onTap: () => vm.toggleBookmark(article.id),
                            isDarkMode: vm.isDarkMode,
                          ),
                          InteractionPill(
                            icon: FDIcons.hourglass,
                            label: isReadLater ? 'In Queue' : 'Read Later',
                            color: isReadLater ? FlartColors.amber : FlartColors.grey,
                            onTap: () => vm.toggleReadLater(article.id),
                            isDarkMode: vm.isDarkMode,
                          ),
                        ],
                      ),
                      FDRow(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FDText(
                            'READ DISPATCH',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'Space Grotesk',
                              letterSpacing: 0.08,
                              color: vm.isDarkMode ? FlartColors.white : FlartColors.black,
                            ),
                          ),
                          const FDSizedBox(width: 4),
                          FDIcon(
                            icon: FDIcons.arrow_forward,
                            size: 14,
                            color: vm.isDarkMode ? FlartColors.white : FlartColors.black,
                          ),
                        ],
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
