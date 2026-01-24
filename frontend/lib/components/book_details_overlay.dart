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
      print('Error fetching book details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: SafeArea(
        child: GestureDetector(
          onTap: widget.onClose,
          child: Container(
            color: Colors.transparent,
            child: Center(
              child: GestureDetector(
                onTap: () {}, // Prevent tap from closing when tapping on card
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  constraints: const BoxConstraints(maxWidth: 500, maxHeight: 800),
                  clipBehavior: Clip.hardEdge, // Ensure scrolling content doesn't bleed
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
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
                                      // Limit initial image height relative to screen or fixed max
                                      height: 350, 
                                      placeholder: (context, url) => Container(
                                        height: 350,
                                        color: Colors.grey[300],
                                        child: const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) => Container(
                                        height: 350,
                                        color: Colors.grey[300],
                                        child: const Center(
                                          child: Icon(
                                            Icons.broken_image,
                                            size: 64,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                    )
                                  else
                                    Container(
                                      height: 300,
                                      color: Colors.grey[300],
                                      child: const Center(
                                        child: Icon(
                                          Icons.book,
                                          size: 64,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                    
                                  // Close button overlay
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.5),
                                        shape: BoxShape.circle,
                                      ),
                                      child: IconButton(
                                        icon: const Icon(Icons.close, color: Colors.white),
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
                                      _book.title,
                                      style: const TextStyle(
                                        fontSize: 24, // Slightly smaller for better fit
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.person,
                                          size: 18,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            _book.author,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              color: Colors.grey,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                     const SizedBox(height: 16),
                                    if (_isLoading)
                                      const Center(child: CircularProgressIndicator())
                                    else ...[
                                      if (_book.description != null) ...[
                                        const Text(
                                          'Description',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          _book.description!,
                                          style: const TextStyle(fontSize: 16, height: 1.5),
                                        ),
                                        const SizedBox(height: 16),
                                      ],
                                      if (_book.subjects != null && _book.subjects!.isNotEmpty) ...[
                                        const Text(
                                          'Subjects',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          children: _book.subjects!.map((subject) {
                                            return Chip(
                                              label: Text(subject),
                                              backgroundColor: Colors.grey[200],
                                            );
                                          }).toList(),
                                        ),
                                        const SizedBox(height: 16),
                                      ],
                                      if (_book.publishers != null && _book.publishers!.isNotEmpty) ...[
                                        Text(
                                          'Publisher: ${_book.publishers!.join(", ")}',
                                          style: const TextStyle(color: Colors.grey),
                                        ),
                                      ],
                                      if (_book.publishDate != null)
                                        Text(
                                          'Published: ${_book.publishDate}',
                                          style: const TextStyle(color: Colors.grey),
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
                        padding: const EdgeInsets.all(24),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: widget.onClose,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: Colors.black, // Dark theme accent
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Continue Swiping',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

