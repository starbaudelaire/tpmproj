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
    required this.locationLabel,
    this.isStale = false,
  });

  final double temp;
  final String condition;
  final int humidity;
  final double windSpeed;
  final double uvIndex;
  final String locationLabel;
  final bool isStale;

  Map<String, dynamic> toJson() => {
        'temp': temp,
        'condition': condition,
        'humidity': humidity,
        'windSpeed': windSpeed,
        'uvIndex': uvIndex,
        'locationLabel': locationLabel,
      };

  factory WeatherModel.fromJson(Map<String, dynamic> json, {bool isStale = false}) {
    return WeatherModel(
      temp: (json['temp'] as num?)?.toDouble() ?? 0,
      condition: json['condition']?.toString() ?? 'Cuaca Jogja',
      humidity: (json['humidity'] as num?)?.round() ?? 0,
      windSpeed: (json['windSpeed'] as num?)?.toDouble() ?? 0,
      uvIndex: (json['uvIndex'] as num?)?.toDouble() ?? 0,
      locationLabel: json['locationLabel']?.toString() ?? 'Kota Yogyakarta, DI Yogyakarta',
      isStale: isStale,
    );
  }

  factory WeatherModel.unavailable() => WeatherModel(
        temp: 27,
        condition: 'Cuaca belum tersinkron',
        humidity: 70,
        windSpeed: 1.8,
        uvIndex: 4.0,
        locationLabel: 'Kota Yogyakarta, DI Yogyakarta',
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
    final cacheKey = '${AppConstants.weatherCacheKey}_${lat.toStringAsFixed(2)}_${lon.toStringAsFixed(2)}';
    final cacheTimeKey = '${AppConstants.weatherCacheTimeKey}_${lat.toStringAsFixed(2)}_${lon.toStringAsFixed(2)}';
    final cached = _prefs.getString(cacheKey) ?? _prefs.getString(AppConstants.weatherCacheKey);
    final cachedAt = _prefs.getInt(cacheTimeKey) ?? _prefs.getInt(AppConstants.weatherCacheTimeKey);
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
      final uvIndex = _currentUvIndex(hourly);

      final weather = WeatherModel(
        temp: (current['temperature_2m'] as num?)?.toDouble() ?? 0,
        condition: _conditionFromCode((current['weather_code'] as num?)?.toInt()),
        humidity: (current['relative_humidity_2m'] as num?)?.round() ?? 0,
        windSpeed: (current['wind_speed_10m'] as num?)?.toDouble() ?? 0,
        uvIndex: uvIndex,
        locationLabel: _locationLabel(lat, lon),
      );

      await _prefs.setString(cacheKey, jsonEncode(weather.toJson()));
      await _prefs.setInt(cacheTimeKey, DateTime.now().millisecondsSinceEpoch);
      return weather;
    } catch (_) {
      if (cached != null) {
        return WeatherModel.fromJson(jsonDecode(cached) as Map<String, dynamic>, isStale: true);
      }
      return WeatherModel.unavailable();
    }
  }

  double _currentUvIndex(Map<String, dynamic> hourly) {
    final values = hourly['uv_index'] as List<dynamic>? ?? const <dynamic>[];
    if (values.isEmpty) return _estimatedUvIndex();

    final times = hourly['time'] as List<dynamic>? ?? const <dynamic>[];
    var index = DateTime.now().hour.clamp(0, values.length - 1).toInt();
    if (times.isNotEmpty && times.length == values.length) {
      final now = DateTime.now();
      for (var i = 0; i < times.length; i++) {
        final parsed = DateTime.tryParse(times[i].toString());
        if (parsed != null && parsed.hour == now.hour) {
          index = i;
          break;
        }
      }
    }

    final raw = (values[index] as num?)?.toDouble() ?? 0.0;
    if (raw > 0) return raw;
    return _estimatedUvIndex();
  }

  double _estimatedUvIndex() {
    final hour = DateTime.now().hour;
    if (hour < 6 || hour >= 18) return 0.0;
    if (hour < 9 || hour >= 16) return 1.0;
    if (hour < 11 || hour >= 14) return 3.0;
    return 5.0;
  }

  String _locationLabel(double lat, double lon) {
    // Heuristik ringan supaya banner tidak hanya menulis "Yogyakarta".
    // Ini cukup untuk demo LBS tanpa menambah package geocoding baru.
    if (lat >= -7.86 && lat <= -7.72 && lon >= 110.32 && lon <= 110.43) {
      if (lat < -7.83) return 'Sewon, Bantul, DI Yogyakarta';
      if (lon > 110.39) return 'Banguntapan, Bantul, DI Yogyakarta';
      if (lat > -7.76) return 'Depok, Sleman, DI Yogyakarta';
      return 'Kota Yogyakarta, DI Yogyakarta';
    }
    if (lat > -7.75 && lon >= 110.30 && lon <= 110.45) return 'Sleman, DI Yogyakarta';
    if (lat < -7.86 && lon >= 110.25 && lon <= 110.45) return 'Bantul, DI Yogyakarta';
    if (lon < 110.25) return 'Kulon Progo, DI Yogyakarta';
    if (lon > 110.45) return 'Gunungkidul, DI Yogyakarta';
    return 'DI Yogyakarta';
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
