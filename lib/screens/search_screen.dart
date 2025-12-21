import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/search_provider.dart';
import '../widgets/search/search_result_row.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _debounce;
  bool _isSearchFocused = false;

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {
      setState(() {
        _isSearchFocused = _searchFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(searchQueryProvider.notifier).state = value;
    });
  }

  Future<void> _performSearch(String query) async {
    _debounce?.cancel();
    if (query.trim().isNotEmpty) {
      final trimmedQuery = query.trim();
      ref.read(searchQueryProvider.notifier).state = trimmedQuery;
      await ref.read(searchHistoryProvider.notifier).addSearch(trimmedQuery);
      _searchController.text = trimmedQuery;
      _searchFocusNode.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchQuery = ref.watch(searchQueryProvider);
    final searchResults = ref.watch(searchResultsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              decoration: InputDecoration(
                hintText: 'Search for books...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(searchQueryProvider.notifier).state = '';
                        },
                      )
                    : null,
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: _onSearchChanged,
              onSubmitted: (value) {
                _performSearch(value);
              },
            ),
          ),
          if (_isSearchFocused && searchQuery.isEmpty) 
            _buildRecentSearches(),
          Expanded(
            child: searchQuery.isEmpty && !_isSearchFocused
                ? const Center(
                    child: Text('Enter a search query to find books'),
                  )
                : searchQuery.isEmpty
                    ? const SizedBox.shrink()
                    : searchResults.when(
                    data: (books) {
                      if (books.isEmpty) {
                        return const Center(
                          child: Text('No books found'),
                        );
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.all(8.0),
                        itemCount: books.length,
                        itemBuilder: (context, index) {
                          return SearchResultRow(book: books[index]);
                        },
                      );
                    },
                    loading: () => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    error: (error, stack) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 48, color: Colors.red),
                          const SizedBox(height: 16),
                          Text(
                            'Error searching books',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            error.toString(),
                            style: Theme.of(context).textTheme.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSearches() {
    final searchHistoryAsync = ref.watch(searchHistoryProvider);

    return searchHistoryAsync.when(
      data: (searchHistory) {
        if (searchHistory.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          constraints: const BoxConstraints(maxHeight: 300),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Searches',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                    ),
                    TextButton(
                      onPressed: () {
                        ref.read(searchHistoryProvider.notifier).clearHistory();
                      },
                      child: const Text('Clear'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  itemCount: searchHistory.length,
                  itemBuilder: (context, index) {
                    final query = searchHistory[index];
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          _performSearch(query);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                          child: Row(
                            children: [
                              const Icon(Icons.history, size: 20, color: Colors.grey),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  query,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }
}
