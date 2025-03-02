import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SearchAutoCompService {
  final String apiKey = dotenv.env['OPENWEATHER_API_KEY'] ?? '';

  Future<List<Map<String, String>>> fetchCitySuggestions(String query) async {
    final response = await http.get(
      Uri.parse("https://api.openweathermap.org/geo/1.0/direct?q=$query&limit=5&appid=$apiKey"),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map<Map<String, String>>((city) {
        return {
          "name": city["name"],
          "country": city["country"] ?? "--"
        };
      }).toList();
    } else {
      throw Exception("Failed to load city suggestions");
    }
  }
}
