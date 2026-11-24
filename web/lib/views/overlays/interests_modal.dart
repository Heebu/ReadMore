import 'package:flartdart/flartdart.dart';
import '../../core/constants/app_colors.dart';
import '../../viewmodels/news_app_viewmodel.dart';

/// Modal for tuning user interests and topics to steer algorithmic feed personalization.
class InterestsModal extends StatelessWidget {
  final NewsAppViewModel vm;
  final bool isMobile;

  const InterestsModal({
    required this.vm,
    required this.isMobile,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FDContainer(
      decoration: const BoxDecoration(color: FlartColor('rgba(0, 0, 0, 0.85)')),
      child: FDCenter(
        child: FDContainer(
          margin: EdgeInsets.all(isMobile ? 12 : 32),
          decoration: BoxDecoration(
            color: vm.isDarkMode ? AppColors.darkCard : AppColors.lightCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderRegular, width: 1),
          ),
          child: FDConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600, maxHeight: 600),
            child: FDContainer(
              padding: const EdgeInsets.all(28),
              child: FDColumn(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FDRow(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const FDText(
                        'Tune Your Intelligence Feed',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      FDGestureDetector(
                        onTap: () => vm.closeInterestsModal(),
                        child: const FDIcon(icon: FDIcons.close, size: 24, color: FlartColors.grey),
                      ),
                    ],
                  ),
                  const FDSizedBox(height: 8),
                  const FDText(
                    'Select topics to weight algorithmic recommendations in your "For You" stream.',
                    style: TextStyle(fontSize: 12, color: FlartColors.grey),
                  ),
                  const FDSizedBox(height: 20),

                  Expanded(
                    child: FDSingleChildScrollView(
                      child: FDWrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: vm.allAvailableInterests.map((interest) {
                          final isSelected = vm.userInterests.contains(interest);

                          return FDGestureDetector(
                            onTap: () => vm.toggleInterest(interest),
                            child: FDContainer(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primaryBlue
                                    : (vm.isDarkMode ? AppColors.borderSubtle : AppColors.lightInput),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected ? AppColors.primaryBlue : AppColors.borderRegular,
                                  width: 1,
                                ),
                              ),
                              child: FDRow(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (isSelected) const FDText('✓ ', style: TextStyle(fontSize: 12, color: FlartColors.white)),
                                  FDText(
                                    interest,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                      color: isSelected ? FlartColors.white : (vm.isDarkMode ? FlartColors.white : FlartColors.black),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const FDSizedBox(height: 20),

                  FDGestureDetector(
                    onTap: () => vm.closeInterestsModal(),
                    child: FDContainer(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const FDCenter(
                        child: FDText(
                          'Save & Update Feed',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: FlartColors.white),
                        ),
                      ),
                    ),
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
