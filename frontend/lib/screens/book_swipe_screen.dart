import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../bloc/book_swipe_bloc.dart';
import '../components/book_cover_card.dart';
import '../components/book_details_overlay.dart';
import '../models/book.dart';
import '../utils/constants.dart';

class BookSwipeScreen extends StatelessWidget {
  const BookSwipeScreen({super.key});

  void _showGenreSelectionDialog(BuildContext context) {
    final bookSwipeBloc = context.read<BookSwipeBloc>();
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => SafeArea(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  'Select Genre',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: availableSubjects.length,
                  itemBuilder: (context, index) {
                    final subject = availableSubjects[index];
                    return ListTile(
                      title: Text(
                        subject.replaceAll('_', ' ').toUpperCase(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                      splashColor: colorScheme.primary.withValues(alpha: 0.15),
                      onTap: () {
                        Navigator.pop(context);
                        bookSwipeBloc.add(LoadSpecificSubject(subject));
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Load books on first build if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bloc = context.read<BookSwipeBloc>();
      if (bloc.state is BookSwipeInitial) {
        bloc.add(const LoadBooks());
      }
    });

    return BlocConsumer<BookSwipeBloc, BookSwipeState>(
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
        final isDetailsActive = state is BookSwipeDetails;

        return PopScope(
          canPop: !isDetailsActive,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            if (isDetailsActive) {
              context.read<BookSwipeBloc>().add(const CloseDetails());
            }
          },
          child: Scaffold(
            backgroundColor: Colors.black,
            body: Builder(
              builder: (context) {
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
                    RepaintBoundary(
                      child: Stack(
                        children: [
                          if (activeBook?.coverUrl != null)
                            Positioned.fill(
                              child: CachedNetworkImage(
                                imageUrl: activeBook!.coverUrl!,
                                fit: BoxFit.cover,
                              ),
                            )
                          else
                            Positioned.fill(
                              child: Container(color: Colors.grey[900]),
                            ),
                          Positioned.fill(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
                              child: Container(
                                color: Colors.black.withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (state is BookSwipeInitial || state is BookSwipeLoading)
                      const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    else if (state is BookSwipeError)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.wifi_off_rounded, size: 64, color: Colors.white70),
                              const SizedBox(height: 16),
                              Text(
                                'Unable to Load Books',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                state.message,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: () {
                                  context.read<BookSwipeBloc>().add(const LoadBooks());
                                },
                                icon: const Icon(Icons.refresh),
                                label: const Text('Try Again'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).colorScheme.primary,
                                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      SafeArea(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 16, bottom: 8),
                              child: Container(
                                constraints: BoxConstraints(
                                  maxWidth: MediaQuery.of(context).size.width - 32,
                                  minWidth: 200,
                                ),
                                margin: const EdgeInsets.symmetric(horizontal: 16),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.white30),
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.black26,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        currentSubject.replaceAll('_', ' ').toUpperCase(),
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Semantics(
                                      label: 'Filter by genre',
                                      button: true,
                                      child: IconButton(
                                        constraints: const BoxConstraints(
                                          minWidth: 48,
                                          minHeight: 48,
                                        ),
                                        onPressed: () => _showGenreSelectionDialog(context),
                                        icon: const Icon(
                                          Icons.filter_list,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        tooltip: 'Filter by genre',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: Stack(
                                children: [
                                  if (currentIndex >= books.length)
                                    Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(24.0),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Icon(Icons.auto_stories_outlined, size: 64, color: Colors.white70),
                                            const SizedBox(height: 16),
                                            Text(
                                              'End of ${currentSubject.replaceAll('_', ' ')}',
                                              textAlign: TextAlign.center,
                                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              "You've swiped through all available books in this genre.",
                                              textAlign: TextAlign.center,
                                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                color: Colors.white70,
                                              ),
                                            ),
                                            const SizedBox(height: 24),
                                            ElevatedButton.icon(
                                              onPressed: () => _showGenreSelectionDialog(context),
                                              icon: const Icon(Icons.filter_list),
                                              label: const Text('Choose Another Genre'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Theme.of(context).colorScheme.primary,
                                                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  else
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
          ),
        );
      },
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
  final ValueNotifier<Offset> _dragOffsetNotifier = ValueNotifier(Offset.zero);

  @override
  void dispose() {
    _dragOffsetNotifier.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    _dragOffsetNotifier.value += details.delta;
  }

  void _onPanEnd(DragEndDetails details, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final velocity = details.velocity.pixelsPerSecond.dx;
    final dragDistance = _dragOffsetNotifier.value.dx;

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
    _dragOffsetNotifier.value = Offset.zero;
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

    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    final cardStack = Stack(
      alignment: Alignment.center,
      children: [
        ...nextBooks
            .asMap()
            .entries
            .map((entry) {
              final index = entry.key + 1;
              return RepaintBoundary(
                child: Transform.scale(
                  scale: 1.0 - (index * 0.05),
                  child: Transform.translate(
                    offset: Offset(0, index * 15),
                    child: Opacity(
                      opacity: 0.6 - (index * 0.15),
                      child: BookCoverCard(book: entry.value),
                    ),
                  ),
                ),
              );
            })
            .toList()
            .reversed,
        Semantics(
          label: 'Book card: ${currentBook.title} by ${currentBook.author}. Double tap for details, or use accessibility actions to like or dislike.',
          customSemanticsActions: {
            const CustomSemanticsAction(label: 'Dislike book'): () {
              context.read<BookSwipeBloc>().add(const SwipeLeft());
            },
            const CustomSemanticsAction(label: 'Like book'): () {
              context.read<BookSwipeBloc>().add(const SwipeRight());
            },
          },
          onTap: () {
            context.read<BookSwipeBloc>().add(const SwipeRight());
          },
          child: GestureDetector(
            onTap: () {
              context.read<BookSwipeBloc>().add(const SwipeRight());
            },
            onPanStart: (_) {},
            onPanUpdate: _onPanUpdate,
            onPanEnd: (details) => _onPanEnd(details, context),
            child: ValueListenableBuilder<Offset>(
              valueListenable: _dragOffsetNotifier,
              builder: (context, offset, child) {
                final screenWidth = MediaQuery.of(context).size.width;
                final rotation = (offset.dx / screenWidth) * 0.3;
                return Transform.translate(
                  offset: offset,
                  child: Transform.rotate(
                    angle: rotation,
                    child: child,
                  ),
                );
              },
              child: RepaintBoundary(
                child: BookCoverCard(book: currentBook),
              ),
            ),
          ),
        ),
      ],
    );

    final dislikeButton = _buildGlassButton(
      icon: Icons.close,
      color: Colors.redAccent,
      semanticsLabel: 'Dislike book',
      onTap: () {
        context.read<BookSwipeBloc>().add(const SwipeLeft());
      },
    );

    final likeButton = _buildGlassButton(
      icon: Icons.favorite,
      color: Colors.greenAccent,
      semanticsLabel: 'Like book',
      isLarge: true,
      onTap: () {
        context.read<BookSwipeBloc>().add(const SwipeRight());
      },
    );

    if (isLandscape) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            dislikeButton,
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: cardStack,
              ),
            ),
            likeButton,
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: cardStack,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(32, 0, 32, 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              dislikeButton,
              const SizedBox(width: 32),
              likeButton,
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGlassButton({
    required IconData icon,
    required Color color,
    required String semanticsLabel,
    required VoidCallback onTap,
    bool isLarge = false,
  }) {
    final size = isLarge ? 80.0 : 60.0;
    return Semantics(
      label: semanticsLabel,
      button: true,
      enabled: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.1),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.2),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(icon, color: color, size: size * 0.5),
        ),
      ),
    );
  }
}

