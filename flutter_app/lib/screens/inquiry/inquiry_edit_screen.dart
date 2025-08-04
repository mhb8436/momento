import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/inquiry.dart';
import '../../providers/inquiry_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/loading_overlay.dart';

class InquiryEditScreen extends StatefulWidget {
  final Inquiry inquiry;

  const InquiryEditScreen({
    super.key,
    required this.inquiry,
  });

  @override
  State<InquiryEditScreen> createState() => _InquiryEditScreenState();
}

class _InquiryEditScreenState extends State<InquiryEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  
  late InquiryCategory _selectedCategory;
  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    
    // 기존 값으로 초기화
    _titleController = TextEditingController(text: widget.inquiry.title);
    _contentController = TextEditingController(text: widget.inquiry.content);
    _selectedCategory = widget.inquiry.category;
    
    // 변경 감지를 위한 리스너 추가
    _titleController.addListener(_onContentChanged);
    _contentController.addListener(_onContentChanged);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _onContentChanged() {
    final hasChanges = _titleController.text.trim() != widget.inquiry.title ||
                      _contentController.text.trim() != widget.inquiry.content ||
                      _selectedCategory != widget.inquiry.category;
    
    if (hasChanges != _hasChanges) {
      setState(() {
        _hasChanges = hasChanges;
      });
    }
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
                          _buildCategorySection(),
                          const SizedBox(height: 24),
                          _buildTitleSection(),
                          const SizedBox(height: 24),
                          _buildContentSection(),
                          const SizedBox(height: 32),
                          _buildSubmitButton(),
                          const SizedBox(height: 16),
                          _buildWarningText(),
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
            onPressed: _onBackPressed,
          ),
          const Spacer(),
          Text(
            '문의사항 수정',
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
                Icons.info_outline,
                color: Colors.blue,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '수정 안내',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '답변이 달리기 전까지만 문의사항을 수정할 수 있습니다.\n'
            '수정 후에는 다시 검토 과정을 거치게 됩니다.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
          ),
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
                _getCategoryDescription(category),
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
                _onContentChanged();
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
            hintText: '문의 내용을 자세히 작성해주세요.',
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
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isLoading ? null : _onBackPressed,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: AppTheme.textSecondary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              '취소',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: CustomButton(
            text: '수정 완료',
            onPressed: _isLoading || !_hasChanges ? null : _submitUpdate,
            isLoading: _isLoading,
          ),
        ),
      ],
    );
  }

  Widget _buildWarningText() {
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
                Icons.warning_amber_outlined,
                color: Colors.orange,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '수정 시 주의사항',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '• 관리자가 답변을 시작한 경우 수정이 제한될 수 있습니다\n'
            '• 수정된 내용은 다시 검토 과정을 거치게 됩니다\n'
            '• 중요한 정보가 누락되지 않도록 신중히 작성해주세요',
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

  String _getCategoryDescription(InquiryCategory category) {
    switch (category) {
      case InquiryCategory.general:
        return '일반적인 문의사항이나 의견';
      case InquiryCategory.bug:
        return '앱 오류나 버그 발견 시';
      case InquiryCategory.feature:
        return '새로운 기능에 대한 제안';
      case InquiryCategory.account:
        return '계정 관련 문의 (로그인, 비밀번호 등)';
      case InquiryCategory.recipe:
        return '레시피 생성 및 관리 관련';
      case InquiryCategory.audio:
        return '음성 녹음 및 처리 관련';
      case InquiryCategory.ui:
        return '화면 디자인이나 사용성 관련';
      case InquiryCategory.performance:
        return '속도나 성능 관련 문제';
    }
  }

  Future<void> _submitUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<InquiryProvider>(context, listen: false);
      
      final request = InquiryUpdateRequest(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        category: _selectedCategory,
      );

      final success = await provider.updateInquiry(widget.inquiry.id, request);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ 문의사항이 성공적으로 수정되었습니다!'),
            backgroundColor: AppTheme.primaryColor,
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pop(context, true);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? '수정에 실패했습니다.'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('수정 중 오류가 발생했습니다: $e'),
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

  Future<void> _onBackPressed() async {
    if (!_hasChanges) {
      Navigator.pop(context);
      return;
    }

    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('수정 내용이 있습니다'),
        content: const Text(
          '수정된 내용이 저장되지 않습니다.\n'
          '정말로 나가시겠습니까?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('계속 수정'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('나가기'),
          ),
        ],
      ),
    );

    if (shouldLeave == true && mounted) {
      Navigator.pop(context);
    }
  }
}