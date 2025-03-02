import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:Forecast/models/weather_model.dart';
import 'package:Forecast/database/hive_database.dart';
import 'package:Forecast/utils/utils.dart';
import 'package:Forecast/screens/weather_add.dart';
import 'package:Forecast/screens/weather_list.dart';
import 'package:Forecast/components/weather_background.dart';
import 'package:Forecast/components/weather_detail.dart';
import 'package:Forecast/components/dropdown_city_selector.dart';

class WeatherHome extends StatefulWidget {
  const WeatherHome({super.key});

  @override
  State<WeatherHome> createState() => _WeatherHomeState();
}

class _WeatherHomeState extends State<WeatherHome> {
  late WeatherData weatherInfo;
  bool isLoading = false;
  List<Map<String, dynamic>> cities = [];
  String? selectedCity;
  String? selectedCountry;
  bool isDropdownOpened = false;

  @override
  void initState() {
    super.initState();

    weatherInfo = WeatherData(
      coord: Coord(lon: 0.0, lat: 0.0),
      weather: [
        WeatherInfo(main: "Clear", description: "", icon: "01d", id: 0),
      ],
      base: '',
      main: MainInfo(
        temp: 0.0,
        feelsLike: 0.0,
        tempMin: 0.0,
        tempMax: 0.0,
        pressure: 0,
        humidity: 0,
        seaLevel: 0,
        grndLevel: 0,
      ),
      visibility: 0,
      wind: Wind(speed: 0.0, deg: 0, gust: 0.0),
      clouds: Clouds(all: 0),
      dt: 0,
      sys: Sys(country: '', sunrise: 0, sunset: 0),
      timezone: 0,
      id: 0,
      name: '',
      cod: 0,
    );

    loadCities(context, (newCities, newSelectedCity) {
      setState(() {
        cities = newCities;
        selectedCity = newSelectedCity;
        selectedCountry = _getCountry(newSelectedCity);
      });

      if (selectedCity != null) {
        fetchWeather(selectedCity!, _updateWeather, _setLoading);
      }
    });
  }

  String _getCountry(String? cityName) {
    if (cityName == null) return "--";
    final city = cities.firstWhere(
      (c) => c["name"] == cityName,
      orElse: () => {"country": "--"},
    );
    return city["country"] ?? "--";
  }

  void _updateWeather(WeatherData newWeather, String newCountry) {
    setState(() {
      weatherInfo = newWeather;
      selectedCountry = _getCountry(selectedCity);
      isLoading = false;
    });
  }

  void _setLoading() {
    setState(() {
      isLoading = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: CityDropdown(
          selectedCity: selectedCity,
          cities: cities,
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                selectedCity = newValue;
                selectedCountry = _getCountry(newValue);
                fetchWeather(
                  selectedCity!,
                  _updateWeather,
                  _setLoading,
                );
              });
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt, color: Colors.black),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WeatherList()),
              );
              if (result == true) {
                loadCities(context, (newCities, newSelectedCity) {
                  setState(() {
                    cities = newCities;
                    selectedCity = newSelectedCity;
                    selectedCountry = _getCountry(newSelectedCity);
                  });
                  if (selectedCity != null) {
                    fetchWeather(
                      selectedCity!,
                      _updateWeather,
                      _setLoading,
                    );
                  }
                });
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black),
            onPressed: () async {
              final newCity = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WeatherAdd()),
              );
              if (newCity != null && newCity is Map<String, String>) {
                HiveDatabase.addCity(newCity);
                loadCities(context, (newCities, newSelectedCity) {
                  setState(() {
                    cities = newCities;
                    selectedCity = newSelectedCity;
                    selectedCountry = _getCountry(newSelectedCity);
                  });
                  if (selectedCity != null) {
                    fetchWeather(
                      selectedCity!,
                      _updateWeather,
                      _setLoading,
                    );
                  }
                });
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          WeatherBackground(
            weatherCondition:
                weatherInfo.weather.isNotEmpty
                    ? weatherInfo.weather[0].main
                    : "Clear",
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child:
                cities.isEmpty
                    ? const Center(
                      child: Text(
                        "ไม่มีข้อมูล",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    )
                    : Column(
                      children: [
                        Expanded(
                          child:
                              isLoading
                                  ? const Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.black,
                                    ),
                                  )
                                  : WeatherDetail(weather: weatherInfo),
                        ),
                      ],
                    ),
          ),
        ],
      ),
    );
  }
}
