import 'package:flutter/material.dart';
import '../../models/series_group.dart';
import '../shared/book_details_modal.dart';
import '../shared/book_cover_image.dart';

class BookGridView extends StatelessWidget {
  final List<SeriesGroup> seriesGroups;
  final void Function(String)? onSeriesTap;

  const BookGridView({
    super.key,
    required this.seriesGroups,
    this.onSeriesTap,
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
      itemCount: seriesGroups.length,
      itemBuilder: (context, index) {
        final seriesGroup = seriesGroups[index];
        final book = seriesGroup.firstBook;
        final displayTitle = seriesGroup.allBooks.length > 1 
            ? seriesGroup.seriesName 
            : book.title;
        
        return Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              if (onSeriesTap != null && seriesGroup.allBooks.length > 1) {
                onSeriesTap!(seriesGroup.seriesName);
              } else {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => BookDetailsModal(book: book),
                );
              }
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      BookCoverImage(
                        book: book,
                        width: 200,
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.medium,
                      ),
                      if (seriesGroup.allBooks.length > 1)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${seriesGroup.allBooks.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    displayTitle,
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

