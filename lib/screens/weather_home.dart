import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_application/models/weather_model.dart';
import 'package:weather_application/services/services.dart';
import 'package:weather_application/database/hive_database.dart';
import 'package:weather_application/screens/weather_add.dart';

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
  String? selectedContry;

  @override
  void initState() {
    super.initState();
    _loadCities();
  }

  void _loadCities() {
    setState(() {
      cities = HiveDatabase.getCities();
      if (cities.isNotEmpty) {
        selectedCity = cities.first["name"];
        fetchWeather(selectedCity!);
      }
    });
  }

  void fetchWeather(String cityName) {
    setState(() {
      isLoading = true;
    });

    WeatherServices()
        .fetchWeather(cityName)
        .then((value) {
          setState(() {
            weatherInfo = value;
            selectedContry =
                weatherInfo.sys.country.isNotEmpty
                    ? weatherInfo.sys.country
                    : "--";
            isLoading = false;
          });
        })
        .catchError((error) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Error: ${error.toString()}")));
          setState(() {
            isLoading = false;
          });
        });
  }

  void _confirmDeleteCity(String cityName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("ยืนยันการลบ"),
          content: Text(
            "คุณต้องการลบเมือง $cityName,${weatherInfo.sys.country} ใช่หรือไม่?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("ยกเลิก"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteCity(cityName);
              },
              child: const Text("ลบ", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _deleteCity(String cityName) {
    if (selectedCity == cityName) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("ไม่สามารถลบเมืองที่เลือกอยู่ได้")),
      );
      return;
    }

    HiveDatabase.removeCity(cityName);
    _loadCities();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title:
            cities.isEmpty
                ? const Text("Weather A", style: TextStyle(color: Colors.black))
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
                      fetchWeather(selectedCity!);
                    });
                  },
                  items:
                      cities.map<DropdownMenuItem<String>>((city) {
                        return DropdownMenuItem<String>(
                          value: city["name"],
                          child: Text(city["name"]),
                        );
                      }).toList(),
                ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black),
            onPressed: () async {
              final newCity = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WeatherAdd()),
              );

              if (newCity != null && newCity is String) {
                HiveDatabase.addCity(newCity);
                _loadCities();
                fetchWeather(newCity);
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
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: cities.length,
                        itemBuilder: (context, index) {
                          final city = cities[index]["name"];
                          final addedAt = DateTime.parse(
                            cities[index]["added_at"],
                          );

                          return ListTile(
                            title: Text(
                              city,
                              style: const TextStyle(fontSize: 18),
                            ),
                            subtitle: Text(
                              "Added on: ${DateFormat('MMM d, yyyy - hh:mm a').format(addedAt)}",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _confirmDeleteCity(city),
                            ),
                            onTap: () {
                              setState(() {
                                selectedCity = city;
                              });
                              fetchWeather(city);
                            },
                          );
                        },
                      ),
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
                Text(
                  "${weather.wind.speed}m/s ${_getWindDirection(weather.wind.deg)}",
                ),
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

  String _getWindDirection(int degree) {
    if (degree >= 337 || degree < 23) {
      return "N";
    } else if (degree >= 23 && degree < 68) {
      return "NE";
    } else if (degree >= 68 && degree < 113) {
      return "E";
    } else if (degree >= 113 && degree < 158) {
      return "SE";
    } else if (degree >= 158 && degree < 203) {
      return "S";
    } else if (degree >= 203 && degree < 248) {
      return "SW";
    } else if (degree >= 248 && degree < 293) {
      return "W";
    } else {
      return "NW";
    }
  }
}
