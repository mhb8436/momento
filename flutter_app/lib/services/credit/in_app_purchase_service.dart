import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import '../../models/credit.dart';
import 'credit_service.dart';

/// 인앱 결제 서비스
class InAppPurchaseService {
  static const List<String> _productIds = [
    'starter_10_credits',
    'family_30_credits', 
    'premium_100_credits',
    'monthly_subscription',
    'yearly_subscription',
  ];

  final InAppPurchase _inAppPurchase;
  final CreditService _creditService;
  
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  
  // 상품 정보 캐시
  List<ProductDetails> _products = [];
  
  // 구매 완료 콜백
  Function(PurchaseDetails)? _onPurchaseCompleted;
  Function(String)? _onPurchaseError;

  InAppPurchaseService({
    InAppPurchase? inAppPurchase,
    CreditService? creditService,
  })  : _inAppPurchase = inAppPurchase ?? InAppPurchase.instance,
        _creditService = creditService ?? CreditService();

  /// 초기화
  Future<bool> initialize() async {
    try {
      // 인앱 결제 사용 가능 여부 확인
      final available = await _inAppPurchase.isAvailable();
      if (!available) {
        debugPrint('인앱 결제가 사용 불가능합니다.');
        return false;
      }

      // iOS 설정
      if (Platform.isIOS) {
        final iosPlatformAddition = _inAppPurchase
            .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
        await iosPlatformAddition.setDelegate(PaymentQueueDelegate());
      }

      // 구매 이벤트 리스너 설정
      _subscription = _inAppPurchase.purchaseStream.listen(
        _onPurchaseUpdate,
        onDone: () => debugPrint('구매 스트림 완료'),
        onError: (error) => debugPrint('구매 스트림 오류: $error'),
      );

      // 상품 정보 로드
      await _loadProducts();

      // 미완료 구매 복원
      await _restorePurchases();

      debugPrint('인앱 결제 서비스 초기화 완료');
      return true;
    } catch (e) {
      debugPrint('인앱 결제 서비스 초기화 실패: $e');
      return false;
    }
  }

  /// 상품 정보 로드
  Future<void> _loadProducts() async {
    try {
      final ProductDetailsResponse response = await _inAppPurchase
          .queryProductDetails(_productIds.toSet());
      
      if (response.error != null) {
        debugPrint('상품 조회 오류: ${response.error}');
        return;
      }

      _products = response.productDetails;
      debugPrint('로드된 상품 수: ${_products.length}');
      
      for (final product in _products) {
        debugPrint('상품: ${product.id} - ${product.title} - ${product.price}');
      }
    } catch (e) {
      debugPrint('상품 로드 실패: $e');
    }
  }

  /// 상품 목록 조회
  List<ProductDetails> get products => List.unmodifiable(_products);

  /// 특정 상품 조회
  ProductDetails? getProduct(String productId) {
    try {
      return _products.firstWhere((product) => product.id == productId);
    } catch (e) {
      return null;
    }
  }

