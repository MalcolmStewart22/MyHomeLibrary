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

const _undefined = Object();

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
    Object? minRating = _undefined,
    Object? genre = _undefined,
    Object? searchQuery = _undefined,
    Object? series = _undefined,
    GroupBy? groupBy,
    SortOption? sortBy,
    bool? sortAscending,
  }) {
    return LibraryFilter(
      readStatus: readStatus ?? this.readStatus,
      minRating: minRating == _undefined ? this.minRating : minRating as int?,
      genre: genre == _undefined ? this.genre : genre as String?,
      searchQuery: searchQuery == _undefined ? this.searchQuery : searchQuery as String?,
      series: series == _undefined ? this.series : series as String?,
      groupBy: groupBy ?? this.groupBy,
      sortBy: sortBy ?? this.sortBy,
      sortAscending: sortAscending ?? this.sortAscending,
    );
  }
}

