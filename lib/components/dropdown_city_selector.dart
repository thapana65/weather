import 'package:flutter/material.dart';

class CityDropdown extends StatelessWidget {
  final String? selectedCity;
  final List<Map<String, dynamic>> cities;
  final ValueChanged<String?> onChanged;

  const CityDropdown({
    super.key,
    required this.selectedCity,
    required this.cities,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedCity,
          dropdownColor: Colors.white,
          menuMaxHeight: 300,
          icon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(width: 2),
              const Icon(Icons.arrow_drop_down, color: Colors.black),
            ],
          ),
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          onChanged: onChanged,
          selectedItemBuilder: (BuildContext context) {
            return cities.map<Widget>((city) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("${city["name"]}, ${city["country"]}"),
                  const SizedBox(width: 2),
                ],
              );
            }).toList();
          },
          items: cities.map<DropdownMenuItem<String>>((city) {
            return DropdownMenuItem<String>(
              value: city["name"],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("${city["name"]}, ${city["country"]}"),
                  if (city["name"] == selectedCity)
                    const Icon(Icons.check, color: Colors.green, size: 18),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
