import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:task_management_flutter/core/providers/api_provider.dart';
import 'package:task_management_flutter/core/providers/database_provider.dart';
import 'package:task_management_flutter/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:task_management_flutter/features/auth/data/datasources/remote/auth_api_service.dart';
import 'package:task_management_flutter/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:task_management_flutter/features/auth/data/datasources/remote/user_api_service.dart';
import 'package:task_management_flutter/features/auth/data/repositories/auth_repository.dart';
import 'package:task_management_flutter/features/auth/data/repositories/auth_repository_impl.dart';

part 'auth_providers.g.dart';

// Remote DataSource Provider
@riverpod
AuthRemoteDataSource authRemoteDataSource(Ref ref) {
  return AuthRemoteDataSourceImpl(
    authApi: ref.watch(authApiServiceProvider),
    userApi: ref.watch(userApiServiceProvider),
  );
}

@riverpod
AuthApiService authApiService(Ref ref) {
  return AuthApiService(ref.watch(dioProvider));
}

@riverpod
UserApiService userApiService(Ref ref) {
  return UserApiService(ref.watch(dioProvider));
}

// Local DataSource Provider (uses UserDao)
@riverpod
AuthLocalDataSource authLocalDataSource(Ref ref) {
  return AuthLocalDataSourceImpl(ref.watch(userDaoProvider));
}

// Repository Provider
@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    localDataSource: ref.watch(authLocalDataSourceProvider),
    tokenService: ref.watch(tokenServiceProvider)
  );
}
