import 'package:news_models/news_models.dart';

/// Provides utility feed widgets (Weather, Financial Bourse Ticker, Trending Topics)
class WidgetService {
  static const Map<String, WeatherSnapshot> _cityWeatherPresets = {
    'new york': WeatherSnapshot(
      city: 'New York',
      country: 'US',
      temperatureC: 22.0,
      condition: 'Partly Cloudy',
      iconCode: 'partly-cloudy-day',
      humidity: 58,
      windSpeedKmh: 14.2,
      stationCode: 'KNYC',
      airQualityIndex: 32,
      forecast: [
        DailyWeatherForecast(day: 'Tue', temperatureC: 24, condition: 'Sunny', iconCode: '☀️'),
        DailyWeatherForecast(day: 'Wed', temperatureC: 19, condition: 'Showers', iconCode: '🌧️'),
        DailyWeatherForecast(day: 'Thu', temperatureC: 21, condition: 'Partly Cloudy', iconCode: '⛅'),
      ],
    ),
    'london': WeatherSnapshot(
      city: 'London',
      country: 'UK',
      temperatureC: 16.5,
      condition: 'Light Rain',
      iconCode: 'rainy',
      humidity: 78,
      windSpeedKmh: 18.0,
      stationCode: 'EGLL',
      airQualityIndex: 26,
      forecast: [
        DailyWeatherForecast(day: 'Tue', temperatureC: 15, condition: 'Showers', iconCode: '🌧️'),
        DailyWeatherForecast(day: 'Wed', temperatureC: 17, condition: 'Cloudy', iconCode: '⛅'),
        DailyWeatherForecast(day: 'Thu', temperatureC: 18, condition: 'Partly Cloudy', iconCode: '⛅'),
      ],
    ),
    'tokyo': WeatherSnapshot(
      city: 'Tokyo',
      country: 'JP',
      temperatureC: 20.0,
      condition: 'Clear Sky',
      iconCode: 'sunny',
      humidity: 45,
      windSpeedKmh: 9.5,
      stationCode: 'RJTT',
      airQualityIndex: 18,
      forecast: [
        DailyWeatherForecast(day: 'Tue', temperatureC: 21, condition: 'Sunny', iconCode: '☀️'),
        DailyWeatherForecast(day: 'Wed', temperatureC: 22, condition: 'Sunny', iconCode: '☀️'),
        DailyWeatherForecast(day: 'Thu', temperatureC: 19, condition: 'Cloudy', iconCode: '⛅'),
      ],
    ),
    'paris': WeatherSnapshot(
      city: 'Paris',
      country: 'FR',
      temperatureC: 18.0,
      condition: 'Mild Breeze',
      iconCode: 'partly-cloudy-day',
      humidity: 62,
      windSpeedKmh: 12.0,
      stationCode: 'LFPG',
      airQualityIndex: 29,
      forecast: [
        DailyWeatherForecast(day: 'Tue', temperatureC: 19, condition: 'Partly Cloudy', iconCode: '⛅'),
        DailyWeatherForecast(day: 'Wed', temperatureC: 21, condition: 'Sunny', iconCode: '☀️'),
        DailyWeatherForecast(day: 'Thu', temperatureC: 17, condition: 'Overcast', iconCode: '☁️'),
      ],
    ),
    'lagos': WeatherSnapshot(
      city: 'Lagos',
      country: 'NG',
      temperatureC: 29.5,
      condition: 'Tropical Haze',
      iconCode: 'partly-cloudy-day',
      humidity: 82,
      windSpeedKmh: 15.0,
      stationCode: 'DNMM',
      airQualityIndex: 45,
      forecast: [
        DailyWeatherForecast(day: 'Tue', temperatureC: 31, condition: 'Sunny', iconCode: '☀️'),
        DailyWeatherForecast(day: 'Wed', temperatureC: 30, condition: 'Thunderstorms', iconCode: '⛈️'),
        DailyWeatherForecast(day: 'Thu', temperatureC: 29, condition: 'Showers', iconCode: '🌧️'),
      ],
    ),
    'san francisco': WeatherSnapshot(
      city: 'San Francisco',
      country: 'US',
      temperatureC: 17.0,
      condition: 'Coastal Fog',
      iconCode: 'fog',
      humidity: 74,
      windSpeedKmh: 20.5,
      stationCode: 'KSFO',
      airQualityIndex: 22,
      forecast: [
        DailyWeatherForecast(day: 'Tue', temperatureC: 18, condition: 'Fog', iconCode: '🌫️'),
        DailyWeatherForecast(day: 'Wed', temperatureC: 19, condition: 'Sunny', iconCode: '☀️'),
        DailyWeatherForecast(day: 'Thu', temperatureC: 17, condition: 'Partly Cloudy', iconCode: '⛅'),
      ],
    ),
  };

