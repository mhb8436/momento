import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import '../../models/audio_file.dart';
import '../../config/app_config.dart';
import 'api_service.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final ApiService _apiService = ApiService();

  Future<AudioUploadResult> uploadAudio(String filePath) async {
    try {
      print('🔍 AudioService uploadAudio 시작: $filePath');
      
      final file = File(filePath);
      if (!await file.exists()) {
        return AudioUploadResult.failure(message: '파일을 찾을 수 없습니다.');
      }

      final fileName = filePath.split('/').last;
      final fileExtension = fileName.split('.').last.toLowerCase();
      
      // 파일 확장자에 따른 MIME type 설정
      MediaType? mediaType;
      switch (fileExtension) {
        case 'wav':
          mediaType = MediaType('audio', 'wav');
          break;
        case 'mp3':
          mediaType = MediaType('audio', 'mpeg');
          break;
        case 'm4a':
          mediaType = MediaType('audio', 'mp4');
          break;
        case 'aac':
          mediaType = MediaType('audio', 'aac');
          break;
        default:
          mediaType = MediaType('audio', 'wav'); // 기본값
      }
      
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          filePath,
          filename: fileName,
          contentType: mediaType,
        ),
      });

      print('🔍 API URL: ${AppConfig.baseUrl}${AppConfig.audioEndpoint}/upload');
      print('🔍 파일명: $fileName, 파일 크기: ${await file.length()} bytes');
      print('🔍 MIME Type: ${mediaType.toString()}');
      
      final response = await _apiService.post(
        '${AppConfig.audioEndpoint}/upload',
        data: formData,
      );

      print('🔍 업로드 API 응답: status=${response.statusCode}, data=${response.data}');

      if (response.statusCode == 200) {
        final audioId = response.data['id'] as String?;
        if (audioId != null) {
          return AudioUploadResult.success(audioId: audioId);
        } else {
          print('❌ 응답에서 ID를 찾을 수 없음: ${response.data}');
          return AudioUploadResult.failure(message: '서버 응답에서 오디오 ID를 찾을 수 없습니다.');
        }
      } else {
        final errorMsg = response.data['detail'] ?? '파일 업로드에 실패했습니다.';
        print('❌ 업로드 API 오류 응답: $errorMsg');
        return AudioUploadResult.failure(message: errorMsg);
      }
    } on ApiException catch (e) {
      print('❌ AudioService uploadAudio ApiException: ${e.message} (status: ${e.statusCode})');
      return AudioUploadResult.failure(message: e.message);
    } catch (e) {
      print('❌ AudioService uploadAudio Exception: $e');
      return AudioUploadResult.failure(message: '파일 업로드 중 오류가 발생했습니다: $e');
    }
  }

  Future<AudioProcessResult> processAudio(String audioId) async {
    try {
      print('🔍 AudioService processAudio 시작: $audioId');
      print('🔍 API URL: ${AppConfig.baseUrl}${AppConfig.audioEndpoint}/process');
      
      final response = await _apiService.post(
        '${AppConfig.audioEndpoint}/process',
        data: {
          'audio_id': audioId,
        },
      );

      print('🔍 처리 API 응답: status=${response.statusCode}, data=${response.data}');

      if (response.statusCode == 200) {
        final recipeId = response.data['recipe_id'] as String?;
        final transcriptText = response.data['transcript_text'] as String?;
        
        return AudioProcessResult.success(
          recipeId: recipeId,
          transcriptText: transcriptText,
        );
      } else {
        final errorMsg = response.data['detail'] ?? '음성 처리에 실패했습니다.';
        print('❌ 처리 API 오류 응답: $errorMsg');
        return AudioProcessResult.failure(message: errorMsg);
      }
    } on ApiException catch (e) {
      print('❌ AudioService processAudio ApiException: ${e.message} (status: ${e.statusCode})');
      return AudioProcessResult.failure(message: e.message);
    } catch (e) {
      print('❌ AudioService processAudio Exception: $e');
      return AudioProcessResult.failure(message: '음성 처리 중 오류가 발생했습니다: $e');
    }
  }

  Future<AudioListResult> getAudioFiles() async {
    try {
      print('🔍 AudioService getAudioFiles 시작');
      
      final response = await _apiService.get('${AppConfig.audioEndpoint}/');

      print('🔍 오디오 목록 API 응답: status=${response.statusCode}, data=${response.data}');

      if (response.statusCode == 200) {
        final List<dynamic> audioData = response.data is List 
            ? response.data 
            : response.data['audio_files'] ?? [];
        
        print('🔍 파싱할 오디오 데이터 개수: ${audioData.length}');
        
        final List<AudioFile> audioFiles = [];
        for (int i = 0; i < audioData.length; i++) {
          try {
            final audioFile = AudioFile.fromJson(audioData[i]);
            audioFiles.add(audioFile);
          } catch (e) {
            print('❌ 오디오 파일 파싱 오류 (인덱스 $i): $e');
            print('   데이터: ${audioData[i]}');
          }
        }
        
        print('✅ 오디오 파일 ${audioFiles.length}개 로드 완료');
        return AudioListResult.success(audioFiles: audioFiles);
      } else {
        final errorMsg = response.data['detail'] ?? '오디오 파일 목록을 가져올 수 없습니다.';
        print('❌ 오디오 목록 API 오류 응답: $errorMsg');
        return AudioListResult.failure(message: errorMsg);
      }
    } on ApiException catch (e) {
      return AudioListResult.failure(message: e.message);
    } catch (e) {
      return AudioListResult.failure(message: '오디오 파일 목록을 가져오는 중 오류가 발생했습니다.');
    }
  }
}

