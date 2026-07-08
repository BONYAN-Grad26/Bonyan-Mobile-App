import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  SecureStorageService({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  static const _accessTokenKey = 'accessToken';
  static const _refreshTokenKey = 'refreshToken';

  final FlutterSecureStorage _secureStorage;

  Future<void> saveAccessToken(String token) {
    return _secureStorage.write(key: _accessTokenKey, value: token);
  }

  Future<String?> readAccessToken() {
    return _secureStorage.read(key: _accessTokenKey);
  }

  Future<void> deleteAccessToken() {
    return _secureStorage.delete(key: _accessTokenKey);
  }

  Future<void> saveRefreshToken(String token) {
    return _secureStorage.write(key: _refreshTokenKey, value: token);
  }

  Future<String?> readRefreshToken() {
    return _secureStorage.read(key: _refreshTokenKey);
  }

  Future<void> deleteRefreshToken() {
    return _secureStorage.delete(key: _refreshTokenKey);
  }

  Future<void> clearTokens() async {
    await deleteAccessToken();
    await deleteRefreshToken();
  }
}
