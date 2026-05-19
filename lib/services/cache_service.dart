import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weather_model.dart';

class CacheService {
  static const String _weatherCacheKey = 'cached_weather';
  static const String _lastCityKey = 'last_city';

  /// Save the weather data to local cache
  Future<void> cacheWeather(WeatherModel weather) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(weather.toJson());
    await prefs.setString(_weatherCacheKey, jsonString);
  }

  /// Retrieve the weather data from local cache
  Future<WeatherModel?> getCachedWeather() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_weatherCacheKey);
    
    if (jsonString != null) {
      try {
        final data = json.decode(jsonString);
        return WeatherModel.fromJson(data);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Save the last successfully searched city
  Future<void> saveLastCity(String city) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastCityKey, city);
  }

  /// Retrieve the last searched city
  Future<String?> getLastCity() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastCityKey);
  }
}
