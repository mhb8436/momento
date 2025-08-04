# Firebase Push Notification 설정 가이드

MOMENTO 앱에서 Firebase Cloud Messaging(FCM)을 통한 푸시 알림 기능을 설정하는 완전한 가이드입니다.

## 1. Firebase 프로젝트 생성

1. [Firebase Console](https://console.firebase.google.com/)에 접속
2. "프로젝트 추가" 클릭
3. 프로젝트 이름: `momento-app` (또는 원하는 이름)
4. Google Analytics 사용 여부 선택 (선택사항)
5. 프로젝트 생성 완료

## 2. Android 앱 추가

1. Firebase 프로젝트에서 "앱 추가" → Android 아이콘 클릭
2. Android 패키지 이름: `com.momento.momento_app`
3. 앱 닉네임: `MOMENTO Android`
4. SHA-1 서명 인증서 지문 (선택사항, 나중에 추가 가능)
5. `google-services.json` 파일 다운로드
6. 다운로드한 파일을 `flutter_app/android/app/` 디렉토리에 복사

## 3. iOS 앱 추가

1. Firebase 프로젝트에서 "앱 추가" → iOS 아이콘 클릭
2. iOS 번들 ID: `com.momento.momentoApp`
3. 앱 닉네임: `MOMENTO iOS`
4. App Store ID (선택사항)
5. `GoogleService-Info.plist` 파일 다운로드
6. 다운로드한 파일을 `flutter_app/ios/Runner/` 디렉토리에 복사
7. Xcode에서 `GoogleService-Info.plist`를 Runner 타겟에 추가

## 4. Android 설정

### 4.1 build.gradle (Project-level) 수정
파일: `flutter_app/android/build.gradle`

```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.3.15'
    }
}
```

### 4.2 build.gradle (App-level) 수정
파일: `flutter_app/android/app/build.gradle`

```gradle
// 파일 맨 아래에 추가
apply plugin: 'com.google.gms.google-services'

android {
    compileSdkVersion 34

    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 34
    }
}

dependencies {
    implementation 'com.google.firebase:firebase-messaging:23.2.1'
}
```

### 4.3 Android Manifest 수정
파일: `flutter_app/android/app/src/main/AndroidManifest.xml`

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
    <uses-permission android:name="android.permission.VIBRATE" />
    
    <application>
        <!-- Firebase Messaging Service -->
        <service
            android:name="io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingService"
            android:exported="false">
            <intent-filter>
                <action android:name="com.google.firebase.MESSAGING_EVENT" />
            </intent-filter>
        </service>
        
        <!-- Notification icon -->
        <meta-data
            android:name="com.google.firebase.messaging.default_notification_icon"
            android:resource="@drawable/ic_notification" />
        
        <!-- Notification color -->
        <meta-data
            android:name="com.google.firebase.messaging.default_notification_color"
            android:resource="@color/notification_color" />
    </application>
</manifest>
```

## 5. iOS 설정

### 5.1 Capabilities 추가
Xcode에서:
1. Runner 타겟 선택
2. "Signing & Capabilities" 탭
3. "+ Capability" 클릭
4. "Push Notifications" 추가
5. "Background Modes" 추가 후 "Background fetch"와 "Remote notifications" 체크

### 5.2 AppDelegate.swift 수정
파일: `flutter_app/ios/Runner/AppDelegate.swift`

```swift
import UIKit
import Flutter
import Firebase

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    }
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

## 6. Firebase Admin SDK 설정 (백엔드)

### 6.1 서비스 계정 키 생성
1. Firebase Console → 프로젝트 설정 → 서비스 계정
2. "새 비공개 키 생성" 클릭
3. JSON 파일 다운로드
4. 파일명을 `firebase-service-account.json`으로 변경
5. 백엔드 프로젝트 루트에 저장

### 6.2 환경 변수 설정
`.env` 파일에 추가:
```
FIREBASE_SERVICE_ACCOUNT_PATH=firebase-service-account.json
```

### 6.3 Python 패키지 설치
```bash
pip install firebase-admin
```

## 7. 테스트

1. Flutter 앱 실행
2. 알림 설정 화면에서 "테스트 알림 보내기" 버튼 클릭
3. 로컬 알림이 표시되는지 확인
4. FCM 토큰이 서버에 정상적으로 등록되는지 로그 확인

## 8. 주의사항

- iOS의 경우 실제 기기에서만 푸시 알림 테스트 가능 (시뮬레이터 불가)
- Android의 경우 에뮬레이터에서도 테스트 가능 (Google Play Services 필요)
- 프로덕션에서는 APNs 인증서 또는 APNs Auth Key 설정 필요
- Firebase 프로젝트의 할당량 및 요금제 확인

## 9. 다음 단계

1. Firebase 설정 완료 후 앱 재빌드
2. 실제 기기에서 푸시 알림 테스트
3. 백엔드에서 Firebase Admin SDK를 통한 알림 발송 구현
4. 프로덕션 환경 설정

---

설정 완료 후 문제가 있다면 Firebase Console의 디버깅 도구를 활용하여 문제를 해결할 수 있습니다.