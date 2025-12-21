import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/book.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init() {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('library.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    String path;
    
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      final documentsDirectory = await getApplicationDocumentsDirectory();
      path = join(documentsDirectory.path, filePath);
    } else {
      final dbPath = await getDatabasesPath();
      path = join(dbPath, filePath);
    }

    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE books (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        author TEXT,
        isbn TEXT,
        publisher TEXT,
        publishedDate TEXT,
        description TEXT,
        thumbnailUrl TEXT,
        pageCount INTEGER DEFAULT 0,
        genre TEXT,
        dateAdded TEXT NOT NULL,
        isInLibrary INTEGER NOT NULL DEFAULT 0,
        isRead INTEGER NOT NULL DEFAULT 0,
        rating INTEGER,
        priority INTEGER,
        version TEXT,
        edition TEXT,
        language TEXT,
        previewLink TEXT,
        notes TEXT,
        series TEXT
      )
    ''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE books ADD COLUMN notes TEXT');
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE books ADD COLUMN series TEXT');
    }
  }

  Future<Book> createBook(Book book) async {
    final db = await database;
    final id = await db.insert('books', book.toMap());
    return book.copyWith(id: id);
  }

  Future<Book?> readBook(int id) async {
    final db = await database;
    final maps = await db.query(
      'books',
      columns: null,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Book.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<List<Book>> readAllBooks({bool? inLibrary}) async {
    final db = await database;
    if (inLibrary != null) {
      final maps = await db.query(
        'books',
        where: 'isInLibrary = ?',
        whereArgs: [inLibrary ? 1 : 0],
        orderBy: 'dateAdded DESC',
      );
      return maps.map((map) => Book.fromMap(map)).toList();
    } else {
      final maps = await db.query('books', orderBy: 'dateAdded DESC');
      return maps.map((map) => Book.fromMap(map)).toList();
    }
  }

  Future<int> updateBook(Book book) async {
    final db = await database;
    return db.update(
      'books',
      book.toMap(),
      where: 'id = ?',
      whereArgs: [book.id],
    );
  }

  Future<int> deleteBook(int id) async {
    final db = await database;
    return db.delete(
      'books',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Book>> updateBookPriorities(List<Book> books) async {
    final db = await database;
    final batch = db.batch();
    
    for (final book in books) {
      if (book.id != null) {
        batch.update(
          'books',
          {'priority': book.priority},
          where: 'id = ?',
          whereArgs: [book.id],
        );
      }
    }
    
    await batch.commit(noResult: true);
    return books;
  }

  Future<int> getMaxWishlistPriority() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT MAX(priority) as maxPriority FROM books WHERE isInLibrary = 0'
    );
    final maxPriority = result.first['maxPriority'] as int?;
    return maxPriority ?? 0;
  }

  Future<List<String>> getAllSeriesNames({bool? inLibrary}) async {
    final db = await database;
    String query = 'SELECT DISTINCT series FROM books WHERE series IS NOT NULL AND series != ""';
    List<dynamic> whereArgs = [];
    
    if (inLibrary != null) {
      query += ' AND isInLibrary = ?';
      whereArgs.add(inLibrary ? 1 : 0);
    }
    
    query += ' ORDER BY series ASC';
    
    final result = await db.rawQuery(query, whereArgs);
    return result.map((row) => row['series'] as String).toList();
  }

  Future<int> deleteAllBooks() async {
    final db = await database;
    return await db.delete('books');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}

