import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/credit_provider.dart';
import '../../screens/credit/credit_store_screen.dart';
import '../../config/theme.dart';

/// 크레딧 상태를 표시하는 위젯
class CreditStatusWidget extends StatelessWidget {
  final bool showDetails;
  final VoidCallback? onTap;

  const CreditStatusWidget({
    Key? key,
    this.showDetails = true,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CreditProvider>(
      builder: (context, creditProvider, child) {
        final balance = creditProvider.creditBalance;
        
        return GestureDetector(
          onTap: onTap ?? () => _navigateToCreditStore(context),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: showDetails 
                ? _buildDetailedView(balance, creditProvider)
                : _buildCompactView(balance),
          ),
        );
      },
    );
  }

  Widget _buildDetailedView(balance, CreditProvider creditProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.account_balance_wallet,
              color: AppTheme.primaryColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            const Text(
              '보유 크레딧',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              '${balance?.balance ?? 0}개',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
        if (balance?.hasFreeCreditLeft == true) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '무료 크레딧 ${balance!.remainingFreeCredits}개 남음 (오늘)',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
        if (balance?.hasAutoRecharge == true) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              '자동충전 설정됨',
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
        const SizedBox(height: 12),
        Text(
          creditProvider.getCreditSuggestion(),
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildCompactView(balance) {
    return Row(
      children: [
        Icon(
          Icons.account_balance_wallet,
          color: AppTheme.primaryColor,
          size: 16,
        ),
        const SizedBox(width: 6),
        Text(
          '${balance?.balance ?? 0}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(width: 4),
        const Icon(
          Icons.keyboard_arrow_right,
          size: 16,
          color: Colors.grey,
        ),
      ],
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

/// 크레딧 부족 알림 위젯
class CreditInsufficiencyWidget extends StatelessWidget {
  final VoidCallback? onPurchase;

  const CreditInsufficiencyWidget({
    Key? key,
    this.onPurchase,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CreditProvider>(
      builder: (context, creditProvider, child) {
        final recommendedPackage = creditProvider.recommendedPackage;
        
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryColor.withOpacity(0.1),
                AppTheme.secondaryColor.withOpacity(0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.primaryColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                size: 48,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(height: 16),
              const Text(
                '크레딧이 부족합니다',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '더 많은 레시피를 생성하려면\n크레딧을 구매해주세요',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              if (recommendedPackage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Text('⭐', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              recommendedPackage.name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${recommendedPackage.creditsAmount}개 • ${recommendedPackage.formattedPrice}',
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
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onPurchase ?? () => _navigateToCreditStore(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '크레딧 구매하기',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
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

/// 크레딧 사용 확인 다이얼로그
class CreditUsageConfirmDialog extends StatelessWidget {
  final String action;
  final int creditsRequired;
  final VoidCallback onConfirm;

  const CreditUsageConfirmDialog({
    Key? key,
    required this.action,
    required this.creditsRequired,
    required this.onConfirm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CreditProvider>(
      builder: (context, creditProvider, child) {
        final balance = creditProvider.creditBalance;
        final canAfford = (balance?.balance ?? 0) >= creditsRequired ||
                          (balance?.hasFreeCreditLeft ?? false);

        return AlertDialog(
          title: Text(action),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$action에 $creditsRequired개의 크레딧이 필요합니다.'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    size: 16,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text('현재 크레딧: ${balance?.balance ?? 0}개'),
                ],
              ),
              if (balance?.hasFreeCreditLeft == true) ...[
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
                      '무료 크레딧: ${balance!.remainingFreeCredits}개',
                      style: const TextStyle(color: Colors.green),
                    ),
                  ],
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            if (canAfford)
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  onConfirm();
                },
                child: const Text('사용하기'),
              )
            else
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _navigateToCreditStore(context);
                },
                child: const Text('크레딧 구매'),
              ),
          ],
        );
      },
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