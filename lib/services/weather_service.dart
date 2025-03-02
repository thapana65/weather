import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:Forecast/models/weather_model.dart';
import 'package:Forecast/database/hive_database.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class WeatherServices {
  Future<WeatherData> fetchWeather(String cityName) async {
    final String apiKey = dotenv.env['OPENWEATHER_API_KEY'] ?? '';
    final response = await http.get(
      Uri.parse(
        "https://api.openweathermap.org/data/2.5/weather?q=$cityName&units=metric&appid=$apiKey",
      ),
    );

    try {
      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);
        WeatherData weather = WeatherData.fromJson(json);

        HiveDatabase.updateCityCountry(cityName, weather.sys.country);

        return weather;
      } else {
        throw Exception('Failed to load weather data for $cityName');
      }
    } catch (e) {
      throw Exception("Error fetching weather data: ${e.toString()}");
    }
  }

  void checkEnv() {
    print("API Key Loaded: ${dotenv.env['OPENWEATHER_API_KEY']}");
  }
}
