import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/library_filter.dart' show LibraryFilter, ReadStatus, SortOption, ViewMode, GroupBy;
import '../models/series_group.dart';
import '../providers/library_provider.dart';
import '../providers/books_provider.dart';
import '../widgets/library/book_grid_view.dart';
import '../widgets/library/book_list_view.dart';
import '../widgets/library/library_filter_modal.dart';
import '../utils/book_utils.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewMode = ref.watch(libraryViewModeProvider);
    final filter = ref.watch(libraryFilterProvider);
    final booksAsync = ref.watch(libraryBooksProvider);

    return booksAsync.when(
      data: (books) {
        var filteredBooks = BookUtils.filterBySearchQuery(books, filter.searchQuery);

        if (filter.readStatus != ReadStatus.all) {
          filteredBooks = filteredBooks.where((book) {
            return filter.readStatus == ReadStatus.read ? book.isRead : !book.isRead;
          }).toList();
        }

        if (filter.minRating != null) {
          filteredBooks = filteredBooks.where((book) {
            return book.rating != null && book.rating! >= filter.minRating!;
          }).toList();
        }

        filteredBooks = BookUtils.filterByGenre(filteredBooks, filter.genre);

        filteredBooks.sort((a, b) {
          int comparison = 0;
          
          switch (filter.sortBy) {
            case SortOption.title:
              comparison = a.title.toLowerCase().compareTo(b.title.toLowerCase());
              break;
            case SortOption.author:
              comparison = (a.author ?? '').toLowerCase().compareTo((b.author ?? '').toLowerCase());
              break;
            case SortOption.rating:
              final aRating = a.rating ?? 0;
              final bRating = b.rating ?? 0;
              comparison = aRating.compareTo(bRating);
              break;
            case SortOption.dateAdded:
              comparison = a.dateAdded.compareTo(b.dateAdded);
              break;
            case SortOption.genre:
              comparison = (a.genre ?? '').toLowerCase().compareTo((b.genre ?? '').toLowerCase());
              break;
          }
          
          return filter.sortAscending ? comparison : -comparison;
        });

        final bool showFilteredSeries = filter.series != null;
        final List<SeriesGroup> seriesGroups;
        
        if (showFilteredSeries) {
          // When filtering by a specific series, show individual books
          seriesGroups = BookUtils.filterBySeries(filteredBooks, filter.series)
              .map((book) => SeriesGroup(
                seriesName: filter.series!,
                firstBook: book,
                allBooks: [book],
              )).toList();
        } else if (filter.groupBy == GroupBy.series) {
          // Group by series
          seriesGroups = BookUtils.groupBySeries(filteredBooks);
        } else if (filter.groupBy == GroupBy.author) {
          // Group by author
          seriesGroups = BookUtils.groupByAuthor(filteredBooks);
        } else {
          // No grouping - show each book individually
          seriesGroups = filteredBooks.map((book) => SeriesGroup(
            seriesName: book.title,
            firstBook: book,
            allBooks: [book],
          )).toList();
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(filter.series != null ? 'Library - ${filter.series}' : 'Library'),
            leading: filter.series != null
                ? IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      ref.read(libraryFilterProvider.notifier).state =
                          filter.copyWith(series: null);
                    },
                  )
                : null,
            actions: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) => const LibraryFilterModal(),
                  );
                },
              ),
              IconButton(
                icon: Icon(viewMode == ViewMode.grid ? Icons.view_list : Icons.view_module),
                onPressed: () {
                  ref.read(libraryViewModeProvider.notifier).state =
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
                    ref.read(libraryFilterProvider.notifier).state =
                        filter.copyWith(searchQuery: value.isEmpty ? null : value);
                  },
                ),
              ),
              Expanded(
                child: seriesGroups.isEmpty
                    ? const Center(
                        child: Text('No books found'),
                      )
                    : viewMode == ViewMode.grid
                        ? BookGridView(
                            seriesGroups: seriesGroups,
                            onSeriesTap: (!showFilteredSeries && filter.groupBy == GroupBy.series) ? (seriesName) {
                              ref.read(libraryFilterProvider.notifier).state =
                                  filter.copyWith(series: seriesName);
                            } : null,
                          )
                        : BookListView(
                            seriesGroups: seriesGroups,
                            onSeriesTap: (!showFilteredSeries && filter.groupBy == GroupBy.series) ? (seriesName) {
                              ref.read(libraryFilterProvider.notifier).state =
                                  filter.copyWith(series: seriesName);
                            } : null,
                          ),
              ),
            ],
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Library')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Library')),
        body: Center(child: Text('Error: $error')),
      ),
    );
  }
}
