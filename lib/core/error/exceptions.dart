class AppException implements Exception {
  final String message;
  final int? code;

  AppException(this.message, [this.code]);

  @override
  String toString() => message;
}

/// Server-related exceptions
class ServerException extends AppException {
  ServerException(super.message, [super.code]);
}

/// Authentication exceptions
class UnauthorizedException extends AppException {
  UnauthorizedException(String message) : super(message, 401);
}

/// Validation exceptions
class ValidationException extends AppException {
  ValidationException(String message) : super(message, 422);
}

/// Network exceptions
class NetworkException extends AppException {
  NetworkException(super.message);
}

/// Cache exceptions
class CacheException extends AppException {
  CacheException(super.message);
}