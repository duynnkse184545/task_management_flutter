import 'package:flutter/foundation.dart';
import 'package:task_management_flutter/core/models/token_refresh_response.dart';
import 'package:task_management_flutter/core/network/api_client.dart';
import 'package:task_management_flutter/core/services/token_service.dart';

class AuthInterceptor {
  final ApiClient _apiClient;
  final TokenService _tokenService;

  AuthInterceptor({
    required ApiClient apiClient,
    required TokenService tokenService,
  }) : _apiClient = apiClient,
       _tokenService = tokenService;

  /// Refresh access token using refresh token
  Future<TokenRefreshResponse> refreshAccessToken() async {
    final refreshToken = await _tokenService.getRefreshToken();

    if (refreshToken == null) {
      throw Exception('No refresh token available');
    }

    if (kDebugMode) {
      print('🔄 Refreshing access token...');
    }

    try {
      // Get raw response
      final rawResponse = await _apiClient.post<Map<String, dynamic>>(
        '/token?grant_type=refresh_token',
        body: {'refresh_token': refreshToken},
        useAuthBaseUrl: true,
      );

      // Parse into type-safe model
      final tokenResponse = TokenRefreshResponse.fromJson(rawResponse);

      // Get current user ID
      final userId = await _tokenService.getUserId();
      if (userId == null) {
        throw Exception('User ID not found');
      }

      // Save new tokens using TokenService
      await _tokenService.saveTokens(
        accessToken: tokenResponse.accessToken,
        refreshToken: tokenResponse.refreshToken ?? refreshToken,
        userId: userId,
      );

      // Update API client with new token
      _apiClient.setAccessToken(tokenResponse.accessToken);

      if (kDebugMode) {
        print('✅ Token refreshed successfully');
      }

      return tokenResponse;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Token refresh failed: $e');
      }
      rethrow;
    }
  }

  /// Clear tokens (logout)
  Future<void> clearTokens() async {
    await _tokenService.clearTokens();
    _apiClient.setAccessToken(null);
  }
}
