import 'package:flutter/material.dart';
import 'package:task_management_flutter/core/error/failures.dart';
import 'package:task_management_flutter/core/error/failure_handler.dart';

/// Mixin to add failure handling capabilities to controllers
mixin ErrorHandlerMixin {
  /// Handle failure with automatic retry support
  Future<void> handleFailure(
    Failure failure, {
    VoidCallback? onRetry,
    VoidCallback? onLogout,
  }) async {
    // Check if requires logout
    if (FailureHandler.requiresLogout(failure)) {
      onLogout?.call();
      return;
    }

    // Auto-retry for network failures (optional)
    if (failure is NetworkFailure && onRetry != null) {
      // Could implement exponential backoff here
      await Future.delayed(const Duration(seconds: 2));
      onRetry();
    }
  }

  /// Get user-friendly error message
  String getErrorMessage(Failure failure) {
    return FailureHandler.getErrorMessage(failure);
  }

  /// Check if can retry
  bool canRetry(Failure failure) {
    return FailureHandler.isRetryable(failure);
  }
}
