import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveDatabase {
  static const String _boxName = "cities";

  /// ✅ เปิด Hive และเปิด Box เมื่อลงแอป
  static Future<void> init() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<Map>(_boxName);
    }
  }

  static Box<Map> get box => Hive.box<Map>(_boxName);

  /// ✅ ดึงรายชื่อเมืองทั้งหมด พร้อมวันที่บันทึก
  static List<Map<String, dynamic>> getCities() {
    return box.values
        .map((city) => Map<String, dynamic>.from(city as Map)) // ✅ แปลง Type
        .toList();
  }

  /// ✅ เพิ่มเมืองใหม่ พร้อมวันที่บันทึก
  static void addCity(String city) {
    if (!box.containsKey(city)) {
      box.put(city, {
        "name": city,
        "added_at": DateTime.now().toIso8601String(), // ✅ บันทึกวันที่แบบ ISO
      });
    }
  }

  /// ✅ ลบเมืองออกจากฐานข้อมูล
  static void removeCity(String city) {
    box.delete(city);
  }
}
