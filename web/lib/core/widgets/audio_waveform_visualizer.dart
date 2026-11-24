import 'package:flartdart/flartdart.dart';
import '../constants/app_colors.dart';

/// Reusable animated audio waveform bars that bounce rhythmically during audio playback.
class AudioWaveformVisualizer extends StatelessWidget {
  final bool isPlaying;
  final FlartColor color;

  const AudioWaveformVisualizer({
    required this.isPlaying,
    this.color = AppColors.primaryBlue,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FDRow(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List.generate(5, (index) {
        return FDContainer(
          margin: const EdgeInsets.symmetric(horizontal: 1.5),
          cssStyle: {
            'width': '3px',
            'height': isPlaying ? '18px' : '4px',
            'background': isPlaying
                ? '#111111'
                : 'rgba(128, 128, 128, 0.4)',
            'border-radius': '2px',
            'transition': 'all 0.25s ease',
            if (isPlaying)
              'animation': 'audio-wave-bounce 0.8s ease-in-out infinite ${(index * 0.14).toStringAsFixed(2)}s',
          },
        );
      }),
    );
  }
}
