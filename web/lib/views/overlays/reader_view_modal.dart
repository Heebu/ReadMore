import 'package:flartdart/flartdart.dart';
import 'package:news_models/news_models.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/article_helper.dart';
import '../../core/utils/time_formatter.dart';
import '../../core/utils/web_dom_helper.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/audio_waveform_visualizer.dart';
import '../../core/widgets/compact_article_tile.dart';
import '../../core/widgets/interaction_pill.dart';
import '../../viewmodels/news_app_viewmodel.dart';

/// Full-screen Reader View modal with font scaling (A- / A+), TTS audio narration,
/// dynamic editorial takeaways, multi-paragraph reading, full-story continuation,
/// related dispatches, keyboard navigation, dialog accessibility, and community comments.
class ReaderViewModal extends StatefulWidget {
  final NewsAppViewModel vm;
  final bool isMobile;

  const ReaderViewModal({
    required this.vm,
    required this.isMobile,
    super.key,
  });

  @override
  State<ReaderViewModal> createState() => _ReaderViewModalState();
}

class _ReaderViewModalState extends State<ReaderViewModal> {
  Object? _keySub;

  @override
  void initState() {
    super.initState();
    _keySub = addWindowKeyDownListener((key, isInputFocused) {
      if (key == 'Escape') {
        widget.vm.closeReaderModal();
      } else if (!isInputFocused && key == 'ArrowRight') {
        widget.vm.nextArticle();
      } else if (!isInputFocused && key == 'ArrowLeft') {
        widget.vm.prevArticle();
      }
    });
    focusElementById('reader-modal-dialog');
  }

