import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../l10n/app_localizations.dart';
import '../../config/theme.dart';
import '../../providers/audio_provider.dart';
import '../../providers/recipe_provider.dart';
import '../../widgets/common/custom_icon_button.dart';
import '../../widgets/credit/credit_required_dialog.dart';
import '../../services/cache_service.dart';

class RecordingScreen extends StatefulWidget {
  const RecordingScreen({super.key});

  @override
  State<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _waveController;
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _checkNetworkStatus();
  }
  
  Future<void> _checkNetworkStatus() async {
    final isOffline = await CacheService.isOffline();
    if (mounted) {
      setState(() {
        _isOffline = isOffline;
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
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
                child: _buildRecognitionArea(),
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
            AppLocalizations.of(context)!.voiceRecognition,
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

  Widget _buildRecognitionArea() {
    return Consumer<AudioProvider>(
      builder: (context, audioProvider, _) {
        return SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            // Offline Warning
            if (_isOffline)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.wifi_off,
                      color: Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.offlineRecognition,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            
            // Recognition Status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: audioProvider.isListening 
                    ? AppTheme.primaryColor.withOpacity(0.1)
                    : AppTheme.textLight.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: audioProvider.isListening 
                          ? AppTheme.primaryColor 
                          : AppTheme.textLight,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    audioProvider.isListening ? AppLocalizations.of(context)!.recognizing : AppLocalizations.of(context)!.waiting,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: audioProvider.isListening 
                          ? AppTheme.primaryColor 
                          : AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Accumulated transcript display (전체 누적 내용)
            if (audioProvider.hasAccumulatedText)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                padding: const EdgeInsets.all(16),
                constraints: const BoxConstraints(maxHeight: 120),
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
                    Row(
                      children: [
                        Icon(
                          Icons.history,
                          color: AppTheme.primaryColor,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          AppLocalizations.of(context)!.accumulatedContent(audioProvider.accumulatedTranscript.length),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => audioProvider.clearAccumulated(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.errorColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.initialize,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.errorColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        child: SelectionContainer.disabled(
                          child: Text(
                            audioProvider.accumulatedTranscript,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Real-time transcript display (현재 세션)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              constraints: const BoxConstraints(minHeight: 120),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: audioProvider.isListening 
                      ? AppTheme.primaryColor.withOpacity(0.3)
                      : Colors.grey.withOpacity(0.2),
                  width: 2,
                ),
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
                        Icons.mic,
                        color: audioProvider.isListening ? AppTheme.primaryColor : AppTheme.textLight,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        audioProvider.isListening ? AppLocalizations.of(context)!.currentlyRecognizing : AppLocalizations.of(context)!.waitingForVoice,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: audioProvider.isListening ? AppTheme.primaryColor : AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    child: audioProvider.currentTranscript.isNotEmpty
                        ? Text(
                            audioProvider.currentTranscript,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textPrimary,
                              height: 1.5,
                              fontWeight: FontWeight.w500,
                            ),
                            selectionColor: Colors.transparent, // 선택 비활성화
                          )
                        : Text(
                            audioProvider.isListening 
                                ? '음성을 듣고 있습니다...'
                                : '음성 인식 버튼을 눌러 시작하세요',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textLight,
                              fontStyle: FontStyle.italic,
                            ),
                            selectionColor: Colors.transparent, // 선택 비활성화
                          ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Microphone Animation
            _buildMicrophoneAnimation(audioProvider),
            
            const SizedBox(height: 40),
            
            // Recognition Instructions
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
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
                    Icons.lightbulb_outline,
                    color: AppTheme.primaryColor,
                    size: 28,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    audioProvider.isListening 
                        ? AppLocalizations.of(context)!.speakRecipeDetails
                        : AppLocalizations.of(context)!.startVoiceRecognitionPrompt,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    audioProvider.isListening
                        ? AppLocalizations.of(context)!.includeIngredientsAndStepsLong
                        : AppLocalizations.of(context)!.allowMicrophonePermission,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            // Error message display
            if (audioProvider.errorMessage != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                        audioProvider.errorMessage!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.errorColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
          ),
        );
      },
    );
  }

  Widget _buildMicrophoneAnimation(AudioProvider audioProvider) {
    if (audioProvider.isListening) {
      _pulseController.repeat();
      _waveController.repeat();
    } else {
      _pulseController.stop();
      _waveController.stop();
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        // Animated waves
        if (audioProvider.isListening)
          ...List.generate(3, (index) {
            return AnimatedBuilder(
              animation: _waveController,
              builder: (context, child) {
                return Container(
                  width: 120 + (index * 40) * _waveController.value,
                  height: 120 + (index * 40) * _waveController.value,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.primaryColor.withOpacity(
                        0.3 * (1 - _waveController.value),
                      ),
                      width: 2,
                    ),
                  ),
                );
              },
            );
          }),
        
        // Microphone button
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Transform.scale(
              scale: audioProvider.isListening 
                  ? 1.0 + (_pulseController.value * 0.1)
                  : 1.0,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: audioProvider.isListening 
                      ? LinearGradient(
                          colors: [
                            AppTheme.primaryColor,
                            AppTheme.primaryColor.withOpacity(0.8),
                          ],
                        )
                      : AppTheme.primaryGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(
                  audioProvider.isListening ? Icons.mic : Icons.mic_none,
                  color: Colors.white,
                  size: 48,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBottomControls() {
    return Consumer<AudioProvider>(
      builder: (context, audioProvider, _) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Main controls
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Cancel Button
                  _buildControlButton(
                    icon: Icons.close,
                    label: '취소',
                    color: AppTheme.textLight,
                    onTap: () async {
                      if (audioProvider.isListening) {
                        await audioProvider.cancelListening();
                      }
                      Navigator.pop(context);
                    },
                  ),
                  
                  // Recognition Start/Stop Button
                  GestureDetector(
                    onTap: () async {
                      if (audioProvider.isListening) {
                        await _stopListening(audioProvider);
                      } else {
                        await _startListening(audioProvider);
                      }
                    },
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: audioProvider.isListening 
                            ? LinearGradient(
                                colors: [
                                  AppTheme.errorColor,
                                  AppTheme.errorColor.withOpacity(0.8),
                                ],
                              )
                            : AppTheme.primaryGradient,
                        boxShadow: [
                          BoxShadow(
                            color: (audioProvider.isListening 
                                ? AppTheme.errorColor 
                                : AppTheme.primaryColor).withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Icon(
                        audioProvider.isListening ? Icons.stop : Icons.mic,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                  
                  // Recipe Creation Button
                  _buildControlButton(
                    icon: Icons.restaurant_menu,
                    label: '레시피\n작성',
                    color: (audioProvider.currentTranscript.isNotEmpty || audioProvider.hasAccumulatedText)
                        ? AppTheme.primaryColor 
                        : AppTheme.textLight,
                    onTap: (audioProvider.currentTranscript.isNotEmpty || audioProvider.hasAccumulatedText)
                        ? () => _processTranscript(audioProvider) 
                        : null,
                  ),
                ],
              ),
              
              // Usage instruction
              if (audioProvider.currentTranscript.isNotEmpty || audioProvider.hasAccumulatedText)
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    audioProvider.hasAccumulatedText 
                        ? AppLocalizations.of(context)!.moreInstructionsVoice
                        : AppLocalizations.of(context)!.moreInstructionsVoiceAgain,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        );
      },
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
          ),
        ],
      ),
    );
  }

  Future<void> _startListening(AudioProvider audioProvider) async {
    try {
      audioProvider.clearError();
      final success = await audioProvider.startListening();
      
      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(audioProvider.errorMessage ?? '음성 인식을 시작할 수 없습니다'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      } else if (success && audioProvider.hasAccumulatedText && mounted) {
        // Show feedback when text is auto-accumulated
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('이전 내용이 자동으로 추가되었습니다'),
            backgroundColor: AppTheme.primaryColor,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('음성 인식을 시작할 수 없습니다: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _stopListening(AudioProvider audioProvider) async {
    try {
      await audioProvider.stopListening();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('음성 인식을 중지할 수 없습니다: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }


  Future<void> _processTranscript(AudioProvider audioProvider) async {
    final finalTranscript = audioProvider.getFinalTranscript();
    if (finalTranscript.isEmpty) return;

    // Show loading dialog with new style
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryColor.withOpacity(0.1),
                      AppTheme.secondaryColor.withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SpinKitPulsingGrid(
                  color: AppTheme.primaryColor,
                  size: 50,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                AppLocalizations.of(context)!.processingAndGenerating,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.processingCharactersCount(finalTranscript.length),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );

    try {
      // Process transcript and create recipe
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
            SnackBar(
              content: Text(AppLocalizations.of(context)!.recipeCreated),
              backgroundColor: AppTheme.primaryColor,
            ),
          );
        } else {
          // Check if credit purchase is needed
          if (audioProvider.needsCreditPurchase) {
            CreditRequiredDialog.show(
              context,
              action: '음성 레시피 생성',
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