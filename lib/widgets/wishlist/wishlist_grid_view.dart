import 'package:flutter/material.dart';
import '../../models/book.dart';
import '../shared/book_details_modal.dart';
import '../shared/book_cover_image.dart';

class WishlistGridView extends StatelessWidget {
  final List<Book> books;

  const WishlistGridView({
    super.key,
    required this.books,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.6,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => BookDetailsModal(book: book),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: BookCoverImage(
                    book: book,
                    width: 200,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.medium,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    book.title,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

