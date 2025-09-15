import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

class STTService {
  static final STTService _instance = STTService._internal();
  factory STTService() => _instance;
  STTService._internal();

  final SpeechToText _speechToText = SpeechToText();
  bool _isInitialized = false;
  bool _isListening = false;
  String _recognizedWords = '';
  String _currentLocaleId = 'ko_KR'; // Default to Korean
  
  // Stream controllers for real-time updates
  final StreamController<String> _transcriptController = StreamController<String>.broadcast();
  final StreamController<bool> _listeningController = StreamController<bool>.broadcast();
  final StreamController<String> _errorController = StreamController<String>.broadcast();

  // Getters for streams
  Stream<String> get transcriptStream => _transcriptController.stream;
  Stream<bool> get listeningStream => _listeningController.stream;
  Stream<String> get errorStream => _errorController.stream;
  
  bool get isListening => _isListening;
  String get recognizedWords => _recognizedWords;

  /// Initialize Speech-to-Text service
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      debugPrint('🔍 STT 서비스 초기화 시작');
      
      // Initialize speech-to-text (자동으로 권한 요청 포함)
      _isInitialized = await _speechToText.initialize(
        onError: _onError,
        onStatus: _onStatus,
        debugLogging: kDebugMode,
      );
      
      if (_isInitialized) {
        debugPrint('✅ STT 서비스 초기화 완료');
        return true;
      } else {
        debugPrint('❌ STT 서비스 초기화 실패');
        _errorController.add('음성 인식 서비스를 초기화할 수 없습니다.');
        return false;
      }
    } catch (e) {
      debugPrint('❌ STT 서비스 초기화 실패: $e');
      _errorController.add('음성 인식 서비스 초기화 실패: $e');
      return false;
    }
  }

  /// Start real-time speech recognition
  Future<bool> startListening() async {
    try {
      // 먼저 기존 세션 정리
      if (_isListening) {
        debugPrint('⚠️ 기존 세션 정리 중...');
        await _speechToText.stop();
        _isListening = false;
        _listeningController.add(false);
        // 세션 간 간격 추가
        await Future.delayed(const Duration(milliseconds: 500));
      }
      
      // 초기화 상태 확인 및 재초기화
      if (!_speechToText.isAvailable) {
        debugPrint('🔄 STT 서비스 재초기화 필요');
        _isInitialized = false;
        final initialized = await initialize();
        if (!initialized) {
          return false;
        }
      }

      debugPrint('🎤 실시간 음성 인식 시작');
      debugPrint('🔍 STT 사용 가능 상태: ${_speechToText.isAvailable}');
      debugPrint('🔍 STT 리스닝 상태: ${_speechToText.isListening}');
      
      _recognizedWords = '';
      _transcriptController.add('');
      
      // speech_to_text의 상태를 먼저 확인
      if (!_speechToText.isAvailable) {
        debugPrint('❌ STT 서비스가 사용 불가능한 상태입니다.');
        _errorController.add('음성 인식 서비스가 사용할 수 없는 상태입니다.');
        return false;
      }
      
      // listen 시작 - 현재 설정된 로케일 사용
      final available = await _speechToText.listen(
        onResult: _onResult,
        listenFor: const Duration(seconds: 30), // 30초로 단축
        pauseFor: const Duration(seconds: 2),   // 2초로 단축
        partialResults: true,
        localeId: _currentLocaleId,
        cancelOnError: false,
        listenMode: ListenMode.confirmation,
      );
      
      debugPrint('🔍 listen() 반환값: $available');
      
      // null이나 false가 아닌 경우 성공으로 간주
      if (available == true) {
        _isListening = true;
        _listeningController.add(true);
        debugPrint('✅ 음성 인식 시작 성공');
        return true;
      } else {
        debugPrint('❌ 음성 인식을 시작할 수 없습니다. available: $available');
        // available이 null인 경우에도 한 번 더 상태 확인
        if (_speechToText.isListening) {
          debugPrint('🔍 실제로는 리스닝 상태임 - 성공으로 처리');
          _isListening = true;
          _listeningController.add(true);
          return true;
        }
        _errorController.add('음성 인식을 시작할 수 없습니다.');
        return false;
      }
    } catch (e) {
      debugPrint('❌ 음성 인식 시작 실패: $e');
      _errorController.add('음성 인식 시작 실패: $e');
      return false;
    }
  }
  
  /// Stop speech recognition and return final result
  Future<STTResult> stopListening() async {
    try {
      if (!_isListening) {
        return STTResult.failure(message: '현재 음성 인식이 진행되지 않고 있습니다.');
      }
      
      debugPrint('🛑 음성 인식 중지');
      await _speechToText.stop();
      
      _isListening = false;
      _listeningController.add(false);
      
      if (_recognizedWords.isNotEmpty) {
        debugPrint('✅ 최종 인식 결과: $_recognizedWords');
        return STTResult.success(transcript: _recognizedWords);
      } else {
        return STTResult.failure(message: '인식된 음성이 없습니다.');
      }
    } catch (e) {
      debugPrint('❌ 음성 인식 중지 실패: $e');
      _isListening = false;
      _listeningController.add(false);
      return STTResult.failure(message: '음성 인식 중지 실패: $e');
    }
  }
  
  /// Cancel ongoing speech recognition
  Future<void> cancelListening() async {
    try {
      if (_isListening) {
        debugPrint('❌ 음성 인식 취소');
        await _speechToText.cancel();
        _isListening = false;
        _listeningController.add(false);
        _recognizedWords = '';
        _transcriptController.add('');
      }
    } catch (e) {
      debugPrint('❌ 음성 인식 취소 실패: $e');
    }
  }
  
  // Handle speech recognition results
  void _onResult(result) {
    _recognizedWords = result.recognizedWords;
    debugPrint('📝 인식 결과 업데이트: $_recognizedWords (final: ${result.finalResult})');
    _transcriptController.add(_recognizedWords);
    
    // If this is a final result, stop listening
    if (result.finalResult) {
      _isListening = false;
      _listeningController.add(false);
    }
  }
  
  // Handle status changes
  void _onStatus(String status) {
    debugPrint('📊 STT 상태 변화: $status');
    
    if (status == 'done' || status == 'notListening') {
      _isListening = false;
      _listeningController.add(false);
    }
  }
  
  // Handle errors
  void _onError(error) {
    final errorMsg = error.toString();
    debugPrint('❌ STT 오류: $error');
    
    // error_no_match는 음성을 감지하지 못한 일반적인 상황으로 무시
    if (errorMsg.contains('error_no_match')) {
      debugPrint('ℹ️ 음성 감지 안됨 - 정상적인 상황');
      return;
    }
    
    // 실제 심각한 에러만 사용자에게 표시
    if (errorMsg.contains('error_network') || 
        errorMsg.contains('error_audio') || 
        errorMsg.contains('error_permission')) {
      _errorController.add('음성 인식 오류: $error');
      _isListening = false;
      _listeningController.add(false);
    }
  }
  

  /// Get available locales
  Future<List<LocaleName>> getAvailableLocales() async {
    if (_isInitialized) {
      return await _speechToText.locales();
    }
    return [];
  }
  
  /// Get model information for UI  
  Future<String> getModelInfo() async {
    if (_isInitialized) {
      final locales = await getAvailableLocales();
      final currentLocale = locales.where((locale) => locale.localeId == _currentLocaleId).firstOrNull;
      if (currentLocale != null) {
        return 'Speech-to-Text (${currentLocale.name})';
      }
    }
    return 'Speech-to-Text (초기화 필요)';
  }

  /// Set the speech recognition locale
  void setLocale(Locale locale) {
    // Convert Flutter Locale to STT locale format
    switch (locale.languageCode) {
      case 'ko':
        _currentLocaleId = 'ko_KR';
        break;
      case 'en':
        _currentLocaleId = 'en_US';
        break;
      case 'ja':
        _currentLocaleId = 'ja_JP';
        break;
      case 'es':
        _currentLocaleId = 'es_ES';
        break;
      default:
        // Default to Korean if unsupported locale
        _currentLocaleId = 'ko_KR';
        break;
    }
    debugPrint('🌐 STT 언어 설정 변경: $_currentLocaleId');
  }

  /// Get supported locales for the app
  static List<Locale> getSupportedLocales() {
    return [
      const Locale('ko', 'KR'),
      const Locale('en', 'US'),
      const Locale('ja', 'JP'),
      const Locale('es', 'ES'),
    ];
  }

  /// Get current locale
  String get currentLocaleId => _currentLocaleId;

  /// Check if STT service is ready
  bool get isReady => _isInitialized;

  /// Dispose resources
  void dispose() {
    cancelListening();
    _transcriptController.close();
    _listeningController.close();
    _errorController.close();
    _isInitialized = false;
  }
}

// STT Result Classes
abstract class STTResult {
  final bool isSuccess;
  final String? message;
  final String? transcript;

  STTResult._({
    required this.isSuccess,
    this.message,
    this.transcript,
  });

  factory STTResult.success({required String transcript}) = STTSuccess;
  factory STTResult.failure({required String message}) = STTFailure;
}

class STTSuccess extends STTResult {
  STTSuccess({required String transcript}) 
      : super._(isSuccess: true, transcript: transcript);
}

class STTFailure extends STTResult {
  STTFailure({required String message}) 
      : super._(isSuccess: false, message: message);
}