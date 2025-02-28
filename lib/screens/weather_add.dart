import 'package:flutter/material.dart';
import 'package:weather_application/database/hive_database.dart';

class WeatherAdd extends StatefulWidget {
  const WeatherAdd({super.key});

  @override
  State<WeatherAdd> createState() => _WeatherAddState();
}

class _WeatherAddState extends State<WeatherAdd> {
  final TextEditingController cityController = TextEditingController();

  void _addCity() {
    String cityName = cityController.text.trim();

    if (cityName.isEmpty) {
      _showErrorDialog("โปรดกรอกชื่อเมือง");
      return;
    }

    List<Map<String, dynamic>> existingCities = HiveDatabase.getCities();
    bool cityExists = existingCities.any(
      (city) => city["name"].toString().toLowerCase() == cityName.toLowerCase(),
    );

    if (cityExists) {
      _showErrorDialog("เมืองนี้ถูกเพิ่มแล้ว");
      return;
    }

    HiveDatabase.addCity(cityName);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("$cityName ถูกเพิ่มเรียบร้อยแล้ว")));

    Navigator.pop(context, cityName);
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("ข้อผิดพลาด"),
          content: Text(message),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("เพิ่มเมือง"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "กรอกชื่อเมืองที่ต้องการเพิ่ม",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: cityController,
              decoration: InputDecoration(
                labelText: "ชื่อเมือง",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.location_city),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _addCity, // ✅ เรียกฟังก์ชันตรวจสอบข้อมูลก่อนเพิ่ม
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "เพิ่มเมือง",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
