import 'package:hive/hive.dart';

import '../../../core/constants/app_constants.dart';
import '../../../shared/models/destination.dart';

class ExploreRepositoryImpl {
  Future<List<DestinationModel>> all() async {
    return Hive.box<DestinationModel>(
      AppConstants.destinationsBox,
    ).values.toList();
  }
}
