import '../../../core/network/api_client.dart';
import '../../../shared/models/destination.dart';

class FavoritesRemoteDataSource {
  FavoritesRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<List<DestinationModel>> fetchFavorites() async {
    final response = await _apiClient.dio.get<List<dynamic>>('/me/favorites');
    return (response.data ?? const <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .map((item) => DestinationModel.fromApiJson({...item, 'isFavorite': true}))
        .toList();
  }

  Future<void> addFavorite(String destinationId) async {
    await _apiClient.dio.post<void>('/me/favorites/$destinationId');
  }

  Future<void> removeFavorite(String destinationId) async {
    await _apiClient.dio.delete<void>('/me/favorites/$destinationId');
  }
}
