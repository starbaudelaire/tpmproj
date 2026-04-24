import '../../../../shared/models/destination.dart';

class FilterModel {
  const FilterModel({this.query = '', this.category});

  final String query;
  final String? category;
}

class FilterDestinationsUseCase {
  const FilterDestinationsUseCase();

  List<DestinationModel> call(
    List<DestinationModel> items,
    FilterModel filter,
  ) {
    return items.where((item) {
      final matchesQuery = filter.query.isEmpty ||
          item.name.toLowerCase().contains(filter.query.toLowerCase()) ||
          item.description.toLowerCase().contains(filter.query.toLowerCase());
      final matchesCategory =
          filter.category == null || item.category == filter.category;
      return matchesQuery && matchesCategory;
    }).toList();
  }
}
