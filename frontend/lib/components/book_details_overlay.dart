import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/book.dart';
import '../networking/api/book_api.dart';

class BookDetailsOverlay extends StatefulWidget {
  final Book book;
  final VoidCallback onClose;

  const BookDetailsOverlay({
    super.key,
    required this.book,
    required this.onClose,
  });

  @override
  State<BookDetailsOverlay> createState() => _BookDetailsOverlayState();
}

class _BookDetailsOverlayState extends State<BookDetailsOverlay> {
  late Book _book;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _book = widget.book;
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    try {
      final updatedBook = await BookApi().getBookDetails(widget.book);
      if (mounted) {
        setState(() {
          _book = updatedBook;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      debugPrint('Error fetching book details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Material(
      color: Colors.black.withValues(alpha: 0.65),
      child: SafeArea(
        child: GestureDetector(
          onTap: widget.onClose,
          child: Container(
            color: Colors.transparent,
            child: Center(
              child: GestureDetector(
                onTap: () {}, // Prevent tap from closing when tapping on card
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  constraints: const BoxConstraints(maxWidth: 500, maxHeight: 800),
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 24,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header with scrollable content below
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Stack for Cover + Close button
                              Stack(
                                children: [
                                  if (_book.coverUrl != null)
                                    CachedNetworkImage(
                                      imageUrl: _book.coverUrl!,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      alignment: Alignment.topCenter,
                                      height: 340,
                                      placeholder: (context, url) => Container(
                                        height: 340,
                                        color: colorScheme.surfaceContainer,
                                        child: Center(
                                          child: CircularProgressIndicator(color: colorScheme.primary),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) => Container(
                                        height: 340,
                                        color: colorScheme.surfaceContainer,
                                        child: Center(
                                          child: Icon(
                                            Icons.broken_image,
                                            size: 64,
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ),
                                    )
                                  else
                                    Container(
                                      height: 280,
                                      color: colorScheme.surfaceContainer,
                                      child: Center(
                                        child: Icon(
                                          Icons.book,
                                          size: 64,
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ),
                                    
                                  // Close button overlay
                                  Positioned(
                                    top: 12,
                                    right: 12,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.6),
                                        shape: BoxShape.circle,
                                      ),
                                      child: IconButton(
                                        icon: const Icon(Icons.close, color: Colors.white),
                                        tooltip: 'Close details',
                                        onPressed: widget.onClose,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              
                              // Book details
                              Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _book.title.isNotEmpty ? _book.title : 'Untitled Book',
                                      style: textTheme.headlineSmall?.copyWith(
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.person_outline_rounded,
                                          size: 18,
                                          color: colorScheme.primary,
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            _book.author.isNotEmpty ? _book.author : 'Unknown Author',
                                            style: textTheme.titleMedium?.copyWith(
                                              color: colorScheme.onSurfaceVariant,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    if (_isLoading)
                                      Center(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 24),
                                          child: CircularProgressIndicator(color: colorScheme.primary),
                                        ),
                                      )
                                    else ...[
                                      if (_book.description != null && _book.description!.isNotEmpty) ...[
                                        Text(
                                          'Description',
                                          style: textTheme.titleSmall?.copyWith(
                                            color: colorScheme.onSurface,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          _book.description!,
                                          style: textTheme.bodyMedium?.copyWith(
                                            color: colorScheme.onSurface.withValues(alpha: 0.88),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                      ],
                                      if (_book.subjects != null && _book.subjects!.isNotEmpty) ...[
                                        Text(
                                          'Subjects',
                                          style: textTheme.titleSmall?.copyWith(
                                            color: colorScheme.onSurface,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          children: _book.subjects!.map((subject) {
                                            return Chip(
                                              label: Text(
                                                subject,
                                                style: textTheme.labelSmall?.copyWith(
                                                  color: colorScheme.onPrimaryContainer,
                                                ),
                                              ),
                                              backgroundColor: colorScheme.primaryContainer.withValues(alpha: 0.6),
                                              side: BorderSide.none,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                        const SizedBox(height: 16),
                                      ],
                                      if (_book.publishers != null && _book.publishers!.isNotEmpty) ...[
                                        Text(
                                          'Publisher: ${_book.publishers!.join(", ")}',
                                          style: textTheme.bodySmall?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                      if (_book.publishDate != null)
                                        Text(
                                          'Published: ${_book.publishDate}',
                                          style: textTheme.bodySmall?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Footer Action
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: widget.onClose,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Text(
                              'Continue Swiping',
                              style: textTheme.titleMedium?.copyWith(
                                color: colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

