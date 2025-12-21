import 'book.dart';

class SeriesGroup {
  final String seriesName;
  final Book firstBook;
  final List<Book> allBooks;

  SeriesGroup({
    required this.seriesName,
    required this.firstBook,
    required this.allBooks,
  });
}

