import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/main_navigation.dart';
import 'providers/theme_provider.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final darkModeAsync = ref.watch(darkModeProvider);
    const darkNavy = Color(0xFF0A1929);
    final isDarkMode = darkModeAsync.valueOrNull ?? false;

    return MaterialApp(
      title: 'My Home Library',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ).copyWith(
          surface: darkNavy,
        ),
        useMaterial3: true,
      ),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      builder: (context, child) {
        return Container(
          color: isDarkMode ? darkNavy : null,
          child: child,
        );
      },
      home: const MainNavigation(),
    );
  }
}

