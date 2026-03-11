import 'package:flutter/material.dart';
import '../../models/book.dart';
import '../../models/wishlist_filter.dart';
import '../shared/book_details_modal.dart';
import '../shared/book_cover_image.dart';

class WishlistListView extends StatelessWidget {
  final List<Book> books;
  final WishlistFilter filter;
  final Function(List<Book>)? onReorder;

  const WishlistListView({
    super.key,
    required this.books,
    required this.filter,
    this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    final canReorder = filter.sortBy == WishlistSortOption.priority && onReorder != null;

    if (canReorder) {
      return ReorderableListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: books.length,
        onReorder: (oldIndex, newIndex) {
          if (newIndex > oldIndex) {
            newIndex -= 1;
          }
          final newList = List<Book>.from(books);
          final item = newList.removeAt(oldIndex);
          newList.insert(newIndex, item);
          
          final updatedList = newList.asMap().entries.map((entry) {
            return entry.value.copyWith(priority: entry.key + 1);
          }).toList();
          
          onReorder!(updatedList);
        },
        itemBuilder: (context, index) {
          final book = books[index];
          return _buildBookTile(context, book, index, canReorder: true);
        },
      );
    } else {
      return ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: books.length,
        itemBuilder: (context, index) {
          final book = books[index];
          return _buildBookTile(context, book, index, canReorder: false);
        },
      );
    }
  }

  Widget _buildBookTile(BuildContext context, Book book, int index, {required bool canReorder}) {
    return Card(
      key: ValueKey(book.id ?? index),
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        leading: BookCoverImage(
          book: book,
          width: 60,
          height: 90,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.medium,
        ),
        title: Text(
          book.title,
          style: Theme.of(context).textTheme.titleMedium,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (book.author != null) ...[
              const SizedBox(height: 4),
              Text(
                book.author!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 8),
            if (book.priority != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.priority_high,
                      size: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${book.priority}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        trailing: canReorder
            ? const Icon(Icons.drag_handle, color: Colors.grey)
            : null,
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => Builder(
              builder: (context) => Padding(
                padding: MediaQuery.of(context).viewInsets,
                child: BookDetailsModal(book: book),
              ),
            ),
          );
        },
        isThreeLine: true,
      ),
    );
  }
}

