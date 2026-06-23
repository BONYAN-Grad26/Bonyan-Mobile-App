/// Concrete implementation of TokenStorage using SharedPreferences
import 'package:shared_preferences/shared_preferences.dart';
import 'api_client.dart';

/// Implementation of TokenStorage using SharedPreferences
/// Stores JWT tokens persistently on device
class SharedPreferencesTokenStorage implements TokenStorage {
  static const String _tokenKey = 'jwt_access_token';

  @override
  Future<String?> getAccessToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      print('Error retrieving token from SharedPreferences: $e');
      return null;
    }
  }

  @override
  Future<void> saveAccessToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
    } catch (e) {
      print('Error saving token to SharedPreferences: $e');
      rethrow;
    }
  }

  @override
  Future<void> clearAccessToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
    } catch (e) {
      print('Error clearing token from SharedPreferences: $e');
      rethrow;
    }
  }
}
