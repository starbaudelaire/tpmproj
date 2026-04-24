import '../../../../shared/models/destination.dart';
import '../../data/explore_repository_impl.dart';

class SearchDestinationsUseCase {
  const SearchDestinationsUseCase(this._repository);

  final ExploreRepositoryImpl _repository;

  Future<List<DestinationModel>> call(String query) async {
    final all = await _repository.all();
    if (query.isEmpty) return all;
    return all
        .where(
          (destination) =>
              destination.name.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }
}
