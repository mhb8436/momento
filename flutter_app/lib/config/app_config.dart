class AppConfig {
  static const String appName = 'MOMENTO';
  static const String appVersion = '1.0.0';

  // API Configuration
  static const String baseUrl = 'http://localhost:8000';
  static const String apiVersion = 'v1';

  // API Endpoints
  static const String authEndpoint = '/auth';
  static const String audioEndpoint = '/audio';
  static const String recipeEndpoint = '/recipes';

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
