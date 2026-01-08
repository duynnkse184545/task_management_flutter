import 'package:drift/drift.dart';
import 'package:task_management_flutter/core/database/app_database.dart';

part 'user_dao.g.dart';

@DriftAccessor(tables: [Users])
class UserDao extends DatabaseAccessor<AppDatabase> with _$UserDaoMixin {
  UserDao(super.attachedDatabase);

  Future<UserEntity?> getUserById(String userId) async {
    final query = select(users)..where((tbl) => tbl.id.equals(userId));
    return await query.getSingleOrNull();
  }

  Future<void> saveUser(UsersCompanion user) async {
    await into(users).insertOnConflictUpdate(user);
  }

  Future<void> deleteUser(String userId) async {
    await (delete(users)..where((tbl) => tbl.id.equals(userId))).go();
  }

  Future<void> clearAllUsers() async {
    await delete(users).go();
  }
}