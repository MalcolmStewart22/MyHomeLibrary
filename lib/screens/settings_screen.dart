import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';
import '../providers/books_provider.dart';
import '../providers/search_provider.dart';
import '../widgets/settings/delete_confirmation_modal.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final darkModeAsync = ref.watch(darkModeProvider);
    final isDarkMode = darkModeAsync.valueOrNull ?? false;
    final booksNotifier = ref.read(booksNotifierProvider.notifier);

    Future<void> handleDeleteAll() async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => const DeleteConfirmationModal(),
      );

      if (confirmed == true) {
        await booksNotifier.deleteAllBooks();
        ref.read(searchHistoryProvider.notifier).clearHistory();
        ref.invalidate(libraryBooksProvider);
        ref.invalidate(wishlistBooksProvider);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('All data has been cleared'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Enable dark mode with dark navy background'),
            value: isDarkMode,
            onChanged: (value) {
              ref.read(darkModeProvider.notifier).setDarkMode(value);
            },
          ),
          const Divider(),
          ListTile(
            title: const Text(
              'Clear All Data',
              style: TextStyle(color: Colors.red),
            ),
            subtitle: const Text(
              'Permanently delete all books from library and wishlist, and clear search history',
            ),
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            onTap: handleDeleteAll,
          ),
        ],
      ),
    );
  }
}

