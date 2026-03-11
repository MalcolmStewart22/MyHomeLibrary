enum WishlistSortOption {
  priority,
  title,
  author,
  dateAdded,
  genre,
}

const _undefined = Object();

class WishlistFilter {
  final String? genre;
  final String? searchQuery;
  final WishlistSortOption sortBy;
  final bool sortAscending;

  WishlistFilter({
    this.genre,
    this.searchQuery,
    this.sortBy = WishlistSortOption.priority,
    this.sortAscending = true,
  });

  WishlistFilter copyWith({
    Object? genre = _undefined,
    Object? searchQuery = _undefined,
    WishlistSortOption? sortBy,
    bool? sortAscending,
  }) {
    return WishlistFilter(
      genre: genre == _undefined ? this.genre : genre as String?,
      searchQuery: searchQuery == _undefined ? this.searchQuery : searchQuery as String?,
      sortBy: sortBy ?? this.sortBy,
      sortAscending: sortAscending ?? this.sortAscending,
    );
  }
}

