class Book {
  final String title;
  final String author;
  final String? coverUrl;
  final String openLibraryKey;

  Book({
    required this.title,
    required this.author,
    this.coverUrl,
    required this.openLibraryKey,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      title: json['title'] as String,
      author: json['author'] as String,
      coverUrl: json['cover_url'] as String?,
      openLibraryKey: json['open_library_key'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'author': author,
      'cover_url': coverUrl,
      'open_library_key': openLibraryKey,
    };
  }
}

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
          .map((bookJson) => Book.fromJson(bookJson as Map<String, dynamic>))
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

