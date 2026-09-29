import 'package:shared_preferences/shared_preferences.dart';

class FavoriteService {
  static const _key = 'favorite_projects';

  Future<Set<String>> load() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_key) ?? const <String>[]).toSet();
  }

  Future<Set<String>> toggle(String fullName) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = (prefs.getStringList(_key) ?? const <String>[]).toSet();

    if (favorites.contains(fullName)) {
      favorites.remove(fullName);
    } else {
      favorites.add(fullName);
    }

    await prefs.setStringList(_key, favorites.toList()..sort());
    return favorites;
  }
}
