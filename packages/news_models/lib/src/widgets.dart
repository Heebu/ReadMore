/// Daily weather forecast snapshot
class DailyWeatherForecast {
  final String day;
  final double temperatureC;
  final String condition;
  final String iconCode;

  const DailyWeatherForecast({
    required this.day,
    required this.temperatureC,
    required this.condition,
    required this.iconCode,
  });

  Map<String, dynamic> toJson() => {
        'day': day,
        'temperatureC': temperatureC,
        'condition': condition,
        'iconCode': iconCode,
      };

  factory DailyWeatherForecast.fromJson(Map<String, dynamic> json) =>
      DailyWeatherForecast(
        day: json['day'] as String,
        temperatureC: (json['temperatureC'] as num).toDouble(),
        condition: json['condition'] as String,
        iconCode: json['iconCode'] as String? ?? 'sunny',
      );
}

/// Real-time utility widget data (Weather, Markets, Quick Reads)
class WeatherSnapshot {
  final String city;
  final String country;
  final double temperatureC;
  final String condition;
  final String iconCode;
  final int humidity;
  final double windSpeedKmh;
  final String stationCode;
  final int airQualityIndex;
  final List<DailyWeatherForecast> forecast;

  const WeatherSnapshot({
    required this.city,
    required this.country,
    required this.temperatureC,
    required this.condition,
    required this.iconCode,
    required this.humidity,
    required this.windSpeedKmh,
    this.stationCode = 'KNYC',
    this.airQualityIndex = 32,
    this.forecast = const [
      DailyWeatherForecast(day: 'Tue', temperatureC: 24, condition: 'Sunny', iconCode: '☀️'),
      DailyWeatherForecast(day: 'Wed', temperatureC: 19, condition: 'Showers', iconCode: '🌧️'),
      DailyWeatherForecast(day: 'Thu', temperatureC: 21, condition: 'Partly Cloudy', iconCode: '⛅'),
    ],
  });

  Map<String, dynamic> toJson() => {
        'city': city,
        'country': country,
        'temperatureC': temperatureC,
        'condition': condition,
        'iconCode': iconCode,
        'humidity': humidity,
        'windSpeedKmh': windSpeedKmh,
        'stationCode': stationCode,
        'airQualityIndex': airQualityIndex,
        'forecast': forecast.map((f) => f.toJson()).toList(),
      };

  factory WeatherSnapshot.fromJson(Map<String, dynamic> json) => WeatherSnapshot(
        city: json['city'] as String,
        country: json['country'] as String,
        temperatureC: (json['temperatureC'] as num).toDouble(),
        condition: json['condition'] as String,
        iconCode: json['iconCode'] as String? ?? 'partly-cloudy-day',
        humidity: (json['humidity'] as num?)?.toInt() ?? 50,
        windSpeedKmh: (json['windSpeedKmh'] as num?)?.toDouble() ?? 10.0,
        stationCode: json['stationCode'] as String? ?? 'KNYC',
        airQualityIndex: (json['airQualityIndex'] as num?)?.toInt() ?? 32,
        forecast: (json['forecast'] as List<dynamic>?)
                ?.map((f) => DailyWeatherForecast.fromJson(f as Map<String, dynamic>))
                .toList() ??
            const [
              DailyWeatherForecast(day: 'Tue', temperatureC: 24, condition: 'Sunny', iconCode: '☀️'),
              DailyWeatherForecast(day: 'Wed', temperatureC: 19, condition: 'Showers', iconCode: '🌧️'),
              DailyWeatherForecast(day: 'Thu', temperatureC: 21, condition: 'Partly Cloudy', iconCode: '⛅'),
            ],
      );
}

class MarketTickerItem {
  final String symbol;
  final String name;
  final double price;
  final double changePercent;
  final bool isPositive;
  final String sector;
  final List<double> sparkline;

  const MarketTickerItem({
    required this.symbol,
    required this.name,
    required this.price,
    required this.changePercent,
    required this.isPositive,
    this.sector = 'All',
    this.sparkline = const [100.0, 102.5, 101.8, 104.2, 103.5, 105.0],
  });

  Map<String, dynamic> toJson() => {
        'symbol': symbol,
        'name': name,
        'price': price,
        'changePercent': changePercent,
        'isPositive': isPositive,
        'sector': sector,
        'sparkline': sparkline,
      };

  factory MarketTickerItem.fromJson(Map<String, dynamic> json) => MarketTickerItem(
        symbol: json['symbol'] as String,
        name: json['name'] as String,
        price: (json['price'] as num).toDouble(),
        changePercent: (json['changePercent'] as num).toDouble(),
        isPositive: json['isPositive'] as bool,
        sector: json['sector'] as String? ?? 'All',
        sparkline: (json['sparkline'] as List<dynamic>?)
                ?.map((e) => (e as num).toDouble())
                .toList() ??
            const [100.0, 102.5, 101.8, 104.2, 103.5, 105.0],
      );
}
