import 'package:dartz/dartz.dart';
import 'package:task_management_flutter/core/error/failures.dart';
import 'package:task_management_flutter/core/services/token_service.dart';
import 'package:task_management_flutter/core/utils/error_handler.dart';
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

  AuthRepositoryImpl(
      this._remoteDataSource,
      this._localDataSource,
      this._tokenService,
      );

  @override
  FutureEither<User> signUp(SignUpRequest request) async {
    try {
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
      await _localDataSource.cacheUser(user);

      return Right(user);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  FutureEither<User> signIn(SignInRequest request) async {
    try {
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
      await _localDataSource.cacheUser(user);

      return Right(user);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  FutureEither<void> signOut() async {
    try {
      // Try to sign out remotely
      try {
        await _remoteDataSource.signOut();
      } catch (_) {
        // Ignore remote sign out errors (e.g. no network)
        // We still want to clear local session
      }

      // Clear tokens using TokenService
      await _tokenService.clearTokens();

      // Clear cached user data
      await _localDataSource.clearUserCache();

      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  FutureEither<User> getCurrentUser() async {
    try {
      // Get user ID from token service
      final userId = await _tokenService.getUserId();
      if (userId == null) {
        return const Left(Failure.unauthorizedFailure('User not logged in'));
      }

      // Try cache first
      final cachedUser = await _localDataSource.getCachedUser(userId);

      // Fetch from remote
      try {
        final user = await _remoteDataSource.getCurrentUser();
        await _localDataSource.cacheUser(user);
        return Right(user);
      } catch (e) {
        // If remote fails (e.g. no internet), return cached user if available
        if (cachedUser != null) {
          return Right(cachedUser);
        }
        rethrow;
      }
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  FutureEither<User> updateProfile(
      String userId,
      UpdateProfileRequest request,
      ) async {
    try {
      final user = await _remoteDataSource.updateProfile(userId, request);
      await _localDataSource.cacheUser(user);

      return Right(user);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  FutureEither<bool> isUsernameAvailable(String username) async {
    try {
      final isAvailable = await _remoteDataSource.isUsernameAvailable(username);
      return Right(isAvailable);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
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