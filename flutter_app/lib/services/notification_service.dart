import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/storage/local_storage_service.dart';
import '../services/api/api_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = 
      FlutterLocalNotificationsPlugin();
  
  static bool _initialized = false;
  String? _fcmToken;

  // 알림 채널 ID
  static const String _defaultChannelId = 'momento_default';
  static const String _inquiryChannelId = 'momento_inquiry';
  static const String _updateChannelId = 'momento_update';
  static const String _recipeChannelId = 'momento_recipe';
  static const String _systemChannelId = 'momento_system';

  /// 알림 서비스 초기화
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      print('🔔 NotificationService 초기화 시작');

      // Firebase 초기화 (main.dart에서 이미 초기화되었다면 스킵됨)
      if (!Firebase.apps.isNotEmpty) {
        await Firebase.initializeApp();
      }

      // 로컬 알림 초기화
      await _initializeLocalNotifications();

      // Firebase 메시징 초기화
      await _initializeFirebaseMessaging();

      // 백그라운드 메시지 핸들러 등록
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      _initialized = true;
      print('✅ NotificationService 초기화 완료');
    } catch (e) {
      print('❌ NotificationService 초기화 실패: $e');
      rethrow;
    }
  }

  /// 로컬 알림 초기화
  static Future<void> _initializeLocalNotifications() async {
    // Android 초기화 설정
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS 초기화 설정
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Android 알림 채널 생성
    if (defaultTargetPlatform == TargetPlatform.android) {
      await _createNotificationChannels();
    }
  }

  /// Firebase 메시징 초기화
  static Future<void> _initializeFirebaseMessaging() async {
    // 알림 권한 요청
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('🔔 알림 권한 상태: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // FCM 토큰 획득 및 저장
      await _instance._getFCMToken();

      // 포그라운드 메시지 리스너
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // 앱이 백그라운드에서 열렸을 때
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

      // 앱이 완전히 종료된 상태에서 알림으로 열렸을 때
      RemoteMessage? initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleMessageOpenedApp(initialMessage);
      }

      // 토큰 갱신 리스너
      _messaging.onTokenRefresh.listen((newToken) {
        _instance._fcmToken = newToken;
        _instance._saveTokenToServer(newToken);
      });
    }
  }

  /// Android 알림 채널 생성
  static Future<void> _createNotificationChannels() async {
    final List<AndroidNotificationChannel> channels = [
      const AndroidNotificationChannel(
        _defaultChannelId,
        '기본 알림',
        description: '일반적인 앱 알림',
        importance: Importance.defaultImportance,
      ),
      const AndroidNotificationChannel(
        _inquiryChannelId,
        '문의 답변',
        description: '문의사항에 대한 답변 알림',
        importance: Importance.high,
      ),
      const AndroidNotificationChannel(
        _updateChannelId,
        '앱 업데이트',
        description: '앱 업데이트 관련 알림',
        importance: Importance.defaultImportance,
      ),
      const AndroidNotificationChannel(
        _recipeChannelId,
        '레시피 추천',
        description: '새로운 레시피 추천 알림',
        importance: Importance.defaultImportance,
      ),
      const AndroidNotificationChannel(
        _systemChannelId,
        '시스템 점검',
        description: '시스템 점검 및 유지보수 알림',
        importance: Importance.high,
      ),
    ];

    for (final channel in channels) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
  }

  /// FCM 토큰 획득 및 서버 저장
  Future<void> _getFCMToken() async {
    try {
      String? token = await _messaging.getToken();
      if (token != null) {
        _fcmToken = token;
        print('🔔 FCM 토큰 획득: ${token.substring(0, 20)}...');
        
        // 로컬 저장
        await LocalStorageService.saveFCMToken(token);
        
        // 서버에 저장
        await _saveTokenToServer(token);
      }
    } catch (e) {
      print('❌ FCM 토큰 획득 실패: $e');
    }
  }

  /// FCM 토큰을 서버에 저장
  Future<void> _saveTokenToServer(String token) async {
    try {
      if (!LocalStorageService.hasAccessToken()) {
        print('⚠️ 로그인되지 않아 FCM 토큰 서버 저장 스킵');
        return;
      }

      final apiService = ApiService();
      await apiService.post(
        '/notifications/register-token',
        data: {'fcm_token': token},
      );
      
      print('✅ FCM 토큰 서버 저장 완료');
    } catch (e) {
      print('❌ FCM 토큰 서버 저장 실패: $e');
    }
  }

  /// 포그라운드 메시지 처리
  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('🔔 포그라운드 메시지 수신: ${message.notification?.title}');

    // 사용자 알림 설정 확인
    if (!await _shouldShowNotification(message)) {
      return;
    }

    // 로컬 알림으로 표시
    await _showLocalNotification(message);
  }

  /// 백그라운드 메시지 처리
  @pragma('vm:entry-point')
  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    print('🔔 백그라운드 메시지 수신: ${message.notification?.title}');
    
    // Firebase 초기화 (백그라운드에서 필요)
    await Firebase.initializeApp();
    
    // 필요한 경우 백그라운드 처리 로직 추가
  }

  /// 알림 탭 처리
  static Future<void> _handleMessageOpenedApp(RemoteMessage message) async {
    print('🔔 알림 클릭으로 앱 열림: ${message.notification?.title}');
    
    // 알림 타입에 따른 네비게이션 처리
    final String? type = message.data['type'];
    final String? targetId = message.data['target_id'];
    
    // TODO: 네비게이션 로직 구현
    _navigateToScreen(type, targetId);
  }

  /// 로컬 알림 탭 처리
  static void _onNotificationTapped(NotificationResponse response) {
    print('🔔 로컬 알림 탭: ${response.payload}');
    
    if (response.payload != null) {
      final Map<String, dynamic> data = jsonDecode(response.payload!);
      _navigateToScreen(data['type'], data['target_id']);
    }
  }

  /// 화면 네비게이션 처리
  static void _navigateToScreen(String? type, String? targetId) {
    // TODO: NavigatorKey를 통한 네비게이션 구현
    print('🔄 네비게이션: type=$type, targetId=$targetId');
  }

  /// 알림 표시 여부 확인
  static Future<bool> _shouldShowNotification(RemoteMessage message) async {
    final String? type = message.data['type'];
    
    // 조용한 시간 확인
    if (await _isInQuietHours()) {
      return false;
    }

    // 알림 타입별 설정 확인
    switch (type) {
      case 'inquiry_answer':
        return LocalStorageService.getNotificationSetting('inquiry_answers') ?? true;
      case 'app_update':
        return LocalStorageService.getNotificationSetting('app_updates') ?? true;
      case 'recipe_recommendation':
        return LocalStorageService.getNotificationSetting('recipe_recommendations') ?? true;
      case 'system_maintenance':
        return LocalStorageService.getNotificationSetting('system_maintenance') ?? true;
      default:
        return LocalStorageService.getNotificationSetting('push_notifications') ?? true;
    }
  }

  /// 조용한 시간 확인
  static Future<bool> _isInQuietHours() async {
    if (!(LocalStorageService.getNotificationSetting('quiet_hours_enabled') ?? false)) {
      return false;
    }

    final String? startTime = LocalStorageService.getNotificationSetting('quiet_hours_start');
    final String? endTime = LocalStorageService.getNotificationSetting('quiet_hours_end');
    
    if (startTime == null || endTime == null) {
      return false;
    }

    final now = TimeOfDay.now();
    final start = _parseTimeOfDay(startTime);
    final end = _parseTimeOfDay(endTime);

    // 시간 비교 로직
    if (start.hour < end.hour || (start.hour == end.hour && start.minute < end.minute)) {
      // 같은 날 (예: 22:00 ~ 07:00이 아닌 10:00 ~ 18:00)
      return _isTimeBetween(now, start, end);
    } else {
      // 다음 날까지 (예: 22:00 ~ 07:00)
      return _isTimeBetween(now, start, const TimeOfDay(hour: 23, minute: 59)) ||
             _isTimeBetween(now, const TimeOfDay(hour: 0, minute: 0), end);
    }
  }

  /// TimeOfDay 파싱
  static TimeOfDay _parseTimeOfDay(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  /// 시간 범위 확인
  static bool _isTimeBetween(TimeOfDay current, TimeOfDay start, TimeOfDay end) {
    final currentMinutes = current.hour * 60 + current.minute;
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;
    
    return currentMinutes >= startMinutes && currentMinutes <= endMinutes;
  }

  /// 로컬 알림 표시
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    final String? type = message.data['type'];
    final String channelId = _getChannelId(type);
    
    final payload = jsonEncode({
      'type': type,
      'target_id': message.data['target_id'],
    });

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title,
      message.notification?.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          _getChannelName(channelId),
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: payload,
    );
  }

  /// 채널 ID 반환
  static String _getChannelId(String? type) {
    switch (type) {
      case 'inquiry_answer':
        return _inquiryChannelId;
      case 'app_update':
        return _updateChannelId;
      case 'recipe_recommendation':
        return _recipeChannelId;
      case 'system_maintenance':
        return _systemChannelId;
      default:
        return _defaultChannelId;
    }
  }

  /// 채널 이름 반환
  static String _getChannelName(String channelId) {
    switch (channelId) {
      case _inquiryChannelId:
        return '문의 답변';
      case _updateChannelId:
        return '앱 업데이트';
      case _recipeChannelId:
        return '레시피 추천';
      case _systemChannelId:
        return '시스템 점검';
      default:
        return '기본 알림';
    }
  }

  /// 현재 FCM 토큰 반환
  String? get fcmToken => _fcmToken;

  /// 알림 서비스 초기화 상태
  bool get isInitialized => _initialized;

  /// 테스트용 로컬 알림 표시
  static Future<void> showTestNotification() async {
    await _localNotifications.show(
      0,
      'MOMENTO 테스트',
      '푸시 알림이 정상적으로 설정되었습니다! 🎉',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _defaultChannelId,
          '기본 알림',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }
}