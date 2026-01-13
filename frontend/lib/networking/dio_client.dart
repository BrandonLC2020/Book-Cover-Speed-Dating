import 'package:dio/dio.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  late final Dio _dio;

  // Update this base URL to match your backend server
  // For local development, use: http://localhost:8000
  // For emulator, use: http://10.0.2.2:8000 (Android) or http://localhost:8000 (iOS)
  static const String _baseUrl = 'http://localhost:8000';

  factory DioClient() {
    return _instance;
  }

  DioClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 3),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );
    
    // Add interceptors here if needed (e.g., logging, auth)
    // _dio.interceptors.add(LogInterceptor(responseBody: true));
  }

  Dio get dio => _dio;
}
