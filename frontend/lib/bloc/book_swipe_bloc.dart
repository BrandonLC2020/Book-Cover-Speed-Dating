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

  const BookSwipeLoaded({
    required this.books,
    required this.currentIndex,
    required this.currentSubject,
  });

  Book? get currentBook {
    if (currentIndex >= 0 && currentIndex < books.length) {
      return books[currentIndex];
    }
    return null;
  }

  bool get hasMoreBooks => currentIndex < books.length - 1;

  @override
  List<Object?> get props => [books, currentIndex, currentSubject];
}

class BookSwipeDetails extends BookSwipeState {
  final Book book;
  final List<Book> remainingBooks;
  final int currentIndex;
  final String currentSubject;

  const BookSwipeDetails({
    required this.book,
    required this.remainingBooks,
    required this.currentIndex,
    required this.currentSubject,
  });

  @override
  List<Object?> get props => [book, remainingBooks, currentIndex, currentSubject];
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
  }

  Future<void> _onLoadBooks(LoadBooks event, Emitter<BookSwipeState> emit) async {
    emit(const BookSwipeLoading());

    try {
      // First get a random subject
      final subjectResponse = await _bookApi.getRandomSubject();
      
      // Then get books for that subject
      final bookListResponse = await _bookApi.getBooksBySubject(subjectResponse.subject);

      if (bookListResponse.books.isEmpty) {
        // If no books, try loading next subject
        add(const LoadNextSubject());
      } else {
        emit(BookSwipeLoaded(
          books: bookListResponse.books,
          currentIndex: 0,
          currentSubject: bookListResponse.subject,
        ));
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
        emit(BookSwipeLoaded(
          books: currentState.books,
          currentIndex: nextIndex,
          currentSubject: currentState.currentSubject,
        ));
      }
    }
  }

  void _onSwipeRight(SwipeRight event, Emitter<BookSwipeState> emit) {
    if (state is BookSwipeLoaded) {
      final currentState = state as BookSwipeLoaded;
      final currentBook = currentState.currentBook;

      if (currentBook != null) {
        emit(BookSwipeDetails(
          book: currentBook,
          remainingBooks: currentState.books,
          currentIndex: currentState.currentIndex,
          currentSubject: currentState.currentSubject,
        ));
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
        emit(BookSwipeLoaded(
          books: detailsState.remainingBooks,
          currentIndex: nextIndex,
          currentSubject: detailsState.currentSubject,
        ));
      }
    }
  }

  Future<void> _onLoadNextSubject(LoadNextSubject event, Emitter<BookSwipeState> emit) async {
    emit(const BookSwipeLoading());

    try {
      // Get a new random subject
      final subjectResponse = await _bookApi.getRandomSubject();
      
      // Get books for that subject
      final bookListResponse = await _bookApi.getBooksBySubject(subjectResponse.subject);

      if (bookListResponse.books.isEmpty) {
        // If still no books, try again
        add(const LoadNextSubject());
      } else {
        emit(BookSwipeLoaded(
          books: bookListResponse.books,
          currentIndex: 0,
          currentSubject: bookListResponse.subject,
        ));
      }
    } catch (e) {
      emit(BookSwipeError(e.toString()));
    }
  }
}

