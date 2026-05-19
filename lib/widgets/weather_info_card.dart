import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../utils/constants.dart';

class WeatherInfoCard extends StatelessWidget {
  final WeatherModel weather;

  const WeatherInfoCard({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          weather.cityName,
          style: AppStyles.headline,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (weather.weatherIconUrl.isNotEmpty)
              Image.network(
                weather.weatherIconUrl,
                width: 64,
                height: 64,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.cloud, size: 64, color: Colors.white),
              ),
            const SizedBox(width: 10),
            Text(
              '${weather.currentTemp.round()}°',
              style: AppStyles.temperature,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(weather.weatherCondition, style: AppStyles.subhead),
        const SizedBox(height: 20),
        // Extra info
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildInfoItem(
                Icons.water_drop,
                '${weather.humidity}%',
                'Humidity',
              ),
              _buildInfoItem(Icons.air, '${weather.windSpeed} km/h', 'Wind'),
              _buildInfoItem(
                Icons.thermostat,
                '${weather.feelsLikeTemp.round()}°',
                'Feels Like',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}
