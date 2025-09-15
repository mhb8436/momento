import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../config/app_config.dart';
import '../../models/credit.dart';
import '../storage/local_storage_service.dart';

/// 크레딧 관련 API 서비스
class CreditService {
  final Dio _dio;

  CreditService({Dio? dio})
      : _dio = dio ?? Dio() {
    _setupDio();
  }

  void _setupDio() {
    _dio.options.baseUrl = AppConfig.baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);

    // 요청 인터셉터 - 토큰 자동 추가
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = LocalStorageService.getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          debugPrint('CreditService Error: ${error.message}');
          handler.next(error);
        },
      ),
    );
  }

  /// 크레딧 잔액 조회
  Future<CreditBalance?> getCreditBalance() async {
    try {
      final response = await _dio.get('/credits/balance');
      if (response.statusCode == 200) {
        return CreditBalance.fromJson(response.data);
      }
    } catch (e) {
      debugPrint('크레딧 잔액 조회 실패: $e');
    }
    return null;
  }

  /// 크레딧 패키지 목록 조회
  Future<List<CreditPackage>> getCreditPackages() async {
    try {
      final response = await _dio.get('/credits/packages');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => CreditPackage.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('크레딧 패키지 조회 실패: $e');
    }
    return [];
  }

  /// 결제 검증
  Future<PurchaseVerificationResponse?> verifyPurchase({
    required String packageType,
    required String transactionId,
    required String receiptData,
  }) async {
    try {
      final platform = Platform.isIOS ? 'ios' : 'android';
      
      final purchaseRequest = PurchaseRequest(
        packageType: packageType,
        platform: platform,
        transactionId: transactionId,
        receiptData: receiptData,
      );

      final response = await _dio.post(
        '/credits/purchase/verify',
        data: purchaseRequest.toJson(),
      );

      if (response.statusCode == 200) {
        return PurchaseVerificationResponse.fromJson(response.data);
      }
    } catch (e) {
      debugPrint('결제 검증 실패: $e');
    }
    return null;
  }

  /// 결제 히스토리 조회
  Future<List<PaymentHistory>> getPaymentHistory() async {
    try {
      final response = await _dio.get('/credits/history');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => PaymentHistory.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('결제 히스토리 조회 실패: $e');
    }
    return [];
  }

  /// 사용량 통계 조회
  Future<UsageStats?> getUsageStats() async {
    try {
      final response = await _dio.get('/credits/usage-stats');
      if (response.statusCode == 200) {
        return UsageStats.fromJson(response.data);
      }
    } catch (e) {
      debugPrint('사용량 통계 조회 실패: $e');
    }
    return null;
  }

  /// 크레딧 부족 여부 확인
  Future<bool> checkCreditAvailability() async {
    final balance = await getCreditBalance();
    return balance?.hasCredits ?? false;
  }

  /// 테스트용 크레딧 차감 (개발/테스트용)
  Future<Map<String, dynamic>?> testCreditDeduction() async {
    try {
      final response = await _dio.post('/credits/test-deduct');
      if (response.statusCode == 200) {
        return response.data;
      }
    } catch (e) {
      debugPrint('테스트 크레딧 차감 실패: $e');
    }
    return null;
  }

  /// 사용량 통계 조회 (캐시된 버전)
  Future<UsageStats?> getUsageStatsWithCache() async {
    try {
      final response = await _dio.get('/credits/usage/stats');
      if (response.statusCode == 200) {
        return UsageStats.fromJson(response.data);
      }
    } catch (e) {
      debugPrint('사용량 통계 조회 실패: $e');
    }
    return null;
  }

  /// 에러 메시지 한국어 변환 (확장)
  String getErrorMessage(DioException error) {
    switch (error.response?.statusCode) {
      case 400:
        return '잘못된 요청입니다. 입력 정보를 확인해주세요.';
      case 401:
        return '로그인이 필요합니다.';
      case 402:
        return '크레딧이 부족합니다. 크레딧을 구매해주세요.';
      case 403:
        return '권한이 없습니다.';
      case 404:
        return '요청한 정보를 찾을 수 없습니다.';
      case 409:
        return '이미 처리된 요청입니다.';
      case 429:
        return '너무 많은 요청입니다. 잠시 후 다시 시도해주세요.';
      case 500:
        return '서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.';
      case 503:
        return '서비스가 일시적으로 이용할 수 없습니다.';
      default:
        if (error.type == DioExceptionType.connectionTimeout) {
          return '연결 시간이 초과되었습니다. 네트워크를 확인해주세요.';
        } else if (error.type == DioExceptionType.receiveTimeout) {
          return '응답 시간이 초과되었습니다. 다시 시도해주세요.';
        } else if (error.type == DioExceptionType.cancel) {
          return '요청이 취소되었습니다.';
        } else if (error.type == DioExceptionType.unknown) {
          return '네트워크 연결을 확인해주세요.';
        }
        return '오류가 발생했습니다. 잠시 후 다시 시도해주세요.';
    }
  }

  /// 크레딧 관련 알림 메시지 생성
  String getCreditNotificationMessage(int creditsUsed, bool usedFreeTier) {
    if (usedFreeTier) {
      return '무료 크레딧 ${creditsUsed}개를 사용하여 레시피를 생성했습니다.';
    } else {
      return '크레딧 ${creditsUsed}개를 사용하여 레시피를 생성했습니다.';
    }
  }
}