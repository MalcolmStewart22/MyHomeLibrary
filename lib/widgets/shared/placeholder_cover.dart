import 'package:flutter/material.dart';

class PlaceholderCover extends StatelessWidget {
  final double? iconSize;

  const PlaceholderCover({
    super.key,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[300],
      child: Center(
        child: Icon(
          Icons.book,
          size: iconSize ?? 48,
          color: Colors.grey,
        ),
      ),
    );
  }
}


