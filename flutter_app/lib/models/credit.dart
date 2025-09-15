import 'package:json_annotation/json_annotation.dart';

part 'credit.g.dart';

/// 크레딧 잔액 정보
@JsonSerializable()
class CreditBalance {
  final int balance;
  @JsonKey(name: 'free_daily_used')
  final int freeDailyUsed;
  @JsonKey(name: 'free_daily_limit')
  final int freeDailyLimit;
  @JsonKey(name: 'has_auto_recharge')
  final bool hasAutoRecharge;
  @JsonKey(name: 'auto_recharge_expires_at')
  final DateTime? autoRechargeExpiresAt;
  @JsonKey(name: 'total_purchased')
  final int totalPurchased;
  @JsonKey(name: 'total_used')
  final int totalUsed;
  
  // 백엔드에서 내려주는 설정 정보 (하드코딩 제거)
  @JsonKey(name: 'daily_free_credits')
  final int dailyFreeCredits;
  @JsonKey(name: 'initial_free_credits')
  final int initialFreeCredits;
  @JsonKey(name: 'recipe_generation_cost')
  final int recipeGenerationCost;
  @JsonKey(name: 'recipe_improvement_cost')
  final int recipeImprovementCost;

  CreditBalance({
    required this.balance,
    required this.freeDailyUsed,
    required this.freeDailyLimit,
    required this.hasAutoRecharge,
    this.autoRechargeExpiresAt,
    required this.totalPurchased,
    required this.totalUsed,
    required this.dailyFreeCredits,
    required this.initialFreeCredits,
    required this.recipeGenerationCost,
    required this.recipeImprovementCost,
  });

  factory CreditBalance.fromJson(Map<String, dynamic> json) =>
      _$CreditBalanceFromJson(json);

  Map<String, dynamic> toJson() => _$CreditBalanceToJson(this);

  /// 사용 가능한 크레딧이 있는지 확인
  bool get hasCredits => balance > 0 || hasFreeCreditLeft;

  /// 무료 크레딧이 남아있는지 확인
  bool get hasFreeCreditLeft => freeDailyUsed < freeDailyLimit;

  /// 오늘 남은 무료 크레딧
  int get remainingFreeCredits => freeDailyLimit - freeDailyUsed;
}

/// 크레딧 패키지 정보
@JsonSerializable()
class CreditPackage {
  @JsonKey(name: 'package_type')
  final String packageType;
  final String name;
  @JsonKey(name: 'credits_amount')
  final int creditsAmount;
  @JsonKey(name: 'price_krw')
  final double priceKrw;
  @JsonKey(name: 'discount_percentage')
  final int discountPercentage;
  final String? description;
  @JsonKey(name: 'is_recommended')
  final bool isRecommended;
  @JsonKey(name: 'sort_order')
  final int sortOrder;
  @JsonKey(name: 'is_active')
  final bool isActive;

  CreditPackage({
    required this.packageType,
    required this.name,
    required this.creditsAmount,
    required this.priceKrw,
    required this.discountPercentage,
    this.description,
    required this.isRecommended,
    this.sortOrder = 0,
    this.isActive = true,
  });

  factory CreditPackage.fromJson(Map<String, dynamic> json) =>
      _$CreditPackageFromJson(json);

  Map<String, dynamic> toJson() => _$CreditPackageToJson(this);

  /// 크레딧당 가격 계산
  double get pricePerCredit => priceKrw / creditsAmount;

  /// 포맷된 가격 문자열
  String get formattedPrice => '₩${priceKrw.toInt().toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      )}';

  /// 할인이 있는지 확인
  bool get hasDiscount => discountPercentage > 0;
}

/// 결제 히스토리
@JsonSerializable()
class PaymentHistory {
  final String id;
  @JsonKey(name: 'package_type')
  final String packageType;
  @JsonKey(name: 'credits_amount')
  final int creditsAmount;
  @JsonKey(name: 'price_paid')
  final double pricePaid;
  final String platform;
  final String status;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'verified_at')
  final DateTime? verifiedAt;

  PaymentHistory({
    required this.id,
    required this.packageType,
    required this.creditsAmount,
    required this.pricePaid,
    required this.platform,
    required this.status,
    required this.createdAt,
    this.verifiedAt,
  });

  factory PaymentHistory.fromJson(Map<String, dynamic> json) =>
      _$PaymentHistoryFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentHistoryToJson(this);

  /// 결제 상태가 성공인지 확인
  bool get isVerified => status == 'verified';

  /// 포맷된 날짜 문자열
  String get formattedDate => '${createdAt.year}.${createdAt.month.toString().padLeft(2, '0')}.${createdAt.day.toString().padLeft(2, '0')}';
}

