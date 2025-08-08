import '../../config/app_config.dart';
import 'api_service.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final ApiService _apiService = ApiService();

  /// Process transcribed text to recipe (new client-side STT flow)
  Future<TextProcessResult> processTranscript(String transcript) async {
    try {
      print('🔍 AudioService processTranscript 시작');
      print('🔍 API URL: ${AppConfig.baseUrl}${AppConfig.audioEndpoint}/process-text');
      
      final response = await _apiService.post(
        '${AppConfig.audioEndpoint}/process-text',
        data: {
          'transcript': transcript,
        },
      );

      print('🔍 텍스트 처리 API 응답: status=${response.statusCode}, data=${response.data}');

      if (response.statusCode == 200) {
        final recipeId = response.data['recipe_id'] as String?;
        
        return TextProcessResult.success(
          recipeId: recipeId,
          transcript: transcript,
        );
      } else {
        final errorMsg = response.data['detail'] ?? '텍스트 처리에 실패했습니다.';
        print('❌ 텍스트 처리 API 오류 응답: $errorMsg');
        return TextProcessResult.failure(message: errorMsg);
      }
    } on ApiException catch (e) {
      print('❌ AudioService processTranscript ApiException: ${e.message} (status: ${e.statusCode})');
      return TextProcessResult.failure(message: e.message);
    } catch (e) {
      print('❌ AudioService processTranscript Exception: $e');
      return TextProcessResult.failure(message: '텍스트 처리 중 오류가 발생했습니다: $e');
    }
  }
}

// Text Processing Result Classes (for client-side STT)
abstract class TextProcessResult {
  final bool isSuccess;
  final String? message;
  final String? recipeId;
  final String? transcript;

  TextProcessResult._({
    required this.isSuccess,
    this.message,
    this.recipeId,
    this.transcript,
  });

  factory TextProcessResult.success({
    String? recipeId,
    required String transcript,
  }) = TextProcessSuccess;
  
  factory TextProcessResult.failure({required String message}) = TextProcessFailure;
}

class TextProcessSuccess extends TextProcessResult {
  TextProcessSuccess({
    String? recipeId,
    required String transcript,
  }) : super._(
         isSuccess: true,
         recipeId: recipeId,
         transcript: transcript,
       );
}

class TextProcessFailure extends TextProcessResult {
  TextProcessFailure({required String message})
      : super._(isSuccess: false, message: message);
}