class Validators {
  // Private constructor to prevent instantiation
  Validators._();

  static final _emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
  static final _usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');

  /// Validates email format. Returns error message or null if valid.
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!_emailRegex.hasMatch(value)) {
      return 'Invalid email format';
    }
    return null;
  }

  /// Validates password strength. Returns error message or null if valid.
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    // Optional: Add complexity checks (uppercase, number, etc.)
    return null;
  }

  /// Validates username format and length. Returns error message or null if valid.
  static String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username is required';
    }
    if (value.trim().length < 3) {
      return 'Username must be at least 3 characters';
    }
    if (value.trim().length > 30) {
      return 'Username must be less than 30 characters';
    }
    if (!_usernameRegex.hasMatch(value)) {
      return 'Username can only contain letters, numbers, and underscores';
    }
    return null;
  }

  /// Validates required fields. Returns error message or null if valid.
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
}