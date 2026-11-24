import 'package:flartdart/flartdart.dart';
import '../../core/widgets/audio_waveform_visualizer.dart';
import '../../core/widgets/interaction_pill.dart';
import '../../viewmodels/news_app_viewmodel.dart';

/// Full-screen Reader View modal with font scaling (A- / A+), TTS audio narration,
/// executive AI takeaways, full content reading, and interactive community commenting.
class ReaderViewModal extends StatelessWidget {
  final NewsAppViewModel vm;
  final bool isMobile;

  const ReaderViewModal({
    required this.vm,
    required this.isMobile,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final article = vm.activeReadingArticle;
    if (article == null) return const FDSizedBox.shrink();

    final isBookmarked = vm.isBookmarked(article.id);
    final isReadLater = vm.isReadLater(article.id);
    final isLiked = vm.isLiked(article.id);

    return FDGestureDetector(
      onSwipeLeft: () => vm.nextArticle(),
      onSwipeRight: () => vm.prevArticle(),
      child: FDContainer(
        decoration: const BoxDecoration(color: FlartColor('rgba(0, 0, 0, 0.85)')),
        child: FDStack(
          children: [
            FDCenter(
              child: FDContainer(
                id: 'reader-modal-dialog',
                margin: EdgeInsets.all(isMobile ? 8 : 24),
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
                child: FDConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 860, maxHeight: 880),
                  child: FDSingleChildScrollView(
                    child: FDContainer(
                      padding: EdgeInsets.all(isMobile ? 18 : 36),
                      child: FDColumn(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
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
                                  'width': '65%',
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
                            children: [
                              FDRow(
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
                                  const FDSizedBox(width: 8),
                                  // Article Index Counter with quick arrow flips
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
                                  const FDSizedBox(width: 8),
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
                              FDRow(
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
                                  const FDSizedBox(width: 14),
                                  FDGestureDetector(
                                    onTap: () => vm.closeReaderModal(),
                                    child: const FDIcon(icon: FDIcons.close, size: 22, color: FlartColors.grey),
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

                          // Source & Meta
                          FDRow(
                            children: [
                              FDImage.network(
                                article.source.iconUrl,
                                width: 18,
                                height: 18,
                                borderRadius: BorderRadius.circular(2),
                                fit: BoxFit.cover,
                              ),
                              const FDSizedBox(width: 8),
                              FDText(
                                article.source.name,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  fontFamily: 'Space Grotesk',
                                  color: vm.isDarkMode ? FlartColors.white : FlartColors.black,
                                ),
                              ),
                              const FDSizedBox(width: 8),
                              FDText(
                                '• Published Today • Syndicated Press Desk',
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
                                height: 380,
                                fit: BoxFit.cover,
                                cssStyle: const {
                                  'width': '100%',
                                  'height': '380px',
                                  'object-fit': 'cover',
                                  'display': 'block',
                                },
                              ),
                            ),

                    // TTS Audio Player Bar in Broadsheet Dispatch Styling
                    FDContainer(
                      padding: const EdgeInsets.all(14),
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
                        children: [
                          FDRow(
                            children: [
                              FDGestureDetector(
                                onTap: () => vm.toggleAudioPlaying(),
                                child: FDContainer(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: vm.isDarkMode ? FlartColors.white : FlartColors.black,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                  child: FDCenter(
                                    child: FDIcon(
                                      icon: vm.isAudioPlaying ? FDIcons.close : FDIcons.play_arrow,
                                      size: 16,
                                      color: vm.isDarkMode ? FlartColors.black : FlartColors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const FDSizedBox(width: 12),
                              FDColumn(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  FDText(
                                    vm.isAudioPlaying ? 'PLAYING SPOKEN DISPATCH...' : 'LISTEN TO SPOKEN DISPATCH (3M)',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                      fontFamily: 'Space Grotesk',
                                      letterSpacing: 0.08,
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
                              const FDSizedBox(width: 14),
                              AudioWaveformVisualizer(
                                isPlaying: vm.isAudioPlaying,
                                color: vm.isDarkMode ? FlartColors.white : FlartColors.black,
                              ),
                            ],
                          ),
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

                    // AI Key Takeaways Box
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
                          FDText(
                            '• Critical global developments corroborated by multiple international reporting bureaus.',
                            style: TextStyle(
                              fontSize: 13,
                              fontFamily: 'Newsreader',
                              height: 1.5,
                              color: vm.isDarkMode ? const FlartColor('#D4CFBE') : const FlartColor('#2E2D2A'),
                            ),
                          ),
                          const FDSizedBox(height: 6),
                          FDText(
                            '• Cross-border coordination mandates synchronous energy infrastructure investments by 2035.',
                            style: TextStyle(
                              fontSize: 13,
                              fontFamily: 'Newsreader',
                              height: 1.5,
                              color: vm.isDarkMode ? const FlartColor('#D4CFBE') : const FlartColor('#2E2D2A'),
                            ),
                          ),
                          const FDSizedBox(height: 6),
                          FDText(
                            '• Industrial and commercial commodities markets pricing in regulatory transitions over the upcoming decade.',
                            style: TextStyle(
                              fontSize: 13,
                              fontFamily: 'Newsreader',
                              height: 1.5,
                              color: vm.isDarkMode ? const FlartColor('#D4CFBE') : const FlartColor('#2E2D2A'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const FDSizedBox(height: 24),

                    // Article Content in Stately Newsreader Typography
                    FDText(
                      article.content ?? article.summary,
                      style: TextStyle(
                        fontSize: vm.readerFontSize,
                        fontFamily: 'Newsreader',
                        height: 1.75,
                        color: vm.isDarkMode ? const FlartColor('#D4CFBE') : const FlartColor('#222222'),
                      ),
                    ),
                    const FDSizedBox(height: 28),

                    // Action Buttons Bar
                    FDRow(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        FDRow(
                          children: [
                            InteractionPill(
                              icon: FDIcons.favorite,
                              label: isBookmarked ? 'Saved' : 'Bookmark',
                              color: isBookmarked ? FlartColors.red : FlartColors.grey,
                              onTap: () => vm.toggleBookmark(article.id),
                              isDarkMode: vm.isDarkMode,
                            ),
                            const FDSizedBox(width: 8),
                            InteractionPill(
                              icon: FDIcons.hourglass,
                              label: isReadLater ? 'In Queue' : 'Read Later',
                              color: isReadLater ? FlartColors.amber : FlartColors.grey,
                              onTap: () => vm.toggleReadLater(article.id),
                              isDarkMode: vm.isDarkMode,
                            ),
                            const FDSizedBox(width: 8),
                            InteractionPill(
                              icon: FDIcons.star,
                              label: '${article.likeCount + (isLiked ? 1 : 0)} Likes',
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
                    FDDivider(color: vm.isDarkMode ? const FlartColor('#2A2B35') : const FlartColor('#D4CFBE')),
                    const FDSizedBox(height: 24),

                    // Comments Section
                    _buildCommentsSection(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),

      // Floating Previous Article Side Pill (Desktop only)
      if (!isMobile)
        FDPositioned(
          left: 20,
          top: 0,
          bottom: 0,
          child: FDCenter(
            child: FDGestureDetector(
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
          ),
        ),

      // Floating Next Article Side Pill (Desktop only)
      if (!isMobile)
        FDPositioned(
          right: 20,
          top: 0,
          bottom: 0,
          child: FDCenter(
            child: FDGestureDetector(
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
          ),
        ),
    ],
  ),
),
);
}

  Widget _buildCommentsSection() {
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
        const FDSizedBox(height: 14),

        // Add Comment Input
        FDRow(
          children: [
            Expanded(
              child: FDTextField(
                placeholder: 'Record your dispatch remark or commentary...',
                backgroundColor: vm.isDarkMode ? const FlartColor('#181920') : const FlartColor('#FFFFFF'),
                borderColor: vm.isDarkMode ? const FlartColor('#33353F') : const FlartColor('#C8C4B7'),
                borderRadius: 2,
                onChanged: (val) => vm.setNewCommentDraft(val),
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
        FDColumn(
          children: vm.comments.map((c) {
            return FDContainer(
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
                  FDRow(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FDRow(
                        children: [
                          FDImage.network(
                            c.avatarUrl,
                            width: 20,
                            height: 20,
                            borderRadius: BorderRadius.circular(2),
                            fit: BoxFit.cover,
                          ),
                          const FDSizedBox(width: 8),
                          FDText(
                            c.author,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'Space Grotesk',
                              color: vm.isDarkMode ? FlartColors.white : FlartColors.black,
                            ),
                          ),
                          const FDSizedBox(width: 8),
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
