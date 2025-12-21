import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/library_filter.dart';
import '../../providers/library_provider.dart';
import '../../providers/books_provider.dart';

class LibraryFilterModal extends ConsumerStatefulWidget {
  const LibraryFilterModal({super.key});

  @override
  ConsumerState<LibraryFilterModal> createState() => _LibraryFilterModalState();
}

class _LibraryFilterModalState extends ConsumerState<LibraryFilterModal> {
  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(libraryFilterProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Filter & Sort',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    TextButton(
                      onPressed: () {
                        ref.read(libraryFilterProvider.notifier).state = LibraryFilter();
                        Navigator.pop(context);
                      },
                      child: const Text('Reset'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    _buildFilterSection(
                      context,
                      'Filter by Read Status',
                      _buildReadStatusFilter(filter),
                    ),
                    const SizedBox(height: 24),
                    _buildFilterSection(
                      context,
                      'Filter by Rating',
                      _buildRatingFilter(filter),
                    ),
                    const SizedBox(height: 24),
                    _buildFilterSection(
                      context,
                      'Filter by Genre',
                      _buildGenreFilter(filter),
                    ),
                    const SizedBox(height: 24),
                    _buildFilterSection(
                      context,
                      'Group By',
                      _buildGroupByOptions(filter),
                    ),
                    const SizedBox(height: 24),
                    _buildFilterSection(
                      context,
                      'Sort By',
                      _buildSortOptions(filter),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterSection(BuildContext context, String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        content,
      ],
    );
  }

  Widget _buildReadStatusFilter(LibraryFilter filter) {
    return SegmentedButton<ReadStatus>(
      segments: const [
        ButtonSegment(value: ReadStatus.all, label: Text('All')),
        ButtonSegment(value: ReadStatus.read, label: Text('Read')),
        ButtonSegment(value: ReadStatus.unread, label: Text('Unread')),
      ],
      selected: {filter.readStatus},
      onSelectionChanged: (Set<ReadStatus> selection) {
        ref.read(libraryFilterProvider.notifier).state =
            filter.copyWith(readStatus: selection.first);
      },
    );
  }

  Widget _buildRatingFilter(LibraryFilter filter) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(5, (index) {
            final rating = index + 1;
            final isSelected = filter.minRating != null && filter.minRating! <= rating;
            return FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('$rating+'),
                  if (isSelected) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.star, size: 16, color: Colors.amber),
                  ],
                ],
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (isSelected && filter.minRating == rating) {
                  ref.read(libraryFilterProvider.notifier).state = filter.copyWith(
                    minRating: null,
                  );
                } else {
                  ref.read(libraryFilterProvider.notifier).state = filter.copyWith(
                    minRating: rating,
                  );
                }
              },
            );
          }),
        ),
        if (filter.minRating != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: TextButton.icon(
              onPressed: () {
                ref.read(libraryFilterProvider.notifier).state =
                    filter.copyWith(minRating: null);
              },
              icon: const Icon(Icons.clear, size: 16),
              label: const Text('Clear rating filter'),
            ),
          ),
      ],
    );
  }

  Widget _buildGenreFilter(LibraryFilter filter) {
    final booksAsync = ref.watch(libraryBooksProvider);
    
    return booksAsync.when(
      data: (books) {
        final genreSet = <String>{};
        for (var book in books) {
          if (book.genre != null && book.genre!.isNotEmpty) {
            final genres = book.genre!.split(',').map((g) => g.trim()).where((g) => g.isNotEmpty);
            genreSet.addAll(genres);
          }
        }
        final genres = genreSet.toList()..sort();
        
        if (genres.isEmpty) {
          return const Text('No genres available');
        }
        
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: const Text('All'),
              selected: filter.genre == null,
              onSelected: (selected) {
                ref.read(libraryFilterProvider.notifier).state =
                    filter.copyWith(genre: null);
              },
            ),
            ...genres.map((genre) {
              final isSelected = filter.genre?.toLowerCase() == genre.toLowerCase();
              return ChoiceChip(
                label: Text(genre),
                selected: isSelected,
                onSelected: (selected) {
                  ref.read(libraryFilterProvider.notifier).state =
                      filter.copyWith(genre: isSelected ? null : genre);
                },
              );
            }),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Text('Error loading genres: $error'),
    );
  }

  Widget _buildSortOptions(LibraryFilter filter) {
    return Column(
      children: [
        ...SortOption.values.map((option) {
          return RadioListTile<SortOption>(
            title: Text(_getSortOptionLabel(option)),
            value: option,
            groupValue: filter.sortBy,
            onChanged: (value) {
              if (value != null) {
                ref.read(libraryFilterProvider.notifier).state =
                    filter.copyWith(sortBy: value);
              }
            },
          );
        }),
        const Divider(),
        SwitchListTile(
          title: const Text('Sort Ascending'),
          subtitle: Text(filter.sortAscending ? 'A-Z' : 'Z-A'),
          value: filter.sortAscending,
          onChanged: (value) {
            ref.read(libraryFilterProvider.notifier).state =
                filter.copyWith(sortAscending: value);
          },
        ),
      ],
    );
  }

  Widget _buildGroupByOptions(LibraryFilter filter) {
    return SegmentedButton<GroupBy>(
      segments: const [
        ButtonSegment(value: GroupBy.none, label: Text('None')),
        ButtonSegment(value: GroupBy.series, label: Text('Series')),
        ButtonSegment(value: GroupBy.author, label: Text('Author')),
      ],
      selected: {filter.groupBy},
      onSelectionChanged: (Set<GroupBy> selection) {
        ref.read(libraryFilterProvider.notifier).state =
            filter.copyWith(groupBy: selection.first);
      },
    );
  }

  String _getSortOptionLabel(SortOption option) {
    switch (option) {
      case SortOption.title:
        return 'Title';
      case SortOption.author:
        return 'Author';
      case SortOption.rating:
        return 'Rating';
      case SortOption.dateAdded:
        return 'Date Added';
      case SortOption.genre:
        return 'Genre';
    }
  }
}


