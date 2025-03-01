import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_application/models/weather_model.dart';
import 'package:weather_application/database/hive_database.dart';
import 'package:weather_application/utils/utils.dart';
import 'package:weather_application/screens/weather_add.dart';
import 'package:weather_application/screens/weather_list.dart';
import 'package:weather_application/components/weather_background.dart';

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
      });

      if (selectedCity != null) {
        fetchWeather(context, selectedCity!, _updateWeather, _setLoading);
      }
    });
  }

  void _updateWeather(WeatherData newWeather, String newCountry) {
    setState(() {
      weatherInfo = newWeather;
      selectedCountry = newCountry;
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
        title:
            cities.isEmpty
                ? const Text(
                  "Weather App",
                  style: TextStyle(color: Colors.black),
                )
                : DropdownButton<String>(
                  value: selectedCity,
                  dropdownColor: Colors.white,
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  underline: Container(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedCity = newValue;
                      fetchWeather(
                        context,
                        selectedCity!,
                        _updateWeather,
                        _setLoading,
                      );
                    });
                  },
                  items:
                      cities.map<DropdownMenuItem<String>>((city) {
                        return DropdownMenuItem<String>(
                          value: city["name"],
                          child: Text(
                            "${city["name"]}, ${selectedCountry ?? "--"}",
                          ),
                        );
                      }).toList(),
                ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt, color: Colors.black),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WeatherList()),
              );

              if (result == true) {
                loadCities(context, (newCities, newSeletedCity) {
                  setState(() {
                    cities = newCities;
                    selectedCity = newSeletedCity;
                  });

                  if (selectedCity != null) {
                    fetchWeather(
                      context,
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

              if (newCity != null && newCity is String) {
                HiveDatabase.addCity(newCity);
                loadCities(context, (newCities, newSelectedCity) {
                  setState(() {
                    cities = newCities;
                    selectedCity = newSelectedCity;
                  });

                  if (selectedCity != null) {
                    fetchWeather(
                      context,
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

class WeatherDetail extends StatelessWidget {
  final WeatherData weather;

  const WeatherDetail({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    String formattedTime = DateFormat('MMM d, hh:mm a').format(DateTime.now());

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
