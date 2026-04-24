import 'package:hive/hive.dart';

import '../../../core/constants/app_constants.dart';
import '../../../shared/models/destination.dart';
import 'weather_remote_datasource.dart';

class HomeRepositoryImpl {
  HomeRepositoryImpl(this._weatherDataSource);

  final WeatherRemoteDataSource _weatherDataSource;

  Future<WeatherModel> getWeather() => _weatherDataSource.fetchWeather();

  Future<List<DestinationModel>> destinations() async {
    return Hive.box<DestinationModel>(
      AppConstants.destinationsBox,
    ).values.toList();
  }
}
