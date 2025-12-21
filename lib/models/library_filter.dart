enum ReadStatus { all, read, unread }

enum SortOption {
  title,
  author,
  rating,
  dateAdded,
  genre,
}

enum ViewMode { grid, list }

enum GroupBy { none, series, author }

class LibraryFilter {
  final ReadStatus readStatus;
  final int? minRating;
  final String? genre;
  final String? searchQuery;
  final String? series;
  final GroupBy groupBy;
  final SortOption sortBy;
  final bool sortAscending;

  LibraryFilter({
    this.readStatus = ReadStatus.all,
    this.minRating,
    this.genre,
    this.searchQuery,
    this.series,
    this.groupBy = GroupBy.series,
    this.sortBy = SortOption.title,
    this.sortAscending = true,
  });

  LibraryFilter copyWith({
    ReadStatus? readStatus,
    int? minRating,
    String? genre,
    String? searchQuery,
    String? series,
    GroupBy? groupBy,
    SortOption? sortBy,
    bool? sortAscending,
  }) {
    return LibraryFilter(
      readStatus: readStatus ?? this.readStatus,
      minRating: minRating ?? this.minRating,
      genre: genre ?? this.genre,
      searchQuery: searchQuery ?? this.searchQuery,
      series: series ?? this.series,
      groupBy: groupBy ?? this.groupBy,
      sortBy: sortBy ?? this.sortBy,
      sortAscending: sortAscending ?? this.sortAscending,
    );
  }
}

