import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'storage/local_storage_service.dart';

/// FCM 토큰 생성 도우미 클래스
class FCMTokenHelper {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  
  /// iOS에서 APNS 토큰 대기 후 FCM 토큰 생성
  static Future<String?> generateFCMToken({
    int maxAttempts = 10,
    Duration delayBetweenAttempts = const Duration(seconds: 1),
  }) async {
    try {
      // iOS에서 APNS 토큰 확보 대기
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        print('🍎 iOS APNS 토큰 확보 대기 중...');
        
        bool apnsReady = await _waitForAPNSToken(
          maxAttempts: maxAttempts,
          delay: delayBetweenAttempts,
        );
        
        if (!apnsReady) {
          print('⚠️ APNS 토큰 확보 실패, FCM 토큰 생성을 계속 시도합니다...');
        }
      }
      
      // FCM 토큰 생성
      print('🔄 FCM 토큰 생성 시도 중...');
      String? token = await _messaging.getToken();
      
      if (token != null) {
        print('✅ FCM 토큰 생성 성공: ${token.substring(0, 20)}...');
        
        // 로컬 저장
        await LocalStorageService.saveFCMToken(token);
        
        // 디버그 모드에서 전체 토큰 출력
        if (kDebugMode) {
          print('🔑 전체 FCM 토큰:');
          print(token);
          print('📋 위 토큰을 Firebase Console에서 테스트하세요!');
        }
        
        return token;
      } else {
        print('❌ FCM 토큰이 null입니다');
        return null;
      }
    } catch (e) {
      print('❌ FCM 토큰 생성 실패: $e');
      return null;
    }
  }
  
  /// APNS 토큰이 준비될 때까지 대기
  static Future<bool> _waitForAPNSToken({
    required int maxAttempts,
    required Duration delay,
  }) async {
    int attempts = 0;
    
    while (attempts < maxAttempts) {
      try {
        String? apnsToken = await _messaging.getAPNSToken();
        if (apnsToken != null && apnsToken.isNotEmpty) {
          print('✅ APNS 토큰 확보 완료');
          return true;
        }
      } catch (e) {
        print('🔄 APNS 토큰 대기 중... (${attempts + 1}/$maxAttempts): $e');
      }
      
      attempts++;
      if (attempts < maxAttempts) {
        await Future.delayed(delay);
      }
    }
    
    return false;
  }
  
  /// 저장된 FCM 토큰 확인 및 유효성 검사 (캐시 우선)
  static Future<String?> getValidFCMToken() async {
    // 로컬 저장소에서 토큰 확인
    String? token = LocalStorageService.getFCMToken();
    
    if (token != null && token.isNotEmpty) {
      print('💾 저장된 FCM 토큰 발견: ${token.substring(0, 20)}...');
      return token;
    }
    
    print('📭 저장된 FCM 토큰이 없습니다. 새로 생성합니다...');
    return await generateFCMToken();
  }

  /// 캐시된 토큰 우선 사용, 백그라운드에서 갱신
  static Future<String?> getValidFCMTokenWithCache() async {
    // 1단계: 캐시된 토큰 우선 반환
    String? cachedToken = LocalStorageService.getFCMToken();
    
    if (cachedToken != null && cachedToken.isNotEmpty) {
      print('🚀 캐시된 FCM 토큰 사용: ${cachedToken.substring(0, 20)}...');
      
      // 2단계: 백그라운드에서 새 토큰 확인 및 비교
      _validateAndUpdateTokenInBackground(cachedToken);
      
      return cachedToken;
    }
    
    // 3단계: 캐시가 없으면 새로 생성
    print('🆕 캐시된 토큰이 없습니다. 새로 생성합니다...');
    return await generateFCMTokenFast();
  }

  /// 백그라운드에서 토큰 유효성 검사 및 업데이트
  static void _validateAndUpdateTokenInBackground(String cachedToken) {
    Future.delayed(const Duration(seconds: 2), () async {
      try {
        print('🔄 백그라운드에서 토큰 유효성 검사 중...');
        
        String? currentToken = await _messaging.getToken();
        
        if (currentToken != null && currentToken != cachedToken) {
          print('🆕 새로운 FCM 토큰 발견, 업데이트 중...');
          await LocalStorageService.saveFCMToken(currentToken);
          print('✅ FCM 토큰 백그라운드 업데이트 완료');
        } else {
          print('✅ 캐시된 FCM 토큰이 유효합니다.');
        }
      } catch (e) {
        print('⚠️ 백그라운드 토큰 검사 실패: $e');
      }
    });
  }

  /// 빠른 FCM 토큰 생성 (APNS 대기 시간 단축)
  static Future<String?> generateFCMTokenFast() async {
    try {
      // iOS에서도 빠른 생성을 위해 대기 시간 단축
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        print('🍎 iOS 빠른 FCM 토큰 생성 시도...');
        
        // APNS 토큰 대기 시간을 단축 (3초만 대기)
        bool apnsReady = await _waitForAPNSToken(
          maxAttempts: 3,
          delay: const Duration(seconds: 1),
        );
        
        if (!apnsReady) {
          print('⚠️ APNS 토큰 빠른 확보 실패, FCM 토큰 생성 계속...');
        }
      }
      
      // FCM 토큰 생성
      print('🚀 빠른 FCM 토큰 생성 시도 중...');
      String? token = await _messaging.getToken();
      
      if (token != null) {
        print('✅ 빠른 FCM 토큰 생성 성공: ${token.substring(0, 20)}...');
        
        // 로컬 저장
        await LocalStorageService.saveFCMToken(token);
        
        return token;
      } else {
        print('❌ 빠른 FCM 토큰이 null입니다');
        return null;
      }
    } catch (e) {
      print('❌ 빠른 FCM 토큰 생성 실패: $e');
      return null;
    }
  }
  
  /// FCM 토큰 재생성 (강제)
  static Future<String?> regenerateFCMToken() async {
    print('🔄 FCM 토큰 강제 재생성...');
    
    try {
      // 기존 토큰 삭제
      await LocalStorageService.removeFCMToken();
      
      // 새 토큰 생성
      return await generateFCMToken();
    } catch (e) {
      print('❌ FCM 토큰 재생성 실패: $e');
      return null;
    }
  }
}