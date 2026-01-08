import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:task_management_flutter/core/error/exceptions.dart';
import 'package:task_management_flutter/core/error/failures.dart';

class ErrorHandler {
  static Failure handle(dynamic error) {
    if (error is DioException) {
      return _handleDioError(error);
    } else if (error is ServerException) {
      return Failure.serverFailure(error.message, error.code);
    } else if (error is UnauthorizedException) {
      return Failure.unauthorizedFailure(error.message);
    } else if (error is ValidationException) {
      return Failure.validationFailure(error.message);
    } else if (error is NetworkException) {
      return Failure.networkFailure(error.message);
    } else if (error is CacheException) {
      return Failure.cacheFailure(error.message);
    } else if (error is SocketException) {
      return const Failure.networkFailure('No internet connection');
    } else if (error is FormatException) {
      return const Failure.serverFailure('Invalid data format');
    } else {
      return Failure.unknownFailure(error.toString());
    }
  }

  static Failure _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return const Failure.networkFailure('Connection timeout or network error');
        
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = _extractErrorMessage(error.response?.data);
        
        if (statusCode == 401) {
          return Failure.unauthorizedFailure(message);
        } else if (statusCode == 422) {
          return Failure.validationFailure(message);
        } else if (statusCode == 404) {
          return Failure.serverFailure('Not Found: $message', 404);
        } else {
          return Failure.serverFailure(message, statusCode);
        }
        
      case DioExceptionType.cancel:
        return const Failure.serverFailure('Request cancelled');
        
      case DioExceptionType.unknown:
      default:
        return Failure.unknownFailure(error.message ?? 'Unknown Dio error');
    }
  }

  static String _extractErrorMessage(dynamic data) {
    String message = 'Request failed';
    if (data is Map<String, dynamic>) {
      message = data['message'] ??
          data['error_description'] ??
          data['msg'] ??
          message;
    } else if (data is String) {
      message = data;
    }
    return message;
  }

  static Future<void> handleSafely(
      Future<void> Function() operation,
      String context,
      ) async {
    try {
      await operation();
    } catch (e, stackTrace) {
      debugPrint('⚠️ $context failed: $e');
      debugPrintStack(stackTrace: stackTrace, maxFrames: 2);
    }
  }
}