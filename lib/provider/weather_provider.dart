import 'package:flutter/material.dart';
import 'package:weather_application/models/weather_model.dart';
import 'package:weather_application/services/services.dart';
import 'package:weather_application/database/hive_database.dart';

class WeatherProvider extends ChangeNotifier {
  WeatherData? weatherData;
  bool isLoading = false;
  List<String> savedCities = [];

  WeatherProvider() {
    loadSavedCities();
  }

  Future<void> fetchWeather(String cityName) async {
    isLoading = true;
    notifyListeners();

    weatherData = await WeatherServices().fetchWeather(cityName);

    isLoading = false;
    notifyListeners();
  }

  void loadSavedCities() {
    savedCities = HiveDatabase.getCities().cast<String>();
    notifyListeners();
  }

  void addCity(String city) {
    HiveDatabase.addCity(city);
    savedCities.add(city);
    notifyListeners();
  }

  void removeCity(String city) {
    HiveDatabase.removeCity(city);
    savedCities.remove(city);
  }
}
