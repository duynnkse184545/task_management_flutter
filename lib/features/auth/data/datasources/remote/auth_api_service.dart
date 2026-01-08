import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:task_management_flutter/core/config/api_config.dart';
import 'package:task_management_flutter/features/auth/data/models/auth_models.dart';
import 'package:task_management_flutter/features/auth/data/models/user_models.dart';

part 'auth_api_service.g.dart';

@RestApi()
abstract class AuthApiService {
  factory AuthApiService(Dio dio, {String baseUrl}) = _AuthApiService;

  // --- Auth Endpoints (Base URL: ApiConfig.authBaseUrl) ---
  
  @POST('/signup')
  Future<AuthResponse> signUp(@Body() SignUpRequest request);

  @POST('/token?grant_type=password')
  Future<AuthResponse> signIn(@Body() SignInRequest request);

  @POST('/logout')
  Future<void> signOut();

  @GET('/user')
  Future<AuthUser> getUser();
}
