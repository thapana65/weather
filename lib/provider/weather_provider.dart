import 'package:flutter/material.dart';
import 'package:Forecast/models/weather_model.dart';
import 'package:Forecast/services/weather_service.dart';
import 'package:Forecast/database/hive_database.dart';

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

  void addCity(Map<String, String> city) {
    HiveDatabase.addCity(city);
    savedCities.add(city["name"] ?? "");
    notifyListeners();
  }

  void removeCity(String city) {
    HiveDatabase.removeCity(city);
    savedCities.remove(city);
  }

  void updateCityOrder(List<String> newOrder) {
    HiveDatabase.updateCityOrder(
      newOrder.map((city) => {"name": city}).toList(),
    );
    savedCities = newOrder;
    notifyListeners();
  }
}
