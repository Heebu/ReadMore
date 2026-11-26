import 'package:flartdart/flartdart.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/audio_waveform_visualizer.dart';
import '../../viewmodels/news_app_viewmodel.dart';

/// Persistent bottom sticky player for the daily morning intelligence briefing podcast.
class StickyAudioPlayer extends StatelessWidget {
  final NewsAppViewModel vm;
  final bool isMobile;

  const StickyAudioPlayer({
    required this.vm,
    required this.isMobile,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FDPositioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: FDContainer(
        id: 'sticky-audio-player',
        decoration: BoxDecoration(
          color: vm.isDarkMode ? AppColors.darkRibbon : AppColors.lightCard,
          border: const Border(top: BorderSide(color: AppColors.primaryBlueLight, width: 1.5)),
          boxShadow: const [
            BoxShadow(color: FlartColor('rgba(0, 0, 0, 0.5)'), blurRadius: 20, offset: Offset(0, -4)),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: FDRow(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FDRow(
              children: [
                FDGestureDetector(
                  key: const ValueKey('sticky-briefing-toggle'),
                  onTap: () => vm.toggleBriefingPlaying(),
                  child: FDContainer(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: FDCenter(
                      child: FDIcon(
                        icon: vm.isBriefingPlaying ? FDIcons.pause : FDIcons.play_arrow,
                        size: 20,
                        color: FlartColors.white,
                        semanticLabel: vm.isBriefingPlaying ? 'Pause morning briefing' : 'Play morning briefing',
                      ),
                    ),
                  ),
                ),
                const FDSizedBox(width: 14),
                FDColumn(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FDText(
                      'ReadMore Morning Intelligence Briefing',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: vm.isDarkMode ? FlartColors.white : FlartColors.black,
                      ),
                    ),
                    const FDText(
                      'Episode #142 • 5 mins • AI Voice Synthesized',
                      style: TextStyle(fontSize: 11, color: FlartColors.grey),
                    ),
                  ],
                ),
                const FDSizedBox(width: 14),
                AudioWaveformVisualizer(isPlaying: vm.isBriefingPlaying),
              ],
            ),
            if (!isMobile)
              FDRow(
                children: [
                  FDText(
                    vm.briefingElapsedFormatted,
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                  const FDSizedBox(width: 8),
                  FDContainer(
                    width: 220,
                    height: 4,
                    decoration: BoxDecoration(
                      color: vm.isDarkMode
                          ? const FlartColor('rgba(255, 255, 255, 0.2)')
                          : const FlartColor('rgba(0, 0, 0, 0.14)'),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: FDAlign(
                      alignment: Alignment.centerLeft,
                      child: FDContainer(
                        width: (220 * vm.briefingProgress).clamp(4.0, 220.0),
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                  const FDSizedBox(width: 8),
                  FDText(
                    vm.briefingTotalFormatted,
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
              ),
            FDGestureDetector(
              key: const ValueKey('sticky-briefing-close'),
              onTap: () => vm.closeBottomBriefing(),
              child: const FDIcon(
                icon: FDIcons.close,
                size: 20,
                color: FlartColors.grey,
                semanticLabel: 'Close morning briefing',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
