import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_management_flutter/core/config/api_config.dart';
import 'package:task_management_flutter/core/network/api_client.dart';
import 'package:task_management_flutter/core/network/auth_interceptor.dart';
import 'package:task_management_flutter/core/services/token_service.dart';

part 'api_provider.g.dart';

@riverpod
Dio dio(Ref ref) {
  return Dio(
    BaseOptions(
      baseUrl: ApiConfig.restBaseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      headers: ApiConfig.defaultHeaders,
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
    ),
  );
}

@riverpod
ApiClient apiClient(Ref ref) {
  return ApiClient(ref.watch(dioProvider));
}

@riverpod
FlutterSecureStorage flutterSecureStorage(Ref ref) {
  const androidOptions = AndroidOptions();

  const iosOptions = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock,
  );

  return const FlutterSecureStorage(
    aOptions: androidOptions,
    iOptions: iosOptions,
  );
}

@riverpod
TokenService tokenService(Ref ref) =>
    TokenServiceImpl(ref.watch(flutterSecureStorageProvider));

AuthInterceptor authInterceptor(Ref ref) {
  return AuthInterceptor(
    apiClient: ref.watch(apiClientProvider),
    tokenService: ref.watch(tokenServiceProvider),
  );
}
