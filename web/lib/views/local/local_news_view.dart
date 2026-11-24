import 'package:flartdart/flartdart.dart';
import '../../core/constants/app_colors.dart';
import '../../viewmodels/news_app_viewmodel.dart';
import '../headlines/widgets/articles_grid.dart';

/// Local news explorer view with city switcher chips, weather spotlight hero card,
/// and local community reporting.
class LocalNewsView extends StatelessWidget {
  final NewsAppViewModel vm;
  final bool isMobile;
  final bool isTablet;

  const LocalNewsView({
    required this.vm,
    required this.isMobile,
    required this.isTablet,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final cities = ['New York', 'London', 'Tokyo', 'Lagos', 'Paris', 'San Francisco'];
    final weather = vm.currentWeather;

    // Filter local articles matching the selected city
    final localArticles = vm.sampleArticles.where((a) {
      return a.category == 'local' &&
          (a.tags.any((t) => t.toLowerCase() == vm.selectedCity.toLowerCase()) ||
              a.title.toLowerCase().contains(vm.selectedCity.toLowerCase()) ||
              a.summary.toLowerCase().contains(vm.selectedCity.toLowerCase()));
    }).toList();

    final articlesToShow = localArticles.isNotEmpty
        ? localArticles
        : vm.sampleArticles.where((a) => a.category == 'local').toList();

    return FDColumn(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // City Selector Navigation Tabs
        FDSingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: FDRow(
            children: cities.map((city) {
              final isSelected = vm.selectedCity == city;
              return FDGestureDetector(
                onTap: () => vm.setSelectedCity(city),
                child: FDContainer(
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryBlue
                        : (vm.isDarkMode ? AppColors.darkCard : AppColors.lightCard),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? AppColors.primaryBlue : AppColors.borderRegular,
                      width: 1,
                    ),
                  ),
                  child: FDRow(
                    children: [
                      FDText(_getCityEmoji(city), style: const TextStyle(fontSize: 16)),
                      const FDSizedBox(width: 6),
                      FDText(
                        city,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
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
        const FDSizedBox(height: 24),

        // Local Weather Hero Spotlight Card
        FDContainer(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [FlartColor('#0284C7'), FlartColor('#0369A1')],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(color: FlartColor('rgba(2, 132, 199, 0.3)'), blurRadius: 20, offset: Offset(0, 8)),
            ],
          ),
          child: FDRow(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FDColumn(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FDRow(
                    children: [
                      const FDText('📍 ', style: TextStyle(fontSize: 18)),
                      FDText(
                        '${vm.selectedCity}, ${weather.country}',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: FlartColors.white),
                      ),
                    ],
                  ),
                  const FDSizedBox(height: 6),
                  FDText(
                    weather.condition,
                    style: const TextStyle(fontSize: 16, color: FlartColor('#E0F2FE'), fontWeight: FontWeight.w600),
                  ),
                  const FDSizedBox(height: 12),
                  FDRow(
                    children: [
                      FDText(
                        '💧 Humidity: ${weather.humidity}%',
                        style: const TextStyle(fontSize: 13, color: FlartColor('#BAE6FD'), fontWeight: FontWeight.bold),
                      ),
                      const FDSizedBox(width: 16),
                      FDText(
                        '💨 Wind: ${weather.windSpeedKmh} km/h',
                        style: const TextStyle(fontSize: 13, color: FlartColor('#BAE6FD'), fontWeight: FontWeight.bold),
                      ),
                      const FDSizedBox(width: 16),
                      const FDText(
                        '🌿 Air Quality: Good (AQI 32)',
                        style: TextStyle(fontSize: 13, color: FlartColor('#BAE6FD'), fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
              FDText(
                '${weather.temperatureC.toInt()}°C',
                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: FlartColors.white),
              ),
            ],
          ),
        ),
        const FDSizedBox(height: 28),

        // City Local Articles Grid
        FDRow(
          children: [
            FDContainer(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const FDSizedBox(width: 10),
            FDText(
              'Top News from ${vm.selectedCity}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: vm.isDarkMode ? FlartColors.white : FlartColors.black,
              ),
            ),
          ],
        ),
        const FDSizedBox(height: 16),
        ArticlesGrid(
          articles: articlesToShow,
          columns: isMobile ? 1 : 2,
          vm: vm,
        ),
      ],
    );
  }

  String _getCityEmoji(String city) {
    switch (city) {
      case 'New York':
        return '🗽';
      case 'London':
        return '🎡';
      case 'Tokyo':
        return '🗼';
      case 'Lagos':
        return '🌴';
      case 'Paris':
        return '🥐';
      case 'San Francisco':
        return '🌁';
      default:
        return '📍';
    }
  }
}
