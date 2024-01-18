import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:ski_tracker/main.dart';

class WeatherManager {
  DateTime lastFetchTime = DateTime.now();

  // Current weather data
  double temperature = 0.0;
  int relativeHumidity = 0;
  double apparentTemperature = 0.0;
  int weatherCode = 0;
  double surfacePressure = 0.0;
  double windSpeed = 0.0;
  int windDirection = 0;

  // Daily weather data
  double maxTemperature = 0.0;
  double minTemperature = 0.0;
  String sunrise = '';
  String sunset = '';
  String uvIndexMax = '';

  // Hourly weather data
  double precipitationProbability = 0.0;
  double snowDepth = 0.0;
  double visibility = 0.0;

  bool weatherLoaded = false;
  bool locationLoaded = false;

  late final Timer _timer;

  Future<void> init() async {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!locationLoaded) {
        if (SkiTracker.getActivity().currentLatitude != 0.0 &&
            SkiTracker.getActivity().currentLongitude != 0.0) {
          fetchData(SkiTracker.getActivity().currentLatitude,
              SkiTracker.getActivity().currentLongitude);
          locationLoaded = true;
        }
        if (!weatherLoaded) {
          weatherLoaded = true;
        }
        if (weatherLoaded && locationLoaded) {
          _timer.cancel();
        }
      }
    });
    Timer(const Duration(minutes: 5), () {
      updateCurrentTemperature();
    });
  }

  Future<void> fetchData(double latitude, double longitude) async {
    final url = Uri.parse(
        "https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&current=temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,surface_pressure,wind_speed_10m,wind_direction_10m&hourly=precipitation_probability,snow_depth,visibility&daily=temperature_2m_max,temperature_2m_min,sunrise,sunset,uv_index_max");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      // Erfolgreiche Anfrage
      final data = json.decode(response.body);
      temperature = data['current']['temperature_2m'] ?? 0;
      relativeHumidity = data['current']['relative_humidity_2m'] ?? 0;
      apparentTemperature = data['current']['apparent_temperature'] ?? 0;
      weatherCode = data['current']['weather_code'] ?? 0;
      surfacePressure = data['current']['surface_pressure'] ?? 0;
      windSpeed = data['current']['wind_speed_10m'] ?? 0;
      windDirection = data['current']['wind_direction_10m'] ?? 0;

      maxTemperature = data['daily']['temperature_2m_max'] ?? 0;
      minTemperature = data['daily']['temperature_2m_min'] ?? 0;
      sunrise = data['daily']['sunrise'] ?? 0;
      sunset = data['daily']['sunset'] ?? 0;
      uvIndexMax = data['daily']['uv_index_max'] ?? 0;

      precipitationProbability =
          data['hourly']['precipitation_probability'] ?? 0;
      snowDepth = data['hourly']['snow_depth'] ?? 0;
      visibility = data['hourly']['visibility'] ?? 0;

      // Setze die letzten abgerufenen Daten
      lastFetchTime = DateTime.now();
    } else {
      // Fehler bei der Anfrage
      if (kDebugMode) {
        print("Fehler bei der Wetter Anfrage: ${response.statusCode}");
      }
    }
  }

  @override
  String toString() {
    return "WeatherManager: temperature: $temperature, relativeHumidity: $relativeHumidity, apparentTemperature: $apparentTemperature, weatherCode: $weatherCode, surfacePressure: $surfacePressure, windSpeed: $windSpeed, windDirection: $windDirection, maxTemperature: $maxTemperature, minTemperature: $minTemperature, sunrise: $sunrise, sunset: $sunset, uvIndexMax: $uvIndexMax, precipitationProbability: $precipitationProbability, snowDepth: $snowDepth, visibility: $visibility";
  }

  void updateCurrentTemperature() async {
    if (DateTime.now().hour != lastFetchTime.hour) {
      await fetchData(SkiTracker.getActivity().currentLatitude,
          SkiTracker.getActivity().currentLongitude);
      lastFetchTime = DateTime.now();
    }
  }
}
