import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/api_constants.dart';
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

  factory WeatherModel.fromJson(
    Map<String, dynamic> json, {
    bool isStale = false,
  }) {
    return WeatherModel(
      temp: (json['temp'] as num).toDouble(),
      condition: json['condition'] as String,
      humidity: json['humidity'] as int,
      windSpeed: (json['windSpeed'] as num).toDouble(),
      uvIndex: (json['uvIndex'] as num).toDouble(),
      isStale: isStale,
    );
  }
}

class WeatherRemoteDataSource {
  WeatherRemoteDataSource({required Dio dio, required SharedPreferences prefs})
      : _dio = dio,
        _prefs = prefs;

  final Dio _dio;
  final SharedPreferences _prefs;

  Future<WeatherModel> fetchWeather({
    double lat = -7.7971,
    double lon = 110.3708,
  }) async {
    final cached = _prefs.getString(AppConstants.weatherCacheKey);
    final cachedAt = _prefs.getInt(AppConstants.weatherCacheTimeKey);
    if (cached != null &&
        cachedAt != null &&
        DateTime.now().millisecondsSinceEpoch - cachedAt <
            const Duration(minutes: 30).inMilliseconds) {
      return WeatherModel.fromJson(jsonDecode(cached) as Map<String, dynamic>);
    }

    if (ApiConstants.weatherApiKey.isEmpty) {
      return _stubWeather();
    }

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.weatherBaseUrl,
        queryParameters: {
          'lat': lat,
          'lon': lon,
          'appid': ApiConstants.weatherApiKey,
          'units': 'metric',
          'lang': 'id',
        },
      );
      final data = response.data ?? <String, dynamic>{};
      final weather = WeatherModel(
        temp: (data['main']['temp'] as num).toDouble(),
        condition: (data['weather'] as List).first['description'] as String,
        humidity: data['main']['humidity'] as int,
        windSpeed: (data['wind']['speed'] as num).toDouble(),
        uvIndex: 4.3,
      );
      await _prefs.setString(
        AppConstants.weatherCacheKey,
        jsonEncode(weather.toJson()),
      );
      await _prefs.setInt(
        AppConstants.weatherCacheTimeKey,
        DateTime.now().millisecondsSinceEpoch,
      );
      return weather;
    } catch (_) {
      if (cached != null) {
        return WeatherModel.fromJson(
          jsonDecode(cached) as Map<String, dynamic>,
          isStale: true,
        );
      }
      return _stubWeather(isStale: true);
    }
  }

  WeatherModel _stubWeather({bool isStale = false}) => WeatherModel(
        temp: 29,
        condition: 'Cerah Berawan',
        humidity: 76,
        windSpeed: 8.1,
        uvIndex: 5.4,
        isStale: isStale,
      );
}
