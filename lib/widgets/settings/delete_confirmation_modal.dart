import 'package:flutter/material.dart';

class DeleteConfirmationModal extends StatelessWidget {
  const DeleteConfirmationModal({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Clear All Data'),
      content: const Text(
        'Are you sure you want to clear all data? This action cannot be undone and will permanently remove all books from your library and wishlist, and clear your search history.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: const Text('Clear All'),
        ),
      ],
    );
  }
}


