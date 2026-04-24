import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/data/auth_local_datasource.dart';
import '../../features/auth/data/auth_repository_impl.dart';
import '../../features/auth/domain/auth_repository.dart';
import '../../features/favorites/data/favorites_local_datasource.dart';
import '../../features/guide/data/ai_remote_datasource.dart';
import '../../features/home/data/weather_remote_datasource.dart';
import '../../features/mini_game/data/quiz_local_datasource.dart';
import '../../features/notifications/notification_service.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  if (getIt.isRegistered<SharedPreferences>()) return;

  final prefs = await SharedPreferences.getInstance();
  getIt
    ..registerSingleton<SharedPreferences>(prefs)
    ..registerSingleton<Dio>(Dio())
    ..registerSingleton<FlutterSecureStorage>(const FlutterSecureStorage())
    ..registerSingleton<LocalAuthentication>(LocalAuthentication())
    ..registerLazySingleton<AuthLocalDataSource>(
      () => AuthLocalDataSource(secureStorage: getIt(), prefs: getIt()),
    )
    ..registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(getIt()))
    ..registerLazySingleton<WeatherRemoteDataSource>(
      () => WeatherRemoteDataSource(dio: getIt(), prefs: getIt()),
    )
    ..registerLazySingleton<AiRemoteDataSource>(
      () => AiRemoteDataSource(getIt()),
    )
    ..registerLazySingleton<FavoritesLocalDataSource>(
      () => FavoritesLocalDataSource(getIt()),
    )
    ..registerLazySingleton<QuizLocalDataSource>(() => QuizLocalDataSource())
    ..registerLazySingleton<NotificationService>(() => NotificationService());
}
