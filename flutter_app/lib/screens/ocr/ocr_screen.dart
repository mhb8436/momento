import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/audio_provider.dart';
import '../../providers/recipe_provider.dart';
import '../../services/text_recognition/ocr_service.dart';
import '../../widgets/common/custom_icon_button.dart';

class OCRScreen extends StatefulWidget {
  const OCRScreen({super.key});

  @override
  State<OCRScreen> createState() => _OCRScreenState();
}

class _OCRScreenState extends State<OCRScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  File? _selectedImage;
  OCRResult? _ocrResult;
  RecipeOCRInfo? _recipeInfo;
  bool _isProcessing = false;
  String? _errorMessage;
  
  final ImagePicker _picker = ImagePicker();
  final OCRService _ocrService = OCRService.instance;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _initializeOCRService();
  }

  Future<void> _initializeOCRService() async {
    await _ocrService.initialize();
  }

  @override
  void dispose() {
    _pulseController.dispose();
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
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _buildImageSelection(),
                      if (_selectedImage != null) ...[
                        const SizedBox(height: 24),
                        _buildImagePreview(),
                      ],
                      if (_ocrResult != null && _ocrResult!.hasText) ...[
                        const SizedBox(height: 24),
                        _buildOCRResult(),
                      ],
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 24),
                        _buildErrorMessage(),
                      ],
                      const SizedBox(height: 100), // Space for bottom buttons
                    ],
                  ),
                ),
              ),
              _buildBottomControls(),
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
          CustomIconButton(
            icon: Icons.arrow_back,
            onPressed: () => Navigator.pop(context),
            backgroundColor: Colors.white,
          ),
          const Spacer(),
          Text(
            '레시피 스캔',
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

  Widget _buildImageSelection() {
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
          Icon(
            Icons.document_scanner_outlined,
            size: 64,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            _selectedImage == null ? '레시피 이미지를 선택하세요' : '다른 이미지 선택',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '손글씨 레시피 노트, 요리책, 잡지 등의\n사진을 찍거나 갤러리에서 선택하세요',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildSelectionButton(
                  icon: Icons.camera_alt,
                  label: '카메라',
                  subtitle: '사진 촬영',
                  gradient: AppTheme.primaryGradient,
                  onTap: () => _pickImage(ImageSource.camera),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSelectionButton(
                  icon: Icons.photo_library,
                  label: '갤러리',
                  subtitle: '사진 선택',
                  gradient: const LinearGradient(
                    colors: [AppTheme.secondaryColor, Color(0xFF26D0CE)],
                  ),
                  onTap: () => _pickImage(ImageSource.gallery),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionButton({
    required IconData icon,
    required String label,
    required String subtitle,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
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
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.image,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '선택된 이미지',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const Spacer(),
                if (_isProcessing)
                  Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '처리 중...',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                _selectedImage!,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isProcessing ? null : _processImage,
                    icon: Icon(_isProcessing ? Icons.hourglass_empty : Icons.text_fields),
                    label: Text(_isProcessing ? '텍스트 인식 중...' : '텍스트 인식 시작'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOCRResult() {
    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.text_snippet,
                color: AppTheme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '인식된 텍스트',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getConfidenceColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '정확도 ${(_recipeInfo?.confidence ?? 0.5 * 100).toInt()}%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _getConfidenceColor(),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.primaryColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_recipeInfo?.title != null) ...[
                  Text(
                    '제목',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _recipeInfo!.title!,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                Text(
                  _recipeInfo?.hasStructuredData == true ? '구조화된 레시피' : '전체 텍스트',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _recipeInfo?.toFormattedString() ?? _ocrResult!.fullText,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.errorColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: AppTheme.errorColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.errorColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Cancel Button
          _buildControlButton(
            icon: Icons.close,
            label: '취소',
            color: AppTheme.textLight,
            onTap: () => Navigator.pop(context),
          ),
          
          // Process Image Button
          _buildControlButton(
            icon: Icons.document_scanner,
            label: '다시 스캔',
            color: _selectedImage != null ? AppTheme.primaryColor : AppTheme.textLight,
            onTap: _selectedImage != null ? _processImage : null,
          ),
          
          // Create Recipe Button
          _buildControlButton(
            icon: Icons.restaurant_menu,
            label: '레시피\n작성',
            color: (_ocrResult != null && _ocrResult!.hasText)
                ? AppTheme.primaryColor 
                : AppTheme.textLight,
            onTap: (_ocrResult != null && _ocrResult!.hasText)
                ? _processRecipe 
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.1),
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getConfidenceColor() {
    final confidence = _recipeInfo?.confidence ?? 0.5;
    if (confidence >= 0.8) return Colors.green;
    if (confidence >= 0.6) return Colors.orange;
    return AppTheme.errorColor;
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _ocrResult = null;
          _recipeInfo = null;
          _errorMessage = null;
        });
        
        // Automatically process image after selection
        await _processImage();
      }
    } catch (e) {
      String errorMsg = '이미지를 선택할 수 없습니다';
      if (e.toString().contains('camera_access_denied')) {
        errorMsg = '카메라 접근 권한이 필요합니다. 설정에서 권한을 허용해주세요.';
      } else if (e.toString().contains('photo_access_denied')) {
        errorMsg = '사진 라이브러리 접근 권한이 필요합니다. 설정에서 권한을 허용해주세요.';
      } else if (e.toString().contains('camera_access_restricted')) {
        errorMsg = '카메라 접근이 제한되어 있습니다.';
      }
      
      setState(() {
        _errorMessage = errorMsg;
      });
      
      // Show permission dialog if needed
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: AppTheme.errorColor,
            action: SnackBarAction(
              label: '설정',
              textColor: Colors.white,
              onPressed: () {
                // Could open app settings here if needed
              },
            ),
          ),
        );
      }
    }
  }

  Future<void> _processImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
      _pulseController.repeat();
    });

    try {
      final result = await _ocrService.extractTextFromImage(_selectedImage!);
      
      if (result.success && result.hasText) {
        final recipeInfo = _ocrService.extractRecipeInfo(result.fullText);
        
        setState(() {
          _ocrResult = result;
          _recipeInfo = recipeInfo;
          _isProcessing = false;
        });
      } else {
        setState(() {
          _errorMessage = result.error ?? '텍스트를 인식할 수 없습니다. 이미지가 선명한지 확인해주세요.';
          _isProcessing = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'OCR 처리 중 오류가 발생했습니다: $e';
        _isProcessing = false;
      });
    } finally {
      _pulseController.stop();
    }
  }

  Future<void> _processRecipe() async {
    if (_ocrResult == null || !_ocrResult!.hasText) return;

    final finalText = _recipeInfo?.toFormattedString() ?? _ocrResult!.fullText;

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              '이미지 텍스트를 분석하고 레시피를 생성하고 있습니다...',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '총 ${finalText.length}자의 내용을 처리 중입니다.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );

    try {
      // Process OCR text and create recipe using AudioProvider's method
      final audioProvider = context.read<AudioProvider>();
      audioProvider.setTranscriptFromOCR(finalText);
      
      final success = await audioProvider.processTranscriptAndCreateRecipe();
      
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        
        if (success) {
          // Navigate back to home and show success message
          Navigator.pop(context);
          
          // Refresh recipe list on home screen
          if (mounted) {
            context.read<RecipeProvider>().loadRecipes();
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🎉 이미지에서 레시피가 성공적으로 생성되었습니다!'),
              backgroundColor: AppTheme.primaryColor,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('처리 중 오류가 발생했습니다: ${audioProvider.errorMessage}'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('처리 중 오류가 발생했습니다: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }
}