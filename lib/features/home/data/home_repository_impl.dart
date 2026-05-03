import '../../../core/services/location_service.dart';
import '../../../features/explore/data/destinations_remote_datasource.dart';
import '../../../shared/models/destination.dart';
import 'weather_remote_datasource.dart';

class HomeRepositoryImpl {
  HomeRepositoryImpl(
    this._weatherDataSource,
    this._locationService,
    this._destinationsDataSource,
  );

  final WeatherRemoteDataSource _weatherDataSource;
  final LocationService _locationService;
  final DestinationsRemoteDataSource _destinationsDataSource;

  Future<WeatherModel> getWeather() async {
    final position = await _locationService.getCurrentPositionOrJogjaFallback();

    return _weatherDataSource.fetchWeather(
      lat: position.latitude,
      lon: position.longitude,
    );
  }

  Future<List<DestinationModel>> destinations() async {
    return _destinationsDataSource.fetchDestinations();
  }

  Future<List<DestinationModel>> nearbyDestinations() async {
    final all = await destinations();
    final position = await _locationService.getCurrentPositionOrNull();

    if (position == null) {
      return all.take(3).toList();
    }

    return _locationService
        .sortByDistance(
          destinations: all,
          userLat: position.latitude,
          userLon: position.longitude,
        )
        .take(3)
        .toList();
  }

  Future<String> distanceLabelFor(DestinationModel destination) async {
    final position = await _locationService.getCurrentPositionOrNull();

    if (position == null) {
      return 'Lokasi belum aktif';
    }

    final meters = _locationService.distanceInMeters(
      fromLat: position.latitude,
      fromLon: position.longitude,
      toLat: destination.latitude,
      toLon: destination.longitude,
    );

    return _locationService.formatDistance(meters);
  }
}
