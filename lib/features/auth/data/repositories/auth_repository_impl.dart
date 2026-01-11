import 'package:task_management_flutter/core/error/exceptions.dart';
import 'package:task_management_flutter/core/services/token_service.dart';
import 'package:task_management_flutter/core/error/error_handler.dart';
import 'package:task_management_flutter/core/utils/type_defs.dart';
import 'package:task_management_flutter/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:task_management_flutter/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:task_management_flutter/features/auth/data/models/auth_models.dart';
import 'package:task_management_flutter/features/auth/data/models/user_models.dart';
import 'package:task_management_flutter/features/auth/data/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;
  final TokenService _tokenService;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
    required TokenService tokenService,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource,
       _tokenService = tokenService;

  @override
  TaskResult<User> signUp(SignUpRequest request) {
    return ErrorHandler.execute(() async {
      // Get auth response with tokens
      final authResponse = await _remoteDataSource.signUp(request);

      // Save tokens using TokenService
      await _tokenService.saveTokens(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
        userId: authResponse.user.id,
      );

      // Get user profile
      final user = await _remoteDataSource.getCurrentUser();

      // Cache user locally (optional, don't fail if this fails)
      await ErrorHandler.executeOrNull(() => _localDataSource.cacheUser(user));

      return user;
    });
  }

  @override
  TaskResult<User> signIn(SignInRequest request) {
    return ErrorHandler.execute(() async {
      // Get auth response with tokens
      final authResponse = await _remoteDataSource.signIn(request);

      // Save tokens using TokenService
      await _tokenService.saveTokens(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
        userId: authResponse.user.id,
      );

      // Get user profile
      final user = await _remoteDataSource.getCurrentUser();

      // Cache user locally (optional, don't fail if this fails)
      await ErrorHandler.executeOrNull(() => _localDataSource.cacheUser(user));

      return user;
    });
  }

  @override
  TaskResult<void> signOut() {
    return ErrorHandler.execute(() async {
      // Try to sign out remotely, but don't fail if it errors (e.g. offline)
      await ErrorHandler.handleSafely(
        () => _remoteDataSource.signOut(),
        'Remote SignOut',
      );

      // Clear tokens using TokenService
      await _tokenService.clearTokens();

      // Clear cached user data (optional, don't fail if this fails)
      await ErrorHandler.executeOrNull(() => _localDataSource.clearUserCache());
    });
  }

  @override
  TaskResult<User> getCurrentUser() {
    return ErrorHandler.execute(() async {
      // Get user ID from token service
      final userId = await _tokenService.getUserId();
      if (userId == null) {
        throw UnauthorizedException('User not logged in');
      }

      // Try cache first (optional)
      final cachedUser = await ErrorHandler.executeOrNull(
        () => _localDataSource.getCachedUser(userId),
      );

      try {
        // Fetch from remote
        final user = await _remoteDataSource.getCurrentUser();

        // Update cache (optional, don't fail if this fails)
        await ErrorHandler.executeOrNull(
          () => _localDataSource.cacheUser(user),
        );

        return user;
      } catch (e) {
        // If remote fails (e.g. no internet), return cached user if available
        if (cachedUser != null) {
          return cachedUser;
        }
        rethrow;
      }
    });
  }

  @override
  TaskResult<User> updateProfile(String userId, UpdateProfileRequest request) {
    return ErrorHandler.execute(() async {
      final user = await _remoteDataSource.updateProfile(userId, request);

      // Update cache (optional, don't fail if this fails)
      await ErrorHandler.executeOrNull(() => _localDataSource.cacheUser(user));

      return user;
    });
  }

  @override
  TaskResult<bool> isUsernameAvailable(String username) {
    return ErrorHandler.execute(() async {
      return await _remoteDataSource.isUsernameAvailable(username);
    });
  }

  @override
  User? getCachedUser() {
    try {
      // Note: This is a sync wrapper for async method
      // In production, consider making this async or using FutureOr
      return null; // Will be fetched in getCurrentUser
    } catch (e) {
      return null;
    }
  }

  @override
  bool isLoggedIn() {
    // Note: This should be called as async in practice
    // For now, return false and check tokens in repository methods
    return false;
  }
}
