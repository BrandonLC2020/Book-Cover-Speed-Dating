import '../../models/book.dart';
import 'book_dto.dart';

class BookListResponse {
  final String subject;
  final List<Book> books;

  BookListResponse({
    required this.subject,
    required this.books,
  });

  factory BookListResponse.fromJson(Map<String, dynamic> json) {
    return BookListResponse(
      subject: json['subject'] as String,
      books: (json['books'] as List<dynamic>)
          .map((bookJson) => BookDto.fromJson(bookJson as Map<String, dynamic>).toDomain())
          .toList(),
    );
  }
}

class SubjectResponse {
  final String subject;

  SubjectResponse({
    required this.subject,
  });

  factory SubjectResponse.fromJson(Map<String, dynamic> json) {
    return SubjectResponse(
      subject: json['subject'] as String,
    );
  }
}
