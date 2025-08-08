class AppConfig {
  static const String appName = 'MOMENTO';
  static const String appVersion = '1.0.0';

  // API Configuration
  static String get baseUrl {
    // ngrok 터널 URL (고정, 네트워크 무관)
    return 'https://687000934841.ngrok-free.app';

    // 이전 IP들 (참고용)
    // 핫스팟: 'http://192.0.0.3:8000'
    // WiFi: 'http://172.17.6.62:8000'
    // 시뮬레이터: 'http://localhost:8000'
  }

  // 수동 오버라이드용 (필요시 변경)
  static const String manualBaseUrl = 'http://172.17.4.164:8000';
  static const String apiVersion = 'v1';

  // API Endpoints
  static const String authEndpoint = '/auth/';
  static const String audioEndpoint = '/audio/';
  static const String recipeEndpoint = '/recipes/';

  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String userDataKey = 'user_data';
  static const String settingsKey = 'app_settings';

  // Audio Configuration
  static const int maxRecordingDuration = 300; // 5 minutes in seconds
  static const String audioFormat = 'wav';
  static const int audioSampleRate = 44100;

  // File Upload
  static const int maxFileSize = 50 * 1024 * 1024; // 50MB
  static const List<String> supportedAudioFormats = [
    'wav',
    'mp3',
    'm4a',
    'aac'
  ];

  // UI Configuration
  static const Duration splashDuration = Duration(seconds: 2);
  static const Duration toastDuration = Duration(seconds: 3);

  // Validation
  static const int minPasswordLength = 6;
  static const int maxRecipeTitleLength = 100;
  static const int maxRecipeDescriptionLength = 500;
}
