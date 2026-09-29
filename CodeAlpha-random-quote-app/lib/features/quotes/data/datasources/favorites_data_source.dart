import 'package:shared_preferences/shared_preferences.dart';

class FavoritesDataSource {
  static const _key = 'favorite_quote_ids';

  Future<Set<String>> loadFavoriteIds() async {
    final preferences = await SharedPreferences.getInstance();
    return (preferences.getStringList(_key) ?? const <String>[]).toSet();
  }

  Future<void> saveFavoriteIds(Set<String> ids) async {
    final preferences = await SharedPreferences.getInstance();
    final sortedIds = ids.toList()..sort();
    await preferences.setStringList(_key, sortedIds);
  }
}
