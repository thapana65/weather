# Weather App

Developed by **Thapana**

## Framework
- **Flutter** (Android)

## Setting Up `.env` File
To configure the environment variables, follow these steps:

1. **Create a new `.env` file** in `assets/env/.env`.
2. **Add the following content** to the `.env` file:
   ```env
   OPENWEATHER_API_KEY=your_api_key_here
   ```
3. **Ensure the `.env` file is not pushed to Git** by adding it to `.gitignore`:
   ```
   # Environment Variables
   .env
   ```
4. **Modify `pubspec.yaml`** to include the `.env` file:
   ```yaml
   flutter:
     assets:
       - assets/env/.env
   ```
5. **Load the `.env` file in your Flutter project** using `flutter_dotenv`:
   ```dart
   import 'package:flutter_dotenv/flutter_dotenv.dart';
   
   void main() async {
       await dotenv.load(fileName: "assets/env/.env");
       String apiKey = dotenv.env['OPENWEATHER_API_KEY'] ?? '';
       print('API Key: $apiKey');
   }
   ```

## Dependencies Used
The following dependencies are required for this project:
```yaml
  cupertino_icons: ^1.0.8
  http: ^1.3.0
  interpolate_animated: ^0.0.1
  intl: ^0.20.2
  hive: ^2.2.3
  path_provider: ^2.1.5
  hive_flutter: ^1.1.0
  weather_animation: ^1.1.2
  flutter_dotenv: ^5.2.1
  flutter_launcher_icons: ^0.14.3
```

## Running the Project
1. Install Flutter dependencies:
   ```sh
   flutter pub get
   ```
2. Run the application:
   ```sh
   flutter run
   ```

## Building the APK
To generate the release APK, run:
```sh
flutter build apk --release
```

