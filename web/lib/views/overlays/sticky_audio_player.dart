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
                        icon: vm.isBriefingPlaying ? FDIcons.close : FDIcons.play_arrow,
                        size: 20,
                        color: FlartColors.white,
                      ),
                    ),
                  ),
                ),
                const FDSizedBox(width: 14),
                FDColumn(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    FDText(
                      'ReadMore Morning Intelligence Briefing',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    FDText(
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
                  const FDText('01:45', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  const FDSizedBox(width: 8),
                  FDContainer(
                    width: 220,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const FlartColor('rgba(255, 255, 255, 0.2)'),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: FDAlign(
                      alignment: Alignment.centerLeft,
                      child: FDContainer(
                        width: 77,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                  const FDSizedBox(width: 8),
                  const FDText('05:00', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                ],
              ),
            FDGestureDetector(
              onTap: () => vm.closeBottomBriefing(),
              child: const FDIcon(icon: FDIcons.close, size: 20, color: FlartColors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
