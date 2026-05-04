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

    if (cached != null && cached.length > 10 && cacheStillFresh) {
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

      final rates = <String, double>{};
      for (final entry in rawRates.entries) {
        final code = entry.key.toString().trim().toUpperCase();
        final value = entry.value;
        if (code.length != 3 || value is! num || value <= 0) continue;
        rates[code] = value.toDouble();
      }

      // Endpoint memakai USD sebagai base, pastikan USD tetap tersedia.
      rates['USD'] = rates['USD'] ?? 1;
      if (!rates.containsKey('IDR')) {
        throw const FormatException('IDR rate not found');
      }

      final sortedRates = Map.fromEntries(
        rates.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
      );

      await _writeCache(sortedRates);
      return sortedRates;
    } catch (_) {
      // Kalau API gagal tapi ada cache lama, tetap pakai cache lama.
      if (cached != null && cached.isNotEmpty) return cached;

      // Fallback hanya untuk mode offline pertama kali. Nilai ini bukan sumber utama.
      final fallback = <String, double>{
        'AUD': 1.52,
        'CAD': 1.36,
        'CHF': 0.91,
        'CNY': 7.20,
        'EUR': 0.92,
        'GBP': 0.79,
        'IDR': 16000,
        'JPY': 150.0,
        'KRW': 1330.0,
        'MYR': 4.70,
        'SAR': 3.75,
        'SGD': 1.35,
        'THB': 36.0,
        'USD': 1,
      };
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

      final rates = <String, double>{};
      for (final entry in decoded.entries) {
        final value = entry.value;
        if (value is! num || value <= 0) continue;
        rates[entry.key.toString().toUpperCase()] = value.toDouble();
      }
      return rates;
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
