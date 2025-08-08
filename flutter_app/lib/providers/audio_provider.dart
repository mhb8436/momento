import 'package:flutter/foundation.dart';
import 'dart:async';
import '../services/api/audio_service.dart';
import '../services/audio/stt_service.dart';

class AudioProvider extends ChangeNotifier {
  final AudioService _audioService = AudioService();
  final STTService _sttService = STTService();

  bool _isLoading = false;
  bool _isListening = false;
  bool _isProcessing = false;
  String? _errorMessage;
  String _currentTranscript = '';  // 현재 세션의 인식 결과
  String _accumulatedTranscript = '';  // 누적된 전체 텍스트
  StreamSubscription? _transcriptSubscription;
  StreamSubscription? _listeningSubscription;
  StreamSubscription? _errorSubscription;

  bool get isLoading => _isLoading;
  bool get isListening => _isListening;
  bool get isProcessing => _isProcessing;
  String? get errorMessage => _errorMessage;
  String get currentTranscript => _currentTranscript;
  String get accumulatedTranscript => _accumulatedTranscript;
  bool get hasAccumulatedText => _accumulatedTranscript.isNotEmpty;

  /// Initialize STT service and set up streams
  Future<bool> initializeSTT() async {
    try {
      _clearError();
      debugPrint('🔍 STT 서비스 초기화 시작');
      
      final initialized = await _sttService.initialize();
      if (!initialized) {
        _setError('음성 인식 서비스를 초기화할 수 없습니다.');
        return false;
      }
      
      // Set up streams for real-time updates
      _transcriptSubscription = _sttService.transcriptStream.listen((transcript) {
        _currentTranscript = transcript;
        notifyListeners();
      });
      
      _listeningSubscription = _sttService.listeningStream.listen((listening) {
        _isListening = listening;
        notifyListeners();
      });
      
      _errorSubscription = _sttService.errorStream.listen((error) {
        _setError(error);
      });
      
      debugPrint('✅ STT 서비스 초기화 완료');
      return true;
    } catch (e) {
      _setError('음성 인식 서비스 초기화 실패: $e');
      debugPrint('❌ STT 초기화 오류: $e');
      return false;
    }
  }

  /// Get STT service status
  bool get isSTTReady => _sttService.isReady;

  /// Get model information for UI
  Future<String> getSTTModelInfo() async {
    return await _sttService.getModelInfo();
  }

  /// Start real-time speech recognition
  Future<bool> startListening() async {
    try {
      _clearError();
      
      // Auto-accumulate current transcript if it exists
      if (_currentTranscript.isNotEmpty) {
        if (_accumulatedTranscript.isNotEmpty) {
          _accumulatedTranscript += ' $_currentTranscript';
        } else {
          _accumulatedTranscript = _currentTranscript;
        }
        debugPrint('📝 자동 텍스트 추가됨. 누적 길이: ${_accumulatedTranscript.length}');
        debugPrint('📝 누적 내용: ${_accumulatedTranscript.length > 100 ? _accumulatedTranscript.substring(0, 100) + "..." : _accumulatedTranscript}');
      }
      
      // Initialize STT service if not already done
      if (!_sttService.isReady) {
        final initialized = await initializeSTT();
        if (!initialized) {
          return false;
        }
      }

      debugPrint('🎤 실시간 음성 인식 시작');
      final started = await _sttService.startListening();
      
      if (started) {
        _currentTranscript = '';
        debugPrint('✅ 음성 인식 시작 성공');
        return true;
      } else {
        _setError('음성 인식을 시작할 수 없습니다.');
        return false;
      }
    } catch (e) {
      _setError('음성 인식 시작 실패: $e');
      debugPrint('❌ 음성 인식 시작 오류: $e');
      return false;
    }
  }

  /// Stop speech recognition and get final transcript
  Future<String?> stopListening() async {
    try {
      _clearError();

      if (!_isListening) {
        _setError('현재 음성 인식이 진행되지 않고 있습니다.');
        return null;
      }

      debugPrint('🛑 음성 인식 중지');
      final result = await _sttService.stopListening();

      if (result.isSuccess && result.transcript != null) {
        _currentTranscript = result.transcript!;
        debugPrint('✅ 음성 인식 완료: $_currentTranscript');
        return result.transcript;
      } else {
        _setError(result.message ?? '음성 인식에 실패했습니다.');
        debugPrint('❌ 음성 인식 실패');
        return null;
      }
    } catch (e) {
      _setError('음성 인식 중지 실패: $e');
      debugPrint('❌ 음성 인식 중지 오류: $e');
      return null;
    }
  }
  
