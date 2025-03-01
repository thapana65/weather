import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_application/database/hive_database.dart';
import 'package:weather_application/models/weather_model.dart';
import 'package:weather_application/services/services.dart'; // ✅ Import API
import 'package:weather_application/utils/utils.dart';

class WeatherList extends StatefulWidget {
  const WeatherList({super.key});

  @override
  State<WeatherList> createState() => _WeatherListState();
}

class _WeatherListState extends State<WeatherList> {
  List<Map<String, dynamic>> cities = [];
  Map<String, String> countryCache = {}; // ✅ แคชข้อมูล country

  @override
  void initState() {
    super.initState();
    _loadCities();
  }

  void _loadCities() {
    setState(() {
      cities = HiveDatabase.getCities();
    });

    // ✅ ดึง `country` สำหรับทุกเมือง
    for (var city in cities) {
      if (!countryCache.containsKey(city["name"])) {
        _fetchCountry(city["name"]);
      }
    }
  }

  Future<void> _fetchCountry(String cityName) async {
    try {
      WeatherData weatherData = await WeatherServices().fetchWeather(cityName);
      setState(() {
        countryCache[cityName] = weatherData.sys.country; // ✅ บันทึก country ในแคช
      });
    } catch (e) {
      setState(() {
        countryCache[cityName] = "--"; // ✅ ถ้าดึงไม่ได้ให้ใส่ "--"
      });
    }
  }

  void _deleteCity(String cityName) {
    deleteCity(context, cityName, countryCache[cityName] ?? "--", () {
      setState(() {
        cities = HiveDatabase.getCities();
        countryCache.remove(cityName); // ✅ ลบข้อมูลประเทศออกจากแคช
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("รายชื่อเมือง"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: cities.isEmpty
            ? const Center(
                child: Text(
                  "ไม่มีข้อมูล",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey),
                ),
              )
            : ListView.builder(
                itemCount: cities.length,
                itemBuilder: (context, index) {
                  final city = cities[index]["name"];
                  final addedAt = DateTime.parse(cities[index]["added_at"]);
                  final formattedDate = DateFormat('MMM d, yyyy - hh:mm a').format(addedAt);
                  final country = countryCache[city] ?? "--"; // ✅ ใช้ countryCache ถ้ามีข้อมูล

                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      title: Text("$city, $country", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)), // ✅ แสดง `เมือง, ประเทศ`
                      subtitle: Text(
                        "Added on: $formattedDate",
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => confirmDeleteCity(context, city, country, () {
                          _deleteCity(city);
                          Navigator.pop(context, true);
                        }),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
