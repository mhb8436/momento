import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../widgets/common/custom_icon_button.dart';
import '../recording/recording_screen.dart';
import '../ocr/ocr_screen.dart';
import '../text_input/text_input_screen.dart';
import '../url_input/url_input_screen.dart';

class RecipeCreateScreen extends StatefulWidget {
  const RecipeCreateScreen({super.key});

  @override
  State<RecipeCreateScreen> createState() => _RecipeCreateScreenState();
}

class _RecipeCreateScreenState extends State<RecipeCreateScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      _buildTitle(),
                      const SizedBox(height: 40),
                      _buildCreateOptions(),
                      const SizedBox(height: 40),
                      _buildTips(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          const SizedBox(width: 48), // Balance spacing
          const Spacer(),
          Text(
            '레시피 작성',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 48), // Balance spacing
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        Icon(
          Icons.add_circle_outline,
          size: 80,
          color: AppTheme.primaryColor,
        ),
        const SizedBox(height: 24),
        Text(
          '새로운 레시피 만들기',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          '음성으로 설명하거나 이미지를 스캔해서\n특별한 요리 레시피를 기록해보세요',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppTheme.textSecondary,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCreateOptions() {
    return Column(
      children: [
        // 음성 녹음 카드 (메인)
        _buildCreateOptionCard(
          icon: Icons.mic,
          title: '음성으로 녹음하기',
          subtitle: '요리 과정을 자세히 말씀해주시면\nAI가 체계적인 레시피로 정리해드립니다',
          gradient: AppTheme.primaryGradient,
          isMain: true,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const RecordingScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        
        // 두 번째 행: OCR, 텍스트 입력, URL 입력
        Row(
          children: [
            Expanded(
              child: _buildCreateOptionCard(
                icon: Icons.document_scanner,
                title: '이미지 스캔',
                subtitle: '사진에서\n텍스트 추출',
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF9C88FF)],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OCRScreen(),
                    ),
                  );
                },
                isCompact: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildCreateOptionCard(
                icon: Icons.edit_note,
                title: '텍스트 입력',
                subtitle: '메모/메시지\n직접 입력',
                gradient: const LinearGradient(
                  colors: [Color(0xFF26D0CE), Color(0xFF1A9B9A)],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TextInputScreen(),
                    ),
                  );
                },
                isCompact: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildCreateOptionCard(
                icon: Icons.link,
                title: 'URL 입력',
                subtitle: '유튜브/블로그\n링크 추출',
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UrlInputScreen(),
                    ),
                  );
                },
                isCompact: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCreateOptionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Gradient gradient,
    required VoidCallback onTap,
    bool isMain = false,
    bool isCompact = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isCompact ? null : double.infinity,
        padding: EdgeInsets.all(isMain ? 28 : (isCompact ? 20 : 24)),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(isCompact ? 16 : 20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: isCompact ? 10 : 15,
              offset: Offset(0, isCompact ? 4 : 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(isCompact ? 12 : 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: isMain ? 48 : (isCompact ? 28 : 40),
              ),
            ),
            SizedBox(height: isMain ? 20 : (isCompact ? 12 : 16)),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: isMain ? 24 : (isCompact ? 16 : 20),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isMain ? 12 : (isCompact ? 6 : 8)),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withOpacity(0.9),
                height: 1.4,
                fontSize: isMain ? 16 : (isCompact ? 12 : 14),
              ),
              textAlign: TextAlign.center,
            ),
            if (!isCompact) ...[
              SizedBox(height: isMain ? 16 : 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isMain ? '지금 시작하기' : '시작하기',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: isMain ? 16 : 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: isMain ? 20 : 16,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTips() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.tips_and_updates,
                color: AppTheme.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '레시피 작성 팁',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTipItem(
            icon: Icons.mic,
            title: '음성 녹음 팁',
            description: '재료명, 분량, 조리 순서를 명확하게 말씀해주세요',
          ),
          const SizedBox(height: 12),
          _buildTipItem(
            icon: Icons.camera_alt,
            title: '이미지 스캔 팁',
            description: '텍스트가 선명하게 보이도록 조명을 충분히 확보해주세요',
          ),
          const SizedBox(height: 12),
          _buildTipItem(
            icon: Icons.auto_awesome,
            title: 'AI 처리',
            description: '두 방법 모두 AI가 자동으로 체계적인 레시피로 정리해드립니다',
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryColor,
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}