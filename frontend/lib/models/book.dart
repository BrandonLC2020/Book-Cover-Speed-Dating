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


}


