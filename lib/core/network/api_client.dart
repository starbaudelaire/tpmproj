import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/api_constants.dart';
import '../errors/app_error.dart';

class ApiClient {
  ApiClient({required Dio dio, required FlutterSecureStorage secureStorage})
      : _dio = dio,
        _secureStorage = secureStorage {
    _dio.options.baseUrl = ApiConstants.backendBaseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.sendTimeout = const Duration(seconds: 30);
    _dio.options.headers['Accept'] = 'application/json';
    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _secureStorage.read(key: ApiConstants.authTokenKey);
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          return handler.reject(
            error.copyWith(error: ApiErrorMapper.fromDio(error)),
          );
        },
      ),
    );
  }

  final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  Dio get dio => _dio;

  bool isAuthFailure(Object error) {
    if (error is DioException) {
      final status = error.response?.statusCode;
      return status == 401 || status == 403;
    }
    if (error is AppException) {
      return error.statusCode == 401 || error.statusCode == 403;
    }
    return false;
  }
}
