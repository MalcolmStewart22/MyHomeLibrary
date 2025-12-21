import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/preferences_service.dart';

class DarkModeNotifier extends StateNotifier<AsyncValue<bool>> {
  DarkModeNotifier() : super(const AsyncValue.loading()) {
    _loadDarkMode();
  }

  Future<void> _loadDarkMode() async {
    try {
      final isDark = await PreferencesService.getDarkMode();
      state = AsyncValue.data(isDark);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> setDarkMode(bool isDark) async {
    state = AsyncValue.data(isDark);
    await PreferencesService.saveDarkMode(isDark);
  }
}

final darkModeProvider = StateNotifierProvider<DarkModeNotifier, AsyncValue<bool>>((ref) {
  return DarkModeNotifier();
});