  /// 구매 시작
  Future<bool> buyProduct({
    required String productId,
    Function(PurchaseDetails)? onCompleted,
    Function(String)? onError,
  }) async {
    try {
      final product = getProduct(productId);
      if (product == null) {
        onError?.call('상품을 찾을 수 없습니다: $productId');
        return false;
      }

      _onPurchaseCompleted = onCompleted;
      _onPurchaseError = onError;

      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: product,
      );

      final bool success = await _inAppPurchase.buyNonConsumable(
        purchaseParam: purchaseParam,
      );

      if (!success) {
        onError?.call('구매를 시작할 수 없습니다.');
      }

      return success;
    } catch (e) {
      debugPrint('구매 시작 실패: $e');
      onError?.call('구매 중 오류가 발생했습니다.');
      return false;
    }
  }

  /// 구매 업데이트 처리
  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) async {
    for (final PurchaseDetails purchase in purchaseDetailsList) {
      debugPrint('구매 상태 업데이트: ${purchase.status} - ${purchase.productID}');
      
      switch (purchase.status) {
        case PurchaseStatus.pending:
          debugPrint('구매 대기 중: ${purchase.productID}');
          break;
          
        case PurchaseStatus.purchased:
          await _handlePurchaseSuccess(purchase);
          break;
          
        case PurchaseStatus.error:
          _handlePurchaseError(purchase);
          break;
          
        case PurchaseStatus.restored:
          await _handlePurchaseRestored(purchase);
          break;
          
        case PurchaseStatus.canceled:
          debugPrint('구매 취소됨: ${purchase.productID}');
          _onPurchaseError?.call('구매가 취소되었습니다.');
          break;
      }

      // 구매 완료 처리
      if (purchase.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(purchase);
      }
    }
  }

  /// 구매 성공 처리
  Future<void> _handlePurchaseSuccess(PurchaseDetails purchase) async {
    try {
      debugPrint('구매 성공: ${purchase.productID}');
      
      // 서버에서 결제 검증
      final verification = await _creditService.verifyPurchase(
        packageType: purchase.productID,
        transactionId: purchase.purchaseID ?? '',
        receiptData: _getReceiptData(purchase),
      );

      if (verification?.success == true) {
        debugPrint('결제 검증 성공: ${verification!.creditsAdded}크레딧 추가');
        _onPurchaseCompleted?.call(purchase);
      } else {
        debugPrint('결제 검증 실패: ${verification?.message}');
        _onPurchaseError?.call(verification?.message ?? '결제 검증에 실패했습니다.');
      }
    } catch (e) {
      debugPrint('구매 성공 처리 실패: $e');
      _onPurchaseError?.call('구매 처리 중 오류가 발생했습니다.');
    }
  }

  /// 구매 오류 처리
  void _handlePurchaseError(PurchaseDetails purchase) {
    final error = purchase.error;
    debugPrint('구매 오류: ${error?.code} - ${error?.message}');
    
    String errorMessage = '구매 중 오류가 발생했습니다.';
    
    if (error != null) {
      switch (error.code) {
        case 'user_canceled':
          errorMessage = '구매가 취소되었습니다.';
          break;
        case 'payment_invalid':
          errorMessage = '결제 정보가 올바르지 않습니다.';
          break;
        case 'payment_not_allowed':
          errorMessage = '결제가 허용되지 않습니다.';
          break;
        default:
          errorMessage = error.message;
      }
    }
    
    _onPurchaseError?.call(errorMessage);
  }

  /// 구매 복원 처리
  Future<void> _handlePurchaseRestored(PurchaseDetails purchase) async {
    debugPrint('구매 복원됨: ${purchase.productID}');
    // 구독의 경우 복원 처리가 필요할 수 있음
  }

  /// 영수증 데이터 추출
  String _getReceiptData(PurchaseDetails purchase) {
    if (Platform.isIOS) {
      // iOS: 전체 영수증 데이터
      return purchase.verificationData.serverVerificationData;
    } else {
      // Android: 구매 토큰 + 주문 ID
      final Map<String, dynamic> receiptData = {
        'purchaseToken': purchase.verificationData.serverVerificationData,
        'orderId': purchase.purchaseID,
        'productId': purchase.productID,
      };
      return jsonEncode(receiptData);
    }
  }

  /// 구매 복원
  Future<void> restorePurchases() async {
    try {
      await _inAppPurchase.restorePurchases();
      debugPrint('구매 복원 요청 완료');
    } catch (e) {
      debugPrint('구매 복원 실패: $e');
    }
  }

  /// 미완료 구매 복원
  Future<void> _restorePurchases() async {
    if (Platform.isIOS) {
      // iOS에서만 자동 복원
      await restorePurchases();
    }
  }

  /// 리소스 정리
  Future<void> dispose() async {
    await _subscription.cancel();
  }
}

/// iOS 결제 대기열 델리게이트
class PaymentQueueDelegate implements SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(
    SKPaymentTransactionWrapper transaction,
    SKStorefrontWrapper storefront,
  ) {
    return true;
  }

  @override
  bool shouldShowPriceConsent() {
    return false;
  }
}