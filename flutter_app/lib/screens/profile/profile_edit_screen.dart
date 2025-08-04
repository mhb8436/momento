import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '../../config/theme.dart';
import '../../config/app_config.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/loading_overlay.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  
  String? _selectedImagePath;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _fullNameController.text = authProvider.user?.fullName ?? '';
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    super.dispose();
  }

  Future<void> _pickAndCropImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final CroppedFile? croppedFile = await ImageCropper().cropImage(
          sourcePath: pickedFile.path,
          aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: '프로필 이미지 편집',
              toolbarColor: AppTheme.primaryColor,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.square,
              lockAspectRatio: true,
            ),
            IOSUiSettings(
              title: '프로필 이미지 편집',
              doneButtonTitle: '완료',
              cancelButtonTitle: '취소',
              aspectRatioLockEnabled: true,
              resetAspectRatioEnabled: false,
            ),
          ],
        );

        if (croppedFile != null) {
          print('🔍 크롭된 이미지 경로: ${croppedFile.path}');
          setState(() {
            _selectedImagePath = croppedFile.path;
          });
          print('🔍 _selectedImagePath 업데이트됨: $_selectedImagePath');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('이미지 선택 중 오류가 발생했습니다: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  void _showImageSourceSelection() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '프로필 이미지 변경',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppTheme.primaryColor),
              title: const Text('카메라로 촬영'),
              onTap: () {
                Navigator.pop(context);
                _pickAndCropImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppTheme.primaryColor),
              title: const Text('갤러리에서 선택'),
              onTap: () {
                Navigator.pop(context);
                _pickAndCropImage(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      bool success = true;
      String? errorMessage;

      // 1. 프로필 이미지 업로드 (선택된 경우)
      if (_selectedImagePath != null) {
        final imageResult = await authProvider.uploadProfileImage(_selectedImagePath!);
        if (!imageResult) {
          success = false;
          errorMessage = authProvider.errorMessage ?? '프로필 이미지 업로드에 실패했습니다.';
        }
      }

      // 2. 프로필 정보 업데이트 (이름이 변경된 경우)
      if (success && _fullNameController.text.trim() != (authProvider.user?.fullName ?? '')) {
        final profileResult = await authProvider.updateProfile(
          fullName: _fullNameController.text.trim().isEmpty ? null : _fullNameController.text.trim(),
        );
        if (!profileResult) {
          success = false;
          errorMessage = authProvider.errorMessage ?? '프로필 업데이트에 실패했습니다.';
        }
      }

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ 프로필이 성공적으로 업데이트되었습니다!'),
              backgroundColor: AppTheme.primaryColor,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ $errorMessage'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('프로필 저장 중 오류가 발생했습니다: $e'),
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
                        children: [
                          _buildProfileImageSection(),
                          const SizedBox(height: 40),
                          _buildProfileForm(),
                          const SizedBox(height: 40),
                          _buildSaveButton(),
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
            '프로필 수정',
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

  Widget _buildProfileImageSection() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        print('🔍 빌드 시점 _selectedImagePath: $_selectedImagePath');
        print('🔍 빌드 시점 서버 이미지: ${authProvider.user?.profileImageUrl}');
        
        return Column(
          children: [
            Stack(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppTheme.primaryGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: _selectedImagePath != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(60),
                          child: Image.file(
                            File(_selectedImagePath!),
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                            key: ValueKey(_selectedImagePath), // 캐시 방지용 키
                            errorBuilder: (context, error, stackTrace) {
                              print('❌ 로컬 이미지 로드 실패: $error');
                              return const Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.white,
                              );
                            },
                          ),
                        )
                      : authProvider.user?.profileImageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(60),
                              child: Image.network(
                                '${AppConfig.baseUrl}${authProvider.user!.profileImageUrl}',
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.person,
                                    size: 60,
                                    color: Colors.white,
                                  );
                                },
                              ),
                            )
                          : const Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.white,
                            ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _showImageSourceSelection,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.primaryColor,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '프로필 사진을 변경하려면 탭하세요',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProfileForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '기본 정보',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            return CustomTextField(
              controller: TextEditingController(text: authProvider.user?.email ?? ''),
              label: '이메일',
              enabled: false,
              prefixIcon: Icons.email,
            );
          },
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _fullNameController,
          label: '이름',
          prefixIcon: Icons.person,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '이름을 입력해주세요';
            }
            if (value.trim().length < 2) {
              return '이름은 2글자 이상 입력해주세요';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return CustomButton(
      text: '저장하기',
      onPressed: _isLoading ? null : _saveProfile,
      isLoading: _isLoading,
    );
  }
}