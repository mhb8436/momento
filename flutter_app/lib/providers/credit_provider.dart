import 'package:flutter/foundation.dart';
import '../models/credit.dart';
import '../services/credit/credit_service.dart';
import '../services/credit/in_app_purchase_service.dart';

/// 크레딧 시스템 상태 관리
class CreditProvider with ChangeNotifier {
  final CreditService _creditService;
  final InAppPurchaseService _purchaseService;

  // 상태 변수들
  CreditBalance? _creditBalance;
  List<CreditPackage> _packages = [];
  List<PaymentHistory> _paymentHistory = [];
  UsageStats? _usageStats;
  
  bool _isLoading = false;
  bool _isPurchasing = false;
  String? _errorMessage;

  CreditProvider({
    CreditService? creditService,
    InAppPurchaseService? purchaseService,
  })  : _creditService = creditService ?? CreditService(),
        _purchaseService = purchaseService ?? InAppPurchaseService();

  // Getters
  CreditBalance? get creditBalance => _creditBalance;
  List<CreditPackage> get packages => _packages;
  List<PaymentHistory> get paymentHistory => _paymentHistory;
  UsageStats? get usageStats => _usageStats;
  bool get isLoading => _isLoading;
  bool get isPurchasing => _isPurchasing;
  String? get errorMessage => _errorMessage;

  /// 편의 getters
  int get currentBalance => _creditBalance?.balance ?? 0;
  bool get hasCredits => _creditBalance?.hasCredits ?? false;
  bool get hasAutoRecharge => _creditBalance?.hasAutoRecharge ?? false;
  int get remainingFreeCredits => _creditBalance?.remainingFreeCredits ?? 0;

