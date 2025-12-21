import '../models/book.dart';
import '../models/series_group.dart';

class BookUtils {
  static List<Book> filterBySearchQuery(List<Book> books, String? searchQuery) {
    if (searchQuery == null || searchQuery.isEmpty) {
      return books;
    }
    
    final query = searchQuery.toLowerCase();
    return books.where((book) {
      return book.title.toLowerCase().contains(query) ||
          (book.author?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  static List<Book> filterByGenre(List<Book> books, String? genre) {
    if (genre == null) {
      return books;
    }
    
    return books.where((book) {
      if (book.genre == null) return false;
      final genres = book.genre!.split(',').map((g) => g.trim()).toList();
      return genres.any((g) => g.toLowerCase() == genre.toLowerCase());
    }).toList();
  }

  static List<SeriesGroup> groupBySeries(List<Book> books) {
    final Map<String, List<Book>> seriesMap = {};
    final List<Book> standaloneBooks = [];

    for (final book in books) {
      if (book.series != null && book.series!.trim().isNotEmpty) {
        final seriesName = book.series!.trim();
        seriesMap.putIfAbsent(seriesName, () => []).add(book);
      } else {
        standaloneBooks.add(book);
      }
    }

    final List<SeriesGroup> seriesGroups = [];

    for (final entry in seriesMap.entries) {
      final seriesBooks = entry.value;
      if (seriesBooks.isNotEmpty) {
        seriesBooks.sort((a, b) => a.dateAdded.compareTo(b.dateAdded));
        seriesGroups.add(SeriesGroup(
          seriesName: entry.key,
          firstBook: seriesBooks.first,
          allBooks: seriesBooks,
        ));
      }
    }

    seriesGroups.sort((a, b) => a.seriesName.toLowerCase().compareTo(b.seriesName.toLowerCase()));

    for (final book in standaloneBooks) {
      seriesGroups.add(SeriesGroup(
        seriesName: book.title,
        firstBook: book,
        allBooks: [book],
      ));
    }

    return seriesGroups;
  }

  static List<Book> filterBySeries(List<Book> books, String? series) {
    if (series == null) {
      return books;
    }
    
    return books.where((book) => book.series?.trim().toLowerCase() == series.trim().toLowerCase()).toList();
  }

  static List<SeriesGroup> groupByAuthor(List<Book> books) {
    final Map<String, List<Book>> authorMap = {};
    final List<Book> noAuthorBooks = [];

    for (final book in books) {
      if (book.author != null && book.author!.trim().isNotEmpty) {
        final authorName = book.author!.trim();
        authorMap.putIfAbsent(authorName, () => []).add(book);
      } else {
        noAuthorBooks.add(book);
      }
    }

    final List<SeriesGroup> authorGroups = [];

    for (final entry in authorMap.entries) {
      final authorBooks = entry.value;
      if (authorBooks.isNotEmpty) {
        authorBooks.sort((a, b) => a.dateAdded.compareTo(b.dateAdded));
        authorGroups.add(SeriesGroup(
          seriesName: entry.key,
          firstBook: authorBooks.first,
          allBooks: authorBooks,
        ));
      }
    }

    authorGroups.sort((a, b) => a.seriesName.toLowerCase().compareTo(b.seriesName.toLowerCase()));

    for (final book in noAuthorBooks) {
      authorGroups.add(SeriesGroup(
        seriesName: book.title,
        firstBook: book,
        allBooks: [book],
      ));
    }

    return authorGroups;
  }
}


