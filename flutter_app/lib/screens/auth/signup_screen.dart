import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../config/theme.dart';
import '../../config/app_config.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/loading_overlay.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fullNameController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    print('🔍 회원가입 시작: ${_emailController.text.trim()}');

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signup(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      fullName: _fullNameController.text.trim().isEmpty 
          ? null 
          : _fullNameController.text.trim(),
    );

    print('🔍 회원가입 결과: success=$success, error=${authProvider.errorMessage}');

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.signupSuccess),
          backgroundColor: AppTheme.secondaryColor,
        ),
      );
    } else {
      final errorMessage = authProvider.errorMessage ?? AppLocalizations.of(context)!.signupFailed;
      print('❌ 회원가입 실패: $errorMessage');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: AppTheme.errorColor,
          duration: const Duration(seconds: 5), // 더 오래 표시
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.signup),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return LoadingOverlay(
            isLoading: authProvider.isLoading,
            style: LoadingStyle.modern,
            message: AppLocalizations.of(context)!.creatingAccount,
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppTheme.backgroundGradient,
              ),
              child: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: _buildSignupForm(),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSignupForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppLocalizations.of(context)!.createAccount,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.signupSubtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            // Full Name Field (Optional)
            CustomTextField(
              controller: _fullNameController,
              label: AppLocalizations.of(context)!.nameOptional,
              hintText: AppLocalizations.of(context)!.enterName,
              prefixIcon: Icons.person_outlined,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            
            // Email Field
            CustomTextField(
              controller: _emailController,
              label: AppLocalizations.of(context)!.email,
              hintText: 'example@email.com',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppLocalizations.of(context)!.enterEmail;
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return AppLocalizations.of(context)!.invalidEmail;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Password Field
            CustomTextField(
              controller: _passwordController,
              label: AppLocalizations.of(context)!.password,
              hintText: AppLocalizations.of(context)!.enterPassword,
              prefixIcon: Icons.lock_outlined,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.next,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppLocalizations.of(context)!.enterPassword;
                }
                if (value.length < AppConfig.minPasswordLength) {
                  return AppLocalizations.of(context)!.passwordTooShort;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Confirm Password Field
            CustomTextField(
              controller: _confirmPasswordController,
              label: AppLocalizations.of(context)!.confirmPassword,
              hintText: AppLocalizations.of(context)!.enterPassword,
              prefixIcon: Icons.lock_outlined,
              obscureText: _obscureConfirmPassword,
              textInputAction: TextInputAction.done,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppLocalizations.of(context)!.enterPassword;
                }
                if (value != _passwordController.text) {
                  return AppLocalizations.of(context)!.passwordsNotMatch;
                }
                return null;
              },
              onFieldSubmitted: (_) => _handleSignup(),
            ),
            const SizedBox(height: 32),
            
            // Signup Button
            Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                return CustomButton(
                  text: AppLocalizations.of(context)!.signupButton,
                  onPressed: authProvider.isLoading ? null : _handleSignup,
                  isLoading: authProvider.isLoading,
                  loadingStyle: LoadingStyle.floating,
                  gradient: AppTheme.primaryGradient,
                );
              },
            ),
            const SizedBox(height: 16),
            
            // Terms Text
            Text(
              AppLocalizations.of(context)!.termsAndPrivacy,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textLight,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}