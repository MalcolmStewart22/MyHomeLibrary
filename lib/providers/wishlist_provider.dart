import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/wishlist_filter.dart';
import '../models/library_filter.dart' show ViewMode;

final wishlistViewModeProvider = StateProvider<ViewMode>((ref) => ViewMode.grid);

final wishlistFilterProvider = StateProvider<WishlistFilter>((ref) {
  return WishlistFilter();
});

