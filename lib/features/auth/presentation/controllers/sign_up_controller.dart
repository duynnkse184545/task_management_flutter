import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:task_management_flutter/core/error/failures.dart';
import 'package:task_management_flutter/core/error/failure_handler.dart';
import 'package:task_management_flutter/core/utils/validators.dart';
import 'package:task_management_flutter/features/auth/data/models/auth_models.dart';
import 'package:task_management_flutter/features/auth/data/repositories/auth_repository.dart';
import 'package:task_management_flutter/features/auth/presentation/controllers/auth_controller.dart';
import 'package:task_management_flutter/features/auth/presentation/states/sign_up_state.dart';

import 'auth_providers.dart';

part 'sign_up_controller.g.dart';

@riverpod
class SignUpController extends _$SignUpController {
  late final AuthRepository _authRepository;
  
  // Store credentials for retry functionality
  String? _lastEmail;
  String? _lastPassword;
  String? _lastUsername;
  String? _lastFullName;

  @override
  SignUpState build() {
    _authRepository = ref.read(authRepositoryProvider);
    return const SignUpState.initial();
  }

  /// Sign up with email, password, and username
  /// Returns true if successful, false otherwise
  Future<bool> signUp({
    required String email,
    required String password,
    required String username,
    String? fullName,
  }) async {
    // Validate email
    final emailError = Validators.validateEmail(email);
    if (emailError != null) {
      state = SignUpState.error(
        emailError,
        const Failure.validationFailure('Invalid email'),
      );
      return false;
    }

    // Validate username
    final usernameError = Validators.validateUsername(username);
    if (usernameError != null) {
      state = SignUpState.error(
        usernameError,
        const Failure.validationFailure('Invalid username'),
      );
      return false;
    }

    // Validate password
    final passwordError = Validators.validatePassword(password);
    if (passwordError != null) {
      state = SignUpState.error(
        passwordError,
        const Failure.validationFailure('Invalid password'),
      );
      return false;
    }

    // Store for retry
    _lastEmail = email.trim();
    _lastPassword = password;
    _lastUsername = username.trim();
    _lastFullName = fullName?.trim();

    state = const SignUpState.loading();

    final request = SignUpRequest(
      email: _lastEmail!,
      password: _lastPassword!,
      username: _lastUsername!,
      fullName: _lastFullName,
    );

    final result = await _authRepository.signUp(request).run();

    return result.fold(
      (failure) {
        final errorMessage = FailureHandler.getErrorMessage(failure);
        state = SignUpState.error(errorMessage, failure);
        return false;
      },
      (user) {
        state = const SignUpState.success();
        ref.read(authControllerProvider.notifier).setAuthenticated(user);
        return true;
      },
    );
  }

  /// Check if username is available
  Future<bool> checkUsernameAvailability(String username) async {
    if (Validators.validateUsername(username) != null) return false;

    state = const SignUpState.validating();

    final result = await _authRepository.isUsernameAvailable(username.trim()).run();

    return result.fold(
          (failure) {
        state = const SignUpState.initial();
        return false;
      },
          (isAvailable) {
        state = const SignUpState.initial();
        return isAvailable;
      },
    );
  }

  /// Retry last sign up attempt
  Future<bool> retry() async {
    if (_lastEmail != null && _lastPassword != null && _lastUsername != null) {
      return signUp(
        email: _lastEmail!,
        password: _lastPassword!,
        username: _lastUsername!,
        fullName: _lastFullName,
      );
    }
    return false;
  }

  /// Reset state to initial
  void resetState() {
    state = const SignUpState.initial();
    _lastEmail = null;
    _lastPassword = null;
    _lastUsername = null;
    _lastFullName = null;
  }
}