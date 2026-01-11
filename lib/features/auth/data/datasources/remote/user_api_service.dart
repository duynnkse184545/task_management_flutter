import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:task_management_flutter/features/auth/data/models/user_models.dart';

part 'user_api_service.g.dart';

@RestApi()
abstract class UserApiService {
  factory UserApiService(Dio dio, {String baseUrl}) = _UserApiService;

  // --- Auth User Info ---
  @GET('/auth/v1/user') // Absolute path or relative to base? Assuming separate BaseUrl in Config, but here we might need full path if this service uses REST url.
  // Actually, getAuthUser hits the Auth API, not REST API.
  // Ideally, this should be in AuthApiService. I will move logic there or keep usage clean.
  // Let's assume AuthApiService handles the "get current auth user" and this handles "profiles" table.
  
  // --- Profiles Table (REST API) ---
  
  @POST('/profiles')
  Future<void> createProfile(@Body() CreateProfileRequest request);

  @GET('/profiles')
  Future<List<User>> getUserById(@Query('id') String idQuery);

  @PATCH('/profiles')
  Future<List<User>> updateProfile(
      @Query('id') String idQuery,
      @Body() UpdateProfileRequest request
  );

  @GET('/profiles')
  Future<List<User>> checkUsername(
      @Query('username') String usernameQuery,
      @Query('select') String select
  );
}

