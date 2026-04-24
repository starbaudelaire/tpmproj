import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/constants/app_constants.dart';

class CurrencyRemoteDataSource {
  CurrencyRemoteDataSource({required Dio dio, required SharedPreferences prefs})
      : _dio = dio,
        _prefs = prefs;

  final Dio _dio;
  final SharedPreferences _prefs;

  Future<Map<String, double>> fetchRates() async {
    final cached = _prefs.getString(AppConstants.currencyCacheKey);
    final cachedAt = _prefs.getInt(AppConstants.currencyCacheTimeKey);
    if (cached != null &&
        cachedAt != null &&
        DateTime.now().millisecondsSinceEpoch - cachedAt <
            const Duration(hours: 1).inMilliseconds) {
      return Map<String, double>.from(jsonDecode(cached) as Map);
    }

    if (ApiConstants.currencyApiKey.isEmpty) {
      return {'USD': 1, 'IDR': 15430, 'EUR': 0.92};
    }

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.currencyBaseUrl,
      );
      final rates = Map<String, double>.from(
        (response.data?['rates'] as Map).map(
          (key, value) => MapEntry(key.toString(), (value as num).toDouble()),
        ),
      );
      final subset = {
        'USD': rates['USD'] ?? 1,
        'IDR': rates['IDR'] ?? 15430,
        'EUR': rates['EUR'] ?? 0.92,
      };
      await _prefs.setString(AppConstants.currencyCacheKey, jsonEncode(subset));
      await _prefs.setInt(
        AppConstants.currencyCacheTimeKey,
        DateTime.now().millisecondsSinceEpoch,
      );
      return subset;
    } catch (_) {
      return {'USD': 1, 'IDR': 15430, 'EUR': 0.92};
    }
  }
}
