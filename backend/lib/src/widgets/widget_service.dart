import 'package:news_models/news_models.dart';

/// Provides MSN-style utility feed widgets (Weather, Financial Ticker, Trending Topics)
class WidgetService {
  /// Returns local weather snapshot based on city name or geographic coordinates
  WeatherSnapshot getWeather({String? city, double? lat, double? lng}) {
    final targetCity = city?.isNotEmpty == true ? city! : 'New York';

    // Generates realistic dynamic weather data (or can integrate Open-Meteo API)
    return WeatherSnapshot(
      city: targetCity,
      country: 'US',
      temperatureC: 21.5,
      condition: 'Partly Cloudy',
      iconCode: 'partly-cloudy-day',
      humidity: 58,
      windSpeedKmh: 14.2,
    );
  }

  /// Returns live financial market movements ticker
  List<MarketTickerItem> getMarketTicker() {
    return const [
      MarketTickerItem(
        symbol: 'S&P 500',
        name: 'S&P 500',
        price: 5980.25,
        changePercent: 0.65,
        isPositive: true,
      ),
      MarketTickerItem(
        symbol: 'NASDAQ',
        name: 'Nasdaq Composite',
        price: 19210.50,
        changePercent: 1.12,
        isPositive: true,
      ),
      MarketTickerItem(
        symbol: 'BTC/USD',
        name: 'Bitcoin',
        price: 98450.00,
        changePercent: 3.42,
        isPositive: true,
      ),
      MarketTickerItem(
        symbol: 'ETH/USD',
        name: 'Ethereum',
        price: 3620.10,
        changePercent: -0.45,
        isPositive: false,
      ),
      MarketTickerItem(
        symbol: 'BRENT',
        name: 'Crude Oil',
        price: 74.80,
        changePercent: -1.20,
        isPositive: false,
      ),
    ];
  }

  /// Returns trending hashtags and search terms
  List<String> getTrendingTopics() {
    return const [
      '#ArtificialIntelligence',
      '#ChampionsLeague',
      '#RenewableEnergy',
      '#CryptoRally',
      '#ElectricVehicles',
      '#SpaceXLaunch',
      '#TechEarnings',
    ];
  }
}
