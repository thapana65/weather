import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_application/database/hive_database.dart';
import 'package:weather_application/models/weather_model.dart';
import 'package:weather_application/services/services.dart';
import 'package:weather_application/utils/utils.dart';

class WeatherList extends StatefulWidget {
  const WeatherList({super.key});

  @override
  State<WeatherList> createState() => _WeatherListState();
}

class _WeatherListState extends State<WeatherList> {
  List<Map<String, dynamic>> cities = [];
  Map<String, String> countryCache = {};
  bool isEditing = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadCities();
  }

  void _loadCities() {
    setState(() {
      cities = HiveDatabase.getCities();
    });

    // for (var city in cities) {
    //   if (!countryCache.containsKey(city["name"])) {
    //     _fetchCountry(city["name"]);
    //   }
    // }

    cities.sort((a, b) => ((a["order"] ?? 9999) as int).compareTo((b["order"] ?? 9999) as int));
  }

  Future<void> _fetchCountry(String cityName) async {
    try {
      WeatherData weatherData = await WeatherServices().fetchWeather(cityName);
      setState(() {
        countryCache[cityName] = weatherData.sys.country;
      });
    } catch (e) {
      setState(() {
        countryCache[cityName] = "--";
      });
    }
  }

  void _deleteCity(String cityName) {
    deleteCity(context, cityName, countryCache[cityName] ?? "--", () {
      setState(() {
        cities = HiveDatabase.getCities();
        countryCache.remove(cityName);
      });
    });
  }

  void _updateCityOrder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;
    setState(() {
      final movedCity = cities.removeAt(oldIndex);
      cities.insert(newIndex, movedCity);
    });

    HiveDatabase.updateCityOrder(cities);

    _loadCities();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("รายชื่อเมือง"),
          backgroundColor: Colors.deepPurple,
          actions: [
            IconButton(
              icon: Icon(
                isEditing ? Icons.check : Icons.edit,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  isEditing = !isEditing;
                });

                if (!isEditing) {
                  HiveDatabase.updateCityOrder(cities);
                  Navigator.pop(context, true);
                }
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                  : isEditing
                  ? ReorderableListView.builder(
                    itemCount: cities.length,
                    onReorder: _updateCityOrder,
                    itemBuilder: (context, index) {
                      final city = cities[index]["name"];
                      final addedAt = DateTime.parse(cities[index]["added_at"]);
                      final formattedDate = DateFormat(
                        'MMM d, yyyy - hh:mm a',
                      ).format(addedAt);
                      final country = countryCache[city] ?? "--";

                      return Card(
                        key: ValueKey(city),
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          title: Text(
                            "$city, $country",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            "Added on: $formattedDate",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          trailing: const Icon(
                            Icons.drag_handle,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    },
                  )
                  : ListView.builder(
                    itemCount: cities.length,
                    itemBuilder: (context, index) {
                      final city = cities[index]["name"];
                      final addedAt = DateTime.parse(cities[index]["added_at"]);
                      final formattedDate = DateFormat(
                        'MMM d, yyyy - hh:mm a',
                      ).format(addedAt);
                      final country = countryCache[city] ?? "--";

                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          title: Text(
                            "$city, $country",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            "Added on: $formattedDate",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed:
                                () => confirmDeleteCity(
                                  context,
                                  city,
                                  country,
                                  () {
                                    _deleteCity(city);
                                    Navigator.pop(context, true);
                                  },
                                ),
                          ),
                        ),
                      );
                    },
                  ),
        ),
      ),
    );
  }
}
