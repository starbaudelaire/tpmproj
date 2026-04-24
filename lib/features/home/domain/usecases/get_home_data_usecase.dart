import '../../data/home_repository_impl.dart';
import '../../data/weather_remote_datasource.dart';
import '../../../../shared/models/destination.dart';

class HomeDataBundle {
  HomeDataBundle({required this.weather, required this.destinations});

  final WeatherModel weather;
  final List<DestinationModel> destinations;
}

class GetHomeDataUseCase {
  const GetHomeDataUseCase(this._repository);

  final HomeRepositoryImpl _repository;

  Future<HomeDataBundle> call() async {
    final weather = await _repository.getWeather();
    final destinations = await _repository.destinations();
    return HomeDataBundle(weather: weather, destinations: destinations);
  }
}
