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
      width: double.infinity,
      alignment: Alignment.topCenter,
      child: FDContainer(
        width: double.infinity,
        constraints: BoxConstraints(maxWidth: maxWidth),
        padding: padding,
        cssStyle: const {
          'width': '100%',
          'flex': '1 1 100%',
          'box-sizing': 'border-box',
        },
        child: child,
      ),
    );
  }
}

