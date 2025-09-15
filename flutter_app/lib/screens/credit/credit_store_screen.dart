import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/credit_provider.dart';
import '../../models/credit.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../config/theme.dart';
import 'usage_stats_screen.dart';
import 'payment_history_screen.dart';

/// 크레딧 스토어 화면
class CreditStoreScreen extends StatefulWidget {
  const CreditStoreScreen({super.key});

  @override
  State<CreditStoreScreen> createState() => _CreditStoreScreenState();
}

class _CreditStoreScreenState extends State<CreditStoreScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // 크레딧 정보 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CreditProvider>().refresh();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildCreditStatus(),
              _buildQuickActions(),
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPackagesTab(),
                    _buildSubscriptionsTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          ),
          const Expanded(
            child: Text(
              '크레딧 스토어',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            onPressed: () => _showInfoDialog(),
            icon: const Icon(Icons.info_outline, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildCreditStatus() {
    return Consumer<CreditProvider>(
      builder: (context, creditProvider, child) {
        final balance = creditProvider.creditBalance;
        
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.account_balance_wallet,
                      color: AppTheme.primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '보유 크레딧',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              '${balance?.balance ?? 0}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const Text(
                              '개',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (balance?.hasFreeCreditLeft == true)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '무료 ${balance!.remainingFreeCredits}개',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
              if (creditProvider.hasAutoRecharge) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.orange, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          creditProvider.subscriptionStatus,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: CustomButton(
              text: '사용량 통계',
              onPressed: () => _navigateToUsageStats(),
              backgroundColor: Colors.white.withOpacity(0.2),
              textColor: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: CustomButton(
              text: '결제 내역',
              onPressed: () => _navigateToPaymentHistory(),
              backgroundColor: Colors.white.withOpacity(0.2),
              textColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppTheme.primaryColor,
        unselectedLabelColor: AppTheme.textLight,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppTheme.primaryColor.withOpacity(0.1),
        ),
        tabs: const [
          Tab(text: '크레딧 패키지'),
          Tab(text: '구독 서비스'),
        ],
      ),
    );
  }

  Widget _buildPackagesTab() {
    return Consumer<CreditProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const LoadingOverlay(
            isLoading: true,
            child: SizedBox.shrink(),
          );
        }

        final packages = provider.activePackages.where((p) => !p.packageType.contains('subscription')).toList();

        if (packages.isEmpty) {
          return const Center(
            child: Text('사용 가능한 패키지가 없습니다'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: packages.length,
          itemBuilder: (context, index) => _buildPackageCard(packages[index]),
        );
      },
    );
  }

  Widget _buildSubscriptionsTab() {
    return Consumer<CreditProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const LoadingOverlay(
            isLoading: true,
            child: SizedBox.shrink(),
          );
        }

        final subscriptions = provider.activePackages.where((p) => p.packageType.contains('subscription')).toList();

        return Column(
          children: [
            if (provider.hasAutoRecharge) ...[
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.orange),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '현재 구독 중입니다',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            provider.subscriptionStatus,
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
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: subscriptions.length,
                itemBuilder: (context, index) => _buildPackageCard(subscriptions[index]),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPackageCard(CreditPackage package) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: package.isRecommended 
            ? Border.all(color: AppTheme.primaryColor, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    package.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (package.isRecommended)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '추천',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (package.description != null) ...[
              Text(
                package.description!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                Text(
                  '${package.creditsAmount}개 크레딧',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (package.hasDiscount) ...[
                  Text(
                    '${package.discountPercentage}% 할인',
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  package.formattedPrice,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: '구매하기',
                onPressed: () => _purchasePackage(package),
                backgroundColor: package.isRecommended 
                    ? AppTheme.primaryColor 
                    : Colors.grey[600]!,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _purchasePackage(CreditPackage package) async {
    final provider = context.read<CreditProvider>();
    
    // 구매 진행
    final success = await provider.purchasePackage(package.packageType);
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${package.name} 구매가 완료되었습니다!'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted && provider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _navigateToUsageStats() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const UsageStatsScreen(),
      ),
    );
  }

  void _navigateToPaymentHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PaymentHistoryScreen(),
      ),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => Consumer<CreditProvider>(
        builder: (context, creditProvider, child) {
          final balance = creditProvider.creditBalance;
          return AlertDialog(
            title: const Text('크레딧 스토어 안내'),
            content: Text(
              '크레딧으로 AI 레시피 생성 서비스를 이용하실 수 있습니다.\n\n'
              '📝 사용 요금:\n'
              '• 레시피 생성: ${balance?.recipeGenerationCost ?? 1}크레딧\n'
              '• 레시피 개선: ${balance?.recipeImprovementCost ?? 1}크레딧\n\n'
              '🎁 무료 혜택:\n'
              '• 신규 가입: ${balance?.initialFreeCredits ?? 5}크레딧\n'
              '• 매일 ${balance?.dailyFreeCredits ?? 2}개의 무료 크레딧 제공\n\n'
              '⭐ 자동충전 서비스:\n'
              '• 월간 50개 자동충전: 9,900원 (월)\n'
              '• 연간 100개 자동충전: 99,900원 (년)\n'
              '• 자동충전으로 편리하게 사용',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('확인'),
              ),
            ],
          );
        },
      ),
    );
  }
}