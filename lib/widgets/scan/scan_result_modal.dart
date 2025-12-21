import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/book.dart';
import '../../providers/books_provider.dart';
import '../shared/detail_row.dart';
import '../shared/book_cover_image.dart';

class ScanResultModal extends ConsumerWidget {
  final Book book;

  const ScanResultModal({
    super.key,
    required this.book,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksNotifier = ref.read(booksNotifierProvider.notifier);

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Book Found',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    Center(
                      child: Container(
                        width: 150,
                        height: 225,
                        margin: const EdgeInsets.only(bottom: 16),
                        child: BookCoverImage(
                          book: book,
                          width: 150,
                          height: 225,
                          fit: BoxFit.cover,
                          filterQuality: FilterQuality.high,
                        ),
                      ),
                    ),
                    
                    Text(
                      book.title,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),

                    if (book.author != null) ...[
                      Text(
                        book.author!,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                    ],

                    DetailRow(
                      label: 'Published Date',
                      value: book.publishedDate ?? 'N/A',
                    ),
                    if (book.publisher != null)
                      DetailRow(
                        label: 'Publisher',
                        value: book.publisher!,
                      ),
                    if (book.version != null)
                      DetailRow(
                        label: 'Version',
                        value: book.version!,
                      ),
                    if (book.isbn != null)
                      DetailRow(
                        label: 'ISBN',
                        value: book.isbn!,
                      ),

                    if (book.description != null) ...[
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      Text(
                        'Description',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        book.description!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        Navigator.pop(context);
                        await booksNotifier.addBookToLibrary(book);
                        if (context.mounted) {
                          ref.invalidate(libraryBooksProvider);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Added to Library'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.library_books),
                      label: const Text('Add to Library'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () async {
                        Navigator.pop(context);
                        await booksNotifier.addBookToWishlist(book);
                        if (context.mounted) {
                          ref.invalidate(wishlistBooksProvider);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Added to Wishlist'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.favorite),
                      label: const Text('Add to Wishlist'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.pink,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

}

