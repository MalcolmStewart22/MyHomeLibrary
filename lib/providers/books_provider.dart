import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/book.dart';
import '../services/database_service.dart';

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService.instance;
});

final libraryBooksProvider = FutureProvider<List<Book>>((ref) async {
  final databaseService = ref.watch(databaseServiceProvider);
  return await databaseService.readAllBooks(inLibrary: true);
});

final wishlistBooksProvider = FutureProvider<List<Book>>((ref) async {
  final databaseService = ref.watch(databaseServiceProvider);
  return await databaseService.readAllBooks(inLibrary: false);
});

final allSeriesNamesProvider = FutureProvider<List<String>>((ref) async {
  final databaseService = ref.watch(databaseServiceProvider);
  return await databaseService.getAllSeriesNames();
});

class BooksNotifier extends StateNotifier<AsyncValue<void>> {
  final DatabaseService _databaseService;

  BooksNotifier(this._databaseService) : super(const AsyncValue.data(null));

  Future<void> addBookToLibrary(Book book) async {
    try {
      state = const AsyncValue.loading();
      final bookToAdd = book.copyWith(
        isInLibrary: true,
        isRead: false,
      );
      await _databaseService.createBook(bookToAdd);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> addBookToWishlist(Book book) async {
    try {
      state = const AsyncValue.loading();
      final maxPriority = await _databaseService.getMaxWishlistPriority();
      final bookToAdd = book.copyWith(
        isInLibrary: false,
        priority: maxPriority + 1,
      );
      await _databaseService.createBook(bookToAdd);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> updateWishlistPriorities(List<Book> books) async {
    try {
      state = const AsyncValue.loading();
      await _databaseService.updateBookPriorities(books);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> moveBookToLibrary(Book book) async {
    try {
      state = const AsyncValue.loading();
      if (book.id != null) {
        final updatedBook = book.copyWith(
          isInLibrary: true,
          priority: null,
        );
        await _databaseService.updateBook(updatedBook);
      }
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> deleteAllBooks() async {
    try {
      state = const AsyncValue.loading();
      await _databaseService.deleteAllBooks();
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> deleteBook(int id) async {
    try {
      state = const AsyncValue.loading();
      await _databaseService.deleteBook(id);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

final booksNotifierProvider = StateNotifierProvider<BooksNotifier, AsyncValue<void>>((ref) {
  final databaseService = ref.watch(databaseServiceProvider);
  return BooksNotifier(databaseService);
});

