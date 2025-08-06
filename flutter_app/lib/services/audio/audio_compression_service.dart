import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class AudioCompressionService {
  static const int chunkSizeBytes = 1024 * 1024; // 1MB chunks
  static const int maxFileSizeMB = 50; // 50MB 제한
  static const int maxDurationMinutes = 30; // 30분 제한

  /// 음성 파일 사전 검증 (압축은 서버에서)
  static Future<File> validateAudioFile(File originalFile) async {
    try {
      final fileSize = await originalFile.length();
      final maxSize = maxFileSizeMB * 1024 * 1024;

      print('📏 파일 크기 검증: ${fileSize / (1024 * 1024)} MB');

      // 크기가 적절하면 그대로 반환
      if (fileSize <= maxSize) {
        print('✅ 파일 크기 적절함');
        return originalFile;
      }

      // 클라이언트에서는 기본적인 검증만 수행
      // 실제 압축은 서버에서 처리
      print('⚠️ 파일이 큼 - 서버에서 자동 압축 예정');
      return originalFile;
      
    } catch (e) {
      throw AudioCompressionException('파일 검증 실패: $e');
    }
  }

  /// 청크 단위로 파일 분할
  static Future<List<Uint8List>> splitIntoChunks(File audioFile) async {
    final bytes = await audioFile.readAsBytes();
    final chunks = <Uint8List>[];
    
    for (int i = 0; i < bytes.length; i += chunkSizeBytes) {
      final end = (i + chunkSizeBytes < bytes.length) 
          ? i + chunkSizeBytes 
          : bytes.length;
      chunks.add(bytes.sublist(i, end));
    }
    
    return chunks;
  }

  /// 실시간 녹음 크기 모니터링
  static Future<bool> shouldStopRecording(String filePath) async {
    final file = File(filePath);
    
    if (!await file.exists()) return false;
    
    final fileSize = await file.length();
    final maxSize = maxFileSizeMB * 1024 * 1024;
    
    return fileSize >= maxSize;
  }

  /// 예상 파일 크기 계산
  static int estimateFileSize({
    required int durationSeconds,
    int bitRate = 64000,
  }) {
    // 공식: (bitRate * duration) / 8 bytes
    return (bitRate * durationSeconds) ~/ 8;
  }

  /// 클라이언트 사이드 기본 최적화 (녹음 설정으로 처리)
  static Map<String, dynamic> getOptimalRecordingConfig() {
    return {
      'encoder': 'aac',
      'bitRate': 64000,     // 64kbps
      'sampleRate': 16000,  // 16kHz
      'numChannels': 1,     // Mono
    };
  }

  /// 서버 압축을 위한 파일 준비
  static Future<File> prepareForServerCompression(File inputFile) async {
    // 클라이언트에서는 검증만 수행
    // 실제 압축은 서버에서 처리
    print('📤 서버 압축을 위한 파일 준비');
    return inputFile;
  }
}

class AudioCompressionException implements Exception {
  final String message;
  AudioCompressionException(this.message);
  
  @override
  String toString() => 'AudioCompressionException: $message';
}