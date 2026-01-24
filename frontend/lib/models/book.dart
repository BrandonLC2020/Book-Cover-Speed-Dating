class Book {
  final String title;
  final String author;
  final String? coverUrl;
  final String openLibraryKey;
  final String? description;
  final List<String>? subjects;
  final List<String>? publishers;
  final String? publishDate;

  Book({
    required this.title,
    required this.author,
    this.coverUrl,
    required this.openLibraryKey,
    this.description,
    this.subjects,
    this.publishers,
    this.publishDate,
  });


}


