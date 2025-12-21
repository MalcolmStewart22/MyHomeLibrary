import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/book.dart';
import '../../providers/books_provider.dart';
import '../../services/database_service.dart';
import 'detail_row.dart';
import 'book_cover_image.dart';

class BookDetailsModal extends ConsumerStatefulWidget {
  final Book book;

  const BookDetailsModal({
    super.key,
    required this.book,
  });

  @override
  ConsumerState<BookDetailsModal> createState() => _BookDetailsModalState();
}

class _BookDetailsModalState extends ConsumerState<BookDetailsModal> {
  late bool _isRead;
  late int? _rating;
  late TextEditingController _notesController;
  late TextEditingController _seriesController;

  @override
  void initState() {
    super.initState();
    _isRead = widget.book.isRead;
    _rating = widget.book.rating;
    _notesController = TextEditingController(text: widget.book.notes ?? '');
    _seriesController = TextEditingController(text: widget.book.series ?? '');
  }

  @override
  void dispose() {
    _notesController.dispose();
    _seriesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isFromLibrary = widget.book.isInLibrary;
    
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
                          book: widget.book,
                          width: 150,
                          height: 225,
                          fit: BoxFit.cover,
                          filterQuality: FilterQuality.high,
                        ),
                      ),
                    ),
                    
                    Text(
                      widget.book.title,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),

                    if (widget.book.author != null) ...[
                      Text(
                        widget.book.author!,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                    ],

                    const Divider(),

                    if (!isFromLibrary) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            if (widget.book.id != null) {
                              final booksNotifier = ref.read(booksNotifierProvider.notifier);
                              await booksNotifier.moveBookToLibrary(widget.book);
                              if (mounted) {
                                ref.invalidate(libraryBooksProvider);
                                ref.invalidate(wishlistBooksProvider);
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Book moved to Library'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            }
                          },
                          icon: const Icon(Icons.library_books),
                          label: const Text('Add to Library'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            minimumSize: const Size(double.infinity, 50),
                          ),
                        ),
                      ),
                      const Divider(),
                      const SizedBox(height: 16),
                    ],

                    if (isFromLibrary) ...[
                      _buildReadStatusSection(context),
                      const SizedBox(height: 16),
                      _buildRatingSection(context),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                    ],

                    DetailRow(
                      label: 'Published Date',
                      value: widget.book.publishedDate ?? 'N/A',
                    ),
                    if (widget.book.publisher != null)
                      DetailRow(
                        label: 'Publisher',
                        value: widget.book.publisher!,
                      ),
                    if (widget.book.version != null)
                      DetailRow(
                        label: 'Version',
                        value: widget.book.version!,
                      ),
                    if (widget.book.edition != null)
                      DetailRow(
                        label: 'Edition',
                        value: widget.book.edition!,
                      ),
                    if (widget.book.pageCount > 0)
                      DetailRow(
                        label: 'Pages',
                        value: widget.book.pageCount.toString(),
                      ),
                    if (widget.book.language != null)
                      DetailRow(
                        label: 'Language',
                        value: widget.book.language!.toUpperCase(),
                      ),
                    if (widget.book.isbn != null)
                      DetailRow(
                        label: 'ISBN',
                        value: widget.book.isbn!,
                      ),
                    if (widget.book.genre != null)
                      DetailRow(
                        label: 'Genre',
                        value: widget.book.genre!,
                      ),

                    if (widget.book.description != null) ...[
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
                        widget.book.description!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],

                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    _buildSeriesSection(context),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                    _buildNotesSection(context),
                    
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                    _buildDeleteButton(context),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReadStatusSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Read Status',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(
              value: false,
              label: Text('Unread'),
            ),
            ButtonSegment(
              value: true,
              label: Text('Read'),
            ),
          ],
          selected: {_isRead},
          onSelectionChanged: (Set<bool> selection) async {
            setState(() {
              _isRead = selection.first;
            });
            await _saveChanges();
          },
        ),
      ],
    );
  }

  Widget _buildRatingSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rating',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final rating = index + 1;
            return IconButton(
              icon: Icon(
                _rating != null && rating <= _rating!
                    ? Icons.star
                    : Icons.star_border,
                size: 40,
                color: Colors.amber,
              ),
              onPressed: () async {
                setState(() {
                  _rating = _rating == rating ? null : rating;
                });
                await _saveChanges();
              },
            );
          }),
        ),
        if (_rating != null)
          Center(
            child: TextButton(
              onPressed: () async {
                setState(() {
                  _rating = null;
                });
                await _saveChanges();
              },
              child: const Text('Clear Rating'),
            ),
          ),
      ],
    );
  }

  Future<void> _saveChanges() async {
    if (widget.book.id != null) {
      final databaseService = DatabaseService.instance;
      final updatedBook = widget.book.copyWith(
        isRead: _isRead,
        rating: _rating,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        series: _seriesController.text.trim().isEmpty ? null : _seriesController.text.trim(),
      );
      await databaseService.updateBook(updatedBook);
      
      ref.invalidate(libraryBooksProvider);
      ref.invalidate(wishlistBooksProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Book updated'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    }
  }

  Widget _buildSeriesSection(BuildContext context) {
    final seriesNamesAsync = ref.watch(allSeriesNamesProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Series',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        seriesNamesAsync.when(
          data: (seriesNames) {
            return Autocomplete<String>(
              initialValue: TextEditingValue(text: _seriesController.text),
              optionsBuilder: (textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return seriesNames;
                }
                return seriesNames.where((series) =>
                  series.toLowerCase().contains(textEditingValue.text.toLowerCase())
                ).toList();
              },
              onSelected: (String value) {
                _seriesController.text = value;
                _saveChanges();
              },
              fieldViewBuilder: (
                BuildContext context,
                TextEditingController textEditingController,
                FocusNode focusNode,
                VoidCallback onFieldSubmitted,
              ) {
                // Initialize with current value only once
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (textEditingController.text != _seriesController.text) {
                    textEditingController.text = _seriesController.text;
                  }
                });
                
                return TextField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    hintText: 'Enter series name (e.g., "Harry Potter")',
                    border: OutlineInputBorder(),
                    contentPadding: const EdgeInsets.all(12),
                    suffixIcon: seriesNames.isNotEmpty
                        ? Icon(Icons.arrow_drop_down, color: Colors.grey[600])
                        : null,
                  ),
                  onChanged: (value) {
                    _seriesController.text = value;
                  },
                  onEditingComplete: () {
                    _seriesController.text = textEditingController.text;
                    FocusScope.of(context).unfocus();
                    _saveChanges();
                  },
                  onTapOutside: (event) {
                    _seriesController.text = textEditingController.text;
                    FocusScope.of(context).unfocus();
                    _saveChanges();
                  },
                );
              },
              optionsViewBuilder: (
                BuildContext context,
                AutocompleteOnSelected<String> onSelected,
                Iterable<String> options,
              ) {
                if (options.isEmpty) {
                  return const SizedBox.shrink();
                }
                
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    elevation: 4.0,
                    borderRadius: BorderRadius.circular(4),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: options.length,
                        itemBuilder: (BuildContext context, int index) {
                          final String option = options.elementAt(index);
                          return InkWell(
                            onTap: () => onSelected(option),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text(option),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            );
          },
          loading: () => TextField(
            controller: _seriesController,
            decoration: InputDecoration(
              hintText: 'Enter series name (e.g., "Harry Potter")',
              border: OutlineInputBorder(),
              contentPadding: const EdgeInsets.all(12),
            ),
            onEditingComplete: () {
              FocusScope.of(context).unfocus();
              _saveChanges();
            },
            onTapOutside: (event) {
              FocusScope.of(context).unfocus();
              _saveChanges();
            },
          ),
          error: (error, stack) => TextField(
            controller: _seriesController,
            decoration: InputDecoration(
              hintText: 'Enter series name (e.g., "Harry Potter")',
              border: OutlineInputBorder(),
              contentPadding: const EdgeInsets.all(12),
            ),
            onEditingComplete: () {
              FocusScope.of(context).unfocus();
              _saveChanges();
            },
            onTapOutside: (event) {
              FocusScope.of(context).unfocus();
              _saveChanges();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNotesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Personal Notes',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _notesController,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: 'Add your personal notes about this book...',
            border: OutlineInputBorder(),
            contentPadding: const EdgeInsets.all(12),
          ),
          onEditingComplete: () {
            FocusScope.of(context).unfocus();
            _saveChanges();
          },
          onTapOutside: (event) {
            FocusScope.of(context).unfocus();
            _saveChanges();
          },
        ),
      ],
    );
  }

  Widget _buildDeleteButton(BuildContext context) {
    final isFromLibrary = widget.book.isInLibrary;
    
    return OutlinedButton.icon(
      onPressed: () async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Delete ${isFromLibrary ? "from Library" : "from Wishlist"}?'),
            content: Text(
              'Are you sure you want to remove "${widget.book.title}" ${isFromLibrary ? "from your library" : "from your wishlist"}? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
        );

        if (confirmed == true && widget.book.id != null) {
          final booksNotifier = ref.read(booksNotifierProvider.notifier);
          await booksNotifier.deleteBook(widget.book.id!);
          
          if (mounted) {
            ref.invalidate(libraryBooksProvider);
            ref.invalidate(wishlistBooksProvider);
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Book removed ${isFromLibrary ? "from library" : "from wishlist"}'),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        }
      },
      icon: const Icon(Icons.delete_outline, color: Colors.red),
      label: Text(
        'Remove ${isFromLibrary ? "from Library" : "from Wishlist"}',
        style: const TextStyle(color: Colors.red),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        minimumSize: const Size(double.infinity, 50),
        side: const BorderSide(color: Colors.red),
      ),
    );
  }

}

