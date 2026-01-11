import 'package:flutter/material.dart';
import 'package:task_management_flutter/core/error/failures.dart';

/// Handles failures with appropriate user feedback and actions
class FailureHandler {
  /// Convert failure to user-friendly message
  static String getErrorMessage(Failure failure) {
    return failure.when(
      serverFailure: (message, code) {
        if (code == 500) {
          return 'Server error. Please try again later.';
        } else if (code == 503) {
          return 'Service unavailable. Please try again later.';
        }
        return message.isNotEmpty ? message : 'Something went wrong';
      },
      networkFailure: (message) => 
        'No internet connection. Please check your network.',
      cacheFailure: (message) => 
        'Local data error. Please restart the app.',
      validationFailure: (message) => message,
      unauthorizedFailure: (message) => 
        'Session expired. Please sign in again.',
      unknownFailure: (message) => 
        'An unexpected error occurred. Please try again.',
    );
  }

  /// Check if failure is retryable
  static bool isRetryable(Failure failure) {
    return failure.maybeWhen(
      networkFailure: (_) => true,
      serverFailure: (_, code) => code == 503 || code == 500,
      orElse: () => false,
    );
  }

  /// Check if failure requires logout
  static bool requiresLogout(Failure failure) {
    return failure.maybeWhen(
      unauthorizedFailure: (_) => true,
      orElse: () => false,
    );
  }

  /// Show failure to user with appropriate UI
  static void showFailure(
    BuildContext context,
    Failure failure, {
    VoidCallback? onRetry,
    VoidCallback? onDismiss,
  }) {
    final message = getErrorMessage(failure);
    final canRetry = isRetryable(failure);
    final needsLogout = requiresLogout(failure);

    if (needsLogout) {
      _showLogoutDialog(context, message);
    } else if (canRetry && onRetry != null) {
      _showRetrySnackbar(context, message, onRetry);
    } else {
      _showErrorSnackbar(context, message);
    }
  }

  static void _showLogoutDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Session Expired'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to login - implement based on your routing
              // context.go('/login'); or similar
            },
            child: const Text('Sign In Again'),
          ),
        ],
      ),
    );
  }

  static void _showRetrySnackbar(
    BuildContext context,
    String message,
    VoidCallback onRetry,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'RETRY',
          textColor: Colors.white,
          onPressed: onRetry,
        ),
      ),
    );
  }

  static void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Get appropriate icon for failure type
  static IconData getFailureIcon(Failure failure) {
    return failure.when(
      serverFailure: (_, _) => Icons.error_outline,
      networkFailure: (_) => Icons.wifi_off,
      cacheFailure: (_) => Icons.storage,
      validationFailure: (_) => Icons.warning_amber,
      unauthorizedFailure: (_) => Icons.lock_outline,
      unknownFailure: (_) => Icons.help_outline,
    );
  }
}