// Audio Service Result Classes
abstract class AudioUploadResult {
  final bool isSuccess;
  final String? message;
  final String? audioId;

  AudioUploadResult._({
    required this.isSuccess,
    this.message,
    this.audioId,
  });

  factory AudioUploadResult.success({required String audioId}) = AudioUploadSuccess;
  factory AudioUploadResult.failure({required String message}) = AudioUploadFailure;
}

class AudioUploadSuccess extends AudioUploadResult {
  AudioUploadSuccess({required String audioId}) 
      : super._(isSuccess: true, audioId: audioId);
}

class AudioUploadFailure extends AudioUploadResult {
  AudioUploadFailure({required String message}) 
      : super._(isSuccess: false, message: message);
}

abstract class AudioProcessResult {
  final bool isSuccess;
  final String? message;
  final String? recipeId;
  final String? transcriptText;

  AudioProcessResult._({
    required this.isSuccess,
    this.message,
    this.recipeId,
    this.transcriptText,
  });

  factory AudioProcessResult.success({
    String? recipeId,
    String? transcriptText,
  }) = AudioProcessSuccess;
  
  factory AudioProcessResult.failure({required String message}) = AudioProcessFailure;
}

class AudioProcessSuccess extends AudioProcessResult {
  AudioProcessSuccess({
    String? recipeId,
    String? transcriptText,
  }) : super._(
         isSuccess: true,
         recipeId: recipeId,
         transcriptText: transcriptText,
       );
}

class AudioProcessFailure extends AudioProcessResult {
  AudioProcessFailure({required String message})
      : super._(isSuccess: false, message: message);
}

abstract class AudioListResult {
  final bool isSuccess;
  final String? message;
  final List<AudioFile>? audioFiles;

  AudioListResult._({
    required this.isSuccess,
    this.message,
    this.audioFiles,
  });

  factory AudioListResult.success({required List<AudioFile> audioFiles}) = AudioListSuccess;
  factory AudioListResult.failure({required String message}) = AudioListFailure;
}

class AudioListSuccess extends AudioListResult {
  AudioListSuccess({required List<AudioFile> audioFiles})
      : super._(isSuccess: true, audioFiles: audioFiles);
}

class AudioListFailure extends AudioListResult {
  AudioListFailure({required String message})
      : super._(isSuccess: false, message: message);
}