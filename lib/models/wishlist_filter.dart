enum WishlistSortOption {
  priority,
  title,
  author,
  dateAdded,
  genre,
}

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
    String? genre,
    String? searchQuery,
    WishlistSortOption? sortBy,
    bool? sortAscending,
  }) {
    return WishlistFilter(
      genre: genre ?? this.genre,
      searchQuery: searchQuery ?? this.searchQuery,
      sortBy: sortBy ?? this.sortBy,
      sortAscending: sortAscending ?? this.sortAscending,
    );
  }
}

