import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:task_management_flutter/core/error/failures.dart';
import 'package:task_management_flutter/core/error/failure_handler.dart';
import 'package:task_management_flutter/core/utils/validators.dart';
import 'package:task_management_flutter/features/auth/data/models/auth_models.dart';
import 'package:task_management_flutter/features/auth/data/repositories/auth_repository.dart';
import 'package:task_management_flutter/features/auth/presentation/controllers/auth_controller.dart';
import 'package:task_management_flutter/features/auth/presentation/states/sign_in_state.dart';

import 'auth_providers.dart';

part 'sign_in_controller.g.dart';

@riverpod
class SignInController extends _$SignInController {
  late final AuthRepository _authRepository;
  
  // Store credentials for retry functionality
  String? _lastEmail;
  String? _lastPassword;

  @override
  SignInState build() {
    _authRepository = ref.read(authRepositoryProvider);
    return const SignInState.initial();
  }

  /// Sign in with email and password
  /// Returns true if successful, false otherwise
  /// The UI should watch the state for loading/success/error
  Future<bool> signIn(String email, String password) async {
    // Validate email
    final emailError = Validators.validateEmail(email);
    if (emailError != null) {
      state = SignInState.error(
        emailError,
        const Failure.validationFailure('Invalid email'),
      );
      return false;
    }

    // Validate password
    final passwordError = Validators.validatePassword(password);
    if (passwordError != null) {
      state = SignInState.error(
        passwordError,
        const Failure.validationFailure('Invalid password'),
      );
      return false;
    }

    // Store for retry
    _lastEmail = email.trim();
    _lastPassword = password;

    state = const SignInState.loading();

    final request = SignInRequest(
      email: _lastEmail!,
      password: _lastPassword!,
    );

    final result = await _authRepository.signIn(request).run();

    return result.fold(
      (failure) {
        // Use FailureHandler to get user-friendly message
        final errorMessage = FailureHandler.getErrorMessage(failure);
        state = SignInState.error(errorMessage, failure);
        return false;
      },
      (user) {
        state = const SignInState.success();
        // Update auth controller
        ref.read(authControllerProvider.notifier).setAuthenticated(user);
        return true;
      },
    );
  }

  /// Retry last sign in attempt
  Future<bool> retry() async {
    if (_lastEmail != null && _lastPassword != null) {
      return signIn(_lastEmail!, _lastPassword!);
    }
    return false;
  }

  /// Reset state to initial
  void resetState() {
    state = const SignInState.initial();
    _lastEmail = null;
    _lastPassword = null;
  }
}