  @override
  void didUpdateWidget(ReaderViewModal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.vm.activeReadingArticle?.id != oldWidget.vm.activeReadingArticle?.id) {
      focusElementById('reader-modal-dialog');
    }
  }

  @override
  void dispose() {
    removeWindowKeyDownListener(_keySub);
    _keySub = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.vm;
    final isMobile = widget.isMobile;
    final article = vm.activeReadingArticle;
    if (article == null) return const FDSizedBox.shrink();

    final isBookmarked = vm.isBookmarked(article.id);
    final isReadLater = vm.isReadLater(article.id);
    final isLiked = vm.isLiked(article.id);
    final totalLikes = article.likeCount + (isLiked ? 1 : 0);
    final takeaways = buildArticleTakeaways(article);
    final paragraphs = splitArticleParagraphs(article);
    final showContinuation = isArticleExcerpt(article);
    final relatedArticles = vm.relatedArticlesFor(article, limit: 3);

    return FDGestureDetector(
      onSwipeLeft: () => vm.nextArticle(),
      onSwipeRight: () => vm.prevArticle(),
      child: FDContainer(
        onClick: () => vm.closeReaderModal(),
        decoration: const BoxDecoration(color: FlartColor('rgba(0, 0, 0, 0.85)')),
        cssStyle: const {
          'position': 'fixed',
          'top': '0',
          'left': '0',
          'right': '0',
          'bottom': '0',
          'z-index': '1000',
          'overflow-y': 'auto',
        },
        child: FDStack(
          clipBehavior: Clip.none,
          cssStyle: const {
            'width': '100%',
            'height': 'auto',
            'min-height': '100%',
          },
          children: [
            FDCenter(
              cssStyle: const {
                'height': 'auto',
                'min-height': '100%',
                'align-items': 'safe center',
                'padding': '0',
                'box-sizing': 'border-box',
              },
              child: FDElement(
                tag: 'div',
                id: 'reader-modal-dialog',
                attributes: {
                  'role': 'dialog',
                  'aria-modal': 'true',
                  'aria-label': article.title,
                  'tabindex': '-1',
                },
                styles: {
                  'outline': 'none',
                  'box-sizing': 'border-box',
                  'width': isMobile ? 'calc(100% - 16px)' : 'min(860px, calc(100% - 48px))',
                  'max-width': 'calc(100vw - 16px)',
                  'min-width': '0',
                  'margin': isMobile ? '8px auto' : '24px auto',
                  'cursor': 'default',
                },
                events: {
                  'click': (dynamic e) => stopEventPropagation(e),
                },
                children: [
                  FDContainer(
                    decoration: BoxDecoration(
                      color: vm.isDarkMode ? const FlartColor('#111217') : const FlartColor('#F7F5F0'),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: vm.isDarkMode ? const FlartColor('#33353F') : const FlartColor('#C8C4B7'),
                        width: 1,
                      ),
                      boxShadow: const [
                        BoxShadow(color: FlartColor('rgba(0, 0, 0, 0.6)'), blurRadius: 40, offset: Offset(0, 16)),
                      ],
                    ),
                    cssStyle: const {
                      'width': '100%',
                      'max-width': '100%',
                      'min-width': '0',
                      'box-sizing': 'border-box',
                    },
                    child: FDConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 860, maxHeight: 880),
                      cssStyle: const {
                        'width': '100%',
                        'max-width': '100%',
                        'min-width': '0',
                      },
                      child: FDSingleChildScrollView(
                        cssStyle: {
                          'max-height': isMobile ? 'calc(100vh - 20px)' : 'calc(100vh - 56px)',
                        },
                        child: FDContainer(
                          padding: EdgeInsets.all(isMobile ? 16 : 36),
                          cssStyle: const {
                            'width': '100%',
                            'max-width': '100%',
                            'min-width': '0',
                            'box-sizing': 'border-box',
                            'overflow-wrap': 'break-word',
                          },
                          child: FDColumn(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            cssStyle: const {'width': '100%', 'min-width': '0', 'max-width': '100%'},
                            children: [
                              // Top Monochrome Reading Progress Bar
                              FDContainer(
                                height: 3,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: vm.isDarkMode
                                      ? const FlartColor('rgba(255, 255, 255, 0.08)')
                                      : const FlartColor('#E2DED2'),
                                  borderRadius: BorderRadius.circular(1),
                                ),
                                child: FDAlign(
                                  alignment: Alignment.centerLeft,
                                  child: FDContainer(
                                    height: 3,
                                    cssStyle: {
                                      'width': '${vm.totalArticlesCount > 0 ? (((vm.activeArticleIndex + 1) / vm.totalArticlesCount) * 100).clamp(10, 100).toInt() : 65}%',
                                      'background': vm.isDarkMode
                                          ? 'linear-gradient(90deg, #FFFFFF, #888888)'
                                          : 'linear-gradient(90deg, #111111, #555555)',
                                      'border-radius': '1px',
                                    },
                                  ),
                                ),
                              ),
                              const FDSizedBox(height: 14),

                              // Top Modal Toolbar: Category, Article Flip Counter, Font Size, Close
                              FDRow(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                cssStyle: const {'width': '100%', 'max-width': '100%', 'min-width': '0'},
                                children: [
                                  Expanded(
                                    child: FDWrap(
                                      spacing: 6,
                                      runSpacing: 6,
                                      crossAxisAlignment: WrapCrossAlignment.center,
                                      cssStyle: const {'min-width': '0', 'max-width': '100%'},
                                      children: [
                                      FDContainer(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: vm.isDarkMode ? const FlartColor('#1A1B22') : const FlartColor('#E8E4D8'),
                                          borderRadius: BorderRadius.circular(2),
                                          border: Border.all(
                                            color: vm.isDarkMode ? const FlartColor('#33353F') : const FlartColor('#C8C4B7'),
                                            width: 1,
                                          ),
                                        ),
                                        child: FDText(
                                          '[ ${article.category.toUpperCase()} DISPATCH ]',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w900,
                                            fontFamily: 'Space Grotesk',
                                            letterSpacing: 0.08,
                                            color: vm.isDarkMode ? FlartColors.white : FlartColors.black,
                                          ),
                                        ),
                                      ),
                                      // Article Index Counter with quick arrow flips
                                      if (vm.activeArticleIndex >= 0 && vm.totalArticlesCount > 0)
                                        FDContainer(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: vm.isDarkMode ? const FlartColor('#1A1B22') : const FlartColor('#E8E4D8'),
                                            borderRadius: BorderRadius.circular(2),
                                            border: Border.all(
                                              color: vm.isDarkMode ? const FlartColor('#33353F') : const FlartColor('#C8C4B7'),
                                              width: 1,
                                            ),
                                          ),
                                          child: FDRow(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              FDGestureDetector(
                                                onTap: () => vm.prevArticle(),
                                                child: FDIcon(
                                                  icon: FDIcons.arrow_back,
                                                  size: 12,
                                                  color: vm.isDarkMode ? FlartColors.white : FlartColors.black,
                                                ),
                                              ),
                                              const FDSizedBox(width: 6),
                                              FDText(
                                                '${vm.activeArticleIndex + 1} OF ${vm.totalArticlesCount}',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w800,
                                                  fontFamily: 'Space Grotesk',
                                                  color: vm.isDarkMode ? FlartColors.white : FlartColors.black,
                                                ),
                                              ),
                                              const FDSizedBox(width: 6),
                                              FDGestureDetector(
                                                onTap: () => vm.nextArticle(),
                                                child: FDIcon(
                                                  icon: FDIcons.arrow_forward,
                                                  size: 12,
                                                  color: vm.isDarkMode ? FlartColors.white : FlartColors.black,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      FDText(
                                        '✦ ${article.readTimeMinutes}m read',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontFamily: 'Space Grotesk',
                                          color: vm.isDarkMode ? const FlartColor('#A2A096') : const FlartColor('#666666'),
                                        ),
                                      ),
                                    ],
                                    ),
                                  ),
                                  const FDSizedBox(width: 8),
                                  FDRow(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    cssStyle: const {'flex-shrink': '0'},
                                    children: [
                                      // Font Size Controls (A- / A+)
                                      FDGestureDetector(
                                        onTap: () => vm.decreaseReaderFontSize(),
                                        child: FDContainer(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: vm.isDarkMode ? const FlartColor('#1A1B22') : const FlartColor('#E8E4D8'),
                                            borderRadius: BorderRadius.circular(2),
                                            border: Border.all(
                                              color: vm.isDarkMode ? const FlartColor('#33353F') : const FlartColor('#C8C4B7'),
                                              width: 1,
                                            ),
                                          ),
                                          child: const FDText(
                                            'A-',
                                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Space Grotesk'),
                                          ),
                                        ),
                                      ),
                                      const FDSizedBox(width: 6),
                                      FDGestureDetector(
                                        onTap: () => vm.increaseReaderFontSize(),
                                        child: FDContainer(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: vm.isDarkMode ? const FlartColor('#1A1B22') : const FlartColor('#E8E4D8'),
                                            borderRadius: BorderRadius.circular(2),
                                            border: Border.all(
                                              color: vm.isDarkMode ? const FlartColor('#33353F') : const FlartColor('#C8C4B7'),
                                              width: 1,
                                            ),
                                          ),
                                          child: const FDText(
                                            'A+',
                                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Space Grotesk'),
                                          ),
                                        ),
                                      ),
                                      const FDSizedBox(width: 12),
                                      FDGestureDetector(
                                        key: const ValueKey('reader-close-btn'),
                                        onTap: () => vm.closeReaderModal(),
                                        child: const FDIcon(
                                          icon: FDIcons.close,
                                          size: 22,
                                          color: FlartColors.grey,
                                          semanticLabel: 'Close reader',
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const FDSizedBox(height: 18),

                              // Title in Playfair Display Serif
                              FDText(
                                article.title,
                                style: TextStyle(
                                  fontSize: isMobile ? 22 : 30,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'Playfair Display',
                                  letterSpacing: -0.02,
                                  height: 1.25,
                                  color: vm.isDarkMode ? const FlartColor('#F4F3EE') : const FlartColor('#111111'),
                                ),
                              ),
                              const FDSizedBox(height: 14),

                              // Source & Accurate Relative Timestamp
                              FDWrap(
                                spacing: 8,
                                runSpacing: 4,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                cssStyle: const {'width': '100%', 'max-width': '100%'},
                                children: [
                                  FDImage.network(
                                    article.source.iconUrl,
                                    width: 18,
                                    height: 18,
                                    borderRadius: BorderRadius.circular(2),
                                    fit: BoxFit.cover,
                                  ),
                                  FDText(
                                    article.source.name,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      fontFamily: 'Space Grotesk',
                                      color: vm.isDarkMode ? FlartColors.white : FlartColors.black,
                                    ),
                                  ),
                                  FDText(
                                    '• ${formatRelativeTime(article.publishedAt)} • Syndicated Press Desk',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontFamily: 'Newsreader',
                                      color: vm.isDarkMode ? const FlartColor('#8E8C85') : const FlartColor('#666666'),
                                    ),
                                  ),
                                ],
                              ),
                              const FDSizedBox(height: 20),

                              // Image
                              if (article.imageUrl != null)
                                FDContainer(
                                  margin: const EdgeInsets.only(bottom: 20),
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(3),
                                    border: Border.all(
                                      color: vm.isDarkMode ? const FlartColor('#33353F') : const FlartColor('#D4CFBE'),
                                      width: 1,
                                    ),
                                  ),
                                  child: FDImage.network(
                                    article.imageUrl!,
                                    height: isMobile ? 210 : 380,
                                    fit: BoxFit.cover,
                                    cssStyle: {
                                      'width': '100%',
                                      'height': '${isMobile ? 210 : 380}px',
                                      'object-fit': 'cover',
                                      'display': 'block',
                                    },
                                  ),
                                ),

                              // TTS Audio Player Bar in Broadsheet Dispatch Styling
                              FDContainer(
                                padding: EdgeInsets.all(isMobile ? 12 : 14),
                                decoration: BoxDecoration(
                                  color: vm.isDarkMode ? const FlartColor('#191A22') : const FlartColor('#EFECE4'),
                                  borderRadius: BorderRadius.circular(3),
                                  border: Border.all(
                                    color: vm.isDarkMode ? const FlartColor('#33353F') : const FlartColor('#C8C4B7'),
                                    width: 1,
                                  ),
                                ),
                                child: FDRow(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: FDRow(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          FDGestureDetector(
                                            onTap: () => vm.toggleAudioPlaying(),
                                            child: FDContainer(
                                              width: 32,
                                              height: 32,
                                              cssStyle: const {'flex-shrink': '0'},
                                              decoration: BoxDecoration(
                                                color: vm.isDarkMode ? FlartColors.white : FlartColors.black,
                                                borderRadius: BorderRadius.circular(2),
                                              ),
                                              child: FDCenter(
                                                child: FDIcon(
                                                  icon: vm.isAudioPlaying ? FDIcons.pause : FDIcons.play_arrow,
                                                  size: 16,
                                                  color: vm.isDarkMode ? FlartColors.black : FlartColors.white,
                                                  semanticLabel: vm.isAudioPlaying ? 'Pause narration' : 'Play narration',
                                                ),
                                              ),
                                            ),
                                          ),
                                          const FDSizedBox(width: 10),
                                          Expanded(
                                            child: FDColumn(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                FDText(
                                                  vm.isAudioPlaying
                                                      ? 'PLAYING SPOKEN DISPATCH...'
                                                      : 'LISTEN TO SPOKEN DISPATCH (${article.readTimeMinutes}M)',
                                                  style: TextStyle(
                                                    fontSize: isMobile ? 10 : 11,
                                                    fontWeight: FontWeight.w900,
                                                    fontFamily: 'Space Grotesk',
                                                    letterSpacing: 0.06,
                                                    color: vm.isDarkMode ? FlartColors.white : FlartColors.black,
                                                  ),
                                                ),
                                                FDText(
                                                  'Synthesized Press Narration • ${(vm.audioProgress * 100).toInt()}% Read',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontFamily: 'Newsreader',
                                                    fontStyle: FontStyle.italic,
                                                    color: vm.isDarkMode ? const FlartColor('#A2A096') : const FlartColor('#555555'),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (!isMobile) ...[
                                            const FDSizedBox(width: 14),
                                            AudioWaveformVisualizer(
                                              isPlaying: vm.isAudioPlaying,
                                              color: vm.isDarkMode ? FlartColors.white : FlartColors.black,
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    const FDSizedBox(width: 8),
                                    FDGestureDetector(
                                      onTap: () => vm.cycleAudioSpeed(),
                                      child: FDContainer(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: vm.isDarkMode ? const FlartColor('#262833') : const FlartColor('#DCD8CA'),
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                        child: FDText(
                                          '${vm.audioSpeed}x',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w900,
                                            fontFamily: 'Space Grotesk',
                                            color: vm.isDarkMode ? FlartColors.white : FlartColors.black,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const FDSizedBox(height: 20),

                              // Dynamic Article-Specific Key Takeaways Box
                              FDContainer(
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: vm.isDarkMode ? const FlartColor('#15161C') : const FlartColor('#EAE6DA'),
                                  borderRadius: BorderRadius.circular(2),
                                  border: Border.all(
                                    color: vm.isDarkMode ? const FlartColor('#33353F') : const FlartColor('#C8C4B7'),
                                    width: 1,
                                  ),
                                ),
                                child: FDColumn(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    FDText(
                                      '✦ EDITORIAL MEMORANDUM & TAKEAWAYS',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w900,
                                        fontFamily: 'Space Grotesk',
                                        letterSpacing: 0.1,
                                        color: vm.isDarkMode ? FlartColors.white : FlartColors.black,
                                      ),
                                    ),
                                    const FDSizedBox(height: 10),
                                    ...takeaways.map(
                                      (bullet) => FDPadding(
                                        padding: const EdgeInsets.only(bottom: 6),
                                        child: FDText(
                                          '• $bullet',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontFamily: 'Newsreader',
                                            height: 1.5,
                                            color: vm.isDarkMode ? const FlartColor('#D4CFBE') : const FlartColor('#2E2D2A'),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const FDSizedBox(height: 24),

                              // Multi-Paragraph Article Content in Stately Newsreader Typography
                              FDColumn(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: paragraphs.map((p) {
                                  return FDPadding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: FDText(
                                      p,
                                      style: TextStyle(
                                        fontSize: vm.readerFontSize,
                                        fontFamily: 'Newsreader',
                                        height: 1.75,
                                        color: vm.isDarkMode ? const FlartColor('#D4CFBE') : const FlartColor('#222222'),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),

                              // Full-Story Continuation Callout when article is a syndicated RSS excerpt
                              if (showContinuation) ...[
                                const FDSizedBox(height: 8),
                                FDContainer(
                                  padding: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(
                                    color: vm.isDarkMode ? const FlartColor('#171923') : const FlartColor('#EFECE4'),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: vm.isDarkMode ? const FlartColor('#3B4256') : const FlartColor('#B5B1A2'),
                                      width: 1,
                                    ),
                                  ),
                                  child: FDWrap(
                                    alignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    spacing: 12,
                                    runSpacing: 12,
                                    cssStyle: const {'width': '100%', 'max-width': '100%'},
                                    children: [
                                      FDContainer(
                                        cssStyle: const {'min-width': '0', 'max-width': '100%', 'flex': '1 1 220px'},
                                        child: FDColumn(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            FDText(
                                              'WANT TO READ THE FULL REPORT?',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w900,
                                                fontFamily: 'Space Grotesk',
                                                letterSpacing: 0.08,
                                                color: vm.isDarkMode ? FlartColors.white : FlartColors.black,
                                              ),
                                            ),
                                            const FDSizedBox(height: 4),
                                            FDText(
                                              'This syndication preview was filed by ${article.source.name}. Continue directly on the publisher’s desk for the complete article.',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontFamily: 'Newsreader',
                                                color: vm.isDarkMode ? const FlartColor('#A2A096') : const FlartColor('#4A4842'),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      FDContainer(
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryBlue,
                                          borderRadius: BorderRadius.circular(3),
                                        ),
                                        child: FDLinkText(
                                          text: 'READ FULL STORY ↗',
                                          url: article.originalUrl,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w900,
                                            fontFamily: 'Space Grotesk',
                                            letterSpacing: 0.08,
                                            color: FlartColors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              const FDSizedBox(height: 24),

                              // Action Buttons Bar
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
                                        label: isBookmarked ? 'Saved' : 'Bookmark',
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
                                      InteractionPill(
                                        icon: FDIcons.star,
                                        label: '$totalLikes ${totalLikes == 1 ? 'Like' : 'Likes'}',
                                        color: isLiked ? FlartColors.amber : FlartColors.grey,
                                        onTap: () => vm.toggleLike(article.id),
                                        isDarkMode: vm.isDarkMode,
                                      ),
                                    ],
                                  ),
                                  FDContainer(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: vm.isDarkMode ? FlartColors.white : FlartColors.black,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                    child: FDLinkText(
                                      text: 'ORIGINAL SOURCE ↗',
                                      url: article.originalUrl,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w900,
                                        fontFamily: 'Space Grotesk',
                                        letterSpacing: 0.08,
                                        color: vm.isDarkMode ? FlartColors.black : FlartColors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const FDSizedBox(height: 32),

                              // Related / Read More Dispatches Section
                              if (relatedArticles.isNotEmpty) ...[
                                FDDivider(color: vm.isDarkMode ? const FlartColor('#2A2B35') : const FlartColor('#D4CFBE')),
                                const FDSizedBox(height: 22),
                                FDText(
                                  'CONTINUE READING — RELATED DISPATCHES',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                    fontFamily: 'Space Grotesk',
                                    letterSpacing: 0.08,
                                    color: vm.isDarkMode ? FlartColors.white : FlartColors.black,
                                  ),
                                ),
                                const FDSizedBox(height: 12),
                                FDColumn(
                                  children: relatedArticles.map((rel) {
                                    return CompactArticleTile(
                                      key: ValueKey('reader-related-${rel.id}'),
                                      article: rel,
                                      vm: vm,
                                      showThumbnail: true,
                                    );
                                  }).toList(),
                                ),
                                const FDSizedBox(height: 16),
                              ],

                              FDDivider(color: vm.isDarkMode ? const FlartColor('#2A2B35') : const FlartColor('#D4CFBE')),
                              const FDSizedBox(height: 24),

                              // Comments Section
                              _buildCommentsSection(article),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Floating Previous Article Side Pill (Desktop only)
            if (!isMobile)
              FDContainer(
                cssStyle: const {
                  'position': 'fixed',
                  'left': '20px',
                  'top': '50%',
                  'transform': 'translateY(-50%)',
                  'z-index': '1001',
                },
                child: FDElement(
                  tag: 'div',
                  events: {
                    'click': (dynamic e) => stopEventPropagation(e),
                  },
                  children: [
                    FDGestureDetector(
                      onTap: () => vm.prevArticle(),
                      child: FDContainer(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: vm.isDarkMode ? const FlartColor('#15161C') : const FlartColor('#FFFFFF'),
                          borderRadius: BorderRadius.circular(3),
                          border: Border.all(
                            color: vm.isDarkMode ? const FlartColor('#33353F') : const FlartColor('#C8C4B7'),
                            width: 1,
                          ),
                          boxShadow: const [
                            BoxShadow(color: FlartColor('rgba(0, 0, 0, 0.4)'), blurRadius: 16, offset: Offset(0, 4)),
                          ],
                        ),
                        child: FDRow(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FDIcon(
                              icon: FDIcons.arrow_back,
                              size: 14,
                              color: vm.isDarkMode ? FlartColors.white : FlartColors.black,
                            ),
                            const FDSizedBox(width: 6),
                            FDText(
                              'PREV',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'Space Grotesk',
                                letterSpacing: 0.08,
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

            // Floating Next Article Side Pill (Desktop only)
            if (!isMobile)
              FDContainer(
                cssStyle: const {
                  'position': 'fixed',
                  'right': '20px',
                  'top': '50%',
                  'transform': 'translateY(-50%)',
                  'z-index': '1001',
                },
                child: FDElement(
                  tag: 'div',
                  events: {
                    'click': (dynamic e) => stopEventPropagation(e),
                  },
                  children: [
                    FDGestureDetector(
                      onTap: () => vm.nextArticle(),
                      child: FDContainer(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: vm.isDarkMode ? const FlartColor('#15161C') : const FlartColor('#FFFFFF'),
                          borderRadius: BorderRadius.circular(3),
                          border: Border.all(
                            color: vm.isDarkMode ? const FlartColor('#33353F') : const FlartColor('#C8C4B7'),
                            width: 1,
                          ),
                          boxShadow: const [
                            BoxShadow(color: FlartColor('rgba(0, 0, 0, 0.4)'), blurRadius: 16, offset: Offset(0, 4)),
                          ],
                        ),
                        child: FDRow(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FDText(
                              'NEXT',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'Space Grotesk',
                                letterSpacing: 0.08,
                                color: vm.isDarkMode ? FlartColors.white : FlartColors.black,
                              ),
                            ),
                            const FDSizedBox(width: 6),
                            FDIcon(
                              icon: FDIcons.arrow_forward,
                              size: 14,
                              color: vm.isDarkMode ? FlartColors.white : FlartColors.black,
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

  Widget _buildCommentsSection(Article article) {
    final vm = widget.vm;

    return FDColumn(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FDText(
          'READER DISPATCHES & REMARKS (${vm.comments.length})',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            fontFamily: 'Space Grotesk',
            letterSpacing: 0.08,
            color: vm.isDarkMode ? FlartColors.white : FlartColors.black,
          ),
        ),
        if (!vm.isAuthenticated) ...[
          const FDSizedBox(height: 6),
          FDWrap(
            spacing: 4,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const FDText(
                'Posting as Guest Reader • ',
                style: TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
              FDGestureDetector(
                onTap: () {
                  vm.closeReaderModal();
                  vm.openAuthModal(tab: 'signin');
                },
                child: const FDText(
                  'Sign in for subscriber attribution',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryBlueLight,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ] else ...[
          const FDSizedBox(height: 6),
          FDText(
            'Posting as ${vm.currentUser.displayName} • Subscriber Desk',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
        ],
        const FDSizedBox(height: 14),

        // Add Comment Input (DOM-preserving AppTextField)
        FDRow(
          cssStyle: const {'width': '100%', 'max-width': '100%', 'min-width': '0'},
          children: [
            Expanded(
              child: AppTextField(
                key: ValueKey('reader-comment-input-${article.id}'),
                value: vm.newCommentDraft,
                placeholder: 'Record your dispatch remark or commentary...',
                ariaLabel: 'Add comment',
                backgroundColor: vm.isDarkMode ? const FlartColor('#181920') : const FlartColor('#FFFFFF'),
                borderColor: vm.isDarkMode ? const FlartColor('#33353F') : const FlartColor('#C8C4B7'),
                borderRadius: 2,
                onChanged: (val) => vm.setNewCommentDraft(val),
                onSubmitted: (_) => vm.postComment(),
              ),
            ),
            const FDSizedBox(width: 10),
            FDGestureDetector(
              onTap: () => vm.postComment(),
              child: FDContainer(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: vm.isDarkMode ? FlartColors.white : FlartColors.black,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: FDText(
                  'SUBMIT',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Space Grotesk',
                    letterSpacing: 0.08,
                    color: vm.isDarkMode ? FlartColors.black : FlartColors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        const FDSizedBox(height: 20),

        // Existing Comments List
        if (vm.comments.isEmpty)
          const FDText(
            'No reader remarks on this dispatch yet. Share the first perspective above.',
            style: TextStyle(fontSize: 12, color: AppColors.textMuted, fontStyle: FontStyle.italic),
          )
        else
          FDColumn(
            children: vm.comments.map((c) {
              return FDContainer(
                key: ValueKey('comment-${c.id}'),
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: vm.isDarkMode ? const FlartColor('#17181F') : const FlartColor('#F2EFE9'),
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(
                    color: vm.isDarkMode ? const FlartColor('#262832') : const FlartColor('#E0DCD0'),
                    width: 1,
                  ),
                ),
                child: FDColumn(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                            FDImage.network(
                              c.avatarUrl,
                              width: 20,
                              height: 20,
                              borderRadius: BorderRadius.circular(2),
                              fit: BoxFit.cover,
                            ),
                            FDText(
                              c.author,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                fontFamily: 'Space Grotesk',
                                color: vm.isDarkMode ? FlartColors.white : FlartColors.black,
                              ),
                            ),
                            FDText(
                              c.timeAgo,
                              style: TextStyle(
                                fontSize: 11,
                                fontFamily: 'Newsreader',
                                color: vm.isDarkMode ? const FlartColor('#8E8C85') : const FlartColor('#666666'),
                              ),
                            ),
                          ],
                        ),
                        FDGestureDetector(
                          onTap: () => vm.toggleCommentLike(c.id),
                          child: FDRow(
                            children: [
                              FDText(
                                '${c.likes}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontFamily: 'Space Grotesk',
                                  color: vm.isDarkMode ? const FlartColor('#8E8C85') : const FlartColor('#666666'),
                                ),
                              ),
                              const FDSizedBox(width: 4),
                              FDIcon(
                                icon: FDIcons.favorite,
                                size: 13,
                                color: c.isLiked
                                    ? (vm.isDarkMode ? FlartColors.white : FlartColors.black)
                                    : FlartColors.grey,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const FDSizedBox(height: 8),
                    FDText(
                      c.text,
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'Newsreader',
                        height: 1.5,
                        color: vm.isDarkMode ? const FlartColor('#D4CFBE') : const FlartColor('#2E2D2A'),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}
