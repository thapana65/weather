import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_application/models/weather_model.dart';
import 'package:weather_application/services/services.dart';
import 'package:weather_application/database/hive_database.dart';
import 'package:weather_application/utils/utils.dart';
import 'package:weather_application/screens/weather_add.dart';
import 'package:weather_application/screens/weather_list.dart';

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

  void _deleteCity(String cityName) {
    deleteCity(context, cityName, selectedCountry ?? "--", () {
      loadCities(context, (newCities, newSelectedCity) {
        setState(() {
          cities = newCities;
          selectedCity = newSelectedCity;
        });

        if (selectedCity != null) {
          fetchWeather(context, selectedCity!, _updateWeather, _setLoading);
        }
      });
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
      body: Padding(
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
    );
  }
}

class WeatherDetail extends StatelessWidget {
  final WeatherData weather;

  const WeatherDetail({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    String formattedTime = DateFormat('MMM d, hh:mm a').format(DateTime.now());

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          formattedTime,
          style: const TextStyle(fontSize: 14, color: Colors.redAccent),
        ),
        const SizedBox(height: 5),
        Text(
          "${weather.name.isNotEmpty ? weather.name : "Unknown"}, ${weather.sys.country.isNotEmpty ? weather.sys.country : "--"}",
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 5),
        if (weather.weather.isNotEmpty)
          Text(
            "Feels like ${weather.main.feelsLike.toStringAsFixed(0)}°C. ${weather.weather[0].description}.",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                const Icon(Icons.air, size: 18),
                const SizedBox(width: 5),
                Text("${weather.wind.speed}m/s"),
              ],
            ),
            const SizedBox(width: 15),
            Row(
              children: [
                const Icon(Icons.speed, size: 18),
                const SizedBox(width: 5),
                Text("${weather.main.pressure} hPa"),
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
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(width: 15),
            Text(
              "Visibility: ${(weather.visibility / 1000).toStringAsFixed(1)} km",
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }
}
