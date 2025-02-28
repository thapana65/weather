import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:weather_application/models/weather_model.dart';

class WeatherServices {
  Future<WeatherData> fetchWeather(String cityName) async {
    final String apiKey = "4b14badf54b7df8ca8c6a46e89669f27";
    final response = await http.get(
      Uri.parse("https://api.openweathermap.org/data/2.5/weather?q=$cityName&units=metric&appid=$apiKey"),
    );

    try {
      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);
        return WeatherData.fromJson(json);
      } else {
        throw Exception('Failed to load weather data for $cityName');
      }
    } catch (e) {
      throw Exception("Error fetching weather data: ${e.toString()}");
    }
  }
}
