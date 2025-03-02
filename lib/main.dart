import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:Forecast/database/hive_database.dart';
import 'package:Forecast/screens/weather_home.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: "assets/env/.env");
    print("✅ API Key Loaded: ${dotenv.env['OPENWEATHER_API_KEY']}");
  } catch (e) {
    print("❌ Failed to load .env file: $e");
  }

  await Hive.initFlutter();
  await HiveDatabase.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WeatherHome(),
    );
  }
}
