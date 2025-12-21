import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _searchHistoryKey = 'search_history';
  static const String _darkModeKey = 'dark_mode';

  static Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  static Future<List<String>> getSearchHistory() async {
    final prefs = await _prefs;
    return prefs.getStringList(_searchHistoryKey) ?? [];
  }

  static Future<void> saveSearchHistory(List<String> history) async {
    final prefs = await _prefs;
    await prefs.setStringList(_searchHistoryKey, history);
  }

  static Future<void> clearSearchHistory() async {
    final prefs = await _prefs;
    await prefs.remove(_searchHistoryKey);
  }

  static Future<bool> getDarkMode() async {
    final prefs = await _prefs;
    return prefs.getBool(_darkModeKey) ?? false;
  }

  static Future<void> saveDarkMode(bool isDark) async {
    final prefs = await _prefs;
    await prefs.setBool(_darkModeKey, isDark);
  }
}

