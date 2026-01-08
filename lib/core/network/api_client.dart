import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'auth_interceptor.dart';
import 'network_interceptor.dart';

class ApiClient {
  final Dio dio;
  final NetworkInterceptor _networkInterceptor;
  final AuthInterceptor _authInterceptor;

  ApiClient({
    required Dio dioInstance,
    required NetworkInterceptor networkInterceptor,
    required AuthInterceptor authInterceptor,
  })  : dio = dioInstance,
        _networkInterceptor = networkInterceptor,
        _authInterceptor = authInterceptor {
    _setupInterceptors();
  }

  /// Setup Dio interceptors
  void _setupInterceptors() {
    // Add custom interceptors
    dio.interceptors.add(_networkInterceptor);
    dio.interceptors.add(_authInterceptor);

    // Add logging interceptor
    dio.interceptors.add(
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
}