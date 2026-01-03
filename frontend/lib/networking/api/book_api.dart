import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/book.dart';

class BookApi {
  // Update this base URL to match your backend server
  // For local development, use: http://localhost:8000
  // For emulator, use: http://10.0.2.2:8000 (Android) or http://localhost:8000 (iOS)
  static const String baseUrl = 'http://localhost:8000';

  Future<SubjectResponse> getRandomSubject() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/subjects/random'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return SubjectResponse.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load random subject: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching random subject: $e');
    }
  }

  Future<BookListResponse> getBooksBySubject(String subject) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/books/$subject'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return BookListResponse.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load books: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching books: $e');
    }
  }
}

