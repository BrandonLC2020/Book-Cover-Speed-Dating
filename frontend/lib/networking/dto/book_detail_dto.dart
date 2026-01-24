import '../../models/book.dart';

class BookDetailDto {
  final String title;
  final String? description;
  final List<String> subjects;
  final List<String> publishers;
  final String? publishDate;
  final String key;
  final List<int>? covers;

  BookDetailDto({
    required this.title,
    this.description,
    required this.subjects,
    required this.publishers,
    this.publishDate,
    required this.key,
    this.covers,
  });

  factory BookDetailDto.fromJson(Map<String, dynamic> json) {
    String? description;
    if (json['description'] != null) {
      if (json['description'] is String) {
        description = json['description'];
      } else if (json['description'] is Map) {
        description = json['description']['value'];
      }
    }

    List<String> subjects = [];
    if (json['subjects'] != null) {
      subjects = (json['subjects'] as List).map((e) => e.toString()).toList();
    }

    List<String> publishers = [];
    if (json['publishers'] != null) {
      publishers = (json['publishers'] as List).map((e) => e.toString()).toList();
    }
    
    // First publish date
    String? publishDate;
    // The API might return 'first_publish_date' or we might look at other fields, 
    // but typically for a Work, it is 'first_publish_date' or created.
    // However, the specific edition details might be elsewhere. 
    // For Work details, 'first_publish_date' is common.
    if (json['first_publish_date'] != null) {
       publishDate = json['first_publish_date'];
    }

    List<int>? covers;
    if (json['covers'] != null) {
      covers = (json['covers'] as List).map((e) => e as int).toList();
    }

    return BookDetailDto(
      title: json['title'] ?? '',
      description: description,
      subjects: subjects,
      publishers: publishers,
      publishDate: publishDate,
      key: json['key'] ?? '',
      covers: covers,
    );
  }

  Book toDomain(Book existingBook) {
    // We only want to update the details, preserving the original info if needed,
    // but typically we enrich the existing book.
    // Since Book is immutable, we return a new instance with updated fields.
    
    // Check if we have a better cover from the detail if the original was missing?
    // The existing book logic constructs cover URL from ID.
    // If existing book has cover, keep it. If not, maybe use one from 'covers' list if available?
    // For now, let's strictly stick to enriching the details.
    
    return Book(
      title: existingBook.title, // Keep original title or update? API title might be more complete.
      author: existingBook.author,
      coverUrl: existingBook.coverUrl,
      openLibraryKey: existingBook.openLibraryKey,
      description: description,
      subjects: subjects.take(5).toList(), // Limit subjects to 5
      publishers: publishers,
      publishDate: publishDate,
    );
  }
}
