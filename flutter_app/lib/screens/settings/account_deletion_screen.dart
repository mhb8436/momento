import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/loading_overlay.dart';

class AccountDeletionScreen extends StatefulWidget {
  const AccountDeletionScreen({super.key});

  @override
  State<AccountDeletionScreen> createState() => _AccountDeletionScreenState();
}

class _AccountDeletionScreenState extends State<AccountDeletionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmationController = TextEditingController();
  
  bool _isLoading = false;
  bool _showPassword = false;
  bool _confirmDeletion = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: LoadingOverlay(
            isLoading: _isLoading,
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildWarningCard(),
                          const SizedBox(height: 24),
                          _buildPasswordField(),
                          const SizedBox(height: 16),
                          _buildConfirmationField(),
                          const SizedBox(height: 16),
                          _buildConfirmationCheckbox(),
                          const SizedBox(height: 32),
                          _buildDeleteButton(),
                          const SizedBox(height: 16),
                          _buildInfoCard(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          Text(
            '계정 탈퇴',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 48), // Balance the back button
        ],
      ),
    );
  }

  Widget _buildWarningCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.red.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning,
                color: Colors.red,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '계정 탈퇴 안내',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '계정을 탈퇴하면 다음과 같은 데이터가 영구적으로 삭제됩니다:\n\n'
            '• 모든 녹음된 음성 파일\n'
            '• 작성한 모든 레시피\n'
            '• 문의 내역 및 답변\n'
            '• 프로필 정보 및 설정\n'
            '• 기타 모든 개인 데이터\n\n'
            '⚠️ 이 작업은 되돌릴 수 없습니다.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '본인 확인',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        CustomTextField(
          controller: _passwordController,
          label: '현재 비밀번호',
          prefixIcon: Icons.lock_outline,
          obscureText: !_showPassword,
          suffixIcon: IconButton(
            icon: Icon(
              _showPassword ? Icons.visibility : Icons.visibility_off,
              color: AppTheme.textLight,
            ),
            onPressed: () {
              setState(() {
                _showPassword = !_showPassword;
              });
            },
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '비밀번호를 입력해주세요';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildConfirmationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          controller: _confirmationController,
          label: '확인 문구 입력 (DELETE)',
          prefixIcon: Icons.delete_forever,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '확인 문구를 입력해주세요';
            }
            if (value != 'DELETE') {
              return 'DELETE를 정확히 입력해주세요';
            }
            return null;
          },
        ),
        const SizedBox(height: 8),
        Text(
          '계정 삭제를 진행하려면 "DELETE"를 입력하세요',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmationCheckbox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withOpacity(0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: _confirmDeletion,
            onChanged: (value) {
              setState(() {
                _confirmDeletion = value ?? false;
              });
            },
            activeColor: AppTheme.primaryColor,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '위의 내용을 모두 이해했으며, 계정 탈퇴에 동의합니다.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '계정 탈퇴 후 데이터 복구는 불가능합니다.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteButton() {
    return CustomButton(
      text: '계정 영구 삭제',
      onPressed: (_isLoading || !_confirmDeletion) ? null : _deleteAccount,
      isLoading: _isLoading,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.blue,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '계정 탈퇴 대신 고려해보세요',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '• 잠시 쉬고 싶다면 로그아웃만 하셔도 됩니다\n'
            '• 알림이 싫다면 알림 설정에서 끌 수 있습니다\n'
            '• 문제가 있다면 고객센터에 문의해주세요\n'
            '• 계정은 언제든지 다시 사용할 수 있습니다',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount() async {
    if (!_formKey.currentState!.validate() || !_confirmDeletion) return;

    // Show final confirmation dialog
    final confirmed = await _showFinalConfirmationDialog();
    if (!confirmed) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final success = await authProvider.deleteAccount(
        password: _passwordController.text,
        confirmation: _confirmationController.text,
      );

      if (success && mounted) {
        // Account deleted successfully, user will be automatically logged out
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ 계정이 성공적으로 삭제되었습니다.'),
            backgroundColor: AppTheme.primaryColor,
            duration: Duration(seconds: 3),
          ),
        );
        
        // Navigate to login screen (AuthProvider will handle logout automatically)
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error ?? '계정 삭제에 실패했습니다.'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('계정 삭제 중 오류가 발생했습니다: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<bool> _showFinalConfirmationDialog() async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.red),
              const SizedBox(width: 8),
              Text('최종 확인'),
            ],
          ),
          content: Text(
            '정말로 계정을 영구적으로 삭제하시겠습니까?\n\n'
            '이 작업은 되돌릴 수 없으며, 모든 데이터가 완전히 삭제됩니다.',
            style: TextStyle(height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('취소'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('영구 삭제'),
            ),
          ],
        );
      },
    ) ?? false;
  }
}