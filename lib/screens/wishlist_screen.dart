import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/wishlist_filter.dart';
import '../models/library_filter.dart' show ViewMode;
import '../providers/wishlist_provider.dart';
import '../providers/books_provider.dart';
import '../widgets/wishlist/wishlist_grid_view.dart';
import '../widgets/wishlist/wishlist_list_view.dart';
import '../widgets/wishlist/wishlist_filter_modal.dart';
import '../utils/book_utils.dart';

class WishlistScreen extends ConsumerStatefulWidget {
  const WishlistScreen({super.key});

  @override
  ConsumerState<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends ConsumerState<WishlistScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewMode = ref.watch(wishlistViewModeProvider);
    final filter = ref.watch(wishlistFilterProvider);
    final booksAsync = ref.watch(wishlistBooksProvider);

    return booksAsync.when(
      data: (books) {
        var filteredBooks = BookUtils.filterBySearchQuery(books, filter.searchQuery);
        filteredBooks = BookUtils.filterByGenre(filteredBooks, filter.genre);

        filteredBooks.sort((a, b) {
          int comparison = 0;
          
          switch (filter.sortBy) {
            case WishlistSortOption.priority:
              final aPriority = a.priority ?? 999;
              final bPriority = b.priority ?? 999;
              comparison = aPriority.compareTo(bPriority);
              break;
            case WishlistSortOption.title:
              comparison = a.title.compareTo(b.title);
              break;
            case WishlistSortOption.author:
              comparison = (a.author ?? '').compareTo(b.author ?? '');
              break;
            case WishlistSortOption.dateAdded:
              comparison = a.dateAdded.compareTo(b.dateAdded);
              break;
            case WishlistSortOption.genre:
              comparison = (a.genre ?? '').compareTo(b.genre ?? '');
              break;
          }
          
          return filter.sortAscending ? comparison : -comparison;
        });

        if (filter.sortBy == WishlistSortOption.priority && filteredBooks.isNotEmpty) {
          filteredBooks = filteredBooks.asMap().entries.map((entry) {
            return entry.value.copyWith(priority: entry.key + 1);
          }).toList();
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Wishlist'),
            actions: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) => const WishlistFilterModal(),
                  );
                },
              ),
              IconButton(
                icon: Icon(viewMode == ViewMode.grid ? Icons.view_list : Icons.view_module),
                onPressed: () {
                  ref.read(wishlistViewModeProvider.notifier).state =
                      viewMode == ViewMode.grid ? ViewMode.list : ViewMode.grid;
                },
              ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search books...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onChanged: (value) {
                    ref.read(wishlistFilterProvider.notifier).state =
                        filter.copyWith(searchQuery: value.isEmpty ? null : value);
                  },
                ),
              ),
              Expanded(
                child: filteredBooks.isEmpty
                    ? const Center(
                        child: Text('No books found'),
                      )
                    : viewMode == ViewMode.grid
                        ? WishlistGridView(books: filteredBooks)
                        : WishlistListView(
                            books: filteredBooks,
                            filter: filter,
                            onReorder: filter.sortBy == WishlistSortOption.priority
                                ? (newOrder) async {
                                    final booksNotifier = ref.read(booksNotifierProvider.notifier);
                                    await booksNotifier.updateWishlistPriorities(newOrder);
                                    ref.invalidate(wishlistBooksProvider);
                                  }
                                : null,
                          ),
              ),
            ],
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Wishlist')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Wishlist')),
        body: Center(child: Text('Error: $error')),
      ),
    );
  }
}
