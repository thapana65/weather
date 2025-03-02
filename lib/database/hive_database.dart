import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveDatabase {
  static const String _boxName = "cities";

  static Future<void> init() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<Map>(_boxName);
    }
  }

  static Box<Map> get box => Hive.box<Map>(_boxName);

  static List<Map<String, dynamic>> getCities() {
    final box = Hive.box<Map>(_boxName);

    List<Map<String, dynamic>> cities =
        box.values.map((city) {
          return {
            "name": city["name"],
            "country": city.containsKey("country") ? city["country"] : "--",
            "added_at":
                city.containsKey("added_at")
                    ? city["added_at"]
                    : DateTime.now().toIso8601String(),
            "order": city.containsKey("order") ? city["order"] : 9999,
          };
        }).toList();

    cities.sort((a, b) => (a["order"] as int).compareTo(b["order"] as int));

     print("✅ Cities from Hive: $cities");

    return cities;
  }

  static void updateCityCountry(String city, String country) {
    if (box.containsKey(city)) {
      var cityData = box.get(city);
      cityData?["country"] = country;
      box.put(city, cityData!);
    }
  }

  static void addCity(Map<String, String> cityData) {
    if (!box.containsKey(cityData["name"])) {
      box.put(cityData["name"], {
        "name": cityData["name"],
        "country": cityData["country"] ?? "--",
        "added_at": DateTime.now().toIso8601String(),
      });
    }
  }

  static void updateCityOrder(List<Map<String, dynamic>> newOrder) {
    final box = Hive.box<Map>(_boxName);

    for (int i = 0; i < newOrder.length; i++) {
      var cityData = box.get(newOrder[i]["name"]);
      if (cityData != null) {
        cityData["order"] = i;
        box.put(newOrder[i]["name"], cityData);
      }
    }
  }

  static void removeCity(String city) {
    box.delete(city);
  }
}
