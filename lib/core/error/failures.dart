import 'package:freezed_annotation/freezed_annotation.dart';

part 'failures.freezed.dart';

/// Failure types for error handling
@freezed
abstract class Failure with _$Failure {
  const factory Failure.serverFailure(String message, [int? code]) = ServerFailure;
  const factory Failure.networkFailure(String message) = NetworkFailure;
  const factory Failure.cacheFailure(String message) = CacheFailure;
  const factory Failure.validationFailure(String message) = ValidationFailure;
  const factory Failure.unauthorizedFailure(String message) = UnauthorizedFailure;
  const factory Failure.unknownFailure(String message) = UnknownFailure;
}