import 'package:freezed_annotation/freezed_annotation.dart';

part 'token_refresh_response.freezed.dart';
part 'token_refresh_response.g.dart';

/// Type-safe model for token refresh API response
@freezed
abstract class TokenRefreshResponse with _$TokenRefreshResponse {
  const factory TokenRefreshResponse({
    required String accessToken,
    String? refreshToken,
    required int expiresIn,
    String? tokenType,
  }) = _TokenRefreshResponse;

  factory TokenRefreshResponse.fromJson(Map<String, dynamic> json) =>
      _$TokenRefreshResponseFromJson(json);
}