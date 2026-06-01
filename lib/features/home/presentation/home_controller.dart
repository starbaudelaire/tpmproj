import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/injection.dart';
import '../../../core/services/location_service.dart';
import '../../../shared/models/destination.dart';
import '../data/home_repository_impl.dart';
import '../data/weather_remote_datasource.dart';
import '../../explore/data/destinations_remote_datasource.dart';

final _homeRepositoryProvider = Provider<HomeRepositoryImpl>(
  (ref) => HomeRepositoryImpl(
    getIt<WeatherRemoteDataSource>(),
    getIt<LocationService>(),
    getIt<DestinationsRemoteDataSource>(),
  ),
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
) {
  return ref.read(_homeRepositoryProvider).nearbyDestinations();
});

final destinationDistanceLabelProvider =
    FutureProvider.family.autoDispose<String, DestinationModel>((ref, item) {
  return ref.read(_homeRepositoryProvider).distanceLabelFor(item);
});
