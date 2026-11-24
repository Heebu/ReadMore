import 'package:flartdart/flartdart.dart';
import '../../core/constants/app_colors.dart';
import '../../viewmodels/news_app_viewmodel.dart';

/// Modal for choosing edition and geographic region.
class EditionModal extends StatelessWidget {
  final NewsAppViewModel vm;
  final bool isMobile;

  const EditionModal({
    required this.vm,
    required this.isMobile,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final editions = [
      {'name': 'United States', 'code': 'US', 'flag': '🇺🇸'},
      {'name': 'United Kingdom', 'code': 'UK', 'flag': '🇬🇧'},
      {'name': 'Global International', 'code': 'GL', 'flag': '🌐'},
      {'name': 'Nigeria', 'code': 'NG', 'flag': '🇳🇬'},
      {'name': 'European Union', 'code': 'EU', 'flag': '🇪🇺'},
    ];

    return FDContainer(
      decoration: const BoxDecoration(color: FlartColor('rgba(0, 0, 0, 0.85)')),
      child: FDCenter(
        child: FDContainer(
          margin: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: vm.isDarkMode ? AppColors.darkCard : AppColors.lightCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderRegular, width: 1),
          ),
          child: FDConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: FDContainer(
              padding: const EdgeInsets.all(24),
              child: FDColumn(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FDRow(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const FDText('Select Edition & Region', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      FDGestureDetector(
                        onTap: () => vm.closeEditionModal(),
                        child: const FDIcon(icon: FDIcons.close, size: 20, color: FlartColors.grey),
                      ),
                    ],
                  ),
                  const FDSizedBox(height: 16),

                  FDColumn(
                    children: editions.map((ed) {
                      final isSelected = vm.selectedEdition == ed['name'];

                      return FDGestureDetector(
                        onTap: () => vm.setSelectedEdition(ed['name']!),
                        child: FDContainer(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryBlueSubtle
                                : (vm.isDarkMode ? AppColors.borderSubtle : AppColors.lightSurface),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected ? AppColors.primaryBlue : AppColors.borderSubtle,
                              width: 1,
                            ),
                          ),
                          child: FDRow(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              FDRow(
                                children: [
                                  FDText(ed['flag']!, style: const TextStyle(fontSize: 18)),
                                  const FDSizedBox(width: 10),
                                  FDText(ed['name']!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              if (isSelected)
                                const FDText(
                                  '✓',
                                  style: TextStyle(fontSize: 14, color: AppColors.primaryBlueLight, fontWeight: FontWeight.bold),
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
