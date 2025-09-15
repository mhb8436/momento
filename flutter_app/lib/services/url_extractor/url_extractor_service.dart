import 'dart:convert';
import '../api/api_service.dart';
import '../storage/local_storage_service.dart';

class UrlExtractorService {
  static const Duration _timeout = Duration(seconds: 30);

  /// Extract recipe content from URL using server-side API
  static Future<UrlExtractionResult> extractFromUrl(String url) async {
    try {
      // Validate URL
      final uri = Uri.tryParse(url);
      if (uri == null || !uri.hasScheme) {
        return UrlExtractionResult.error('올바른 URL 형식이 아닙니다.');
      }

      // Get auth token
      final token = await LocalStorageService.getAccessToken();
      if (token == null) {
        return UrlExtractionResult.error('로그인이 필요합니다.');
      }

      // Call server API for secure processing
      final apiService = ApiService();
      final response = await apiService.post(
        '/url-extract/extract',
        data: {'url': url},
      );

      final responseData = response.data as Map<String, dynamic>;
      if (responseData['success'] == true) {
        return UrlExtractionResult.success(
          content: responseData['content'] ?? '',
          sourceUrl: url,
          siteType: responseData['site_type'] ?? 'Web',
          title: responseData['title'],
        );
      } else {
        return UrlExtractionResult.error(
          responseData['error'] ?? 'URL에서 콘텐츠를 추출할 수 없습니다.',
        );
      }
    } catch (e) {
      return UrlExtractionResult.error('추출 중 오류가 발생했습니다: ${e.toString()}');
    }
  }

  /// Check if URL is YouTube (for validation)
  static bool isYouTubeUrl(String url) {
    return url.contains('youtube.com') || url.contains('youtu.be');
  }

  /// Check if URL is a blog (for validation)
  static bool isBlogUrl(String url) {
    return url.contains('blog') ||
        url.contains('tistory') ||
        url.contains('naver.com/PostView') ||
        url.contains('velog.io');
  }

  /// Get YouTube video ID from URL (Shorts 포함)
  static String? getYouTubeVideoId(String url) {
    final regExp = RegExp(
      r'(?:youtube\.com\/watch\?v=|youtu\.be\/|youtube\.com\/embed\/|youtube\.com\/shorts\/)([^&\n?#]+)',
      caseSensitive: false,
    );

    final match = regExp.firstMatch(url);
    return match?.group(1);
  }

  /// Clean and format extracted content
  static String cleanContent(String content) {
    return content
        .replaceAll(RegExp(r'\s+'), ' ') // Multiple spaces to single space
        .replaceAll(RegExp(r'\n\s*\n'), '\n') // Multiple newlines to single
        .trim();
  }
}

/// Result class for URL extraction
class UrlExtractionResult {
  final bool success;
  final String? content;
  final String? error;
  final String? sourceUrl;
  final String? siteType;
  final String? title;

  UrlExtractionResult._({
    required this.success,
    this.content,
    this.error,
    this.sourceUrl,
    this.siteType,
    this.title,
  });

  factory UrlExtractionResult.success({
    required String content,
    required String sourceUrl,
    required String siteType,
    String? title,
  }) {
    return UrlExtractionResult._(
      success: true,
      content: content,
      sourceUrl: sourceUrl,
      siteType: siteType,
      title: title,
    );
  }

  factory UrlExtractionResult.error(String error) {
    return UrlExtractionResult._(
      success: false,
      error: error,
    );
  }

  bool get hasContent => content != null && content!.isNotEmpty;
}
