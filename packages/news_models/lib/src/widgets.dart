/// Real-time MSN-style utility widget data (Weather, Markets, Quick Reads)
class WeatherSnapshot {
  final String city;
  final String country;
  final double temperatureC;
  final String condition;
  final String iconCode;
  final int humidity;
  final double windSpeedKmh;

  const WeatherSnapshot({
    required this.city,
    required this.country,
    required this.temperatureC,
    required this.condition,
    required this.iconCode,
    required this.humidity,
    required this.windSpeedKmh,
  });

  Map<String, dynamic> toJson() => {
        'city': city,
        'country': country,
        'temperatureC': temperatureC,
        'condition': condition,
        'iconCode': iconCode,
        'humidity': humidity,
        'windSpeedKmh': windSpeedKmh,
      };

  factory WeatherSnapshot.fromJson(Map<String, dynamic> json) => WeatherSnapshot(
        city: json['city'] as String,
        country: json['country'] as String,
        temperatureC: (json['temperatureC'] as num).toDouble(),
        condition: json['condition'] as String,
        iconCode: json['iconCode'] as String,
        humidity: (json['humidity'] as num).toInt(),
        windSpeedKmh: (json['windSpeedKmh'] as num).toDouble(),
      );
}

class MarketTickerItem {
  final String symbol;
  final String name;
  final double price;
  final double changePercent;
  final bool isPositive;

  const MarketTickerItem({
    required this.symbol,
    required this.name,
    required this.price,
    required this.changePercent,
    required this.isPositive,
  });

  Map<String, dynamic> toJson() => {
        'symbol': symbol,
        'name': name,
        'price': price,
        'changePercent': changePercent,
        'isPositive': isPositive,
      };

  factory MarketTickerItem.fromJson(Map<String, dynamic> json) => MarketTickerItem(
        symbol: json['symbol'] as String,
        name: json['name'] as String,
        price: (json['price'] as num).toDouble(),
        changePercent: (json['changePercent'] as num).toDouble(),
        isPositive: json['isPositive'] as bool,
      );
}
