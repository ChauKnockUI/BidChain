import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../error/exceptions.dart';
import '../../main.dart'; // Import ApiConfig

class DioClient {
  // Use dynamic baseUrl from ApiConfig instead of hardcoded
  late Dio _dio;

  DioClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: '${ApiConfig.baseUrl}/api', // Dynamic baseUrl
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // Add interceptors
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add token to headers
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          return handler.next(error);
        },
      ),
    );
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return response;
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return response;
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return response;
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Future<Response> postMultipart(
    String path, {
    required FormData data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        // Don't set contentType - let Dio handle FormData automatically
      );
      return response;
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  void _handleError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      throw NetworkException(message: 'Connection timeout');
    } else if (error.response != null) {
      String errorMessage = 'Server error';
      final data = error.response?.data;

      if (data is Map<String, dynamic>) {
        errorMessage = data['error'] ?? 'Server error';
      } else if (data is String) {
        errorMessage = data;
      } else {
        errorMessage = data.toString();
      }

      throw ServerException(
        message: errorMessage,
        statusCode: error.response?.statusCode,
      );
    } else {
      throw NetworkException(message: 'Network error: ${error.message}');
    }
  }
}
