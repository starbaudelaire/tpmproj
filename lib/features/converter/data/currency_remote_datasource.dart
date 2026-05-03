import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/constants/app_constants.dart';

class CurrencyRemoteDataSource {
  CurrencyRemoteDataSource({
    required Dio dio,
    required SharedPreferences prefs,
  })  : _dio = dio,
        _prefs = prefs;

  final Dio _dio;
  final SharedPreferences _prefs;

  Future<Map<String, double>> fetchRates() async {
    final cached = _readCachedRates();
    final cachedAt = _prefs.getInt(AppConstants.currencyCacheTimeKey);
    final cacheStillFresh = cachedAt != null &&
        DateTime.now().millisecondsSinceEpoch - cachedAt <
            const Duration(hours: 1).inMilliseconds;

    if (cached != null && cacheStillFresh) {
      return cached;
    }

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.currencyBaseUrl,
        options: Options(
          receiveTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 10),
        ),
      );

      final rawRates = response.data?['rates'];
      if (rawRates is! Map) {
        throw const FormatException('Currency response does not contain rates');
      }

      final rates = rawRates.map(
        (key, value) => MapEntry(
          key.toString().toUpperCase(),
          (value as num).toDouble(),
        ),
      );

      final subset = <String, double>{
        'USD': rates['USD'] ?? 1,
        'IDR': rates['IDR'] ?? (throw const FormatException('IDR rate not found')),
        'EUR': rates['EUR'] ?? (throw const FormatException('EUR rate not found')),
      };

      await _writeCache(subset);
      return subset;
    } catch (_) {
      // Kalau API gagal tapi ada cache lama, tetap pakai cache lama.
      if (cached != null) return cached;

      final fallback = <String, double>{'USD': 1, 'IDR': 16000, 'EUR': 0.92};
      await _writeCache(fallback);
      return fallback;
    }
  }

  Map<String, double>? _readCachedRates() {
    final cached = _prefs.getString(AppConstants.currencyCacheKey);
    if (cached == null) return null;

    try {
      final decoded = jsonDecode(cached);
      if (decoded is! Map) return null;

      return decoded.map(
        (key, value) => MapEntry(
          key.toString().toUpperCase(),
          (value as num).toDouble(),
        ),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeCache(Map<String, double> rates) async {
    await _prefs.setString(AppConstants.currencyCacheKey, jsonEncode(rates));
    await _prefs.setInt(
      AppConstants.currencyCacheTimeKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }
}
