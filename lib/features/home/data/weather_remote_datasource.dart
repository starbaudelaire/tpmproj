import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';

class WeatherModel {
  WeatherModel({
    required this.temp,
    required this.condition,
    required this.humidity,
    required this.windSpeed,
    required this.uvIndex,
    this.isStale = false,
  });

  final double temp;
  final String condition;
  final int humidity;
  final double windSpeed;
  final double uvIndex;
  final bool isStale;

  Map<String, dynamic> toJson() => {
        'temp': temp,
        'condition': condition,
        'humidity': humidity,
        'windSpeed': windSpeed,
        'uvIndex': uvIndex,
      };

  factory WeatherModel.fromJson(Map<String, dynamic> json, {bool isStale = false}) {
    return WeatherModel(
      temp: (json['temp'] as num?)?.toDouble() ?? 0,
      condition: json['condition']?.toString() ?? 'Cuaca Jogja',
      humidity: (json['humidity'] as num?)?.round() ?? 0,
      windSpeed: (json['windSpeed'] as num?)?.toDouble() ?? 0,
      uvIndex: (json['uvIndex'] as num?)?.toDouble() ?? 0,
      isStale: isStale,
    );
  }

  factory WeatherModel.unavailable() => WeatherModel(
        temp: 27,
        condition: 'Cuaca belum tersinkron',
        humidity: 70,
        windSpeed: 1.8,
        uvIndex: 4.0,
        isStale: true,
      );
}

class WeatherRemoteDataSource {
  WeatherRemoteDataSource({required Dio dio, required SharedPreferences prefs})
      : _dio = dio,
        _prefs = prefs;

  final Dio _dio;
  final SharedPreferences _prefs;

  static const _openMeteoUrl = 'https://api.open-meteo.com/v1/forecast';

  Future<WeatherModel> fetchWeather({double lat = -7.7971, double lon = 110.3708}) async {
    final cached = _prefs.getString(AppConstants.weatherCacheKey);
    final cachedAt = _prefs.getInt(AppConstants.weatherCacheTimeKey);
    final hasFreshCache = cached != null &&
        cachedAt != null &&
        DateTime.now().millisecondsSinceEpoch - cachedAt < const Duration(minutes: 30).inMilliseconds;

    if (hasFreshCache) {
      return WeatherModel.fromJson(jsonDecode(cached) as Map<String, dynamic>);
    }

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        _openMeteoUrl,
        queryParameters: {
          'latitude': lat,
          'longitude': lon,
          'current': 'temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m',
          'hourly': 'uv_index',
          'forecast_days': 1,
          'timezone': 'Asia/Jakarta',
          'wind_speed_unit': 'ms',
        },
        options: Options(responseType: ResponseType.json),
      );

      final data = response.data ?? <String, dynamic>{};
      final current = data['current'] as Map<String, dynamic>? ?? <String, dynamic>{};
      final hourly = data['hourly'] as Map<String, dynamic>? ?? <String, dynamic>{};
      final uvValues = hourly['uv_index'] as List<dynamic>? ?? const <dynamic>[];
      final double uvIndex = uvValues.isNotEmpty
          ? ((uvValues.first as num?)?.toDouble() ?? 0.0)
          : 0.0;

      final weather = WeatherModel(
        temp: (current['temperature_2m'] as num?)?.toDouble() ?? 0,
        condition: _conditionFromCode((current['weather_code'] as num?)?.toInt()),
        humidity: (current['relative_humidity_2m'] as num?)?.round() ?? 0,
        windSpeed: (current['wind_speed_10m'] as num?)?.toDouble() ?? 0,
        uvIndex: uvIndex,
      );

      await _prefs.setString(AppConstants.weatherCacheKey, jsonEncode(weather.toJson()));
      await _prefs.setInt(AppConstants.weatherCacheTimeKey, DateTime.now().millisecondsSinceEpoch);
      return weather;
    } catch (_) {
      if (cached != null) {
        return WeatherModel.fromJson(jsonDecode(cached) as Map<String, dynamic>, isStale: true);
      }
      return WeatherModel.unavailable();
    }
  }

  String _conditionFromCode(int? code) {
    switch (code) {
      case 0:
        return 'Cerah, enak buat jalan-jalan';
      case 1:
      case 2:
        return 'Cerah berawan';
      case 3:
        return 'Berawan';
      case 45:
      case 48:
        return 'Berkabut tipis';
      case 51:
      case 53:
      case 55:
        return 'Gerimis ringan';
      case 61:
      case 63:
      case 65:
        return 'Hujan, siapkan payung';
      case 80:
      case 81:
      case 82:
        return 'Hujan lokal';
      case 95:
      case 96:
      case 99:
        return 'Hujan petir';
      default:
        return 'Cuaca Jogja terkini';
    }
  }
}
