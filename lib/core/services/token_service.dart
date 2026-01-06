import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:task_management_flutter/core/error/exceptions.dart';

abstract class TokenService {
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required String userId,
  });

  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<String?> getUserId();
  Future<void> clearTokens();
  Future<bool> hasValidTokens();
}

class TokenServiceImpl implements TokenService {
  final FlutterSecureStorage _secureStorage;

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';

  TokenServiceImpl(this._secureStorage);

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required String userId,
  }) async {
    try {
      await Future.wait([
        _secureStorage.write(key: _accessTokenKey, value: accessToken),
        _secureStorage.write(key: _refreshTokenKey, value: refreshToken),
        _secureStorage.write(key: _userIdKey, value: userId),
      ]);
    } catch (e) {
      throw CacheException('Failed to save tokens: ${e.toString()}');
    }
  }

  @override
  Future<String?> getAccessToken() async {
    try {
      return await _secureStorage.read(key: _accessTokenKey);
    } catch (e) {
      throw CacheException('Failed to get access token: ${e.toString()}');
    }
  }

  @override
  Future<String?> getRefreshToken() async {
    try {
      return await _secureStorage.read(key: _refreshTokenKey);
    } catch (e) {
      throw CacheException('Failed to get refresh token: ${e.toString()}');
    }
  }

  @override
  Future<String?> getUserId() async {
    try {
      return await _secureStorage.read(key: _userIdKey);
    } catch (e) {
      throw CacheException('Failed to get user ID: ${e.toString()}');
    }
  }

  @override
  Future<void> clearTokens() async {
    try {
      await Future.wait([
        _secureStorage.delete(key: _accessTokenKey),
        _secureStorage.delete(key: _refreshTokenKey),
        _secureStorage.delete(key: _userIdKey),
      ]);
    } catch (e) {
      throw CacheException('Failed to clear tokens: ${e.toString()}');
    }
  }

  @override
  Future<bool> hasValidTokens() async {
    try {
      final accessToken = await getAccessToken();
      final userId = await getUserId();
      return accessToken != null && userId != null;
    } catch (e) {
      return false;
    }
  }
}