  static const List<MarketTickerItem> _allMarketTickers = [
    MarketTickerItem(
      symbol: 'S&P 500',
      name: 'S&P 500 Index',
      price: 5984.10,
      changePercent: 0.72,
      isPositive: true,
      sector: 'Indices',
      sparkline: [5940, 5955, 5960, 5972, 5984],
    ),
    MarketTickerItem(
      symbol: 'NASDAQ',
      name: 'Nasdaq Composite',
      price: 19245.80,
      changePercent: 1.15,
      isPositive: true,
      sector: 'Indices',
      sparkline: [19050, 19120, 19180, 19210, 19245],
    ),
    MarketTickerItem(
      symbol: 'DOW',
      name: 'Dow Jones Industrial',
      price: 43480.20,
      changePercent: -0.18,
      isPositive: false,
      sector: 'Indices',
      sparkline: [43600, 43550, 43520, 43490, 43480],
    ),
    MarketTickerItem(
      symbol: 'BTC/USD',
      name: 'Bitcoin',
      price: 98650.00,
      changePercent: 3.65,
      isPositive: true,
      sector: 'Crypto',
      sparkline: [95200, 96400, 97100, 98200, 98650],
    ),
    MarketTickerItem(
      symbol: 'ETH/USD',
      name: 'Ethereum',
      price: 3640.50,
      changePercent: 2.10,
      isPositive: true,
      sector: 'Crypto',
      sparkline: [3520, 3560, 3590, 3620, 3640],
    ),
    MarketTickerItem(
      symbol: 'SOL/USD',
      name: 'Solana',
      price: 242.80,
      changePercent: 4.80,
      isPositive: true,
      sector: 'Crypto',
      sparkline: [230, 234, 238, 240, 242.8],
    ),
    MarketTickerItem(
      symbol: 'NVDA',
      name: 'NVIDIA Corp',
      price: 148.90,
      changePercent: 2.45,
      isPositive: true,
      sector: 'Tech',
      sparkline: [142, 144, 146, 147.5, 148.9],
    ),
    MarketTickerItem(
      symbol: 'AAPL',
      name: 'Apple Inc',
      price: 228.40,
      changePercent: 0.85,
      isPositive: true,
      sector: 'Tech',
      sparkline: [225, 226, 227, 227.8, 228.4],
    ),
    MarketTickerItem(
      symbol: 'MSFT',
      name: 'Microsoft Corp',
      price: 426.15,
      changePercent: 0.60,
      isPositive: true,
      sector: 'Tech',
      sparkline: [422, 423.5, 424, 425.2, 426.15],
    ),
    MarketTickerItem(
      symbol: 'BRENT',
      name: 'Brent Crude Oil',
      price: 74.20,
      changePercent: -1.15,
      isPositive: false,
      sector: 'Energy',
      sparkline: [75.5, 75.1, 74.8, 74.4, 74.2],
    ),
    MarketTickerItem(
      symbol: 'GOLD',
      name: 'Gold Spot USD/oz',
      price: 2715.40,
      changePercent: 0.40,
      isPositive: true,
      sector: 'Energy',
      sparkline: [2700, 2705, 2710, 2712, 2715.4],
    ),
    MarketTickerItem(
      symbol: 'EUR/USD',
      name: 'Euro / US Dollar',
      price: 1.0542,
      changePercent: -0.22,
      isPositive: false,
      sector: 'Currencies',
      sparkline: [1.058, 1.056, 1.055, 1.0545, 1.0542],
    ),
  ];

  /// Returns local weather snapshot based on city name or geographic coordinates
  WeatherSnapshot getWeather({String? city, double? lat, double? lng}) {
    final key = (city ?? 'New York').trim().toLowerCase();
    if (_cityWeatherPresets.containsKey(key)) {
      return _cityWeatherPresets[key]!;
    }

    // Default dynamic fallback
    return WeatherSnapshot(
      city: city?.isNotEmpty == true ? city! : 'New York',
      country: 'Global',
      temperatureC: 22.0,
      condition: 'Partly Cloudy',
      iconCode: 'partly-cloudy-day',
      humidity: 55,
      windSpeedKmh: 12.0,
    );
  }

  /// Returns live financial market movements ticker optionally filtered by sector
  List<MarketTickerItem> getMarketTicker({String? sector}) {
    if (sector == null || sector.isEmpty || sector.toLowerCase() == 'all') {
      return _allMarketTickers;
    }
    final filtered = _allMarketTickers
        .where((m) => m.sector.toLowerCase() == sector.toLowerCase())
        .toList();
    return filtered.isNotEmpty ? filtered : _allMarketTickers;
  }

  /// Returns trending hashtags and search terms
  List<String> getTrendingTopics() {
    return const [
      '#ArtificialIntelligence',
      '#ClimateAccord2026',
      '#ChampionsLeague',
      '#QuantumComputing',
      '#BTCto120k',
      '#RapidTransit',
      '#CloudEnergy',
      '#Supergrid',
      '#CleanNuclear',
      '#HoloCinema',
      '#AutonomousDev',
    ];
  }
}
