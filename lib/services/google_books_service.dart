import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book.dart';

class GoogleBooksService {
  static const String baseUrl = 'https://www.googleapis.com/books/v1/volumes';

  Future<List<Book>> searchBooks(String query, {int maxResults = 20}) async {
    try {
      final uri = Uri.parse('$baseUrl?q=${Uri.encodeComponent(query)}&maxResults=$maxResults');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final items = jsonData['items'] as List?;
        
        if (items == null) {
          return [];
        }

        return items.map((item) {
          final volumeInfo = (item as Map<String, dynamic>)['volumeInfo'] as Map<String, dynamic>?;
          if (volumeInfo == null) return null;

          String? isbn;
          final identifiers = volumeInfo['industryIdentifiers'] as List?;
          if (identifiers != null) {
            for (var id in identifiers) {
              final type = (id as Map<String, dynamic>)['type'] as String?;
              final identifier = (id as Map<String, dynamic>)['identifier'] as String?;
              if (type == 'ISBN_13' && identifier != null) {
                isbn = identifier;
                break;
              } else if (type == 'ISBN_10' && identifier != null && isbn == null) {
                isbn = identifier;
              }
            }
          }

          String? version;
          final printType = volumeInfo['printType'] as String?;
          if (printType != null) {
            version = _normalizePrintType(printType);
          }

          final imageLinks = volumeInfo['imageLinks'] as Map<String, dynamic>?;
          final thumbnail = imageLinks?['medium'] as String? ?? 
                           imageLinks?['small'] as String? ?? 
                           imageLinks?['thumbnail'] as String?;

          String? edition;
          final subtitle = volumeInfo['subtitle'] as String?;
          if (subtitle != null && subtitle.toLowerCase().contains('edition')) {
            edition = subtitle;
          }

          final language = volumeInfo['language'] as String?;
          final previewLink = volumeInfo['previewLink'] as String?;

          return Book(
            title: volumeInfo['title'] as String? ?? 'Unknown Title',
            author: (volumeInfo['authors'] as List?)?.join(', '),
            isbn: isbn,
            publisher: volumeInfo['publisher'] as String?,
            publishedDate: volumeInfo['publishedDate'] as String?,
            description: volumeInfo['description'] as String?,
            thumbnailUrl: thumbnail,
            pageCount: volumeInfo['pageCount'] as int? ?? 0,
            genre: (volumeInfo['categories'] as List?)?.join(', '),
            version: version,
            edition: edition,
            language: language,
            previewLink: previewLink,
          );
        }).whereType<Book>().toList();
      } else {
        throw Exception('Failed to load books: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching books: $e');
    }
  }

  Future<Book?> getBookByISBN(String isbn) async {
    try {
      final uri = Uri.parse('$baseUrl?q=isbn:$isbn');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final items = jsonData['items'] as List?;
        
        if (items != null && items.isNotEmpty) {
          final item = items.first as Map<String, dynamic>;
          final volumeInfo = item['volumeInfo'] as Map<String, dynamic>?;
          if (volumeInfo == null) return null;

          String? version;
          final printType = volumeInfo['printType'] as String?;
          if (printType != null) {
            version = _normalizePrintType(printType);
          }

          final imageLinks = volumeInfo['imageLinks'] as Map<String, dynamic>?;
          final thumbnail = imageLinks?['medium'] as String? ?? 
                           imageLinks?['small'] as String? ?? 
                           imageLinks?['thumbnail'] as String?;

          String? edition;
          final subtitle = volumeInfo['subtitle'] as String?;
          if (subtitle != null && subtitle.toLowerCase().contains('edition')) {
            edition = subtitle;
          }

          return Book(
            title: volumeInfo['title'] as String? ?? 'Unknown Title',
            author: (volumeInfo['authors'] as List?)?.join(', '),
            isbn: isbn,
            publisher: volumeInfo['publisher'] as String?,
            publishedDate: volumeInfo['publishedDate'] as String?,
            description: volumeInfo['description'] as String?,
            thumbnailUrl: thumbnail,
            pageCount: volumeInfo['pageCount'] as int? ?? 0,
            genre: (volumeInfo['categories'] as List?)?.join(', '),
            version: version,
            edition: edition,
            language: volumeInfo['language'] as String?,
            previewLink: volumeInfo['previewLink'] as String?,
          );
        }
      }
      return null;
    } catch (e) {
      throw Exception('Error getting book by ISBN: $e');
    }
  }

  String _normalizePrintType(String printType) {
    switch (printType.toLowerCase()) {
      case 'book':
        return 'Hardback';
      default:
        return printType;
    }
  }
}

