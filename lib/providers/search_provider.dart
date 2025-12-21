import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/book.dart';
import '../services/google_books_service.dart';
import '../services/preferences_service.dart';

final googleBooksServiceProvider = Provider<GoogleBooksService>((ref) {
  return GoogleBooksService();
});

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = FutureProvider<List<Book>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  final service = ref.watch(googleBooksServiceProvider);

  if (query.isEmpty) {
    return [];
  }

  return await service.searchBooks(query);
});

class SearchHistoryNotifier extends StateNotifier<AsyncValue<List<String>>> {
  SearchHistoryNotifier() : super(const AsyncValue.loading()) {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final history = await PreferencesService.getSearchHistory();
      state = AsyncValue.data(history);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> addSearch(String query) async {
    if (query.trim().isEmpty) return;
    
    final trimmedQuery = query.trim();
    final currentHistory = state.valueOrNull ?? [];
    final updatedList = List<String>.from(currentHistory);
    updatedList.remove(trimmedQuery);
    updatedList.insert(0, trimmedQuery);
    
    if (updatedList.length > 5) {
      updatedList.removeRange(5, updatedList.length);
    }
    
    state = AsyncValue.data(updatedList);
    await PreferencesService.saveSearchHistory(updatedList);
  }

  Future<void> clearHistory() async {
    state = const AsyncValue.data([]);
    await PreferencesService.clearSearchHistory();
  }
}

final searchHistoryProvider = StateNotifierProvider<SearchHistoryNotifier, AsyncValue<List<String>>>((ref) {
  return SearchHistoryNotifier();
});

