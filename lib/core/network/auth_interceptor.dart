import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:task_management_flutter/core/config/api_config.dart';
import 'package:task_management_flutter/core/models/token_refresh_response.dart';
import 'package:task_management_flutter/core/services/token_service.dart';

class AuthInterceptor extends Interceptor {
  final Dio _dio;
  final TokenService _tokenService;

  AuthInterceptor({
    required Dio dio,
    required TokenService tokenService,
  }) : _dio = dio,
       _tokenService = tokenService;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Get token from secure storage
    final token = await _tokenService.getAccessToken();
    
    // Add Authorization header if token exists and header not already set
    if (token != null && !options.headers.containsKey('Authorization')) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle 401 Unauthorized errors
    if (err.response?.statusCode == 401) {
      final refreshToken = await _tokenService.getRefreshToken();
      
      // If no refresh token or already retrying, propagate error
      if (refreshToken == null) {
        return handler.next(err);
      }

      if (kDebugMode) {
        print('🔄 401 Detected. Attempting token refresh...');
      }

      try {
        // Perform refresh using a NEW Dio instance to avoid infinite loops
        // or interceptor conflicts.
        final tokenDio = Dio(); 
        tokenDio.options.baseUrl = ApiConfig.authBaseUrl;
        
        final response = await tokenDio.post(
          '/token?grant_type=refresh_token',
          data: {
            'refresh_token': refreshToken,
          },
          options: Options(
            headers: ApiConfig.defaultHeaders,
          ),
        );

        if (response.statusCode == 200) {
          // Parse response
          final tokenResponse = TokenRefreshResponse.fromJson(response.data);
          final userId = await _tokenService.getUserId();

          if (userId != null) {
             // Save new tokens
            await _tokenService.saveTokens(
              accessToken: tokenResponse.accessToken,
              refreshToken: tokenResponse.refreshToken ?? refreshToken,
              userId: userId,
            );
          }

          if (kDebugMode) {
            print('✅ Token refreshed. Retrying original request...');
          }

          // Retry the original request with the new token
          final opts = err.requestOptions;
          opts.headers['Authorization'] = 'Bearer ${tokenResponse.accessToken}';
          
          final clonedRequest = await _dio.fetch(opts);
          return handler.resolve(clonedRequest);
        }
      } catch (e) {
        if (kDebugMode) {
          print('❌ Token refresh failed: $e');
        }
        // If refresh fails, clear tokens (logout)
        await _tokenService.clearTokens();
      }
    }
    
    return handler.next(err);
  }
}