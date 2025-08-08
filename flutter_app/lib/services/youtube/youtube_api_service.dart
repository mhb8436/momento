import 'dart:convert';
import 'package:http/http.dart' as http;

class YouTubeApiService {
  // ⚠️ 보안 경고: API 키를 소스코드에 직접 넣지 마세요!
  // 프로덕션에서는 서버를 통해 API 호출하거나 환경변수 사용
  static const String _apiKey = ''; // 빈 문자열로 설정 (테스트용)
  static const String _baseUrl = 'https://www.googleapis.com/youtube/v3';

  /// Extract video ID from YouTube URL
  static String? extractVideoId(String url) {
    final regExp = RegExp(
      r'(?:youtube\.com\/watch\?v=|youtu\.be\/|youtube\.com\/embed\/|youtube\.com\/v\/)([^&\n?#]+)',
      caseSensitive: false,
    );

    final match = regExp.firstMatch(url);
    return match?.group(1);
  }

  /// Get video details including description
  static Future<YouTubeVideoResult> getVideoDetails(String videoId) async {
    try {
      final url = '$_baseUrl/videos?part=snippet&id=$videoId&key=$_apiKey';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        return YouTubeVideoResult.error(
            'YouTube API 요청 실패: ${response.statusCode}');
      }

      final data = json.decode(response.body);

      if (data['items'] == null || (data['items'] as List).isEmpty) {
        return YouTubeVideoResult.error('비디오를 찾을 수 없습니다.');
      }

      final video = data['items'][0];
      final snippet = video['snippet'];

      return YouTubeVideoResult.success(
        title: snippet['title'] ?? '',
        description: snippet['description'] ?? '',
        channelTitle: snippet['channelTitle'] ?? '',
        videoId: videoId,
      );
    } catch (e) {
      return YouTubeVideoResult.error('비디오 정보 추출 실패: ${e.toString()}');
    }
  }

  /// Get captions/subtitles for video (if available)
  static Future<YouTubeCaptionResult> getCaptions(String videoId) async {
    try {
      // First, get caption tracks
      final captionsListUrl =
          '$_baseUrl/captions?part=snippet&videoId=$videoId&key=$_apiKey';
      final captionsResponse = await http.get(Uri.parse(captionsListUrl));

      if (captionsResponse.statusCode != 200) {
        return YouTubeCaptionResult.error(
            '자막 목록 조회 실패: ${captionsResponse.statusCode}');
      }

      final captionsData = json.decode(captionsResponse.body);
      final captionsList = captionsData['items'] as List? ?? [];

      if (captionsList.isEmpty) {
        return YouTubeCaptionResult.error('자막이 없는 비디오입니다.');
      }

      // Find Korean or English captions
      Map<String, dynamic>? selectedCaption;

      // Try to find Korean captions first
      for (final caption in captionsList) {
        final language = caption['snippet']['language'];
        if (language == 'ko' || language == 'ko-KR') {
          selectedCaption = caption;
          break;
        }
      }

      // If no Korean, try English
      if (selectedCaption == null) {
        for (final caption in captionsList) {
          final language = caption['snippet']['language'];
          if (language == 'en' || language == 'en-US') {
            selectedCaption = caption;
            break;
          }
        }
      }

      // If still none, use first available
      selectedCaption ??= captionsList.first;

      final captionId = selectedCaption?['id'];

      // Note: 실제 자막 내용을 다운로드하려면 OAuth 인증이 필요합니다
      // 여기서는 자막 트랙 정보만 반환
      return YouTubeCaptionResult.success(
        captionId: captionId,
        language: selectedCaption?['snippet']['language'],
        name: selectedCaption?['snippet']['name'],
        // 실제 자막 텍스트는 OAuth 필요로 인해 현재는 빈 문자열
        text: '',
      );
    } catch (e) {
      return YouTubeCaptionResult.error('자막 추출 실패: ${e.toString()}');
    }
  }

  /// Extract recipe content from video description
  static String extractRecipeFromDescription(String description) {
    if (description.isEmpty) return '';

    final lines = description.split('\n');
    final StringBuffer recipeContent = StringBuffer();
    bool foundRecipeSection = false;

    for (final line in lines) {
      final trimmedLine = line.trim();
      if (trimmedLine.isEmpty) continue;

      // Look for recipe-related keywords
      if (trimmedLine.contains(RegExp(r'재료|ingredient|만드는|레시피|recipe|조리|요리',
          caseSensitive: false))) {
        foundRecipeSection = true;
        recipeContent.writeln(trimmedLine);
      }
      // Continue adding lines if we found recipe section
      else if (foundRecipeSection) {
        // Stop if we hit common video info sections
        if (trimmedLine.contains(RegExp(
            r'구독|subscribe|좋아요|like|댓글|comment|링크|link|음악|music|equipment',
            caseSensitive: false))) {
          break;
        }

        // Add lines that look like recipe content
        if (trimmedLine.length > 3) {
          recipeContent.writeln(trimmedLine);
        }
      }
      // Also look for measurement patterns (ingredients)
      else if (trimmedLine.contains(
          RegExp(r'\d+\s*(?:개|g|ml|컵|큰술|작은술|마리|kg|L)', caseSensitive: false))) {
        recipeContent.writeln(trimmedLine);
      }
    }

    return recipeContent.toString().trim();
  }

  /// Check if API key is configured
  static bool get isConfigured => _apiKey.isNotEmpty;

  /// Display warning about API key security
  static String get securityWarning => '⚠️ YouTube API 키가 설정되지 않았습니다.\n'
      '보안을 위해 서버를 통해 API를 호출하거나\n'
      '환경변수를 사용하여 API 키를 설정하세요.';
}

/// Result class for YouTube video data
class YouTubeVideoResult {
  final bool success;
  final String? title;
  final String? description;
  final String? channelTitle;
  final String? videoId;
  final String? error;

  YouTubeVideoResult._({
    required this.success,
    this.title,
    this.description,
    this.channelTitle,
    this.videoId,
    this.error,
  });

  factory YouTubeVideoResult.success({
    required String title,
    required String description,
    required String channelTitle,
    required String videoId,
  }) {
    return YouTubeVideoResult._(
      success: true,
      title: title,
      description: description,
      channelTitle: channelTitle,
      videoId: videoId,
    );
  }

  factory YouTubeVideoResult.error(String error) {
    return YouTubeVideoResult._(
      success: false,
      error: error,
    );
  }

  bool get hasContent => description != null && description!.isNotEmpty;
}

/// Result class for YouTube captions
class YouTubeCaptionResult {
  final bool success;
  final String? captionId;
  final String? language;
  final String? name;
  final String? text;
  final String? error;

  YouTubeCaptionResult._({
    required this.success,
    this.captionId,
    this.language,
    this.name,
    this.text,
    this.error,
  });

  factory YouTubeCaptionResult.success({
    required String captionId,
    required String language,
    required String name,
    required String text,
  }) {
    return YouTubeCaptionResult._(
      success: true,
      captionId: captionId,
      language: language,
      name: name,
      text: text,
    );
  }

  factory YouTubeCaptionResult.error(String error) {
    return YouTubeCaptionResult._(
      success: false,
      error: error,
    );
  }

  bool get hasText => text != null && text!.isNotEmpty;
}
