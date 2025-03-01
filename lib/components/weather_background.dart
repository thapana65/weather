import 'package:flutter/material.dart';
import 'package:weather_animation/weather_animation.dart';

class WeatherBackground extends StatelessWidget {
  final String weatherCondition;

  const WeatherBackground({super.key, required this.weatherCondition});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: WrapperScene(
        children: _getWeatherWidgets(weatherCondition),
        colors: _getBackgroundColors(weatherCondition),
      ),
    );
  }

  List<Widget> _getWeatherWidgets(String condition) {
    switch (condition.toLowerCase()) {
      case "clear":
        return [SunWidget()];
      case "few clouds":
      case "scattered clouds":
        return [CloudWidget(), SunWidget()];
      case "clouds":
        return [CloudWidget()];
      case "rain":
        return [RainWidget()];
      case "thunderstorm":
        return [ThunderWidget(), RainWidget()];
      case "snow":
        return [SnowWidget()];
      case "wind":
      case "breeze":
      case "gale":
        return [WindWidget()];
      default:
        return [CloudWidget()];
    }
  }

  /// ✅ เปลี่ยนสีพื้นหลังตาม `ช่วงเวลา` และ `weatherCondition`
  List<Color> _getBackgroundColors(String condition) {
    String timeOfDay = _getTimeOfDay(); // ✅ เช็คช่วงเวลา

    if (timeOfDay == "morning") { // 🌅 เช้า
      switch (condition.toLowerCase()) {
        case "clear":
          return [const Color(0xFFFFD54F), const Color(0xFFFFF176)];
        case "clouds":
          return [const Color(0xFFFFE082), const Color(0xFFFFD54F)];
        case "rain":
          return [const Color(0xFF90A4AE), const Color(0xFF78909C)];
        case "thunderstorm":
          return [const Color(0xFF6D4C41), const Color(0xFF5D4037)];
        case "snow":
          return [const Color(0xFFE3F2FD), const Color(0xFFFFFFFF)];
        case "mist":
        case "fog":
          return [const Color(0xFFB0BEC5), const Color(0xFFCFD8DC)];
        default:
          return [const Color(0xFFFFF59D), const Color(0xFFFFD54F)];
      }
    } else if (timeOfDay == "afternoon") {
      switch (condition.toLowerCase()) {
        case "clear":
          return [const Color(0xFF64B5F6), const Color(0xFF90CAF9)];
        case "clouds":
          return [const Color(0xFFB0BEC5), const Color(0xFF90A4AE)];
        case "rain":
          return [const Color(0xFF42A5F5), const Color(0xFF64B5F6)];
        case "thunderstorm":
          return [const Color(0xFF303F9F), const Color(0xFF1A237E)];
        case "snow":
          return [const Color(0xFFE1F5FE), const Color(0xFFB3E5FC)];
        case "mist":
        case "fog":
          return [const Color(0xFF90A4AE), const Color(0xFFB0BEC5)];
        default:
          return [const Color(0xFF81D4FA), const Color(0xFF4FC3F7)];
      }
    } else if (timeOfDay == "evening") {
      switch (condition.toLowerCase()) {
        case "clear":
          return [const Color(0xFFFF8A65), const Color(0xFFD84315)];
        case "clouds":
          return [const Color(0xFFFFA726), const Color(0xFFFB8C00)];
        case "rain":
          return [const Color(0xFF546E7A), const Color(0xFF455A64)];
        case "thunderstorm":
          return [const Color(0xFF5C6BC0), const Color(0xFF3949AB)];
        case "snow":
          return [const Color(0xFFECEFF1), const Color(0xFFCFD8DC)];
        case "mist":
        case "fog":
          return [const Color(0xFFB0BEC5), const Color(0xFF90A4AE)];
        default:
          return [const Color(0xFFFF7043), const Color(0xFFF4511E)];
      }
    } else {
      switch (condition.toLowerCase()) {
        case "clear":
          return [const Color(0xFF0D47A1), const Color(0xFF283593)];
        case "clouds":
          return [const Color(0xFF37474F), const Color(0xFF455A64)];
        case "rain":
          return [const Color(0xFF1A237E), const Color(0xFF283593)];
        case "thunderstorm":
          return [const Color(0xFF3F51B5), const Color(0xFF303F9F)];
        case "snow":
          return [const Color(0xFFB0BEC5), const Color(0xFFECEFF1)];
        case "mist":
        case "fog":
          return [const Color(0xFF607D8B), const Color(0xFF78909C)];
        default:
          return [const Color(0xFF1E88E5), const Color(0xFF1976D2)];
      }
    }
  }

  String _getTimeOfDay() {
    int hour = DateTime.now().hour;

    if (hour >= 5 && hour < 10) {
      return "morning";
    } else if (hour >= 10 && hour < 16) {
      return "afternoon";
    } else if (hour >= 16 && hour < 19) {
      return "evening";
    } else {
      return "night";
    }
  }
}
