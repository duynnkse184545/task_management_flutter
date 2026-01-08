import 'package:task_management_flutter/core/error/exceptions.dart';
import 'package:task_management_flutter/features/auth/data/datasources/local/user_dao.dart';
import 'package:task_management_flutter/features/auth/data/models/user_extension.dart';
import 'package:task_management_flutter/features/auth/data/models/user_models.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheUser(User user);
  Future<User?> getCachedUser(String userId);
  Future<void> clearUserCache();
}

/// Implementation using UserDao for user cache
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final UserDao _userDao;

  AuthLocalDataSourceImpl(this._userDao);

  @override
  Future<void> cacheUser(User user) async {
    try {
      await _userDao.saveUser(user.toCompanion());
    } catch (e) {
      throw CacheException('Failed to cache user: $e');
    }
  }

  @override
  Future<User?> getCachedUser(String userId) async {
    try {
      final result = await _userDao.getUserById(userId);
      return result?.toModel();
    } catch (e) {
      throw CacheException('Failed to get cached user: $e');
    }
  }

  @override
  Future<void> clearUserCache() async {
    try {
      await _userDao.clearAllUsers();
    } catch (e) {
      throw CacheException('Failed to clear user cache: $e');
    }
  }
}