  /// 초기화
  Future<bool> initialize() async {
    _setLoading(true);
    _clearError();

    try {
      // 인앱 결제 서비스 초기화
      final purchaseInitialized = await _purchaseService.initialize();
      if (!purchaseInitialized) {
        _setError('인앱 결제를 사용할 수 없습니다.');
        return false;
      }

      // 크레딧 정보 로드
      await _loadAllData();
      
      debugPrint('크레딧 시스템 초기화 완료');
      return true;
    } catch (e) {
      _setError('초기화 중 오류가 발생했습니다: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 모든 데이터 로드
  Future<void> _loadAllData() async {
    await Future.wait([
      loadCreditBalance(),
      loadPackages(),
      loadPaymentHistory(),
      loadUsageStats(),
    ]);
  }

  /// 크레딧 잔액 로드
  Future<void> loadCreditBalance() async {
    try {
      final balance = await _creditService.getCreditBalance();
      _creditBalance = balance;
      notifyListeners();
    } catch (e) {
      debugPrint('크레딧 잔액 로드 실패: $e');
    }
  }

  /// 패키지 목록 로드
  Future<void> loadPackages() async {
    try {
      final packages = await _creditService.getCreditPackages();
      _packages = packages;
      notifyListeners();
    } catch (e) {
      debugPrint('패키지 로드 실패: $e');
    }
  }

  /// 결제 히스토리 로드
  Future<void> loadPaymentHistory() async {
    try {
      final history = await _creditService.getPaymentHistory();
      _paymentHistory = history;
      notifyListeners();
    } catch (e) {
      debugPrint('결제 히스토리 로드 실패: $e');
    }
  }

  /// 사용량 통계 로드
  Future<void> loadUsageStats() async {
    try {
      final stats = await _creditService.getUsageStats();
      _usageStats = stats;
      notifyListeners();
    } catch (e) {
      debugPrint('사용량 통계 로드 실패: $e');
    }
  }

  /// 크레딧 패키지 구매
  Future<bool> purchasePackage(String packageType) async {
    if (_isPurchasing) return false;

    _setPurchasing(true);
    _clearError();

    try {
      final success = await _purchaseService.buyProduct(
        productId: packageType,
        onCompleted: (purchase) async {
          // 구매 완료 후 크레딧 잔액 새로고침
          await loadCreditBalance();
          await loadPaymentHistory();
          _setPurchasing(false);
          _setError(null);
        },
        onError: (error) {
          _setError(error);
          _setPurchasing(false);
        },
      );

      if (!success) {
        _setError('구매를 시작할 수 없습니다.');
        _setPurchasing(false);
      }

      return success;
    } catch (e) {
      _setError('구매 중 오류가 발생했습니다: $e');
      _setPurchasing(false);
      return false;
    }
  }

  /// 구매 복원
  Future<void> restorePurchases() async {
    _setLoading(true);
    _clearError();

    try {
      await _purchaseService.restorePurchases();
      await loadCreditBalance();
      await loadPaymentHistory();
    } catch (e) {
      _setError('구매 복원 중 오류가 발생했습니다: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 데이터 새로고침
  Future<void> refresh() async {
    _setLoading(true);
    _clearError();

    try {
      await _loadAllData();
    } catch (e) {
      _setError('새로고침 중 오류가 발생했습니다: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 크레딧 사용 가능 여부 확인
  bool canUseCredit() {
    return hasCredits;
  }

  /// 크레딧 부족 시 구매 안내
  String getCreditSuggestion() {
    if (remainingFreeCredits > 0) {
      return '무료 크레딧 ${remainingFreeCredits}개가 남아있습니다.';
    } else if (currentBalance == 0) {
      return '크레딧을 구매하여 더 많은 레시피를 생성하세요!';
    } else {
      return '현재 ${currentBalance}개의 크레딧이 있습니다.';
    }
  }

  /// 추천 패키지 조회
  CreditPackage? get recommendedPackage {
    try {
      return _packages.firstWhere((package) => package.isRecommended);
    } catch (e) {
      return _packages.isNotEmpty ? _packages[1] : null; // 두 번째 패키지를 기본 추천
    }
  }

  /// 가장 저렴한 패키지 조회
  CreditPackage? get cheapestPackage {
    if (_packages.isEmpty) return null;
    
    return _packages.reduce((a, b) => 
        a.priceKrw < b.priceKrw ? a : b);
  }

  /// 가장 가성비 좋은 패키지 조회
  CreditPackage? get bestValuePackage {
    if (_packages.isEmpty) return null;
    
    return _packages.reduce((a, b) => 
        a.pricePerCredit < b.pricePerCredit ? a : b);
  }

  /// 테스트용 크레딧 차감
  Future<bool> testCreditDeduction() async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _creditService.testCreditDeduction();
      if (result != null && result['success'] == true) {
        // 크레딧 잔액 새로고침
        await loadCreditBalance();
        return true;
      } else {
        _setError(result?['message'] ?? '테스트 크레딧 차감 실패');
        return false;
      }
    } catch (e) {
      _setError('테스트 크레딧 차감 중 오류: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 활성화된 패키지만 필터링
  List<CreditPackage> get activePackages {
    return _packages.where((package) => package.isActive).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  /// 구독 관련 정보
  String get subscriptionStatus {
    if (!hasAutoRecharge) return '자동충전 비활성화';
    
    final expiresAt = _creditBalance?.autoRechargeExpiresAt;
    if (expiresAt == null) return '자동충전 활성화 (만료일 없음)';
    
    final now = DateTime.now();
    final daysLeft = expiresAt.difference(now).inDays;
    
    if (daysLeft < 0) return '자동충전 만료됨';
    if (daysLeft == 0) return '오늘 만료';
    if (daysLeft <= 7) return '${daysLeft}일 후 만료';
    
    return '자동충전 활성화 (${expiresAt.month}/${expiresAt.day}까지)';
  }

  /// 크레딧 사용 후 알림 메시지 생성
  String getCreditUsageMessage(int creditsUsed, bool usedFreeTier) {
    return _creditService.getCreditNotificationMessage(creditsUsed, usedFreeTier);
  }

  /// 레시피 생성을 위한 크레딧 사용 가능 여부 확인
  Future<bool> canUseCreditsForRecipe() async {
    try {
      // 크레딧 잔액 새로고침
      await initialize();
      
      // 무료 크레딧이 있거나 구매한 크레딧이 있으면 사용 가능
      return hasCredits;
    } catch (e) {
      _setError('크레딧 확인 중 오류가 발생했습니다: $e');
      return false;
    }
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setPurchasing(bool purchasing) {
    _isPurchasing = purchasing;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  @override
  void dispose() {
    _purchaseService.dispose();
    super.dispose();
  }
}