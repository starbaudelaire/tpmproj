import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/di/injection.dart';
import '../../../shared/models/destination.dart';
import '../data/home_repository_impl.dart';
import '../data/weather_remote_datasource.dart';

final _homeRepositoryProvider = Provider<HomeRepositoryImpl>(
  (ref) => HomeRepositoryImpl(getIt()),
);

final weatherProvider = FutureProvider.autoDispose<WeatherModel>(
  (ref) => ref.read(_homeRepositoryProvider).getWeather(),
);

final featuredDestinationsProvider = FutureProvider<List<DestinationModel>>((
  ref,
) async {
  final all = await ref.read(_homeRepositoryProvider).destinations();
  return all.take(3).toList();
});

final nearbyDestinationsProvider = FutureProvider<List<DestinationModel>>((
  ref,
) async {
  final all = await ref.read(_homeRepositoryProvider).destinations();
  try {
    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return all.reversed.take(3).toList();
    }
    final position = await Geolocator.getCurrentPosition();
    all.sort((a, b) {
      final distanceA = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        a.latitude,
        a.longitude,
      );
      final distanceB = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        b.latitude,
        b.longitude,
      );
      return distanceA.compareTo(distanceB);
    });
  } catch (_) {}
  return all.take(3).toList();
});
