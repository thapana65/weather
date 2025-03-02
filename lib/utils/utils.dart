import 'package:flutter/material.dart';
import 'package:Forecast/database/hive_database.dart';
import 'package:Forecast/services/weather_service.dart';
import 'package:Forecast/models/weather_model.dart';

void showErrorDialog(BuildContext context, String msg) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("เกิดข้อผิดพลาด"),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("ตกลง"),
          ),
        ],
      );
    },
  );
}

void confirmDeleteCity(
  BuildContext context,
  String cityName,
  String country,
  VoidCallback onDelete,
) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("ยืนยันการลบ"),
        content: Text("คุณต้องการลบเมือง $cityName, $country ใช่หรือไม่?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("ยกเลิก"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete();
            },
            child: const Text("ลบ", style: TextStyle(color: Colors.red)),
          ),
        ],
      );
    },
  );
}

void deleteCity(
  BuildContext context,
  String cityName,
  String country,
  Function updateUI,
) {
  HiveDatabase.removeCity(cityName);
  updateUI();

  showSnackBar(context, "ลบเมือง $cityName, $country  เรียบร้อยแล้ว");
}

void showSnackBar(BuildContext context, String msg) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
}

void loadCities(
  BuildContext context,
  Function(List<Map<String, dynamic>>, String?) updateUI,
) {
  List<Map<String, dynamic>> cities = HiveDatabase.getCities();
  for (var city in cities) {
    if (!city.containsKey("country")) {
      city["country"] = "--";
    }
  }
  
  cities.sort((a, b) => ((a["order"] ?? 9999) as int).compareTo((b["order"] ?? 9999) as int));
  
  String? selectedCity = cities.isNotEmpty ? cities.first["name"] : null;
  updateUI(cities, selectedCity);
}

void fetchWeather(
  String cityName,
  Function(WeatherData, String) updateUI,
  Function() setLoading,
) {
  setLoading();

  WeatherServices()
      .fetchWeather(cityName)
      .then((weatherInfo) {
        String country =
            weatherInfo.sys.country.isNotEmpty ? weatherInfo.sys.country : "--";
        updateUI(weatherInfo, country);
      })
      .catchError((error) {
        print("Error: ${error.toString()}");
        setLoading();
      });
}
