import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'lib/services/credit/credit_service.dart';
import 'lib/services/credit/in_app_purchase_service.dart';
import 'lib/providers/credit_provider.dart';
import 'lib/models/credit.dart';

// Mock 클래스 생성을 위한 어노테이션
@GenerateMocks([CreditService, InAppPurchaseService])
import 'test_credit_system.mocks.dart';

void main() {
  group('Credit System Tests', () {
    late CreditProvider creditProvider;
    late MockCreditService mockCreditService;
    late MockInAppPurchaseService mockInAppPurchaseService;

    setUp(() {
      mockCreditService = MockCreditService();
      mockInAppPurchaseService = MockInAppPurchaseService();
      creditProvider = CreditProvider(
        creditService: mockCreditService,
        purchaseService: mockInAppPurchaseService,
      );
    });

    test('초기 크레딧 잔액 로드 테스트', () async {
      // Mock 데이터 준비
      final mockBalance = CreditBalance(
        balance: 5,
        freeMonthlyUsed: 0,
        subscriptionActiveUntil: null,
      );

      // Mock 서비스 응답 설정
      when(mockCreditService.getCreditBalance())
          .thenAnswer((_) async => mockBalance);

      // 테스트 실행
      await creditProvider.loadCreditBalance();

      // 검증
      expect(creditProvider.creditBalance?.balance, equals(5));
      expect(creditProvider.hasCredits, isTrue);
      verify(mockCreditService.getCreditBalance()).called(1);
    });

    test('크레딧 패키지 로드 테스트', () async {
      // Mock 패키지 데이터
      final mockPackages = [
        CreditPackage(
          packageType: 'starter_10_credits',
          name: '시작 패키지',
          creditsAmount: 10,
          priceKrw: 1100,
          description: '10개 크레딧',
          isRecommended: false,
        ),
        CreditPackage(
          packageType: 'family_30_credits',
          name: '가족 패키지',
          creditsAmount: 30,
          priceKrw: 3300,
          description: '30개 크레딧',
          isRecommended: true,
        ),
      ];

      when(mockCreditService.getCreditPackages())
          .thenAnswer((_) async => mockPackages);

      await creditProvider.loadPackages();

      expect(creditProvider.packages.length, equals(2));
      expect(creditProvider.recommendedPackage?.packageType, equals('family_30_credits'));
    });

    test('인앱 구매 성공 시나리오 테스트', () async {
      // 구매 성공 시뮬레이션
      when(mockInAppPurchaseService.buyProduct(
        productId: 'starter_10_credits',
        onCompleted: anyNamed('onCompleted'),
        onError: anyNamed('onError'),
      )).thenAnswer((_) async => true);

      final result = await creditProvider.purchasePackage('starter_10_credits');

      expect(result, isTrue);
      expect(creditProvider.isPurchasing, isFalse);
    });

    test('크레딧 사용 가능 여부 확인 테스트', () {
      // 크레딧이 있는 경우
      creditProvider.creditBalance = CreditBalance(
        balance: 10,
        freeMonthlyUsed: 2,
        subscriptionActiveUntil: null,
      );

      expect(creditProvider.canUseCredit(), isTrue);

      // 크레딧이 없는 경우
      creditProvider.creditBalance = CreditBalance(
        balance: 0,
        freeMonthlyUsed: 3,
        subscriptionActiveUntil: null,
      );

      expect(creditProvider.canUseCredit(), isFalse);
    });

    test('구독자 무제한 크레딧 테스트', () {
      // 구독 활성화 상태
      final futureDate = DateTime.now().add(Duration(days: 30));
      creditProvider.creditBalance = CreditBalance(
        balance: 0,
        freeMonthlyUsed: 3,
        subscriptionActiveUntil: futureDate,
      );

      expect(creditProvider.isSubscriber, isTrue);
      expect(creditProvider.canUseCredit(), isTrue);
    });
  });
}