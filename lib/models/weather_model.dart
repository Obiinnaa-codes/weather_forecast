/// Model representing the current weather data and forecast for a specific city.
/// It contains helper factory constructors to map raw API responses into structured Dart objects
/// and methods to serialize them back to JSON (for caching purposes).
class WeatherModel {
  final String cityName;
  final double currentTemp;
  final String weatherCondition;
  final int humidity;
  final double windSpeed;
  final String weatherIconUrl;
  final double feelsLikeTemp;
  final List<ForecastDayModel> forecast;

  WeatherModel({
    required this.cityName,
    required this.currentTemp,
    required this.weatherCondition,
    required this.humidity,
    required this.windSpeed,
    required this.weatherIconUrl,
    required this.feelsLikeTemp,
    required this.forecast,
  });

  /// Factory constructor to parse raw JSON from WeatherAPI into a structured WeatherModel.
  /// 
  /// Utilizes defensive type casting (`as num`) before calling `.toDouble()` to safely 
  /// handle numbers that might be returned as integers or doubles in different environments.
  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final current = json['current'];
    final location = json['location'];
    
    // Parse the 3-day forecast list
    final forecastList = (json['forecast']['forecastday'] as List)
        .map((e) => ForecastDayModel.fromJson(e))
        .toList();

    return WeatherModel(
      cityName: location['name'],
      // Safely parsing numeric values
      currentTemp: (current['temp_c'] as num).toDouble(),
      weatherCondition: current['condition']['text'],
      humidity: current['humidity'],
      windSpeed: (current['wind_kph'] as num).toDouble(),
      // Prepend 'https:' because WeatherAPI returns relative protocol URLs (e.g., //cdn.weatherapi.com/...)
      weatherIconUrl: 'https:${current['condition']['icon']}',
      feelsLikeTemp: (current['feelslike_c'] as num).toDouble(),
      forecast: forecastList,
    );
  }

  /// Converts the WeatherModel instance back into a JSON Map.
  /// 
  /// This is essential for the offline fallback feature, as we serialize this Map
  /// into a string and store it locally using `shared_preferences`.
  Map<String, dynamic> toJson() {
    return {
      'location': {
        'name': cityName,
      },
      'current': {
        'temp_c': currentTemp,
        'condition': {
          'text': weatherCondition,
          // Strip the prepended 'https:' to mirror the raw API structure
          'icon': weatherIconUrl.replaceFirst('https:', ''),
        },
        'humidity': humidity,
        'wind_kph': windSpeed,
        'feelslike_c': feelsLikeTemp,
      },
      'forecast': {
        'forecastday': forecast.map((e) => e.toJson()).toList(),
      }
    };
  }
}

/// Model representing a single day's forecast.
class ForecastDayModel {
  final String date;
  final double minTemp;
  final double maxTemp;
  final String weatherCondition;
  final String weatherIconUrl;

  ForecastDayModel({
    required this.date,
    required this.minTemp,
    required this.maxTemp,
    required this.weatherCondition,
    required this.weatherIconUrl,
  });

  /// Factory constructor to parse raw JSON forecast day data.
  factory ForecastDayModel.fromJson(Map<String, dynamic> json) {
    final day = json['day'];
    return ForecastDayModel(
      date: json['date'],
      minTemp: (day['mintemp_c'] as num).toDouble(),
      maxTemp: (day['maxtemp_c'] as num).toDouble(),
      weatherCondition: day['condition']['text'],
      // Prepend 'https:' to match relative protocol URLs from the API
      weatherIconUrl: 'https:${day['condition']['icon']}',
    );
  }

  /// Converts the ForecastDayModel instance back into a JSON Map.
  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'day': {
        'mintemp_c': minTemp,
        'maxtemp_c': maxTemp,
        'condition': {
          'text': weatherCondition,
          'icon': weatherIconUrl.replaceFirst('https:', ''),
        }
      }
    };
  }
}
