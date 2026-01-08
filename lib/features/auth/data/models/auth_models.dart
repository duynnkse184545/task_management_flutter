import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_models.freezed.dart';
part 'auth_models.g.dart';

/// Type-safe model for Supabase auth API response
@freezed
abstract class AuthResponse with _$AuthResponse {
  const factory AuthResponse({
    required String accessToken,
    required String refreshToken,
    required int expiresIn,
    String? tokenType,
    required AuthUser user,
  }) = _AuthResponse;

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);
}

/// Represents the user object from Supabase auth response
@freezed
abstract class AuthUser with _$AuthUser {
  const factory AuthUser({
    required String id,
    String? email,
    String? phone,
    DateTime? emailConfirmedAt,
    DateTime? phoneConfirmedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _AuthUser;

  factory AuthUser.fromJson(Map<String, dynamic> json) =>
      _$AuthUserFromJson(json);
}

@freezed
abstract class SignInRequest with _$SignInRequest {
  const factory SignInRequest({
    required String email,
    required String password,
  }) = _SignInRequest;

  factory SignInRequest.fromJson(Map<String, dynamic> json) =>
      _$SignInRequestFromJson(json);
}

/// Domain model for sign in result (simplified for app use)
@freezed
abstract class SignInResponse with _$SignInResponse {
  const factory SignInResponse({
    required String accessToken,
    required String refreshToken,
    required String userId,
    required int expiresIn,
    String? tokenType,
  }) = _SignInResponse;

  factory SignInResponse.fromJson(Map<String, dynamic> json) =>
      _$SignInResponseFromJson(json);
}

@freezed
abstract class SignUpRequest with _$SignUpRequest {
  const factory SignUpRequest({
    required String email,
    required String password,
    required String username,
    String? fullName,
  }) = _SignUpRequest;

  factory SignUpRequest.fromJson(Map<String, dynamic> json) =>
      _$SignUpRequestFromJson(json);
}