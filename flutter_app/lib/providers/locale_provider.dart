import 'package:flutter/material.dart';
import '../services/storage/local_storage_service.dart';
import '../services/audio/stt_service.dart';

class LocaleProvider extends ChangeNotifier {
  static const String _localeKey = 'app_locale';
  
  Locale _currentLocale = const Locale('ko', 'KR'); // Default to Korean
  
  Locale get currentLocale => _currentLocale;
  
  /// Initialize locale from storage
  Future<void> initialize() async {
    try {
      final savedLocaleCode = LocalStorageService.getSetting<String>(_localeKey);
      if (savedLocaleCode != null) {
        final parts = savedLocaleCode.split('_');
        if (parts.length == 2) {
          _currentLocale = Locale(parts[0], parts[1]);
        }
      }
    } catch (e) {
      debugPrint('❌ Failed to load saved locale: $e');
    }
    
    // Update STT service with current locale
    STTService().setLocale(_currentLocale);
    
    notifyListeners();
  }
  
  /// Change the app locale
  Future<void> setLocale(Locale locale) async {
    if (_currentLocale == locale) return;
    
    _currentLocale = locale;
    
    // Save to storage
    try {
      await LocalStorageService.saveSetting(_localeKey, '${locale.languageCode}_${locale.countryCode}');
    } catch (e) {
      debugPrint('❌ Failed to save locale: $e');
    }
    
    // Update STT service
    STTService().setLocale(locale);
    
    notifyListeners();
  }
  
  /// Get available locales
  List<Locale> get supportedLocales => [
    const Locale('ko', 'KR'),
    const Locale('en', 'US'),
    const Locale('ja', 'JP'),
    const Locale('es', 'ES'),
  ];
  
  /// Get display name for locale
  String getLocaleName(Locale locale) {
    switch ('${locale.languageCode}_${locale.countryCode}') {
      case 'ko_KR':
        return '한국어';
      case 'en_US':
        return 'English';
      case 'ja_JP':
        return '日本語';
      case 'es_ES':
        return 'Español';
      default:
        return locale.languageCode;
    }
  }
  
  /// Check if locale is supported
  bool isSupported(Locale locale) {
    return supportedLocales.any((supported) => 
        supported.languageCode == locale.languageCode &&
        supported.countryCode == locale.countryCode);
  }
}