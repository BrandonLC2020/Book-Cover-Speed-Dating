import '../../models/book.dart';

class BookDto {
  final String title;
  final String author;
  final String? coverUrl;
  final String openLibraryKey;

  BookDto({
    required this.title,
    required this.author,
    this.coverUrl,
    required this.openLibraryKey,
  });

  factory BookDto.fromJson(Map<String, dynamic> json) {
    return BookDto(
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

  Book toDomain() {
    return Book(
      title: title,
      author: author,
      coverUrl: coverUrl,
      openLibraryKey: openLibraryKey,
    );
  }
}
