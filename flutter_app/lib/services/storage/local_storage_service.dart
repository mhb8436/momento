import 'dart:convert';
import 'dart:typed_data';
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
  
  static bool isTokenValid() {
    final token = _instance.getString(AppConfig.accessTokenKey);
    if (token == null) return false;
    
    try {
      // JWT 토큰의 payload 부분 디코딩 (간단한 만료 체크)
      final parts = token.split('.');
      if (parts.length != 3) return false;
      
      // Base64 디코딩 (올바른 패딩 처리)
      String payload = parts[1];
      
      // Base64 URL safe 문자를 일반 Base64로 변환
      payload = payload.replaceAll('-', '+').replaceAll('_', '/');
      
      // 올바른 패딩 추가
      switch (payload.length % 4) {
        case 0:
          break; // 패딩 불필요
        case 2:
          payload += '==';
          break;
        case 3:
          payload += '=';
          break;
        default:
          throw FormatException('Invalid base64 string');
      }
      
      final decoded = utf8.decode(base64Decode(payload));
      final payloadMap = json.decode(decoded) as Map<String, dynamic>;
      
      // 만료 시간 체크
      final exp = payloadMap['exp'] as int?;
      if (exp == null) return true; // exp가 없으면 만료되지 않는 토큰으로 간주
      
      final expiryDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      final now = DateTime.now();
      
      // 5분 여유를 두고 만료 체크
      final isValid = expiryDate.isAfter(now.add(const Duration(minutes: 5)));
      
      if (!isValid) {
        print('🕐 토큰 만료됨: 만료시간 ${expiryDate}, 현재시간 ${now}');
      }
      
      return isValid;
    } catch (e) {
      print('🔍 토큰 검증 실패: $e');
      // 검증 실패시 일단 true로 반환 (서버에서 최종 검증)
      return true;
    }
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