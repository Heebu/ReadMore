import 'package:flartdart/flartdart.dart';
import '../../core/widgets/filter_chip_pill.dart';
import '../../core/widgets/section_header.dart';
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
              return FilterChipPill(
                label: city,
                iconOrEmoji: _getCityEmoji(city),
                isSelected: vm.selectedCity == city,
                onTap: () => vm.setSelectedCity(city),
                isDarkMode: vm.isDarkMode,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              );
            }).toList(),
          ),
        ),
        const FDSizedBox(height: 24),

        // Local Weather Hero Spotlight Card in Broadsheet Dispatch Styling
        FDContainer(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: vm.isDarkMode ? const FlartColor('#15161C') : const FlartColor('#FFFFFF'),
            borderRadius: BorderRadius.circular(3),
            border: Border.all(
              color: vm.isDarkMode ? const FlartColor('#33353F') : const FlartColor('#D4CFBE'),
              width: 1,
            ),
          ),
          child: FDRow(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FDColumn(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FDRow(
                    children: [
                      const FDText('📍 ', style: TextStyle(fontSize: 16)),
                      FDText(
                        '${vm.selectedCity.toUpperCase()}, ${weather.country.toUpperCase()}',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Playfair Display',
                          letterSpacing: 0.02,
                          color: vm.isDarkMode ? FlartColors.white : FlartColors.black,
                        ),
                      ),
                    ],
                  ),
                  const FDSizedBox(height: 6),
                  FDText(
                    weather.condition,
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'Newsreader',
                      fontStyle: FontStyle.italic,
                      color: vm.isDarkMode ? const FlartColor('#A2A096') : const FlartColor('#555555'),
                    ),
                  ),
                  const FDSizedBox(height: 12),
                  FDRow(
                    children: [
                      FDText(
                        'Humidity: ${weather.humidity}%',
                        style: TextStyle(
                          fontSize: 11,
                          fontFamily: 'Space Grotesk',
                          color: vm.isDarkMode ? const FlartColor('#8E8C85') : const FlartColor('#666666'),
                        ),
                      ),
                      const FDSizedBox(width: 16),
                      FDText(
                        'Wind: ${weather.windSpeedKmh} km/h',
                        style: TextStyle(
                          fontSize: 11,
                          fontFamily: 'Space Grotesk',
                          color: vm.isDarkMode ? const FlartColor('#8E8C85') : const FlartColor('#666666'),
                        ),
                      ),
                      const FDSizedBox(width: 16),
                      FDText(
                        'Air Quality: 32 (Good)',
                        style: TextStyle(
                          fontSize: 11,
                          fontFamily: 'Space Grotesk',
                          color: vm.isDarkMode ? const FlartColor('#8E8C85') : const FlartColor('#666666'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              FDText(
                '${weather.temperatureC.toInt()}°C',
                style: TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Playfair Display',
                  color: vm.isDarkMode ? const FlartColor('#F4F3EE') : const FlartColor('#111111'),
                ),
              ),
            ],
          ),
        ),
        const FDSizedBox(height: 28),

        // City Local Articles Grid
        SectionHeader(
          title: 'Top News from ${vm.selectedCity}',
          isDarkMode: vm.isDarkMode,
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
