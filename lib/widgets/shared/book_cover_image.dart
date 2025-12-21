import 'package:flutter/material.dart';
import '../../models/book.dart';
import '../../utils/image_utils.dart';
import 'placeholder_cover.dart';

class BookCoverImage extends StatelessWidget {
  final Book book;
  final double width;
  final double? height;
  final BoxFit fit;
  final FilterQuality filterQuality;

  const BookCoverImage({
    super.key,
    required this.book,
    required this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.filterQuality = FilterQuality.medium,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = book.thumbnailUrl;
    final iconSize = width * 0.4;

    if (imageUrl != null) {
      return Image.network(
        ImageUtils.getHighQualityImageUrl(imageUrl) ?? imageUrl,
        width: width,
        height: height,
        fit: fit,
        cacheWidth: ImageUtils.getCacheWidth(displayWidth: width)?.toInt(),
        filterQuality: filterQuality,
        errorBuilder: (context, error, stackTrace) =>
            PlaceholderCover(iconSize: iconSize),
      );
    } else {
      return SizedBox(
        width: width,
        height: height,
        child: PlaceholderCover(iconSize: iconSize),
      );
    }
  }
}


