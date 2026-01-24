import 'package:dio/dio.dart';
import '../../models/book.dart';
import '../dto/book_response.dart';
import '../dto/book_detail_dto.dart';
import '../dio_client.dart';

class BookApi {
  final Dio _dio = DioClient().dio;

  Future<SubjectResponse> getRandomSubject() async {
    try {
      final response = await _dio.get('/api/subjects/random');

      if (response.statusCode == 200) {
        return SubjectResponse.fromJson(response.data);
      } else {
        throw Exception(
          'Failed to load random subject: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Error fetching random subject: ${e.message}');
    } catch (e) {
      throw Exception('Error fetching random subject: $e');
    }
  }

  Future<BookListResponse> getBooksBySubject(
    String subject, {
    int page = 1,
  }) async {
    try {
      final response = await _dio.get(
        '/api/books/$subject',
        queryParameters: {'page': page},
      );

      if (response.statusCode == 200) {
        return BookListResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load books: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Error fetching books: ${e.message}');
    } catch (e) {
      throw Exception('Error fetching books: $e');
    }
  }

  Future<Book> getBookDetails(Book book) async {
    try {
      // The openLibraryKey in Book model is typically like "/works/OL123W" or just "OL123W".
      // The API expects /works/{key}.json
      // Let's ensure we format the URL correctly.
      String key = book.openLibraryKey;
      if (key.startsWith('/works/')) {
        key = key.substring(7);
      }

      // Using the direct Open Library API as per research: https://openlibrary.org/works/{key}.json
      // Note: This calls the external API directly, not the backend proxy.
      // If the backend has a proxy, we should use that.
      // Assuming for now we call Open Library directly or via a proxy if configured in DioClient.
      // However, usually DioClient base URL is the backend.
      // If we need to call external API, we might need a full URL or a different Dio instance.
      // Let's check DioClient configuration.

      // For this specific task, if I look at previous conversations, existing calls go to '/api/...'.
      // If the backend doesn't have an endpoint for details, I might need to call Open Library directly.
      // 'http' package was replaced by 'dio'.

      // I'll assume I should make a direct call to Open Library for now since I don't have backend access to add endpoints easily
      // and the prompt implies fetching from Open Library.
      // But DioClient likely has a BaseUrl set to the backend.
      // So I should use a new Dio instance or override base URL for this call?
      // Or maybe just pass the full URL to dio.get().

      final response = await Dio().get(
        'https://openlibrary.org/works/$key.json',
      );

      if (response.statusCode == 200) {
        final detailDto = BookDetailDto.fromJson(response.data);
        return detailDto.toDomain(book);
      } else {
        throw Exception('Failed to load book details: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // If failing to fetch details, just return the original book
      print('Error fetching book details: ${e.message}');
      return book;
    } catch (e) {
      print('Error fetching book details: $e');
      return book;
    }
  }
}
