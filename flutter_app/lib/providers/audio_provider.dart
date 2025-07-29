import 'package:flutter/foundation.dart';
import '../models/audio_file.dart';

class AudioProvider extends ChangeNotifier {
  List<AudioFile> _audioFiles = [];
  bool _isLoading = false;
  bool _isRecording = false;
  bool _isUploading = false;
  String? _errorMessage;
  AudioFile? _currentProcessingAudio;

  List<AudioFile> get audioFiles => _audioFiles;
  bool get isLoading => _isLoading;
  bool get isRecording => _isRecording;
  bool get isUploading => _isUploading;
  String? get errorMessage => _errorMessage;
  AudioFile? get currentProcessingAudio => _currentProcessingAudio;

  Future<void> loadAudioFiles() async {
    _setLoading(true);
    _clearError();

    try {
      // TODO: Implement API call to load audio files
      // final result = await _audioService.getAudioFiles();
      // if (result.isSuccess) {
      //   _audioFiles = result.audioFiles;
      // } else {
      //   _setError(result.message);
      // }
      
      // Temporary mock data
      _audioFiles = [];
      
    } catch (e) {
      _setError('오디오 파일을 불러오는데 실패했습니다.');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> startRecording() async {
    try {
      _clearError();
      
      // TODO: Implement recording logic
      // Check permissions
      // Start recording
      
      _isRecording = true;
      notifyListeners();
      return true;
    } catch (e) {
      _setError('녹음을 시작할 수 없습니다.');
      return false;
    }
  }

  Future<String?> stopRecording() async {
    try {
      _clearError();
      
      // TODO: Implement stop recording logic
      // Stop recording
      // Return file path
      
      _isRecording = false;
      notifyListeners();
      
      // Return mock file path for now
      return '/path/to/recorded/file.wav';
    } catch (e) {
      _setError('녹음을 중지하는데 실패했습니다.');
      _isRecording = false;
      notifyListeners();
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
}