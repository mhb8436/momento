import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../config/theme.dart';
import '../../providers/audio_provider.dart';
import '../../widgets/common/custom_icon_button.dart';

class RecordingScreen extends StatefulWidget {
  const RecordingScreen({super.key});

  @override
  State<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _waveController;
  Timer? _recordingTimer;
  int _recordingSeconds = 0;

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
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    _recordingTimer?.cancel();
    super.dispose();
  }

  void _startRecordingTimer() {
    _recordingSeconds = 0;
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _recordingSeconds++;
      });
    });
  }

  void _stopRecordingTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = null;
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
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
                child: _buildRecordingArea(),
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
            '음성 녹음',
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

  Widget _buildRecordingArea() {
    return Consumer<AudioProvider>(
      builder: (context, audioProvider, _) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Recording Status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: audioProvider.isRecording 
                    ? AppTheme.errorColor.withOpacity(0.1)
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
                      color: audioProvider.isRecording 
                          ? AppTheme.errorColor 
                          : AppTheme.textLight,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    audioProvider.isRecording ? '녹음 중' : '대기 중',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: audioProvider.isRecording 
                          ? AppTheme.errorColor 
                          : AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Recording Timer
            Text(
              _formatDuration(_recordingSeconds),
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: audioProvider.isRecording 
                    ? AppTheme.errorColor 
                    : AppTheme.textPrimary,
              ),
            ),
            
            const SizedBox(height: 60),
            
            // Microphone Animation
            _buildMicrophoneAnimation(audioProvider),
            
            const SizedBox(height: 40),
            
            // Recording Instructions
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
                    audioProvider.isRecording 
                        ? '요리법을 자세히 설명해주세요'
                        : '녹음 버튼을 눌러 시작하세요',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    audioProvider.isRecording
                        ? '재료, 조리법, 팁 등을 포함해서 말씀해주세요'
                        : '마이크 권한을 허용해주세요',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMicrophoneAnimation(AudioProvider audioProvider) {
    if (audioProvider.isRecording) {
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
        if (audioProvider.isRecording)
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
              scale: audioProvider.isRecording 
                  ? 1.0 + (_pulseController.value * 0.1)
                  : 1.0,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: audioProvider.isRecording 
                      ? LinearGradient(
                          colors: [
                            AppTheme.errorColor,
                            AppTheme.errorColor.withOpacity(0.8),
                          ],
                        )
                      : AppTheme.primaryGradient,
                  boxShadow: [
                    BoxShadow(
                      color: (audioProvider.isRecording 
                          ? AppTheme.errorColor 
                          : AppTheme.primaryColor).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.mic,
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
          padding: const EdgeInsets.all(32),
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
              
              // Record/Stop Button
              GestureDetector(
                onTap: () async {
                  if (audioProvider.isRecording) {
                    await _stopRecording(audioProvider);
                  } else {
                    await _startRecording(audioProvider);
                  }
                },
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: audioProvider.isRecording 
                        ? LinearGradient(
                            colors: [
                              AppTheme.errorColor,
                              AppTheme.errorColor.withOpacity(0.8),
                            ],
                          )
                        : AppTheme.primaryGradient,
                    boxShadow: [
                      BoxShadow(
                        color: (audioProvider.isRecording 
                            ? AppTheme.errorColor 
                            : AppTheme.primaryColor).withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    audioProvider.isRecording ? Icons.stop : Icons.mic,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
              
              // Done Button (only show when has recording)
              _buildControlButton(
                icon: Icons.check,
                label: '완료',
                color: audioProvider.hasRecording 
                    ? AppTheme.primaryColor 
                    : AppTheme.textLight,
                onTap: audioProvider.hasRecording 
                    ? () => _processRecording(audioProvider) 
                    : null,
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

  Future<void> _startRecording(AudioProvider audioProvider) async {
    try {
      await audioProvider.startRecording();
      if (audioProvider.isRecording) {
        _startRecordingTimer();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('녹음을 시작할 수 없습니다: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _stopRecording(AudioProvider audioProvider) async {
    try {
      await audioProvider.stopRecording();
      _stopRecordingTimer();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('녹음을 중지할 수 없습니다: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _processRecording(AudioProvider audioProvider) async {
    if (!audioProvider.hasRecording) return;

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
              '음성을 분석하고 있습니다...',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );

    try {
      // Upload audio and process recipe
      final success = await audioProvider.uploadAndProcessRecording();
      
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        
        if (success) {
          // Navigate back to home and show success message
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🎉 레시피가 성공적으로 생성되었습니다!'),
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