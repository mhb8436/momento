import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../widgets/common/custom_button.dart';

/// 로딩 스타일 데모 화면
class LoadingDemoScreen extends StatefulWidget {
  const LoadingDemoScreen({super.key});

  @override
  State<LoadingDemoScreen> createState() => _LoadingDemoScreenState();
}

class _LoadingDemoScreenState extends State<LoadingDemoScreen> {
  bool _isOverlayLoading = false;
  bool _isButtonLoading = false;
  LoadingStyle _selectedStyle = LoadingStyle.modern;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('로딩 스타일 데모'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.backgroundGradient,
          ),
        ),
      ),
      body: LoadingOverlay(
        isLoading: _isOverlayLoading,
        style: _selectedStyle,
        message: '크레딧을 구매하고 있습니다...',
        child: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.backgroundGradient,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStyleSelector(),
                const SizedBox(height: 32),
                _buildOverlayDemo(),
                const SizedBox(height: 32),
                _buildWidgetDemo(),
                const SizedBox(height: 32),
                _buildButtonDemo(),
                const SizedBox(height: 32),
                _buildInlineDemo(),
                const SizedBox(height: 32),
                _buildFullScreenDemo(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStyleSelector() {
    return Container(
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
          Text(
            '로딩 스타일 선택',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: LoadingStyle.values.map((style) {
              final isSelected = _selectedStyle == style;
              return ChoiceChip(
                label: Text(_getStyleName(style)),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedStyle = style;
                    });
                  }
                },
                selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                labelStyle: TextStyle(
                  color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildOverlayDemo() {
    return _buildDemoSection(
      title: '오버레이 로딩',
      description: '전체 화면을 덮는 로딩 다이얼로그 (크레딧 구매 시 사용)',
      child: CustomButton(
        text: '오버레이 로딩 테스트',
        onPressed: () {
          setState(() {
            _isOverlayLoading = true;
          });
          
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) {
              setState(() {
                _isOverlayLoading = false;
              });
            }
          });
        },
        icon: Icons.layers_outlined,
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildWidgetDemo() {
    return _buildDemoSection(
      title: '위젯 로딩',
      description: '페이지 내부에서 사용되는 로딩 인디케이터',
      child: Container(
        height: 150,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: LoadingWidget(
          message: '크레딧 정보를 불러오는 중...',
          style: _selectedStyle,
        ),
      ),
    );
  }

  Widget _buildButtonDemo() {
    return _buildDemoSection(
      title: '버튼 로딩',
      description: '버튼 내부에서 표시되는 로딩 상태',
      child: Row(
        children: [
          Expanded(
            child: CustomButton(
              text: '크레딧 구매',
              isLoading: _isButtonLoading,
              loadingStyle: _selectedStyle,
              onPressed: _isButtonLoading ? null : () {
                setState(() {
                  _isButtonLoading = true;
                });
                
                Future.delayed(const Duration(seconds: 2), () {
                  if (mounted) {
                    setState(() {
                      _isButtonLoading = false;
                    });
                  }
                });
              },
              icon: Icons.shopping_cart,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: CustomButton(
              text: '구독하기',
              outlined: true,
              isLoading: _isButtonLoading,
              loadingStyle: _selectedStyle,
              onPressed: _isButtonLoading ? null : () {
                setState(() {
                  _isButtonLoading = true;
                });
                
                Future.delayed(const Duration(seconds: 2), () {
                  if (mounted) {
                    setState(() {
                      _isButtonLoading = false;
                    });
                  }
                });
              },
              icon: Icons.subscriptions,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInlineDemo() {
    return _buildDemoSection(
      title: '인라인 로딩',
      description: '작은 공간에서 사용되는 인라인 인디케이터',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: LoadingStyle.values.map((style) {
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                ),
                child: InlineLoadingIndicator(
                  style: style,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _getStyleName(style),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFullScreenDemo() {
    return _buildDemoSection(
      title: '풀스크린 로딩',
      description: '앱 시작 시나 중요한 프로세스에서 사용',
      child: CustomButton(
        text: '풀스크린 로딩 보기',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FullScreenLoading(
                message: 'MOMENTO 앱을 준비하고 있습니다',
                subtitle: '크레딧 시스템을 초기화하는 중...',
                style: _selectedStyle,
                logo: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.restaurant_menu,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          );
          
          // 3초 후 자동으로 돌아가기
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) {
              Navigator.pop(context);
            }
          });
        },
        icon: Icons.fullscreen,
        backgroundColor: AppTheme.secondaryColor,
      ),
    );
  }

  Widget _buildDemoSection({
    required String title,
    required String description,
    required Widget child,
  }) {
    return Container(
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
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  String _getStyleName(LoadingStyle style) {
    switch (style) {
      case LoadingStyle.modern:
        return '모던';
      case LoadingStyle.minimal:
        return '미니멀';
      case LoadingStyle.floating:
        return '플로팅';
      case LoadingStyle.gradient:
        return '그라데이션';
    }
  }
}