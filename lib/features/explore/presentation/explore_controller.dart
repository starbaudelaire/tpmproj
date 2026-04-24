import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/destination.dart';
import '../data/explore_repository_impl.dart';
import '../domain/usecases/filter_destinations_usecase.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');
final activeCategoryProvider = StateProvider<String?>((ref) => null);
final filterStateProvider = StateProvider<FilterModel>(
  (ref) => const FilterModel(),
);
final gridModeProvider = StateProvider<bool>((ref) => true);

final _repositoryProvider = Provider<ExploreRepositoryImpl>(
  (ref) => ExploreRepositoryImpl(),
);

final searchResultsProvider = FutureProvider.autoDispose
    .family<List<DestinationModel>, FilterModel>((ref, filter) async {
  final all = await ref.read(_repositoryProvider).all();
  return const FilterDestinationsUseCase().call(all, filter);
});
