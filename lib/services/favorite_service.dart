import 'package:shared_preferences/shared_preferences.dart';

class FavoriteService {
  static const String _favoriteKey = 'favorites';

  // Add movie ID to favorites list
  Future<void> addFavorite(int movieId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favorites = prefs.getStringList(_favoriteKey) ?? [];
    if (!favorites.contains(movieId.toString())) {
      favorites.add(movieId.toString());
      await prefs.setStringList(_favoriteKey, favorites);
    }
  }

  // Remove movie ID from favorites list
  Future<void> removeFavorite(int movieId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favorites = prefs.getStringList(_favoriteKey) ?? [];
    favorites.remove(movieId.toString());
    await prefs.setStringList(_favoriteKey, favorites);
  }

  // Get the list of favorite movie IDs
  Future<List<int>> getFavoriteMovies() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favorites = prefs.getStringList(_favoriteKey) ?? [];
    return favorites.map((id) => int.parse(id)).toList();
  }
}