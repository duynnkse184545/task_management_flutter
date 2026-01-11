import 'package:task_management_flutter/core/utils/type_defs.dart';
import 'package:task_management_flutter/features/auth/data/models/auth_models.dart';
import 'package:task_management_flutter/features/auth/data/models/user_models.dart';

abstract class AuthRepository {
  TaskResult<User> signUp(SignUpRequest request);
  TaskResult<User> signIn(SignInRequest request);
  TaskResult<void> signOut();
  TaskResult<User> getCurrentUser();
  TaskResult<User> updateProfile(String userId, UpdateProfileRequest request);
  TaskResult<bool> isUsernameAvailable(String username);
  User? getCachedUser();
  bool isLoggedIn();
}