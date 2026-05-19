import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/weather_model.dart';


class ForecastCard extends StatelessWidget {
  final ForecastDayModel forecastDay;

  const ForecastCard({super.key, required this.forecastDay});

  @override
  Widget build(BuildContext context) {
    // Parse the date to get the day name
    DateTime date;
    try {
      date = DateTime.parse(forecastDay.date);
    } catch (e) {
      date = DateTime.now();
    }
    final dayName = DateFormat('EEEE').format(date); // e.g. "Monday"

    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            dayName.substring(0, 3), // Short day name, e.g. "Mon"
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          if (forecastDay.weatherIconUrl.isNotEmpty)
            Image.network(
              forecastDay.weatherIconUrl,
              width: 48,
              height: 48,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.cloud, size: 48, color: Colors.white),
            ),
          const SizedBox(height: 8),
          Text(
            '${forecastDay.maxTemp.round()}° / ${forecastDay.minTemp.round()}°',
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            forecastDay.weatherCondition,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
