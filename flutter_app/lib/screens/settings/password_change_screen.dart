import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/loading_overlay.dart';

class PasswordChangeScreen extends StatefulWidget {
  const PasswordChangeScreen({super.key});

  @override
  State<PasswordChangeScreen> createState() => _PasswordChangeScreenState();
}

class _PasswordChangeScreenState extends State<PasswordChangeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
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
                          _buildInfoCard(),
                          const SizedBox(height: 24),
                          _buildPasswordFields(),
                          const SizedBox(height: 32),
                          _buildChangeButton(),
                          const SizedBox(height: 16),
                          _buildSecurityTips(),
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
            '비밀번호 변경',
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
                Icons.security,
                color: Colors.blue,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '보안 안내',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '계정 보안을 위해 정기적으로 비밀번호를 변경해주세요.\n'
            '새 비밀번호는 현재 비밀번호와 달라야 합니다.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '비밀번호 정보',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        
        // Current Password
        CustomTextField(
          controller: _currentPasswordController,
          label: '현재 비밀번호',
          prefixIcon: Icons.lock_outline,
          obscureText: !_showCurrentPassword,
          suffixIcon: IconButton(
            icon: Icon(
              _showCurrentPassword ? Icons.visibility : Icons.visibility_off,
              color: AppTheme.textLight,
            ),
            onPressed: () {
              setState(() {
                _showCurrentPassword = !_showCurrentPassword;
              });
            },
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '현재 비밀번호를 입력해주세요';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        
        // New Password
        CustomTextField(
          controller: _newPasswordController,
          label: '새 비밀번호',
          prefixIcon: Icons.lock,
          obscureText: !_showNewPassword,
          suffixIcon: IconButton(
            icon: Icon(
              _showNewPassword ? Icons.visibility : Icons.visibility_off,
              color: AppTheme.textLight,
            ),
            onPressed: () {
              setState(() {
                _showNewPassword = !_showNewPassword;
              });
            },
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '새 비밀번호를 입력해주세요';
            }
            if (value.length < 6) {
              return '비밀번호는 최소 6자 이상이어야 합니다';
            }
            if (value == _currentPasswordController.text) {
              return '현재 비밀번호와 다른 비밀번호를 입력해주세요';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        
        // Confirm Password
        CustomTextField(
          controller: _confirmPasswordController,
          label: '새 비밀번호 확인',
          prefixIcon: Icons.lock_reset,
          obscureText: !_showConfirmPassword,
          suffixIcon: IconButton(
            icon: Icon(
              _showConfirmPassword ? Icons.visibility : Icons.visibility_off,
              color: AppTheme.textLight,
            ),
            onPressed: () {
              setState(() {
                _showConfirmPassword = !_showConfirmPassword;
              });
            },
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '비밀번호 확인을 입력해주세요';
            }
            if (value != _newPasswordController.text) {
              return '새 비밀번호와 일치하지 않습니다';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildChangeButton() {
    return CustomButton(
      text: '비밀번호 변경',
      onPressed: _isLoading ? null : _changePassword,
      isLoading: _isLoading,
    );
  }

  Widget _buildSecurityTips() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.orange.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: Colors.orange,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '안전한 비밀번호 만들기',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '• 8자 이상의 길이로 설정하세요\n'
            '• 영문 대소문자, 숫자, 특수문자를 조합하세요\n'
            '• 생일, 전화번호 등 개인정보는 피하세요\n'
            '• 다른 사이트와 다른 비밀번호를 사용하세요\n'
            '• 정기적으로 비밀번호를 변경하세요',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final success = await authProvider.changePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ 비밀번호가 성공적으로 변경되었습니다!'),
            backgroundColor: AppTheme.primaryColor,
            duration: Duration(seconds: 3),
          ),
        );
        Navigator.pop(context);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error ?? '비밀번호 변경에 실패했습니다.'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('비밀번호 변경 중 오류가 발생했습니다: $e'),
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
}