import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/recipe_provider.dart';
import '../../providers/audio_provider.dart';
import '../../widgets/common/custom_icon_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildProfileHeader(),
          const SizedBox(height: 24),
          _buildStatsCards(),
          const SizedBox(height: 24),
          _buildMenuSection(),
          const SizedBox(height: 100), // Space for bottom navigation
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.user;
        
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                user?.fullName?.isNotEmpty == true ? user!.fullName! : '사용자',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user?.email ?? '',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildProfileAction(
                    icon: Icons.edit_outlined,
                    label: '프로필 수정',
                    onTap: _editProfile,
                  ),
                  const SizedBox(width: 16),
                  _buildProfileAction(
                    icon: Icons.camera_alt_outlined,
                    label: '사진 변경',
                    onTap: _changeProfileImage,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: '레시피',
            provider: Consumer<RecipeProvider>(
              builder: (context, recipeProvider, _) {
                return _buildStatContent(
                  count: recipeProvider.recipes.length,
                  icon: Icons.restaurant_menu,
                  color: AppTheme.primaryColor,
                );
              },
            ),
            onTap: () => _switchToTab(1), // Recipe tab
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: '오디오',
            provider: Consumer<AudioProvider>(
              builder: (context, audioProvider, _) {
                return _buildStatContent(
                  count: audioProvider.audioFiles.length,
                  icon: Icons.mic,
                  color: AppTheme.secondaryColor,
                );
              },
            ),
            onTap: () => _switchToTab(2), // Audio tab
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: '즐겨찾기',
            provider: _buildStatContent(
              count: 0, // TODO: Implement favorites count
              icon: Icons.favorite,
              color: AppTheme.accentColor,
            ),
            onTap: _viewFavorites,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required Widget provider,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            provider,
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatContent({
    required int count,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          count.toString(),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '설정',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildMenuItem(
                icon: Icons.notifications_outlined,
                title: '알림 설정',
                subtitle: '푸시 알림 및 이메일 알림 설정',
                onTap: _openNotificationSettings,
              ),
              _buildDivider(),
              _buildMenuItem(
                icon: Icons.privacy_tip_outlined,
                title: '개인정보 보호',
                subtitle: '데이터 사용 및 개인정보 설정',
                onTap: _openPrivacySettings,
              ),
              _buildDivider(),
              _buildMenuItem(
                icon: Icons.language_outlined,
                title: '언어',
                subtitle: '한국어',
                onTap: _openLanguageSettings,
              ),
              _buildDivider(),
              _buildMenuItem(
                icon: Icons.cloud_sync_outlined,
                title: '데이터 동기화',
                subtitle: '클라우드 백업 및 동기화 설정',
                onTap: _openSyncSettings,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          '지원',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildMenuItem(
                icon: Icons.help_outline,
                title: '도움말',
                subtitle: '사용법 및 FAQ',
                onTap: _openHelp,
              ),
              _buildDivider(),
              _buildMenuItem(
                icon: Icons.feedback_outlined,
                title: '피드백 보내기',
                subtitle: '개선 사항 및 문의사항',
                onTap: _sendFeedback,
              ),
              _buildDivider(),
              _buildMenuItem(
                icon: Icons.info_outline,
                title: '앱 정보',
                subtitle: '버전 1.0.0',
                onTap: _showAppInfo,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: _buildMenuItem(
            icon: Icons.logout,
            title: '로그아웃',
            subtitle: '계정에서 로그아웃',
            onTap: _showLogoutDialog,
            textColor: AppTheme.errorColor,
            iconColor: AppTheme.errorColor,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (iconColor ?? AppTheme.primaryColor).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: iconColor ?? AppTheme.primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: textColor ?? AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppTheme.textLight,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 1,
        color: AppTheme.textLight.withOpacity(0.2),
      ),
    );
  }

  void _editProfile() {
    // TODO: Navigate to profile edit screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('프로필 수정 기능 구현 예정'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  void _changeProfileImage() {
    // TODO: Implement profile image change
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('프로필 사진 변경 기능 구현 예정'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  void _switchToTab(int tabIndex) {
    // Access the parent HomeScreen's tab controller
    if (mounted) {
      // This would work if we had access to the parent's setState
      // For now, show a message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tabIndex == 1 ? '레시피 탭으로 이동' : '오디오 탭으로 이동'),
          backgroundColor: AppTheme.primaryColor,
        ),
      );
    }
  }

  void _viewFavorites() {
    // TODO: Navigate to favorites screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('즐겨찾기 기능 구현 예정'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  void _openNotificationSettings() {
    // TODO: Navigate to notification settings
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('알림 설정 기능 구현 예정'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  void _openPrivacySettings() {
    // TODO: Navigate to privacy settings
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('개인정보 보호 설정 기능 구현 예정'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  void _openLanguageSettings() {
    // TODO: Navigate to language settings
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('언어 설정 기능 구현 예정'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  void _openSyncSettings() {
    // TODO: Navigate to sync settings
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('데이터 동기화 설정 기능 구현 예정'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  void _openHelp() {
    // TODO: Navigate to help screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('도움말 기능 구현 예정'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  void _sendFeedback() {
    // TODO: Open feedback form
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('피드백 보내기 기능 구현 예정'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  void _showAppInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('MOMENTO'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('버전: 1.0.0'),
            const SizedBox(height: 8),
            Text('엄마의 요리법을 음성으로 기록하고\nAI로 정리하는 감성 요리 아카이빙 앱'),
            const SizedBox(height: 16),
            Text(
              '© 2024 MOMENTO',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('정말로 로그아웃하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthProvider>().logout();
            },
            child: const Text('로그아웃', style: TextStyle(color: AppTheme.errorColor)),
          ),
        ],
      ),
    );
  }
}