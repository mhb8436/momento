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

  // FCM Token Management
  static Future<void> saveFCMToken(String token) async {
    await _instance.setString('fcm_token', token);
  }

  static String? getFCMToken() {
    return _instance.getString('fcm_token');
  }

  static Future<void> removeFCMToken() async {
    await _instance.remove('fcm_token');
  }

  // Notification Settings Management
  static Future<void> saveNotificationSetting(String key, dynamic value) async {
    await saveSetting('notification_$key', value);
  }

  static T? getNotificationSetting<T>(String key, {T? defaultValue}) {
    return getSetting<T>('notification_$key', defaultValue: defaultValue);
  }

  static Future<void> removeNotificationSetting(String key) async {
    await removeSetting('notification_$key');
  }

  // Convenience methods for notification settings
  static Future<void> setPushNotificationsEnabled(bool enabled) async {
    await saveNotificationSetting('push_notifications', enabled);
  }

  static bool isPushNotificationsEnabled() {
    return getNotificationSetting<bool>('push_notifications', defaultValue: true) ?? true;
  }

  static Future<void> setQuietHoursEnabled(bool enabled) async {
    await saveNotificationSetting('quiet_hours_enabled', enabled);
  }

  static bool isQuietHoursEnabled() {
    return getNotificationSetting<bool>('quiet_hours_enabled', defaultValue: false) ?? false;
  }

  static Future<void> setQuietHoursStart(String time) async {
    await saveNotificationSetting('quiet_hours_start', time);
  }

  static String? getQuietHoursStart() {
    return getNotificationSetting<String>('quiet_hours_start', defaultValue: '22:00');
  }

  static Future<void> setQuietHoursEnd(String time) async {
    await saveNotificationSetting('quiet_hours_end', time);
  }

  static String? getQuietHoursEnd() {
    return getNotificationSetting<String>('quiet_hours_end', defaultValue: '07:00');
  }
}