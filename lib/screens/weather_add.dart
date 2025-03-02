import 'package:flutter/material.dart';
import 'package:Forecast/services/search_autocomp_service.dart';
import 'package:Forecast/database/hive_database.dart';
import 'package:Forecast/utils/utils.dart';

class WeatherAdd extends StatefulWidget {
  const WeatherAdd({super.key});

  @override
  State<WeatherAdd> createState() => _WeatherAddState();
}

class _WeatherAddState extends State<WeatherAdd> {
  final TextEditingController cityController = TextEditingController();
  List<Map<String, String>> citySuggestions = [];

  void _fetchSuggestions(String query) async {
    if (query.isNotEmpty) {
      try {
        List<Map<String, String>> results = await SearchAutoCompService()
            .fetchCitySuggestions(query);
        setState(() {
          citySuggestions = results;
        });
      } catch (e) {
        print("Error fetching city suggestions: $e");
      }
    } else {
      setState(() {
        citySuggestions = [];
      });
    }
  }
  void _addCity(String cityName) {
    if (cityName.isEmpty) {
      showErrorDialog(context, "โปรดกรอกชื่อเมือง");
      return;
    }

    List<Map<String, dynamic>> existingCities = HiveDatabase.getCities();
    bool cityExists = existingCities.any(
      (city) => city["name"].toString().toLowerCase() == cityName.toLowerCase(),
    );

    if (cityExists) {
      showErrorDialog(context, "เมืองนี้ถูกเพิ่มแล้ว");
      return;
    }

    String country = "--";
    try {

    } catch (e) {
      print("Error fetching country: $e");
    }

    HiveDatabase.addCity({"name": cityName, "country": country});
    showSnackBar(context, "$cityName ($country) ถูกเพิ่มเรียบร้อยแล้ว");

    Navigator.pop(context, {"name": cityName, "country": country});
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
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 12),
              Autocomplete<Map<String, String>>(
                optionsBuilder: (TextEditingValue textEditingValue) async {
                  _fetchSuggestions(textEditingValue.text);
                  return citySuggestions;
                },
                displayStringForOption:
                    (Map<String, String> option) =>
                        "${option["name"]}, ${option["country"]}",
                onSelected: (Map<String, String> selection) {
                  cityController.text = selection["name"]!;
                },
                fieldViewBuilder: (
                  BuildContext context,
                  TextEditingController textEditingController,
                  FocusNode focusNode,
                  VoidCallback onFieldSubmitted,
                ) {
                  return TextField(
                    controller: textEditingController,
                    focusNode: focusNode,
                    onChanged: _fetchSuggestions,
                    decoration: InputDecoration(
                      labelText: "ค้นหาเมือง...",
                      labelStyle: const TextStyle(color: Colors.deepPurple),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.deepPurple,
                      ),
                      filled: true,
                      fillColor: Colors.deepPurple.withOpacity(0.05),
                    ),
                  );
                },
                optionsViewBuilder: (
                  BuildContext context,
                  AutocompleteOnSelected<Map<String, String>> onSelected,
                  Iterable<Map<String, String>> options,
                ) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 5.0,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: options.length,
                          itemBuilder: (BuildContext context, int index) {
                            final Map<String, String> option = options
                                .elementAt(index);
                            return ListTile(
                              title: Text(
                                "${option["name"]}, ${option["country"]}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              onTap: () => onSelected(option),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: () => _addCity(cityController.text),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                    shadowColor: Colors.deepPurpleAccent,
                  ),
                  child: const Text(
                    "เพิ่มเมือง",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
