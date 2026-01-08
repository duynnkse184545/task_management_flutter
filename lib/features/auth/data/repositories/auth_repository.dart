import 'package:task_management_flutter/core/utils/type_defs.dart';
import 'package:task_management_flutter/features/auth/data/models/auth_models.dart';
import 'package:task_management_flutter/features/auth/data/models/user_models.dart';

abstract class AuthRepository {
  FutureEither<User> signUp(SignUpRequest request);
  FutureEither<User> signIn(SignInRequest request);
  FutureEither<void> signOut();
  FutureEither<User> getCurrentUser();
  FutureEither<User> updateProfile(String userId, UpdateProfileRequest request);
  FutureEither<bool> isUsernameAvailable(String username);
  User? getCachedUser();
  bool isLoggedIn();
}