import 'package:drift/drift.dart';
import 'package:task_management_flutter/core/database/app_database.dart';

import 'user_models.dart';

extension UserModelExtension on User {
  UsersCompanion toCompanion() {
    return UsersCompanion.insert(
      id: id,
      email: email,
      username: username,
      fullName: Value(fullName),
      avatarUrl: Value(avatarUrl),
      bio: Value(bio),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

extension UserRowExtension on UserEntity {
  User toModel() {
    return User(
      id: id,
      email: email,
      username: username,
      fullName: fullName,
      avatarUrl: avatarUrl,
      bio: bio,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}