import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/app_config.dart';
import '../../models/user.dart';

class LocalStorageService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static SharedPreferences get _instance {
    if (_prefs == null) {
      throw Exception('LocalStorageService not initialized. Call init() first.');
    }
    return _prefs!;
  }

  // Token Management
  static Future<void> saveAccessToken(String token) async {
    await _instance.setString(AppConfig.accessTokenKey, token);
  }

  static String? getAccessToken() {
    return _instance.getString(AppConfig.accessTokenKey);
  }

  static Future<void> removeAccessToken() async {
    await _instance.remove(AppConfig.accessTokenKey);
  }

  static bool hasAccessToken() {
    return _instance.containsKey(AppConfig.accessTokenKey);
  }

  // User Data Management
  static Future<void> saveUserData(User user) async {
    final userJson = json.encode(user.toJson());
    await _instance.setString(AppConfig.userDataKey, userJson);
  }

  static User? getUserData() {
    final userJson = _instance.getString(AppConfig.userDataKey);
    if (userJson == null) return null;
    
    try {
      final userMap = json.decode(userJson) as Map<String, dynamic>;
      return User.fromJson(userMap);
    } catch (e) {
      return null;
    }
  }

  static Future<void> removeUserData() async {
    await _instance.remove(AppConfig.userDataKey);
  }

  // App Settings
  static Future<void> saveSetting(String key, dynamic value) async {
    if (value is String) {
      await _instance.setString(key, value);
    } else if (value is int) {
      await _instance.setInt(key, value);
    } else if (value is double) {
      await _instance.setDouble(key, value);
    } else if (value is bool) {
      await _instance.setBool(key, value);
    } else if (value is List<String>) {
      await _instance.setStringList(key, value);
    } else {
      await _instance.setString(key, json.encode(value));
    }
  }

  static T? getSetting<T>(String key, {T? defaultValue}) {
    try {
      if (T == String) {
        return _instance.getString(key) as T? ?? defaultValue;
      } else if (T == int) {
        return _instance.getInt(key) as T? ?? defaultValue;
      } else if (T == double) {
        return _instance.getDouble(key) as T? ?? defaultValue;
      } else if (T == bool) {
        return _instance.getBool(key) as T? ?? defaultValue;
      } else if (T == List<String>) {
        return _instance.getStringList(key) as T? ?? defaultValue;
      } else {
        final jsonString = _instance.getString(key);
        if (jsonString == null) return defaultValue;
        return json.decode(jsonString) as T;
      }
    } catch (e) {
      return defaultValue;
    }
  }

  static Future<void> removeSetting(String key) async {
    await _instance.remove(key);
  }

  // Clear All Data
  static Future<void> clearAll() async {
    await _instance.clear();
  }

  // Check if key exists
  static bool containsKey(String key) {
    return _instance.containsKey(key);
  }
}