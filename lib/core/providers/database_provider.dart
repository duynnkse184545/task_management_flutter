import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:task_management_flutter/core/database/app_database.dart';
import 'package:task_management_flutter/features/auth/data/datasources/local/user_dao.dart';

part 'database_provider.g.dart';

@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
}

@riverpod
UserDao userDao(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.userDao;
}
