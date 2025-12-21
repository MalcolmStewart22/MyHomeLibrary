import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/library_filter.dart';

final libraryViewModeProvider = StateProvider<ViewMode>((ref) => ViewMode.grid);

final libraryFilterProvider = StateProvider<LibraryFilter>((ref) {
  return LibraryFilter();
});

