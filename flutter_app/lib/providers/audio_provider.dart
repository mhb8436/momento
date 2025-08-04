import 'package:flutter/foundation.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/audio_file.dart';
import '../services/api/audio_service.dart';
import 'recipe_provider.dart';

class AudioProvider extends ChangeNotifier {
  final AudioRecorder _audioRecord = AudioRecorder();
  final AudioService _audioService = AudioService();
  RecipeProvider? _recipeProvider;

  List<AudioFile> _audioFiles = [];
  bool _isLoading = false;
  bool _isRecording = false;
  bool _isUploading = false;
  String? _errorMessage;
  AudioFile? _currentProcessingAudio;
  String? _currentRecordingPath;
  bool _hasRecording = false;

  List<AudioFile> get audioFiles => _audioFiles;
  bool get isLoading => _isLoading;
  bool get isRecording => _isRecording;
  bool get isUploading => _isUploading;
  String? get errorMessage => _errorMessage;
  AudioFile? get currentProcessingAudio => _currentProcessingAudio;
  bool get hasRecording => _hasRecording;

  void setRecipeProvider(RecipeProvider recipeProvider) {
    _recipeProvider = recipeProvider;
  }

  Future<void> loadAudioFiles() async {
    _setLoading(true);
    _clearError();

    try {
      print('🔍 AudioProvider loadAudioFiles 시작');
      final result = await _audioService.getAudioFiles();

      if (result.isSuccess && result.audioFiles != null) {
        _audioFiles = result.audioFiles!;
        print('✅ 오디오 파일 ${_audioFiles.length}개 로드 완료');
      } else {
        final errorMsg = result.message ?? '오디오 파일을 불러오는데 실패했습니다.';
        print('❌ 오디오 파일 로드 실패: $errorMsg');
        _setError(errorMsg);
        _audioFiles = []; // Clear on error
      }
    } catch (e) {
      print('❌ AudioProvider loadAudioFiles exception: $e');
      _setError('오디오 파일을 불러오는데 실패했습니다: $e');
      _audioFiles = [];
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> startRecording() async {
    try {
      _clearError();

      // Check microphone permission
      if (!await _checkMicrophonePermission()) {
        _setError('마이크 권한이 필요합니다.');
        return false;
      }

      // Check if device has microphone
      if (!await _audioRecord.hasPermission()) {
        _setError('마이크 권한이 거부되었습니다.');
        return false;
      }

      // Create directory for recordings
      final directory = await getApplicationDocumentsDirectory();
      final recordingsDir = Directory('${directory.path}/recordings');
      if (!await recordingsDir.exists()) {
        await recordingsDir.create(recursive: true);
      }

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _currentRecordingPath = '${recordingsDir.path}/recording_$timestamp.m4a';

      // Start recording
      await _audioRecord.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: _currentRecordingPath!,
      );

      _isRecording = true;
      _hasRecording = false;
      notifyListeners();

      debugPrint('🎙️ 녹음 시작: $_currentRecordingPath');
      return true;
    } catch (e) {
      _setError('녹음을 시작할 수 없습니다: $e');
      debugPrint('❌ 녹음 시작 오류: $e');
      return false;
    }
  }

  Future<String?> stopRecording() async {
    try {
      _clearError();

      if (!_isRecording) {
        _setError('현재 녹음 중이 아닙니다.');
        return null;
      }

      // Stop recording
      final path = await _audioRecord.stop();

      _isRecording = false;

      if (path != null && await File(path).exists()) {
        _currentRecordingPath = path;
        _hasRecording = true;
        debugPrint('✅ 녹음 완료: $path');
      } else {
        _setError('녹음 파일을 저장할 수 없습니다.');
        _hasRecording = false;
        debugPrint('❌ 녹음 파일 저장 실패');
      }

      notifyListeners();
      return path;
    } catch (e) {
      _setError('녹음을 중지하는데 실패했습니다: $e');
      _isRecording = false;
      _hasRecording = false;
      notifyListeners();
      debugPrint('❌ 녹음 중지 오류: $e');
      return null;
    }
  }

  Future<bool> uploadAudioFile(String filePath) async {
    _setUploading(true);
    _clearError();

    try {
      // TODO: Implement audio upload
      // final result = await _audioService.uploadAudio(filePath);
      // if (result.isSuccess) {
      //   final audioFile = result.audioFile;
      //   _audioFiles.insert(0, audioFile);
      //   notifyListeners();
      //   return true;
      // } else {
      //   _setError(result.message);
      //   return false;
      // }

      // Mock successful upload
      await Future.delayed(const Duration(seconds: 2));
      return true;
    } catch (e) {
      _setError('파일 업로드에 실패했습니다.');
      return false;
    } finally {
      _setUploading(false);
    }
  }

  Future<bool> processAudio(String audioId) async {
    _clearError();

    try {
      // Find the audio file
      final audioIndex = _audioFiles.indexWhere((audio) => audio.id == audioId);
      if (audioIndex == -1) {
        _setError('오디오 파일을 찾을 수 없습니다.');
        return false;
      }

      // Update status to processing
      _audioFiles[audioIndex] = _audioFiles[audioIndex].copyWith(
        processingStatus: 'processing',
      );
      _currentProcessingAudio = _audioFiles[audioIndex];
      notifyListeners();

      // TODO: Implement API call to process audio
      // final result = await _audioService.processAudio(audioId);
      // if (result.isSuccess) {
      //   _audioFiles[audioIndex] = _audioFiles[audioIndex].copyWith(
      //     processingStatus: 'completed',
      //     transcriptText: result.transcriptText,
      //   );
      // } else {
      //   _audioFiles[audioIndex] = _audioFiles[audioIndex].copyWith(
      //     processingStatus: 'failed',
      //   );
      //   _setError(result.message);
      //   return false;
      // }

      // Mock processing
      await Future.delayed(const Duration(seconds: 3));
      _audioFiles[audioIndex] = _audioFiles[audioIndex].copyWith(
        processingStatus: 'completed',
        transcriptText: '엄마가 알려주신 김치찌개 레시피입니다...',
      );

      _currentProcessingAudio = null;
      notifyListeners();
      return true;
    } catch (e) {
      _setError('음성 처리에 실패했습니다.');
      _currentProcessingAudio = null;
      notifyListeners();
      return false;
    }
  }

  void deleteAudioFile(String audioId) {
    _audioFiles.removeWhere((audio) => audio.id == audioId);
    notifyListeners();
  }

  AudioFile? getAudioById(String audioId) {
    try {
      return _audioFiles.firstWhere((audio) => audio.id == audioId);
    } catch (e) {
      return null;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setUploading(bool uploading) {
    _isUploading = uploading;
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

  // Upload and process current recording
  Future<bool> uploadAndProcessRecording() async {
    if (!_hasRecording || _currentRecordingPath == null) {
      _setError('업로드할 녹음 파일이 없습니다.');
      return false;
    }

    try {
      _setUploading(true);
      _clearError();

      // Upload audio file
      debugPrint('📤 오디오 파일 업로드 시작: $_currentRecordingPath');
      final uploadResult =
          await _audioService.uploadAudio(_currentRecordingPath!);

      if (!uploadResult.isSuccess) {
        _setError(uploadResult.message ?? '파일 업로드에 실패했습니다.');
        return false;
      }

      debugPrint('✅ 오디오 파일 업로드 완료');

      // Process audio for recipe extraction
      debugPrint('🔄 음성 처리 및 레시피 생성 시작');
      final processResult =
          await _audioService.processAudio(uploadResult.audioId!);

      if (!processResult.isSuccess) {
        _setError(processResult.message ?? '음성 처리에 실패했습니다.');
        return false;
      }

      debugPrint('🎉 레시피 생성 완료');

      // Create recipe from processed audio
      if (_recipeProvider != null && processResult.recipeId != null) {
        await _recipeProvider!.createRecipeFromAudio(uploadResult.audioId!);
      }

      // Clear current recording
      _hasRecording = false;
      _currentRecordingPath = null;

      // Reload audio files
      await loadAudioFiles();

      return true;
    } catch (e) {
      _setError('처리 중 오류가 발생했습니다: $e');
      debugPrint('❌ 업로드/처리 오류: $e');
      return false;
    } finally {
      _setUploading(false);
    }
  }

  // Check microphone permission
  Future<bool> _checkMicrophonePermission() async {
    try {
      PermissionStatus permission = await Permission.microphone.status;
      debugPrint('🔍 초기 마이크 권한 상태: $permission');
      
      // iOS 시뮬레이터에서는 granted가 아닌 경우 무조건 요청
      if (!permission.isGranted) {
        debugPrint('🔍 마이크 권한 요청 시작');
        permission = await Permission.microphone.request();
        debugPrint('🔍 마이크 권한 요청 후 상태: $permission');
      }

      // iOS 시뮬레이터에서 permanentlyDenied가 잘못 나오는 경우를 위한 추가 체크
      if (permission.isPermanentlyDenied) {
        debugPrint('🔍 권한이 영구적으로 거부됨 - AudioRecorder로도 확인');
        
        // AudioRecorder의 hasPermission으로도 체크
        try {
          final audioPermission = await _audioRecord.hasPermission();
          debugPrint('🔍 AudioRecorder 권한 상태: $audioPermission');
          
          if (audioPermission) {
            debugPrint('🔍 AudioRecorder에서는 권한이 허용됨 - 진행');
            return true;
          }
        } catch (audioError) {
          debugPrint('🔍 AudioRecorder 권한 체크 오류: $audioError');
        }
        
        // 시뮬레이터에서는 실제로 권한이 있을 수 있으므로 한 번 더 체크
        final retryPermission = await Permission.microphone.status;
        debugPrint('🔍 재확인 권한 상태: $retryPermission');
        
        if (retryPermission.isGranted) {
          debugPrint('🔍 재확인 결과 권한이 허용됨');
          return true;
        }
        
        // 여전히 거부되어 있다면 설정으로 이동
        debugPrint('🔍 설정 앱으로 이동');
        await openAppSettings();
        return false;
      }

      debugPrint('🔍 최종 권한 결과: ${permission.isGranted}');
      return permission.isGranted;
    } catch (e) {
      debugPrint('❌ 권한 확인 오류: $e');
      return false;
    }
  }

  // Dispose resources
  @override
  void dispose() {
    _audioRecord.dispose();
    super.dispose();
  }
}
