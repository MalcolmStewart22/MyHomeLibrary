import 'package:flutter/material.dart';
import '../../models/book.dart';
import '../shared/add_book_modal.dart';
import '../shared/book_details_modal.dart';
import '../shared/book_cover_image.dart';

class SearchResultRow extends StatelessWidget {
  final Book book;

  const SearchResultRow({
    super.key,
    required this.book,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
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
            if (book.version != null) ...[
              const SizedBox(height: 4),
              Text(
                book.version!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
              ),
            ],
          ],
        ),
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
        trailing: ElevatedButton.icon(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (context) => AddBookModal(book: book),
            );
          },
          icon: const Icon(Icons.add),
          label: const Text('Add'),
        ),
        isThreeLine: book.version != null,
      ),
    );
  }
}

