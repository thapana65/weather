import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:Forecast/models/weather_model.dart';

class WeatherDetail extends StatelessWidget {
  final WeatherData weather;

  const WeatherDetail({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    DateTime localTime = DateTime.now().toUtc().add(
      Duration(seconds: weather.timezone),
    );

    String formattedTime = DateFormat('MMM d, hh:mm a').format(localTime);

    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 95),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    formattedTime,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.redAccent,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "${weather.name.isNotEmpty ? weather.name : "Unknown"}, ${weather.sys.country.isNotEmpty ? weather.sys.country : "--"}",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (weather.weather.isNotEmpty)
                        Image.network(
                          "https://openweathermap.org/img/wn/${weather.weather[0].icon}@2x.png",
                          width: 50,
                          height: 50,
                        ),
                      const SizedBox(width: 10),
                      Text(
                        "${weather.main.temp.toStringAsFixed(0)}°C",
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  if (weather.weather.isNotEmpty)
                    Text(
                      "Feels like ${weather.main.feelsLike.toStringAsFixed(0)}°C. ${weather.weather[0].description}.",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.air, size: 18, color: Colors.white),
                          const SizedBox(width: 5),
                          Text(
                            "${weather.wind.speed}m/s",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(width: 15),
                      Row(
                        children: [
                          const Icon(
                            Icons.speed,
                            size: 18,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            "${weather.main.pressure} hPa",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Humidity: ${weather.main.humidity}%",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Text(
                        "Visibility: ${(weather.visibility / 1000).toStringAsFixed(1)} km",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
