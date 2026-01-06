import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:task_management_flutter/core/config/api_config.dart';
import 'package:task_management_flutter/core/error/exceptions.dart';

class ApiClient {
  final Dio _dio;

  ApiClient(this._dio) {
    _setupInterceptors();
  }

  /// Build the full URL based on whether it's an auth endpoint
  String _buildUrl(String endpoint, bool useAuthBaseUrl) {
    return useAuthBaseUrl ? '${ApiConfig.authBaseUrl}$endpoint' : endpoint;
  }

  /// Setup Dio interceptors for logging and error handling
  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (kDebugMode) {
            print('🌐 ${options.method}: ${options.uri}');
            print('📤 Headers: ${options.headers}');
            if (options.data != null) {
              print('📦 Body: ${options.data}');
            }
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            print('📥 Status: ${response.statusCode}');
            print('📥 Body: ${response.data}');
          }
          handler.next(response);
        },
        onError: (error, handler) {
          if (kDebugMode) {
            print('❌ Error: ${error.message}');
            print('❌ Response: ${error.response?.data}');
          }
          handler.next(error);
        },
      ),
    );
  }

  /// Set access token for authenticated requests
  void setAccessToken(String? token) {
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    } else {
      _dio.options.headers.remove('Authorization');
    }
  }

  String? get accessToken {
    final auth = _dio.options.headers['Authorization'];
    if (auth is String && auth.startsWith('Bearer ')) {
      return auth.substring(7);
    }
    return null;
  }

  /// GET request
  Future<T> get<T>(
      String endpoint, {
        Map<String, dynamic>? queryParameters,
        Map<String, String>? headers,
        bool useAuthBaseUrl = false,
      }) async {
    try {
      final response = await _dio.get<T>(
        _buildUrl(endpoint, useAuthBaseUrl),
        queryParameters: queryParameters,
        options: Options(
          headers: headers,
        ),
      );
      return response.data as T;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// POST request
  Future<T> post<T>(
      String endpoint, {
        dynamic body,
        Map<String, dynamic>? queryParameters,
        Map<String, String>? headers,
        bool useAuthBaseUrl = false,
      }) async {
    try {
      final response = await _dio.post<T>(
        _buildUrl(endpoint, useAuthBaseUrl),
        data: body,
        queryParameters: queryParameters,
        options: Options(
          headers: headers,
        ),
      );
      return response.data as T;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// PATCH request
  Future<T> patch<T>(
      String endpoint, {
        dynamic body,
        Map<String, dynamic>? queryParameters,
        Map<String, String>? headers,
        bool useAuthBaseUrl = false,
      }) async {
    try {
      final response = await _dio.patch<T>(
        _buildUrl(endpoint, useAuthBaseUrl),
        data: body,
        queryParameters: queryParameters,
        options: Options(
          headers: headers,
        ),
      );
      return response.data as T;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// DELETE request
  Future<T> delete<T>(
      String endpoint, {
        Map<String, dynamic>? queryParameters,
        Map<String, String>? headers,
        bool useAuthBaseUrl = false,
      }) async {
    try {
      final response = await _dio.delete<T>(
        _buildUrl(endpoint, useAuthBaseUrl),
        queryParameters: queryParameters,
        options: Options(
          headers: headers,
        ),
      );
      return response.data as T;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Handle Dio errors and convert to custom exceptions
  Exception _handleDioError(DioException error) {
    final response = error.response;
    final statusCode = response?.statusCode ?? 0;

    // Extract error message from response
    String message = 'Request failed';
    if (response?.data != null) {
      final data = response!.data;
      if (data is Map<String, dynamic>) {
        message = data['message'] ??
            data['error_description'] ??
            data['msg'] ??
            message;
      } else if (data is String) {
        message = data;
      }
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ServerException('Connection timeout', statusCode);

      case DioExceptionType.badResponse:
        return _createExceptionFromStatusCode(statusCode, message);

      case DioExceptionType.cancel:
        return ServerException('Request cancelled', statusCode);

      case DioExceptionType.connectionError:
        return ServerException('Network error: ${error.message}', statusCode);

      case DioExceptionType.unknown:
      default:
        return ServerException('Unknown error: ${error.message}', statusCode);
    }
  }

  /// Create appropriate exception based on status code
  Exception _createExceptionFromStatusCode(int statusCode, String message) {
    switch (statusCode) {
      case 400:
        return ServerException('Bad Request: $message', 400);
      case 401:
        return UnauthorizedException('Unauthorized: $message');
      case 403:
        return ServerException('Forbidden: $message', 403);
      case 404:
        return ServerException('Not Found: $message', 404);
      case 409:
        return ServerException('Conflict: $message', 409);
      case 422:
        return ValidationException('Validation Error: $message');
      case 429:
        return ServerException('Too Many Requests: $message', 429);
      case 500:
      case 502:
      case 503:
      case 504:
        return ServerException('Server Error: $message', statusCode);
      default:
        return ServerException('Request failed: $message', statusCode);
    }
  }
}