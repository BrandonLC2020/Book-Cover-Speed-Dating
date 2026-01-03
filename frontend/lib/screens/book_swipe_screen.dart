import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/book_swipe_bloc.dart';
import '../components/book_cover_card.dart';
import '../components/book_details_overlay.dart';

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
      backgroundColor: Colors.grey[100],
      body: BlocConsumer<BookSwipeBloc, BookSwipeState>(
          listener: (context, state) {
            if (state is BookSwipeError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${state.message}'),
                  action: SnackBarAction(
                    label: 'Retry',
                    onPressed: () {
                      context.read<BookSwipeBloc>().add(const LoadBooks());
                    },
                  ),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is BookSwipeInitial || state is BookSwipeLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state is BookSwipeError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading books',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<BookSwipeBloc>().add(const LoadBooks());
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state is BookSwipeDetails) {
              return Stack(
                children: [
                  // Background (blurred swipe screen)
                  BookSwipeContent(
                    state: BookSwipeLoaded(
                      books: state.remainingBooks,
                      currentIndex: state.currentIndex,
                      currentSubject: state.currentSubject,
                    ),
                  ),
                  // Details overlay
                  BookDetailsOverlay(
                    book: state.book,
                    onClose: () {
                      context.read<BookSwipeBloc>().add(const CloseDetails());
                    },
                  ),
                ],
              );
            }

            if (state is BookSwipeLoaded) {
              return BookSwipeContent(state: state);
            }

            return const Center(
              child: Text('Unknown state'),
            );
          },
        ),
      );
  }
}

class BookSwipeContent extends StatefulWidget {
  final BookSwipeLoaded state;

  const BookSwipeContent({
    super.key,
    required this.state,
  });

  @override
  State<BookSwipeContent> createState() => _BookSwipeContentState();
}

class _BookSwipeContentState extends State<BookSwipeContent> {
  Offset _dragOffset = Offset.zero;
  double _rotation = 0.0;
  double _opacity = 1.0;

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _dragOffset = Offset.zero;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta;
      final screenWidth = MediaQuery.of(context).size.width;
      final dragRatio = _dragOffset.dx / screenWidth;
      _rotation = dragRatio * 0.1; // Max rotation of 0.1 radians
      _opacity = 1.0 - (_dragOffset.dx.abs() / screenWidth * 0.5).clamp(0.0, 0.5);
    });
  }

  void _onPanEnd(DragEndDetails details, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final velocity = details.velocity.pixelsPerSecond.dx;
    final dragDistance = _dragOffset.dx;

    // Determine if swipe was significant enough
    final swipeThreshold = screenWidth * 0.3;
    final isSwipeLeft = dragDistance < -swipeThreshold || velocity < -500;
    final isSwipeRight = dragDistance > swipeThreshold || velocity > 500;

    if (isSwipeLeft) {
      context.read<BookSwipeBloc>().add(const SwipeLeft());
    } else if (isSwipeRight) {
      context.read<BookSwipeBloc>().add(const SwipeRight());
    }

    // Reset transform
    setState(() {
      _dragOffset = Offset.zero;
      _rotation = 0.0;
      _opacity = 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final remainingBooks = widget.state.books.sublist(widget.state.currentIndex);

    if (remainingBooks.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final currentBook = remainingBooks[0];
    final nextBooks = remainingBooks.length > 1 ? remainingBooks.sublist(1, remainingBooks.length > 4 ? 4 : remainingBooks.length) : [];

    return SafeArea(
      child: Column(
        children: [
          // Subject indicator
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.category, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    widget.state.currentSubject.replaceAll('_', ' ').toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Swipeable cards stack
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background cards (stacked behind)
                ...nextBooks.asMap().entries.map((entry) {
                  final index = entry.key;
                  final book = entry.value;
                  return Positioned(
                    top: 20.0 + (index * 10.0),
                    child: Transform.scale(
                      scale: 0.9 - (index * 0.05),
                      child: Opacity(
                        opacity: 0.7 - (index * 0.1),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width - 32,
                          height: MediaQuery.of(context).size.height * 0.7,
                          child: BookCoverCard(book: book),
                        ),
                      ),
                    ),
                  );
                }),
                // Current card (swipeable)
                if (currentBook != null)
                  GestureDetector(
                    onPanStart: _onPanStart,
                    onPanUpdate: _onPanUpdate,
                    onPanEnd: (details) => _onPanEnd(details, context),
                    child: Transform(
                      transform: Matrix4.identity()
                        ..translate(_dragOffset.dx, _dragOffset.dy)
                        ..rotateZ(_rotation),
                      alignment: Alignment.center,
                      child: Opacity(
                        opacity: _opacity,
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width - 32,
                          height: MediaQuery.of(context).size.height * 0.7,
                          child: BookCoverCard(book: currentBook),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Action buttons
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Swipe left button
                FloatingActionButton(
                  onPressed: () {
                    context.read<BookSwipeBloc>().add(const SwipeLeft());
                  },
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.close, color: Colors.white),
                ),
                // Swipe right button
                FloatingActionButton(
                  onPressed: () {
                    context.read<BookSwipeBloc>().add(const SwipeRight());
                  },
                  backgroundColor: Colors.green,
                  child: const Icon(Icons.favorite, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

