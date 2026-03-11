class Book {
  final int? id;
  final String title;
  final String? author;
  final String? isbn;
  final String? publisher;
  final String? publishedDate;
  final String? description;
  final String? thumbnailUrl;
  final int pageCount;
  final String? genre;
  final DateTime dateAdded;
  final bool isInLibrary;
  final bool isRead;
  final int? rating;
  final int? priority;
  final String? version;
  final String? edition;
  final String? language;
  final String? previewLink;
  final String? notes;
  final String? series;

  Book({
    this.id,
    required this.title,
    this.author,
    this.isbn,
    this.publisher,
    this.publishedDate,
    this.description,
    this.thumbnailUrl,
    this.pageCount = 0,
    this.genre,
    DateTime? dateAdded,
    this.isInLibrary = false,
    this.isRead = false,
    this.rating,
    this.priority,
    this.version,
    this.edition,
    this.language,
    this.previewLink,
    this.notes,
    this.series,
  }) : dateAdded = dateAdded ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'isbn': isbn,
      'publisher': publisher,
      'publishedDate': publishedDate,
      'description': description,
      'thumbnailUrl': thumbnailUrl,
      'pageCount': pageCount,
      'genre': genre,
      'dateAdded': dateAdded.toIso8601String(),
      'isInLibrary': isInLibrary ? 1 : 0,
      'isRead': isRead ? 1 : 0,
      'rating': rating,
      'priority': priority,
      'version': version,
      'edition': edition,
      'language': language,
      'previewLink': previewLink,
      'notes': notes,
      'series': series,
    };
  }

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'] as int?,
      title: map['title'] as String,
      author: map['author'] as String?,
      isbn: map['isbn'] as String?,
      publisher: map['publisher'] as String?,
      publishedDate: map['publishedDate'] as String?,
      description: map['description'] as String?,
      thumbnailUrl: map['thumbnailUrl'] as String?,
      pageCount: map['pageCount'] as int? ?? 0,
      genre: map['genre'] as String?,
      dateAdded: map['dateAdded'] != null
          ? DateTime.parse(map['dateAdded'] as String)
          : null,
      isInLibrary: (map['isInLibrary'] as int? ?? 0) == 1,
      isRead: (map['isRead'] as int? ?? 0) == 1,
      rating: map['rating'] as int?,
      priority: map['priority'] as int?,
      version: map['version'] as String?,
      edition: map['edition'] as String?,
      language: map['language'] as String?,
      previewLink: map['previewLink'] as String?,
      notes: map['notes'] as String?,
      series: map['series'] as String?,
    );
  }

  static const _undefined = Object();

  Book copyWith({
    int? id,
    String? title,
    String? author,
    String? isbn,
    String? publisher,
    String? publishedDate,
    String? description,
    String? thumbnailUrl,
    int? pageCount,
    String? genre,
    DateTime? dateAdded,
    bool? isInLibrary,
    bool? isRead,
    Object? rating = _undefined,
    Object? priority = _undefined,
    String? version,
    String? edition,
    String? language,
    String? previewLink,
    Object? notes = _undefined,
    Object? series = _undefined,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      isbn: isbn ?? this.isbn,
      publisher: publisher ?? this.publisher,
      publishedDate: publishedDate ?? this.publishedDate,
      description: description ?? this.description,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      pageCount: pageCount ?? this.pageCount,
      genre: genre ?? this.genre,
      dateAdded: dateAdded ?? this.dateAdded,
      isInLibrary: isInLibrary ?? this.isInLibrary,
      isRead: isRead ?? this.isRead,
      rating: rating == _undefined ? this.rating : rating as int?,
      priority: priority == _undefined ? this.priority : priority as int?,
      version: version ?? this.version,
      edition: edition ?? this.edition,
      language: language ?? this.language,
      previewLink: previewLink ?? this.previewLink,
      notes: notes == _undefined ? this.notes : notes as String?,
      series: series == _undefined ? this.series : series as String?,
    );
  }
}

