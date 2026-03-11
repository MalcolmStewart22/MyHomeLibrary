import 'package:flutter/material.dart';
import '../../models/series_group.dart';
import '../shared/book_details_modal.dart';
import '../shared/book_cover_image.dart';

class BookListView extends StatelessWidget {
  final List<SeriesGroup> seriesGroups;
  final void Function(String)? onSeriesTap;

  const BookListView({
    super.key,
    required this.seriesGroups,
    this.onSeriesTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: seriesGroups.length,
      itemBuilder: (context, index) {
        final seriesGroup = seriesGroups[index];
        final book = seriesGroup.firstBook;
        final displayTitle = seriesGroup.allBooks.length > 1 
            ? seriesGroup.seriesName 
            : book.title;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 8.0),
          child: ListTile(
            leading: Stack(
              children: [
                BookCoverImage(
                  book: book,
                  width: 60,
                  height: 90,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.medium,
                ),
                if (seriesGroup.allBooks.length > 1)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${seriesGroup.allBooks.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            title: Text(
              displayTitle,
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
                Row(
                  children: [
                    if (book.isRead)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Read',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Unread',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    if (book.rating != null) ...[
                      const SizedBox(width: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(5, (starIndex) {
                          return Icon(
                            starIndex < book.rating!
                                ? Icons.star
                                : Icons.star_border,
                            size: 16,
                            color: Colors.amber,
                          );
                        }),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            onTap: () {
              if (onSeriesTap != null && seriesGroup.allBooks.length > 1) {
                onSeriesTap!(seriesGroup.seriesName);
              } else {
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
              }
            },
            isThreeLine: true,
          ),
        );
      },
    );
  }
}

