import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/credit_provider.dart';
import '../../screens/credit/credit_store_screen.dart';
import '../../config/theme.dart';

/// 크레딧 부족 시 표시되는 다이얼로그
class CreditRequiredDialog extends StatelessWidget {
  final String action;
  final VoidCallback? onPurchase;

  const CreditRequiredDialog({
    super.key,
    required this.action,
    this.onPurchase,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CreditProvider>(
      builder: (context, provider, child) {
        final balance = provider.creditBalance;
        
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(width: 8),
              const Text('크레딧이 필요합니다'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$action에는 1개의 크레딧이 필요합니다.',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber,
                      color: Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '현재 크레딧 부족',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          Text(
                            '보유 크레딧: ${balance?.balance ?? 0}개',
                            style: const TextStyle(fontSize: 12),
                          ),
                          if (balance?.hasFreeCreditLeft == true)
                            Text(
                              '무료 크레딧: ${balance!.remainingFreeCredits}개 (오늘)',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.green,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.info,
                          color: Colors.blue,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          '크레딧 획득 방법',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• 매일 ${balance?.dailyFreeCredits ?? 2}개의 무료 크레딧 제공\n'
                      '• 크레딧 패키지 구매\n'
                      '• 월간/연간 구독 (무제한 이용)',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                if (onPurchase != null) {
                  onPurchase!();
                } else {
                  _navigateToCreditStore(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                '크레딧 구매',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  static void show(
    BuildContext context, {
    required String action,
    VoidCallback? onPurchase,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CreditRequiredDialog(
        action: action,
        onPurchase: onPurchase,
      ),
    );
  }

  void _navigateToCreditStore(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreditStoreScreen(),
      ),
    );
  }
}

/// 크레딧 사용 확인 다이얼로그 (사용 전 확인)
class CreditUsageConfirmDialog extends StatelessWidget {
  final String action;
  final VoidCallback onConfirm;

  const CreditUsageConfirmDialog({
    super.key,
    required this.action,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CreditProvider>(
      builder: (context, provider, child) {
        final balance = provider.creditBalance;
        final hasFreeCreditLeft = balance?.hasFreeCreditLeft ?? false;
        
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(action),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$action에 1개의 크레딧을 사용하시겠습니까?'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.account_balance_wallet,
                          size: 16,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '현재 크레딧: ${balance?.balance ?? 0}개',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    if (hasFreeCreditLeft) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.card_giftcard,
                            size: 16,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            hasFreeCreditLeft 
                                ? '무료 크레딧 사용 (오늘 ${balance!.remainingFreeCredits}개 남음)'
                                : '유료 크레딧 사용',
                            style: TextStyle(
                              color: hasFreeCreditLeft ? Colors.green : AppTheme.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      '사용 후 잔액: ${(balance?.balance ?? 0) - (hasFreeCreditLeft ? 0 : 1)}개',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                onConfirm();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                '사용하기',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  static void show(
    BuildContext context, {
    required String action,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (context) => CreditUsageConfirmDialog(
        action: action,
        onConfirm: onConfirm,
      ),
    );
  }
}