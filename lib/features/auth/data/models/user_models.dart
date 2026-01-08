import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_models.freezed.dart';
part 'user_models.g.dart';

/// Type-safe request model for creating user profile
@freezed
abstract class CreateProfileRequest with _$CreateProfileRequest {
  const factory CreateProfileRequest({
    required String id,
    required String email,
    required String username,
    String? fullName,
  }) = _CreateProfileRequest;

  factory CreateProfileRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateProfileRequestFromJson(json);
}

@freezed
abstract class UpdateProfileRequest with _$UpdateProfileRequest {
  const factory UpdateProfileRequest({
    String? username,
    String? fullName,
    String? avatarUrl,
    String? bio,
  }) = _UpdateProfileRequest;

  factory UpdateProfileRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateProfileRequestFromJson(json);
}

@freezed
abstract class User with _$User {
  const factory User({
    required String id,
    required String email,
    required String username,
    String? fullName,
    String? avatarUrl,
    String? bio,
    String? defaultWorkspaceId,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
