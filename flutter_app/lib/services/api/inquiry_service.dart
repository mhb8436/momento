import 'package:dio/dio.dart';
import '../../config/app_config.dart';
import '../../models/inquiry.dart';
import '../../services/storage/local_storage_service.dart';

class InquiryService {
  final Dio _dio;

  InquiryService(this._dio);

  /// 인증 헤더를 포함한 옵션 생성
  Future<Options> _getAuthOptions() async {
    final token = LocalStorageService.getAccessToken();
    return Options(
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
  }

  /// 문의사항 목록 조회
  Future<List<InquiryListItem>> getInquiries({
    String? status,
    String? category,
    int skip = 0,
    int limit = 20,
  }) async {
    try {
      final options = await _getAuthOptions();
      
      final queryParams = <String, dynamic>{
        'skip': skip,
        'limit': limit,
      };
      
      if (status != null) queryParams['status_filter'] = status;
      if (category != null) queryParams['category_filter'] = category;

      final response = await _dio.get(
        '${AppConfig.baseUrl}/inquiries/',
        queryParameters: queryParams,
        options: options,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => InquiryListItem.fromJson(json)).toList();
      } else {
        throw Exception('문의사항 목록을 불러오는데 실패했습니다');
      }
    } on DioException catch (e) {
      print('❌ InquiryService.getInquiries error: ${e.message}');
      if (e.response?.statusCode == 401) {
        throw Exception('인증이 필요합니다');
      }
      throw Exception('문의사항 목록을 불러오는데 실패했습니다: ${e.message}');
    } catch (e) {
      print('❌ InquiryService.getInquiries unexpected error: $e');
      throw Exception('예상치 못한 오류가 발생했습니다: $e');
    }
  }

  /// 문의사항 상세 조회
  Future<Inquiry> getInquiry(String inquiryId) async {
    try {
      final options = await _getAuthOptions();

      final response = await _dio.get(
        '${AppConfig.baseUrl}/inquiries/$inquiryId',
        options: options,
      );

      if (response.statusCode == 200) {
        return Inquiry.fromJson(response.data);
      } else {
        throw Exception('문의사항을 불러오는데 실패했습니다');
      }
    } on DioException catch (e) {
      print('❌ InquiryService.getInquiry error: ${e.message}');
      if (e.response?.statusCode == 401) {
        throw Exception('인증이 필요합니다');
      } else if (e.response?.statusCode == 404) {
        throw Exception('문의사항을 찾을 수 없습니다');
      }
      throw Exception('문의사항을 불러오는데 실패했습니다: ${e.message}');
    } catch (e) {
      print('❌ InquiryService.getInquiry unexpected error: $e');
      throw Exception('예상치 못한 오류가 발생했습니다: $e');
    }
  }

  /// 문의사항 통계 조회
  Future<InquiryStats> getInquiryStats() async {
    try {
      final options = await _getAuthOptions();

      final response = await _dio.get(
        '${AppConfig.baseUrl}/inquiries/stats',
        options: options,
      );

      if (response.statusCode == 200) {
        return InquiryStats.fromJson(response.data);
      } else {
        throw Exception('문의사항 통계를 불러오는데 실패했습니다');
      }
    } on DioException catch (e) {
      print('❌ InquiryService.getInquiryStats error: ${e.message}');
      if (e.response?.statusCode == 401) {
        throw Exception('인증이 필요합니다');
      }
      throw Exception('문의사항 통계를 불러오는데 실패했습니다: ${e.message}');
    } catch (e) {
      print('❌ InquiryService.getInquiryStats unexpected error: $e');
      throw Exception('예상치 못한 오류가 발생했습니다: $e');
    }
  }

  /// 문의사항 작성
  Future<Inquiry> createInquiry(InquiryCreateRequest request) async {
    try {
      final options = await _getAuthOptions();

      final response = await _dio.post(
        '${AppConfig.baseUrl}/inquiries/',
        data: request.toJson(),
        options: options,
      );

      if (response.statusCode == 200) {
        return Inquiry.fromJson(response.data);
      } else {
        throw Exception('문의사항 작성에 실패했습니다');
      }
    } on DioException catch (e) {
      print('❌ InquiryService.createInquiry error: ${e.message}');
      if (e.response?.statusCode == 401) {
        throw Exception('인증이 필요합니다');
      } else if (e.response?.statusCode == 400) {
        throw Exception('입력 정보가 올바르지 않습니다');
      }
      throw Exception('문의사항 작성에 실패했습니다: ${e.message}');
    } catch (e) {
      print('❌ InquiryService.createInquiry unexpected error: $e');
      throw Exception('예상치 못한 오류가 발생했습니다: $e');
    }
  }

  /// 문의사항 수정
  Future<Inquiry> updateInquiry(String inquiryId, InquiryUpdateRequest request) async {
    try {
      final options = await _getAuthOptions();

      final response = await _dio.put(
        '${AppConfig.baseUrl}/inquiries/$inquiryId',
        data: request.toJson(),
        options: options,
      );

      if (response.statusCode == 200) {
        return Inquiry.fromJson(response.data);
      } else {
        throw Exception('문의사항 수정에 실패했습니다');
      }
    } on DioException catch (e) {
      print('❌ InquiryService.updateInquiry error: ${e.message}');
      if (e.response?.statusCode == 401) {
        throw Exception('인증이 필요합니다');
      } else if (e.response?.statusCode == 404) {
        throw Exception('문의사항을 찾을 수 없습니다');
      } else if (e.response?.statusCode == 400) {
        throw Exception('답변이 완료된 문의사항은 수정할 수 없습니다');
      }
      throw Exception('문의사항 수정에 실패했습니다: ${e.message}');
    } catch (e) {
      print('❌ InquiryService.updateInquiry unexpected error: $e');
      throw Exception('예상치 못한 오류가 발생했습니다: $e');
    }
  }

  /// 문의사항 삭제
  Future<void> deleteInquiry(String inquiryId) async {
    try {
      final options = await _getAuthOptions();

      final response = await _dio.delete(
        '${AppConfig.baseUrl}/inquiries/$inquiryId',
        options: options,
      );

      if (response.statusCode != 200) {
        throw Exception('문의사항 삭제에 실패했습니다');
      }
    } on DioException catch (e) {
      print('❌ InquiryService.deleteInquiry error: ${e.message}');
      if (e.response?.statusCode == 401) {
        throw Exception('인증이 필요합니다');
      } else if (e.response?.statusCode == 404) {
        throw Exception('문의사항을 찾을 수 없습니다');
      } else if (e.response?.statusCode == 400) {
        throw Exception('답변이 완료된 문의사항은 삭제할 수 없습니다');
      }
      throw Exception('문의사항 삭제에 실패했습니다: ${e.message}');
    } catch (e) {
      print('❌ InquiryService.deleteInquiry unexpected error: $e');
      throw Exception('예상치 못한 오류가 발생했습니다: $e');
    }
  }
}