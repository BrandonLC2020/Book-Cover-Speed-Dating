import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/book.dart';
import '../networking/api/book_api.dart';

// Events
abstract class BookSwipeEvent extends Equatable {
  const BookSwipeEvent();

  @override
  List<Object?> get props => [];
}

class LoadBooks extends BookSwipeEvent {
  const LoadBooks();
}

class SwipeLeft extends BookSwipeEvent {
  const SwipeLeft();
}

class SwipeRight extends BookSwipeEvent {
  const SwipeRight();
}

class CloseDetails extends BookSwipeEvent {
  const CloseDetails();
}

class LoadNextSubject extends BookSwipeEvent {
  const LoadNextSubject();
}

class LoadSpecificSubject extends BookSwipeEvent {
  final String subject;

  const LoadSpecificSubject(this.subject);

  @override
  List<Object?> get props => [subject];
}

class LoadMoreBooks extends BookSwipeEvent {
  const LoadMoreBooks();
}

// States
abstract class BookSwipeState extends Equatable {
  const BookSwipeState();

  @override
  List<Object?> get props => [];
}

class BookSwipeInitial extends BookSwipeState {
  const BookSwipeInitial();
}

class BookSwipeLoading extends BookSwipeState {
  const BookSwipeLoading();
}

class BookSwipeLoaded extends BookSwipeState {
  final List<Book> books;
  final int currentIndex;
  final String currentSubject;
  final int currentPage;
  final bool isLoadingMore;

  const BookSwipeLoaded({
    required this.books,
    required this.currentIndex,
    required this.currentSubject,
    this.currentPage = 1,
    this.isLoadingMore = false,
  });

  Book? get currentBook {
    if (currentIndex >= 0 && currentIndex < books.length) {
      return books[currentIndex];
    }
    return null;
  }

  bool get hasMoreBooks => currentIndex < books.length - 1;

  @override
  List<Object?> get props => [
    books,
    currentIndex,
    currentSubject,
    currentPage,
    isLoadingMore,
  ];
}

class BookSwipeDetails extends BookSwipeState {
  final Book book;
  final List<Book> remainingBooks;
  final int currentIndex;
  final String currentSubject;

  final int currentPage;

  const BookSwipeDetails({
    required this.book,
    required this.remainingBooks,
    required this.currentIndex,
    required this.currentSubject,
    this.currentPage = 1,
  });

  @override
  List<Object?> get props => [
    book,
    remainingBooks,
    currentIndex,
    currentSubject,
    currentPage,
  ];
}

class BookSwipeError extends BookSwipeState {
  final String message;

