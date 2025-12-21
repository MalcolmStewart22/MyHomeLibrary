import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/book.dart';
import '../../providers/books_provider.dart';

class AddBookModal extends ConsumerWidget {
  final Book book;

  const AddBookModal({
    super.key,
    required this.book,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksNotifier = ref.read(booksNotifierProvider.notifier);

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(
            'Add Book',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            book.title,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          if (book.author != null) ...[
            const SizedBox(height: 4),
            Text(
              book.author!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              await booksNotifier.addBookToLibrary(book);
              if (context.mounted) {
                ref.invalidate(libraryBooksProvider);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Added to Library')),
                );
              }
            },
            icon: const Icon(Icons.library_books),
            label: const Text('Add to Library'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
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
                  const SnackBar(content: Text('Added to Wishlist')),
                );
              }
            },
            icon: const Icon(Icons.favorite),
            label: const Text('Add to Wishlist'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.pink,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}


