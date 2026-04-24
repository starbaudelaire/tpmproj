import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';

class FavoritesLocalDataSource {
  FavoritesLocalDataSource(this._prefs);

  final SharedPreferences _prefs;

  List<String> read() =>
      _prefs.getStringList(AppConstants.favoritesKey) ?? <String>[];

  Future<void> write(List<String> ids) =>
      _prefs.setStringList(AppConstants.favoritesKey, ids);
}
