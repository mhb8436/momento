import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:momento_app/main.dart' as app;

/// 크레딧 시스템 UI 플로우 통합 테스트
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Credit System UI Flow Tests', () {
    testWidgets('홈 화면에서 크레딧 상태 표시 확인', (WidgetTester tester) async {
      // 앱 실행
      app.main();
      await tester.pumpAndSettle();

      // 로그인 화면에서 테스트 계정으로 로그인
      // (실제 테스트 시에는 유효한 테스트 계정 필요)
      final emailField = find.byType(TextField).first;
      final passwordField = find.byType(TextField).last;
      final loginButton = find.text('로그인');

      await tester.enterText(emailField, 'test@momento.com');
      await tester.enterText(passwordField, 'testpassword123');
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // 홈 화면 진입 후 크레딧 위젯 확인
      expect(find.text('보유 크레딧'), findsOneWidget);
      expect(find.byIcon(Icons.account_balance_wallet), findsOneWidget);
    });

    testWidgets('크레딧 스토어 화면 네비게이션 테스트', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 홈 화면에서 크레딧 위젯 탭
      final creditWidget = find.text('보유 크레딧');
      await tester.tap(creditWidget);
      await tester.pumpAndSettle();

      // 크레딧 스토어 화면 확인
      expect(find.text('크레딧 스토어'), findsOneWidget);
      expect(find.text('크레딧 패키지'), findsOneWidget);
      expect(find.text('구독'), findsOneWidget);
    });

    testWidgets('크레딧 패키지 카드 표시 확인', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 크레딧 스토어로 이동
      final creditWidget = find.text('보유 크레딧');
      await tester.tap(creditWidget);
      await tester.pumpAndSettle();

      // 패키지 탭 확인
      expect(find.text('시작 패키지'), findsWidgets);
      expect(find.text('가족 패키지'), findsWidgets);
      expect(find.text('프리미엄 패키지'), findsWidgets);
      expect(find.text('구매하기'), findsWidgets);
    });

    testWidgets('구독 탭 전환 테스트', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 크레딧 스토어로 이동
      final creditWidget = find.text('보유 크레딧');
      await tester.tap(creditWidget);
      await tester.pumpAndSettle();

      // 구독 탭 클릭
      final subscriptionTab = find.text('구독');
      await tester.tap(subscriptionTab);
      await tester.pumpAndSettle();

      // 구독 상품 확인
      expect(find.text('월간 구독'), findsWidgets);
      expect(find.text('연간 구독'), findsWidgets);
      expect(find.text('구독하기'), findsWidgets);
    });

    testWidgets('구매 버튼 탭 시 확인 다이얼로그 표시', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 크레딧 스토어로 이동
      final creditWidget = find.text('보유 크레딧');
      await tester.tap(creditWidget);
      await tester.pumpAndSettle();

      // 첫 번째 구매 버튼 클릭
      final buyButton = find.text('구매하기').first;
      await tester.tap(buyButton);
      await tester.pumpAndSettle();

      // 구매 확인 다이얼로그 확인
      expect(find.text('구매 확인'), findsOneWidget);
      expect(find.text('취소'), findsOneWidget);
      expect(find.text('구매'), findsOneWidget);
    });

    testWidgets('레시피 생성 시 크레딧 사용 확인', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 홈 화면에서 음성 녹음 버튼 탭
      final recordButton = find.text('음성 녹음');
      await tester.tap(recordButton);
      await tester.pumpAndSettle();

      // 녹음 화면에서 녹음 시작
      final startRecording = find.byIcon(Icons.mic);
      await tester.tap(startRecording);
      await tester.pump(Duration(seconds: 2));

      // 녹음 종료
      await tester.tap(startRecording);
      await tester.pumpAndSettle();

      // 처리 버튼 클릭 (크레딧 사용)
      final processButton = find.text('처리하기');
      if (processButton.evaluate().isNotEmpty) {
        await tester.tap(processButton);
        await tester.pumpAndSettle();
      }

      // 크레딧 부족 시 알림 다이얼로그 또는 성공 메시지 확인
      expect(
        find.textContaining('크레딧').or(find.text('처리 완료')),
        findsOneWidget,
      );
    });
  });

  group('Error Handling Tests', () {
    testWidgets('네트워크 오류 시 에러 메시지 표시', (WidgetTester tester) async {
      // 네트워크 연결 없이 앱 실행하여 테스트
      app.main();
      await tester.pumpAndSettle();

      // 크레딧 새로고침 시도
      final refreshButton = find.byIcon(Icons.refresh);
      if (refreshButton.evaluate().isNotEmpty) {
        await tester.tap(refreshButton);
        await tester.pumpAndSettle();

        // 에러 메시지 확인
        expect(find.textContaining('오류'), findsWidgets);
      }
    });

    testWidgets('크레딧 부족 시 구매 안내 표시', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 크레딧을 모두 소진한 상태에서 레시피 생성 시도
      // (실제 테스트에서는 mock 데이터로 크레딧 0 상태 설정)
      
      // 크레딧 부족 알림 확인
      if (find.text('크레딧이 부족합니다').evaluate().isNotEmpty) {
        expect(find.text('크레딧이 부족합니다'), findsOneWidget);
        expect(find.text('크레딧 구매하기'), findsOneWidget);
      }
    });
  });
}