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
    return box.values.map((city) => Map<String, dynamic>.from(city)).toList();
  }

  static void addCity(String city) {
    if (!box.containsKey(city)) {
      box.put(city, {
        "name": city,
        "added_at": DateTime.now().toIso8601String(),
      });
    }
  }

  static void updateCityOrder(List<Map<String, dynamic>> newOrder) {
    final box = Hive.box<Map>(_boxName);
    box.clear();

    for (int i = 0; i < newOrder.length; i++) {
      newOrder[i]["order"] = i;
      if (!newOrder[i].containsKey("country")) {
        newOrder[i]["country"] = "--";
      }
      box.put(newOrder[i]["name"], newOrder[i]);
    }
  }

  static void removeCity(String city) {
    box.delete(city);
  }
}
