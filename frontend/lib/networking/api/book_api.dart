import 'package:dio/dio.dart';
import '../../models/book.dart';
import '../dto/book_response.dart';
import '../dio_client.dart';

class BookApi {
  final Dio _dio = DioClient().dio;

  Future<SubjectResponse> getRandomSubject() async {
    try {
      final response = await _dio.get('/api/subjects/random');

      if (response.statusCode == 200) {
        return SubjectResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load random subject: ${response.statusCode}');
      }
    } on DioException catch (e) {
       throw Exception('Error fetching random subject: ${e.message}');
    } catch (e) {
      throw Exception('Error fetching random subject: $e');
    }
  }

  Future<BookListResponse> getBooksBySubject(String subject) async {
    try {
      final response = await _dio.get('/api/books/$subject');

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
}
