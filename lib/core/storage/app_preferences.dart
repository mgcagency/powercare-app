import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  static const _userKey = 'user_data';
  static const _loggedInKey = 'is_logged_in';
  static const _userEmailKey = 'user_email';
  static const _userNameKey = 'user_name';
  static const _userIdKey = 'user_id';
  static const _userRoleKey = 'user_role';
  static const _userImageKey = 'user_image';
  static const _rememberMeKey = "remember_me";
  static const _secretCode = "secret_code";
  static const _registeredChildrenKey = 'registered_children';

  /// Save user JSON
  static Future<void> saveUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user));
  }

  /// Get user JSON
  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString(_userKey);

    if (userString == null) return null;
    return jsonDecode(userString);
  }

  /// Save user JSON
  static Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, jsonEncode(userId));
  }

  /// Get user JSON
  static Future<String> getUserID() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(_userIdKey);

    if (userId == null) return "";
    return jsonDecode(userId);
  }

  /// Save login state
  static Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loggedInKey, value);
  }

  /// Check login state
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_loggedInKey) ?? false;
  }

  /// Save user role
  static Future<void> saveRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userRoleKey, role);
  }

  /// Get user role
  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userRoleKey);
  }

  /// Save user email
  static Future<void> saveUserEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userEmailKey, email);
  }

  /// Get user role
  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }

  /// Save user name
  static Future<void> saveUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, name);
  }

  /// Get user name
  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey);
  }

//// save user image
  static Future<void> saveUserImage(String image) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userImageKey, image);
  }

  /// Get user image
  static Future<String?> getUserImage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userImageKey);
  }


  static Future<void> setRememberMe(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rememberMeKey, value);
  }

  static Future<bool> getRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_rememberMeKey) ?? false;
  }

  static Future<void> clearRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_rememberMeKey);
  }

  /// Save registered children
  static Future<void> saveRegisteredChildren(List<Map<String, dynamic>> children) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_registeredChildrenKey, jsonEncode(children));
  }

  /// Get registered children
  static Future<List<dynamic>> getRegisteredChildren() async {
    final prefs = await SharedPreferences.getInstance();
    final childrenString = prefs.getString(_registeredChildrenKey);
    if (childrenString == null) return [];
    return jsonDecode(childrenString);
  }

  /// Clear all preferences (logout)
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
  static Future<void> setSecretCode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_secretCode, value);
  }

  static Future<bool> getSecretCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_secretCode) ?? false;
  }

}
