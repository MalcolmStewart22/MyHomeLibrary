import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/wishlist_filter.dart';
import '../../providers/wishlist_provider.dart';
import '../../providers/books_provider.dart';

class WishlistFilterModal extends ConsumerStatefulWidget {
  const WishlistFilterModal({super.key});

  @override
  ConsumerState<WishlistFilterModal> createState() => _WishlistFilterModalState();
}

class _WishlistFilterModalState extends ConsumerState<WishlistFilterModal> {
  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(wishlistFilterProvider);

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
                        ref.read(wishlistFilterProvider.notifier).state = WishlistFilter();
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
                      'Filter by Genre',
                      _buildGenreFilter(filter),
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

  Widget _buildGenreFilter(WishlistFilter filter) {
    final booksAsync = ref.watch(wishlistBooksProvider);
    
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
                ref.read(wishlistFilterProvider.notifier).state =
                    filter.copyWith(genre: null);
              },
            ),
            ...genres.map((genre) {
              final isSelected = filter.genre?.toLowerCase() == genre.toLowerCase();
              return ChoiceChip(
                label: Text(genre),
                selected: isSelected,
                onSelected: (selected) {
                  ref.read(wishlistFilterProvider.notifier).state =
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

  Widget _buildSortOptions(WishlistFilter filter) {
    return Column(
      children: [
        ...WishlistSortOption.values.map((option) {
          return RadioListTile<WishlistSortOption>(
            title: Text(_getSortOptionLabel(option)),
            value: option,
            groupValue: filter.sortBy,
            onChanged: (value) {
              if (value != null) {
                ref.read(wishlistFilterProvider.notifier).state =
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
            ref.read(wishlistFilterProvider.notifier).state =
                filter.copyWith(sortAscending: value);
          },
        ),
      ],
    );
  }

  String _getSortOptionLabel(WishlistSortOption option) {
    switch (option) {
      case WishlistSortOption.priority:
        return 'Priority';
      case WishlistSortOption.title:
        return 'Title';
      case WishlistSortOption.author:
        return 'Author';
      case WishlistSortOption.dateAdded:
        return 'Date Added';
      case WishlistSortOption.genre:
        return 'Genre';
    }
  }
}

