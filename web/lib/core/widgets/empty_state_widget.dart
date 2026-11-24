import 'package:flartdart/flartdart.dart';
import '../constants/app_colors.dart';

/// Reusable empty state view displaying an illustrative icon, informative title,
/// description, and an optional action CTA button.
class EmptyStateWidget extends StatelessWidget {
  final String emoji;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onAction;
  final double verticalPadding;

  const EmptyStateWidget({
    required this.emoji,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onAction,
    this.verticalPadding = 60,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FDContainer(
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
      child: FDCenter(
        child: FDColumn(
          mainAxisSize: MainAxisSize.min,
          children: [
            FDText(emoji, style: const TextStyle(fontSize: 48)),
            const FDSizedBox(height: 16),
            FDText(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const FDSizedBox(height: 8),
            FDConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: FDText(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: FlartColors.grey),
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const FDSizedBox(height: 20),
              FDGestureDetector(
                onTap: onAction!,
                child: FDContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: FlartColor('rgba(59, 130, 246, 0.4)'),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: FDText(
                    actionLabel!,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: FlartColors.white,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
