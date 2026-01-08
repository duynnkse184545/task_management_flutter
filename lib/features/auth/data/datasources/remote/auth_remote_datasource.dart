import 'package:dio/dio.dart';
import 'package:task_management_flutter/core/error/exceptions.dart';
import 'package:task_management_flutter/features/auth/data/datasources/remote/auth_api_service.dart';
import 'package:task_management_flutter/features/auth/data/datasources/remote/user_api_service.dart';
import 'package:task_management_flutter/features/auth/data/models/auth_models.dart';
import 'package:task_management_flutter/features/auth/data/models/user_models.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponse> signUp(SignUpRequest request);

  Future<AuthResponse> signIn(SignInRequest request);

  Future<void> signOut();

  Future<User> getCurrentUser();

  Future<User> updateProfile(String userId, UpdateProfileRequest request);

  Future<User> getUserById(String userId);

  Future<bool> isUsernameAvailable(String username);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final AuthApiService _authApi;
  final UserApiService _userApi;

  AuthRemoteDataSourceImpl({
    required AuthApiService authApi,
    required UserApiService userApi,
  })  : _authApi = authApi,
        _userApi = userApi;

  @override
  Future<AuthResponse> signUp(SignUpRequest request) async {
    try {
      // Step 1: Create auth user
      final authResponse = await _authApi.signUp(request);

      // Step 2: Create profile
      final profileRequest = CreateProfileRequest(
        id: authResponse.user.id,
        email: request.email,
        username: request.username,
        fullName: request.fullName,
      );

      await _userApi.createProfile(profileRequest);

      return authResponse;
    } catch (e) {
      throw _handleError(e, 'Sign up failed');
    }
  }

  @override
  Future<AuthResponse> signIn(SignInRequest request) async {
    try {
      return await _authApi.signIn(request);
    } catch (e) {
      throw _handleError(e, 'Sign in failed');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _authApi.signOut();
    } catch (e) {
      throw _handleError(e, 'Sign out failed');
    }
  }

  @override
  Future<User> getCurrentUser() async {
    try {
      // Get authenticated user info
      final authUser = await _authApi.getUser();

      // Fetch full profile
      final users = await _userApi.getUserById('eq.${authUser.id}');

      if (users.isEmpty) {
        throw ServerException('Profile not found', 404);
      }

      return users.first;
    } catch (e) {
      throw _handleError(e, 'Failed to get current user');
    }
  }

  @override
  Future<User> updateProfile(
    String userId,
    UpdateProfileRequest request,
  ) async {
    try {
      final users = await _userApi.updateProfile('eq.$userId', request);

      if (users.isEmpty) {
        throw ServerException('Failed to update profile', 404);
      }

      return users.first;
    } catch (e) {
      throw _handleError(e, 'Failed to update profile');
    }
  }

  @override
  Future<User> getUserById(String userId) async {
    try {
      final users = await _userApi.getUserById('eq.$userId');

      if (users.isEmpty) {
        throw ServerException('User not found', 404);
      }

      return users.first;
    } catch (e) {
      throw _handleError(e, 'Failed to get user');
    }
  }

  @override
  Future<bool> isUsernameAvailable(String username) async {
    try {
      final users = await _userApi.checkUsername('eq.$username', 'id');
      return users.isEmpty;
    } catch (e) {
      throw _handleError(e, 'Failed to check username');
    }
  }

  Exception _handleError(Object e, String defaultMessage) {
    if (e is DioException) {
       // Convert DioException to ServerException to keep Repository contract
       // Or rely on a better global converter.
       // For now, simple wrapper:
       return ServerException(
         e.response?.data?['message'] ?? e.message ?? defaultMessage,
         e.response?.statusCode,
       );
    }
    if (e is ServerException) return e;
    return ServerException('$defaultMessage: $e');
  }
}