  /// Add current transcript to accumulated text
  void addToAccumulated() {
    if (_currentTranscript.isNotEmpty) {
      if (_accumulatedTranscript.isNotEmpty) {
        _accumulatedTranscript += ' $_currentTranscript';
      } else {
        _accumulatedTranscript = _currentTranscript;
      }
      
      // Clear current transcript for next session
      _currentTranscript = '';
      debugPrint('📝 텍스트 추가됨. 누적 길이: ${_accumulatedTranscript.length}');
      debugPrint('📝 누적 내용: ${_accumulatedTranscript.length > 100 ? _accumulatedTranscript.substring(0, 100) + "..." : _accumulatedTranscript}');
      notifyListeners();
    }
  }
  
  /// Clear accumulated transcript
  void clearAccumulated() {
    _accumulatedTranscript = '';
    _currentTranscript = '';
    debugPrint('🗑️ 누적된 텍스트 초기화');
    notifyListeners();
  }
  
  /// Get final transcript for processing (accumulated + current)
  String getFinalTranscript() {
    if (_currentTranscript.isNotEmpty) {
      if (_accumulatedTranscript.isNotEmpty) {
        return '$_accumulatedTranscript $_currentTranscript';
      } else {
        return _currentTranscript;
      }
    }
    return _accumulatedTranscript;
  }
  
  /// Set transcript from OCR result for recipe processing
  void setTranscriptFromOCR(String ocrText) {
    _accumulatedTranscript = ocrText;
    _currentTranscript = '';
    debugPrint('📷 OCR 텍스트 설정됨. 길이: ${ocrText.length}자');
    debugPrint('📝 OCR 내용: ${ocrText.length > 200 ? ocrText.substring(0, 200) + "..." : ocrText}');
    notifyListeners();
  }
  
  /// Cancel ongoing speech recognition
  Future<void> cancelListening() async {
    try {
      if (_isListening) {
        debugPrint('❌ 음성 인식 취소');
        await _sttService.cancelListening();
        _currentTranscript = '';
        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ 음성 인식 취소 오류: $e');
    }
  }

  /// Process recognized transcript and create recipe
  Future<bool> processTranscriptAndCreateRecipe() async {
    final finalTranscript = getFinalTranscript();
    
    if (finalTranscript.isEmpty) {
      _setError('처리할 음성 인식 결과가 없습니다.');
      return false;
    }

    try {
      _setProcessing(true);
      _clearError();

      debugPrint('📤 텍스트 처리 및 레시피 생성 시작');
      debugPrint('📝 최종 내용 길이: ${finalTranscript.length}자');
      debugPrint('📝 최종 내용: ${finalTranscript.length > 200 ? finalTranscript.substring(0, 200) + "..." : finalTranscript}');
      
      // Send final transcript to server for recipe processing
      final processResult = await _audioService.processTranscript(finalTranscript);

      if (!processResult.isSuccess) {
        _setError(processResult.message ?? '레시피 생성에 실패했습니다.');
        return false;
      }

      debugPrint('🎉 레시피 생성 완료');

      // Recipe created successfully on server
      if (processResult.recipeId != null) {
        debugPrint('✅ 레시피 ID: ${processResult.recipeId}');
      }

      // Clear all transcripts after successful processing
      clearAccumulated();

      return true;
    } catch (e) {
      _setError('처리 중 오류가 발생했습니다: $e');
      debugPrint('❌ 텍스트 처리 오류: $e');
      return false;
    } finally {
      _setProcessing(false);
    }
  }

  void _setProcessing(bool processing) {
    _isProcessing = processing;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }

  /// Dispose resources
  @override
  void dispose() {
    _transcriptSubscription?.cancel();
    _listeningSubscription?.cancel();
    _errorSubscription?.cancel();
    _sttService.dispose();
    super.dispose();
  }
}