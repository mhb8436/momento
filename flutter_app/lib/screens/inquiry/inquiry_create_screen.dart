import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/inquiry.dart';
import '../../providers/inquiry_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/loading_overlay.dart';

class InquiryCreateScreen extends StatefulWidget {
  const InquiryCreateScreen({super.key});

  @override
  State<InquiryCreateScreen> createState() => _InquiryCreateScreenState();
}

class _InquiryCreateScreenState extends State<InquiryCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  
  InquiryCategory _selectedCategory = InquiryCategory.general;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
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
                          _buildCategorySection(),
                          const SizedBox(height: 24),
                          _buildTitleSection(),
                          const SizedBox(height: 24),
                          _buildContentSection(),
                          const SizedBox(height: 32),
                          _buildSubmitButton(),
                          const SizedBox(height: 16),
                          _buildHelpText(),
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
            '문의하기',
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

  Widget _buildCategorySection() {
    return _buildSection(
      title: '문의 유형',
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
          children: InquiryCategory.values.map((category) {
            return RadioListTile<InquiryCategory>(
              title: Row(
                children: [
                  Text(
                    category.displayEmoji,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    category.displayName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              subtitle: Text(
                category.description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              value: category,
              groupValue: _selectedCategory,
              activeColor: AppTheme.primaryColor,
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTitleSection() {
    return _buildSection(
      title: '제목',
      child: CustomTextField(
        controller: _titleController,
        label: '문의 제목을 입력하세요',
        prefixIcon: Icons.title,
        maxLength: 100,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return '제목을 입력해주세요';
          }
          if (value.trim().length < 5) {
            return '제목은 5자 이상 입력해주세요';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildContentSection() {
    return _buildSection(
      title: '문의 내용',
      child: Container(
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
        child: TextFormField(
          controller: _contentController,
          maxLines: 12,
          maxLength: 1000,
          decoration: InputDecoration(
            hintText: '문의 내용을 자세히 작성해주세요.\n\n예시:\n- 어떤 상황에서 문제가 발생했나요?\n- 어떤 결과를 기대하셨나요?\n- 스크린샷이나 추가 정보가 있다면 설명해주세요.',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(16),
            hintStyle: TextStyle(
              color: AppTheme.textLight,
              height: 1.5,
            ),
            counterStyle: TextStyle(
              color: AppTheme.textSecondary,
            ),
          ),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.textPrimary,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '문의 내용을 입력해주세요';
            }
            if (value.trim().length < 20) {
              return '문의 내용을 더 자세히 작성해주세요 (최소 20자)';
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return CustomButton(
      text: '문의하기',
      onPressed: _isLoading ? null : _submitInquiry,
      isLoading: _isLoading,
    );
  }

  Widget _buildHelpText() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppTheme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '문의 전 확인사항',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '• 문의사항은 영업일 기준 1-2일 내에 답변 드립니다\n'
            '• 답변 완료 시 알림을 받으실 수 있습니다\n'
            '• 긴급한 문제는 고객센터(1588-0000)로 연락해주세요\n'
            '• 개인정보는 문의 처리 목적으로만 사용됩니다',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }


  Future<void> _submitInquiry() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<InquiryProvider>(context, listen: false);
      
      final request = InquiryCreateRequest(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        category: _selectedCategory,
      );

      final success = await provider.createInquiry(request);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ 문의사항이 성공적으로 등록되었습니다!\n빠른 시일 내에 답변드리겠습니다.'),
            backgroundColor: AppTheme.primaryColor,
            duration: Duration(seconds: 3),
          ),
        );
        Navigator.pop(context, true);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? '문의 등록에 실패했습니다.'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('문의 등록 중 오류가 발생했습니다: $e'),
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