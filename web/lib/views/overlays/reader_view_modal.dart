import 'package:flartdart/flartdart.dart';
import '../../core/constants/app_colors.dart';
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

    return FDContainer(
      decoration: const BoxDecoration(color: FlartColor('rgba(0, 0, 0, 0.85)')),
      child: FDCenter(
        child: FDContainer(
          margin: EdgeInsets.all(isMobile ? 8 : 24),
          decoration: BoxDecoration(
            color: vm.isDarkMode ? AppColors.darkCard : AppColors.lightCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderRegular, width: 1),
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
                    // Top Modal Toolbar: Category, Font Size Controller, Close
                    FDRow(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FDRow(
                          children: [
                            FDContainer(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlueSubtle,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: FDText(
                                article.category.toUpperCase(),
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                              ),
                            ),
                            const FDSizedBox(width: 8),
                            FDText('⚡ ${article.readTimeMinutes} min read', style: const TextStyle(fontSize: 12, color: FlartColors.grey)),
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
                                  color: AppColors.borderSubtle,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const FDText('A-', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              ),
                            ),
                            const FDSizedBox(width: 6),
                            FDGestureDetector(
                              onTap: () => vm.increaseReaderFontSize(),
                              child: FDContainer(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.borderSubtle,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const FDText('A+', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              ),
                            ),
                            const FDSizedBox(width: 14),
                            FDGestureDetector(
                              onTap: () => vm.closeReaderModal(),
                              child: const FDIcon(icon: FDIcons.close, size: 24, color: FlartColors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const FDSizedBox(height: 18),

                    // Title
                    FDText(
                      article.title,
                      style: TextStyle(
                        fontSize: isMobile ? 22 : 28,
                        fontWeight: FontWeight.w800,
                        color: vm.isDarkMode ? FlartColors.white : FlartColors.black,
                      ),
                    ),
                    const FDSizedBox(height: 14),

                    // Source & Meta
                    FDRow(
                      children: [
                        FDImage.network(
                          article.source.iconUrl,
                          width: 22,
                          height: 22,
                          borderRadius: BorderRadius.circular(4),
                          fit: BoxFit.cover,
                        ),
                        const FDSizedBox(width: 8),
                        FDText(
                          article.source.name,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primaryBlue),
                        ),
                        const FDSizedBox(width: 8),
                        const FDText(
                          '• Published today • Author: Syndicated News Desk',
                          style: TextStyle(fontSize: 13, color: AppColors.textMuted),
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
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: FDImage.network(
                          article.imageUrl!,
                          width: double.infinity,
                          height: 380,
                          fit: BoxFit.cover,
                        ),
                      ),

                    // TTS Audio Player Bar
                    FDContainer(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.darkCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primaryBlueSubtle, width: 1),
                      ),
                      child: FDRow(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          FDRow(
                            children: [
                              FDGestureDetector(
                                onTap: () => vm.toggleAudioPlaying(),
                                child: FDContainer(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryBlue,
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: FDCenter(
                                    child: FDIcon(
                                      icon: vm.isAudioPlaying ? FDIcons.close : FDIcons.play_arrow,
                                      size: 18,
                                      color: FlartColors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const FDSizedBox(width: 12),
                              FDColumn(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  FDText(
                                    vm.isAudioPlaying ? 'Playing Article Audio...' : 'Listen to this article (3m)',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: FlartColors.white),
                                  ),
                                  FDText(
                                    'High-fidelity AI voice • ${(vm.audioProgress * 100).toInt()}% completed',
                                    style: const TextStyle(fontSize: 10, color: FlartColors.grey),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          FDGestureDetector(
                            onTap: () => vm.cycleAudioSpeed(),
                            child: FDContainer(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const FlartColor('rgba(255, 255, 255, 0.1)'),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: FDText(
                                '${vm.audioSpeed}x',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryBlueLight),
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
                        color: AppColors.primaryBlueSubtle,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderHighlighted, width: 1),
                      ),
                      child: FDColumn(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          FDText(
                            '💡 Executive Takeaways',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryBlueLight),
                          ),
                          FDSizedBox(height: 8),
                          FDText('• Critical global developments corroborated by 3+ independent news organizations.'),
                          FDSizedBox(height: 4),
                          FDText('• Policy shift includes long-term infrastructure funding and automated synchronization.'),
                          FDSizedBox(height: 4),
                          FDText('• Market participants anticipate significant cross-border economic impacts over the next decade.'),
                        ],
                      ),
                    ),
                    const FDSizedBox(height: 20),

                    // Article Content
                    FDText(
                      article.content ?? article.summary,
                      style: TextStyle(
                        fontSize: vm.readerFontSize,
                        color: vm.isDarkMode ? AppColors.textSecondary : const FlartColor('#334155'),
                      ),
                    ),
                    const FDSizedBox(height: 28),

                    // Action Buttons Bar
                    FDRow(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: FDLinkText(
                            text: 'Read on ${article.source.name} ↗',
                            url: article.originalUrl,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: FlartColors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const FDSizedBox(height: 32),
                    const FDDivider(color: AppColors.borderRegular),
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
    );
  }

  Widget _buildCommentsSection() {
    return FDColumn(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FDText(
          'Reader Comments (${vm.comments.length})',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const FDSizedBox(height: 14),

        // Add Comment Input
        FDRow(
          children: [
            Expanded(
              child: FDTextField(
                placeholder: 'Share your perspective on this development...',
                backgroundColor: vm.isDarkMode ? AppColors.darkInput : AppColors.lightInput,
                borderColor: AppColors.borderRegular,
                borderRadius: 12,
                onChanged: (val) => vm.setNewCommentDraft(val),
              ),
            ),
            const FDSizedBox(width: 10),
            FDGestureDetector(
              onTap: () => vm.postComment(),
              child: FDContainer(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const FDText(
                  'Post',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: FlartColors.white),
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
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: vm.isDarkMode ? AppColors.borderSubtle : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(12),
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
                            width: 24,
                            height: 24,
                            borderRadius: BorderRadius.circular(12),
                            fit: BoxFit.cover,
                          ),
                          const FDSizedBox(width: 8),
                          FDText(c.author, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          const FDSizedBox(width: 8),
                          FDText(c.timeAgo, style: const TextStyle(fontSize: 11, color: FlartColors.grey)),
                        ],
                      ),
                      FDGestureDetector(
                        onTap: () => vm.toggleCommentLike(c.id),
                        child: FDRow(
                          children: [
                            FDText('${c.likes}', style: const TextStyle(fontSize: 11, color: FlartColors.grey)),
                            const FDSizedBox(width: 4),
                            FDIcon(
                              icon: FDIcons.favorite,
                              size: 13,
                              color: c.isLiked ? FlartColors.red : FlartColors.grey,
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
                      color: vm.isDarkMode ? AppColors.textSecondary : const FlartColor('#334155'),
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