  const BookSwipeError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class BookSwipeBloc extends Bloc<BookSwipeEvent, BookSwipeState> {
  final BookApi _bookApi;

  BookSwipeBloc({BookApi? bookApi})
    : _bookApi = bookApi ?? BookApi(),
      super(const BookSwipeInitial()) {
    on<LoadBooks>(_onLoadBooks);
    on<SwipeLeft>(_onSwipeLeft);
    on<SwipeRight>(_onSwipeRight);
    on<CloseDetails>(_onCloseDetails);
    on<LoadNextSubject>(_onLoadNextSubject);
    on<LoadSpecificSubject>(_onLoadSpecificSubject);
    on<LoadMoreBooks>(_onLoadMoreBooks);
  }

  Future<void> _onLoadBooks(
    LoadBooks event,
    Emitter<BookSwipeState> emit,
  ) async {
    emit(const BookSwipeLoading());

    try {
      // First get a random subject
      final subjectResponse = await _bookApi.getRandomSubject();

      // Then get books for that subject
      final bookListResponse = await _bookApi.getBooksBySubject(
        subjectResponse.subject,
      );

      if (bookListResponse.books.isEmpty) {
        // If no books, try loading next subject
        add(const LoadNextSubject());
      } else {
        emit(
          BookSwipeLoaded(
            books: bookListResponse.books,
            currentIndex: 0,
            currentSubject: bookListResponse.subject,
          ),
        );
      }
    } catch (e) {
      emit(BookSwipeError(e.toString()));
    }
  }

  void _onSwipeLeft(SwipeLeft event, Emitter<BookSwipeState> emit) {
    if (state is BookSwipeLoaded) {
      final currentState = state as BookSwipeLoaded;
      final nextIndex = currentState.currentIndex + 1;

      if (nextIndex >= currentState.books.length) {
        // No more books, load next subject
        add(const LoadNextSubject());
      } else {
        if (nextIndex >= currentState.books.length - 2 &&
            !currentState.isLoadingMore) {
          add(const LoadMoreBooks());
        }

        if (nextIndex >= currentState.books.length) {
          // If we really run out and didn't fetch in time, or no more books
          // Wait, LoadMoreBooks should handle appending.
          // If we are here, it means we swiped everything.
          // We can just keep the index as is if it's bounding, OR show a loader.
          // But for now let's just emit the new index, the UI will show empty/loader if needed
          // until new books arrive.
          emit(
            BookSwipeLoaded(
              books: currentState.books,
              currentIndex: nextIndex,
              currentSubject: currentState.currentSubject,
              currentPage: currentState.currentPage,
              isLoadingMore: currentState.isLoadingMore,
            ),
          );
        } else {
          emit(
            BookSwipeLoaded(
              books: currentState.books,
              currentIndex: nextIndex,
              currentSubject: currentState.currentSubject,
              currentPage: currentState.currentPage,
              isLoadingMore: currentState.isLoadingMore,
            ),
          );
        }
      }
    }
  }

  void _onSwipeRight(SwipeRight event, Emitter<BookSwipeState> emit) {
    if (state is BookSwipeLoaded) {
      final currentState = state as BookSwipeLoaded;
      final currentBook = currentState.currentBook;

      if (currentBook != null) {
        emit(
          BookSwipeDetails(
            book: currentBook,
            remainingBooks: currentState.books,
            currentIndex: currentState.currentIndex,
            currentSubject: currentState.currentSubject,
            currentPage: currentState.currentPage,
          ),
        );
      }
    }
  }

  void _onCloseDetails(CloseDetails event, Emitter<BookSwipeState> emit) {
    if (state is BookSwipeDetails) {
      final detailsState = state as BookSwipeDetails;
      final nextIndex = detailsState.currentIndex + 1;

      if (nextIndex >= detailsState.remainingBooks.length) {
        // No more books, load next subject
        add(const LoadNextSubject());
      } else {
        emit(
          BookSwipeLoaded(
            books: detailsState.remainingBooks,
            currentIndex: nextIndex,
            currentSubject: detailsState.currentSubject,
            currentPage: detailsState.currentPage,
          ),
        );

        if (nextIndex >= detailsState.remainingBooks.length - 2) {
          add(const LoadMoreBooks());
        }
      }
    }
  }

  Future<void> _onLoadNextSubject(
    LoadNextSubject event,
    Emitter<BookSwipeState> emit,
  ) async {
    emit(const BookSwipeLoading());

    try {
      // Get a new random subject
      final subjectResponse = await _bookApi.getRandomSubject();

      // Get books for that subject
      final bookListResponse = await _bookApi.getBooksBySubject(
        subjectResponse.subject,
      );

      if (bookListResponse.books.isEmpty) {
        // If still no books, try again
        add(const LoadNextSubject());
      } else {
        emit(
          BookSwipeLoaded(
            books: bookListResponse.books,
            currentIndex: 0,
            currentSubject: bookListResponse.subject,
            currentPage: 1,
          ),
        );
      }
    } catch (e) {
      emit(BookSwipeError(e.toString()));
    }
  }

  Future<void> _onLoadSpecificSubject(
    LoadSpecificSubject event,
    Emitter<BookSwipeState> emit,
  ) async {
    emit(const BookSwipeLoading());

    try {
      // Get books for the selected subject
      final bookListResponse = await _bookApi.getBooksBySubject(event.subject);

      if (bookListResponse.books.isEmpty) {
        emit(BookSwipeError('No books found for ${event.subject}'));
      } else {
        emit(
          BookSwipeLoaded(
            books: bookListResponse.books,
            currentIndex: 0,
            currentSubject: bookListResponse.subject,
            currentPage: 1,
          ),
        );
      }
    } catch (e) {
      emit(BookSwipeError(e.toString()));
    }
  }

  Future<void> _onLoadMoreBooks(
    LoadMoreBooks event,
    Emitter<BookSwipeState> emit,
  ) async {
    if (state is BookSwipeLoaded) {
      final currentState = state as BookSwipeLoaded;
      if (currentState.isLoadingMore) return;

      emit(
        BookSwipeLoaded(
          books: currentState.books,
          currentIndex: currentState.currentIndex,
          currentSubject: currentState.currentSubject,
          currentPage: currentState.currentPage,
          isLoadingMore: true,
        ),
      );

      try {
        final nextPage = currentState.currentPage + 1;
        final response = await _bookApi.getBooksBySubject(
          currentState.currentSubject,
          page: nextPage,
        );

        if (response.books.isNotEmpty) {
          emit(
            BookSwipeLoaded(
              books: currentState.books + response.books,
              currentIndex: currentState.currentIndex,
              currentSubject: currentState.currentSubject,
              currentPage: nextPage,
              isLoadingMore: false,
            ),
          );
        } else {
          // No more books found, stop loading
          emit(
            BookSwipeLoaded(
              books: currentState.books,
              currentIndex: currentState.currentIndex,
              currentSubject: currentState.currentSubject,
              currentPage: currentState.currentPage,
              isLoadingMore: false,
            ),
          );
        }
      } catch (e) {
        // On error, just reset loading state
        emit(
          BookSwipeLoaded(
            books: currentState.books,
            currentIndex: currentState.currentIndex,
            currentSubject: currentState.currentSubject,
            currentPage: currentState.currentPage,
            isLoadingMore: false,
          ),
        );
      }
    }
  }
}
