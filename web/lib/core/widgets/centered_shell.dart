import 'package:flartdart/flartdart.dart';

/// A robust centered responsive container that enforces desktop max-width constraints
/// and graceful scaling across all zoom levels (25% to 200%+).
class CenteredShell extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double maxWidth;

  const CenteredShell({
    required this.child,
    this.padding,
    this.maxWidth = 1400,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FDContainer(
      padding: padding,
      cssStyle: {
        'width': '100%',
        'max-width': '${maxWidth.toInt()}px',
        'margin-left': 'auto',
        'margin-right': 'auto',
        'box-sizing': 'border-box',
      },
      child: child,
    );
  }
}
