import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:task_management_flutter/features/auth/data/models/user_models.dart';
import 'package:task_management_flutter/features/auth/data/repositories/auth_repository.dart';
import 'package:task_management_flutter/features/auth/presentation/controllers/auth_providers.dart';
import 'package:task_management_flutter/features/auth/presentation/states/auth_state.dart';

part 'auth_controller.g.dart';

@riverpod
class AuthController extends _$AuthController {
  late final AuthRepository _authRepository;

  @override
  AuthState build() {
    _authRepository = ref.read(authRepositoryProvider);
    _checkAuthStatus();
    return const AuthState.initial();
  }

  /// Check authentication status on startup
  Future<void> _checkAuthStatus() async {
    if (_authRepository.isLoggedIn()) {
      state = const AuthState.loading();

      final result = await _authRepository.getCurrentUser().run();
      result.fold(
            (failure) {
          // If token expired or invalid, mark as unauthenticated
          state = const AuthState.unauthenticated();
        },
            (user) => state = AuthState.authenticated(user),
      );
    } else {
      state = const AuthState.unauthenticated();
    }
  }

  /// Sign out
  Future<void> signOut() async {
    state = const AuthState.loading();

    final result = await _authRepository.signOut().run();
    result.fold(
          (failure) => state = AuthState.error(failure.toString()),
          (_) => state = const AuthState.unauthenticated(),
    );
  }

  /// Refresh user data
  Future<void> refreshUser() async {
    final result = await _authRepository.getCurrentUser().run();
    result.fold(
          (failure) => state = AuthState.error(failure.toString()),
          (user) => state = AuthState.authenticated(user),
    );
  }

  /// Update authentication state (called after sign in/up)
  void setAuthenticated(User user) {
    state = AuthState.authenticated(user);
  }

  /// Get current user (null if not authenticated)
  User? get currentUser {
    return state.maybeWhen(
      authenticated: (user) => user,
      orElse: () => null,
    );
  }
}