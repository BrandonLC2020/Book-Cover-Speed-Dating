import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../bloc/book_swipe_bloc.dart';
import '../components/book_cover_card.dart';
import '../components/book_details_overlay.dart';
import '../models/book.dart';

class BookSwipeScreen extends StatelessWidget {
  const BookSwipeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Load books on first build if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bloc = context.read<BookSwipeBloc>();
      if (bloc.state is BookSwipeInitial) {
        bloc.add(const LoadBooks());
      }
    });

    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocConsumer<BookSwipeBloc, BookSwipeState>(
        listener: (context, state) {
          if (state is BookSwipeError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.message}')),
            );
          }
        },
        builder: (context, state) {
          Book? activeBook;
          List<Book> books = [];
          int currentIndex = 0;
          String currentSubject = '';

          if (state is BookSwipeLoaded) {
            books = state.books;
            currentIndex = state.currentIndex;
            currentSubject = state.currentSubject;
            if (currentIndex < books.length) {
              activeBook = books[currentIndex];
            }
          } else if (state is BookSwipeDetails) {
            books = state.remainingBooks;
            currentIndex = state.currentIndex;
            currentSubject = state.currentSubject;
            activeBook = state.book;
          }

          return Stack(
            children: [
              if (activeBook?.coverUrl != null)
                Positioned.fill(
                  child: CachedNetworkImage(
                    imageUrl: activeBook!.coverUrl!,
                    fit: BoxFit.cover,
                  ),
                )
              else
                Container(color: Colors.grey[900]),
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
                  child: Container(
                    color: Colors.black.withOpacity(0.6),
                  ),
                ),
              ),
              if (state is BookSwipeInitial || state is BookSwipeLoading)
                const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              else if (state is BookSwipeError)
                Center(
                  child: Text(
                    state.message,
                    style: const TextStyle(color: Colors.white),
                  ),
                )
              else
                SafeArea(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 16, bottom: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white30),
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.black26,
                          ),
                          child: Text(
                            currentSubject.replaceAll('_', ' ').toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Stack(
                          children: [
                            BookSwipeContent(
                              books: books,
                              currentIndex: currentIndex,
                              currentSubject: currentSubject,
                            ),
                            if (state is BookSwipeDetails)
                              BookDetailsOverlay(
                                book: state.book,
                                onClose: () {
                                  context
                                      .read<BookSwipeBloc>()
                                      .add(const CloseDetails());
                                },
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class BookSwipeContent extends StatefulWidget {
  final List<Book> books;
  final int currentIndex;
  final String currentSubject;

  const BookSwipeContent({
    super.key,
    required this.books,
    required this.currentIndex,
    required this.currentSubject,
  });

  @override
  State<BookSwipeContent> createState() => _BookSwipeContentState();
}

class _BookSwipeContentState extends State<BookSwipeContent> {
  Offset _dragOffset = Offset.zero;
  double _rotation = 0.0;

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta;
      final screenWidth = MediaQuery.of(context).size.width;
      _rotation = (_dragOffset.dx / screenWidth) * 0.3;
    });
  }

  void _onPanEnd(DragEndDetails details, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final velocity = details.velocity.pixelsPerSecond.dx;
    final dragDistance = _dragOffset.dx;

    final swipeThreshold = screenWidth * 0.3;
    final isSwipeLeft = dragDistance < -swipeThreshold || velocity < -500;
    final isSwipeRight = dragDistance > swipeThreshold || velocity > 500;

    if (isSwipeLeft) {
      context.read<BookSwipeBloc>().add(const SwipeLeft());
      _resetCard();
    } else if (isSwipeRight) {
      context.read<BookSwipeBloc>().add(const SwipeRight());
      _resetCard();
    } else {
      _slideBackCard();
    }
  }

  void _resetCard() {
    setState(() {
      _dragOffset = Offset.zero;
      _rotation = 0.0;
    });
  }

  void _slideBackCard() {
    _resetCard();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.currentIndex >= widget.books.length) {
      return const SizedBox();
    }

    final remainingBooks = widget.books.sublist(widget.currentIndex);
    final currentBook = remainingBooks[0];
    final nextBooks = remainingBooks.length > 1
        ? remainingBooks.sublist(1, remainingBooks.length > 3 ? 3 : remainingBooks.length)
        : [];

    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Stack(
              alignment: Alignment.center,
              children: [
                ...nextBooks
                    .asMap()
                    .entries
                    .map((entry) {
                      final index = entry.key + 1;
                      return Transform.scale(
                        scale: 1.0 - (index * 0.05),
                        child: Transform.translate(
                          offset: Offset(0, index * 15),
                          child: Opacity(
                            opacity: 0.6 - (index * 0.15),
                            child: BookCoverCard(book: entry.value),
                          ),
                        ),
                      );
                    })
                    .toList()
                    .reversed,
                GestureDetector(
                  onPanStart: (_) {},
                  onPanUpdate: _onPanUpdate,
                  onPanEnd: (details) => _onPanEnd(details, context),
                  child: Transform.translate(
                    offset: _dragOffset,
                    child: Transform.rotate(
                      angle: _rotation,
                      child: BookCoverCard(book: currentBook),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildGlassButton(
                icon: Icons.close,
                color: Colors.redAccent,
                onTap: () {
                  context.read<BookSwipeBloc>().add(const SwipeLeft());
                },
              ),
              const SizedBox(width: 32),
              _buildGlassButton(
                icon: Icons.favorite,
                color: Colors.greenAccent,
                isLarge: true,
                onTap: () {
                  context.read<BookSwipeBloc>().add(const SwipeRight());
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGlassButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isLarge = false,
  }) {
    final size = isLarge ? 80.0 : 60.0;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.1),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Icon(icon, color: color, size: size * 0.5),
      ),
    );
  }
}
