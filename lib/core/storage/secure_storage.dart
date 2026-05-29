
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _tokenKey = 'auth_token';

  static final FlutterSecureStorage _storage =
  const FlutterSecureStorage();

  /// Save auth token
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  /// Read auth token
  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// Delete auth token (logout)
  static Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
  }

  /// Clear everything (optional)
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
