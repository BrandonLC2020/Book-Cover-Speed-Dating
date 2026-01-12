import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/book.dart';

class BookCoverCard extends StatelessWidget {
  final Book book;
  final VoidCallback? onSwipeLeft;
  final VoidCallback? onSwipeRight;

  const BookCoverCard({
    super.key,
    required this.book,
    this.onSwipeLeft,
    this.onSwipeRight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: book.coverUrl != null
            ? CachedNetworkImage(
                imageUrl: book.coverUrl!,
                fit: BoxFit.contain,
                placeholder: (context, url) => Container(
                  color: Colors.white10,
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.white10,
                  child: const Icon(
                    Icons.broken_image,
                    color: Colors.white54,
                    size: 40,
                  ),
                ),
              )
            : Container(
                color: Colors.white10,
                child: const Icon(
                  Icons.book,
                  color: Colors.white54,
                  size: 60,
                ),
              ),
      ),
    );
  }
}