/// 사용량 통계
@JsonSerializable()
class UsageStats {
  @JsonKey(name: 'current_month_usage')
  final int currentMonthUsage;
  @JsonKey(name: 'current_month_free')
  final int currentMonthFree;
  @JsonKey(name: 'last_30_days_usage')
  final int last30DaysUsage;
  @JsonKey(name: 'total_recipes_created')
  final int totalRecipesCreated;
  @JsonKey(name: 'recent_usage')
  final List<ApiUsageLog> recentUsage;

  UsageStats({
    required this.currentMonthUsage,
    required this.currentMonthFree,
    required this.last30DaysUsage,
    required this.totalRecipesCreated,
    required this.recentUsage,
  });

  factory UsageStats.fromJson(Map<String, dynamic> json) =>
      _$UsageStatsFromJson(json);

  Map<String, dynamic> toJson() => _$UsageStatsToJson(this);
}

/// API 사용 로그
@JsonSerializable()
class ApiUsageLog {
  final String id;
  @JsonKey(name: 'api_type')
  final String apiType;
  @JsonKey(name: 'credits_used')
  final int creditsUsed;
  @JsonKey(name: 'is_free_tier')
  final bool isFreeTier;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  ApiUsageLog({
    required this.id,
    required this.apiType,
    required this.creditsUsed,
    required this.isFreeTier,
    required this.createdAt,
  });

  factory ApiUsageLog.fromJson(Map<String, dynamic> json) =>
      _$ApiUsageLogFromJson(json);

  Map<String, dynamic> toJson() => _$ApiUsageLogToJson(this);

  /// API 타입을 한국어로 변환
  String get apiTypeKorean {
    switch (apiType) {
      case 'recipe_generation':
        return '레시피 생성';
      case 'recipe_improvement':
        return '레시피 개선';
      default:
        return apiType;
    }
  }

  /// 포맷된 시간 문자열
  String get formattedTime => '${createdAt.month}/${createdAt.day} ${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
}

/// 결제 요청 데이터
@JsonSerializable()
class PurchaseRequest {
  @JsonKey(name: 'package_type')
  final String packageType;
  final String platform;
  @JsonKey(name: 'transaction_id')
  final String transactionId;
  @JsonKey(name: 'receipt_data')
  final String receiptData;

  PurchaseRequest({
    required this.packageType,
    required this.platform,
    required this.transactionId,
    required this.receiptData,
  });

  factory PurchaseRequest.fromJson(Map<String, dynamic> json) =>
      _$PurchaseRequestFromJson(json);

  Map<String, dynamic> toJson() => _$PurchaseRequestToJson(this);
}

/// 결제 검증 응답
@JsonSerializable()
class PurchaseVerificationResponse {
  final bool success;
  @JsonKey(name: 'credits_added')
  final int creditsAdded;
  @JsonKey(name: 'new_balance')
  final int newBalance;
  final String message;

  PurchaseVerificationResponse({
    required this.success,
    required this.creditsAdded,
    required this.newBalance,
    required this.message,
  });

  factory PurchaseVerificationResponse.fromJson(Map<String, dynamic> json) =>
      _$PurchaseVerificationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PurchaseVerificationResponseToJson(this);
}

/// 크레딧 관련 상수 (더 이상 하드코딩이 아닌 백엔드에서 동적으로 가져옴)
class CreditConstants {
  // 이제 CreditBalance 객체에서 백엔드 설정을 가져온다
  // static const int initialFreeCredits = 5; // 제거됨
  // static const int dailyFreeCredits = 2; // 제거됨  
  // static const int recipeGenerationCost = 1; // 제거됨
  // static const int recipeImprovementCost = 1; // 제거됨

  // 패키지 타입 (크레딧 전용 모델)
  static const String starterPackage = 'starter_10_credits';
  static const String familyPackage = 'family_30_credits';
  static const String premiumPackage = 'premium_100_credits';
  static const String monthlyAutoRecharge = 'monthly_auto_recharge_50';
  static const String yearlyAutoRecharge = 'yearly_auto_recharge_100';
}