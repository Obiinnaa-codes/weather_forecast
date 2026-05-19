import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';
import '../constants/secrets.dart';

class WeatherApiService {
  static const String _baseUrl = 'https://api.weatherapi.com/v1';

  /// Fetches weather data for a given city
  Future<WeatherModel> fetchWeather(String city) async {
    try {
      final url = Uri.parse(
          '$_baseUrl/forecast.json?key=${Secrets.weatherApiKey}&q=$city&days=3&aqi=no&alerts=no');
      
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return WeatherModel.fromJson(data);
      } else {
        // If the server returns an error (e.g. invalid city name), throw an exception
        final data = json.decode(response.body);
        final errorMessage = data['error']['message'] ?? 'Failed to load weather data.';
        throw Exception(errorMessage);
      }
    } catch (e) {
      // Re-throw to be handled by the UI layer
      throw Exception('Failed to fetch weather: $e');
    }
  }
}
