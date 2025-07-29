import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/audio_provider.dart';
import '../../models/audio_file.dart';
import '../../widgets/common/custom_icon_button.dart';
import '../recording/recording_screen.dart';

class AudioListScreen extends StatefulWidget {
  const AudioListScreen({super.key});

  @override
  State<AudioListScreen> createState() => _AudioListScreenState();
}

class _AudioListScreenState extends State<AudioListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AudioProvider>().loadAudioFiles();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: _buildAudioList(),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '녹음 파일',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
              ),
              const SizedBox(height: 4),
              Consumer<AudioProvider>(
                builder: (context, audioProvider, _) {
                  return Text(
                    '총 ${audioProvider.audioFiles.length}개의 파일',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  );
                },
              ),
            ],
          ),
          const Spacer(),
          CustomIconButton(
            icon: Icons.mic,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RecordingScreen(),
                ),
              );
            },
            backgroundColor: AppTheme.primaryColor,
            iconColor: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildAudioList() {
    return Consumer<AudioProvider>(
      builder: (context, audioProvider, _) {
        if (audioProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (audioProvider.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppTheme.errorColor,
                ),
                const SizedBox(height: 16),
                Text(
                  '오디오 파일을 불러올 수 없습니다',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  audioProvider.errorMessage!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textLight,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => audioProvider.loadAudioFiles(),
                  child: const Text('다시 시도'),
                ),
              ],
            ),
          );
        }

        if (audioProvider.audioFiles.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () => audioProvider.loadAudioFiles(),
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: audioProvider.audioFiles.length,
            itemBuilder: (context, index) {
              return _buildAudioCard(audioProvider.audioFiles[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.mic_none_outlined,
            size: 64,
            color: AppTheme.textLight,
          ),
          const SizedBox(height: 16),
          Text(
            '아직 녹음 파일이 없어요',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '첫 번째 요리 레시피를 녹음해보세요!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textLight,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RecordingScreen(),
                ),
              );
            },
            icon: const Icon(Icons.mic),
            label: const Text('녹음 시작'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioCard(AudioFile audioFile) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: _getStatusGradient(audioFile.processingStatus),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getStatusIcon(audioFile.processingStatus),
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              audioFile.fileName ?? '녹음 파일',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPrimary,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          _buildStatusChip(audioFile.processingStatus),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: AppTheme.textLight,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDuration(audioFile.duration),
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppTheme.textLight,
                                    ),
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            Icons.folder_outlined,
                            size: 16,
                            color: AppTheme.textLight,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatFileSize(audioFile.fileSize),
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppTheme.textLight,
                                    ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _showAudioOptions(audioFile),
                  icon: const Icon(Icons.more_vert),
                  color: AppTheme.textLight,
                ),
              ],
            ),
            if (audioFile.transcriptText != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '음성 변환 결과',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      audioFile.transcriptText!.length > 100
                          ? '${audioFile.transcriptText!.substring(0, 100)}...'
                          : audioFile.transcriptText!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textPrimary,
                          ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  _formatDate(audioFile.createdAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textLight,
                      ),
                ),
                const Spacer(),
                if (audioFile.processingStatus == 'completed' &&
                    audioFile.recipeId != null)
                  TextButton.icon(
                    onPressed: () => _viewGeneratedRecipe(audioFile.recipeId!),
                    icon: const Icon(Icons.restaurant_menu, size: 16),
                    label: const Text('레시피 보기'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;

    switch (status.toLowerCase()) {
      case 'completed':
        color = Colors.green;
        label = '완료';
        break;
      case 'processing':
        color = Colors.orange;
        label = '처리중';
        break;
      case 'failed':
        color = Colors.red;
        label = '실패';
        break;
      default:
        color = AppTheme.textLight;
        label = '대기';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }

  LinearGradient _getStatusGradient(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return const LinearGradient(
          colors: [Colors.green, Color(0xFF66BB6A)],
        );
      case 'processing':
        return const LinearGradient(
          colors: [Colors.orange, Color(0xFFFFB74D)],
        );
      case 'failed':
        return const LinearGradient(
          colors: [Colors.red, Color(0xFFE57373)],
        );
      default:
        return AppTheme.primaryGradient;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Icons.check_circle;
      case 'processing':
        return Icons.sync;
      case 'failed':
        return Icons.error;
      default:
        return Icons.mic;
    }
  }

  String _formatDuration(int? durationSeconds) {
    if (durationSeconds == null) return '알 수 없음';

    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String _formatFileSize(int? sizeBytes) {
    if (sizeBytes == null) return '알 수 없음';

    if (sizeBytes < 1024) {
      return '${sizeBytes}B';
    } else if (sizeBytes < 1024 * 1024) {
      return '${(sizeBytes / 1024).toStringAsFixed(1)}KB';
    } else {
      return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return '오늘 ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return '어제 ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}일 전';
    } else {
      return '${date.month}/${date.day}';
    }
  }

  void _viewGeneratedRecipe(String recipeId) {
    // TODO: Navigate to recipe detail
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('레시피 보기 기능 구현 예정'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  void _showAudioOptions(AudioFile audioFile) {
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
            if (audioFile.processingStatus == 'pending') ...[
              ListTile(
                leading: const Icon(Icons.play_arrow),
                title: const Text('처리 시작'),
                onTap: () {
                  Navigator.pop(context);
                  _processAudio(audioFile);
                },
              ),
            ],
            if (audioFile.processingStatus == 'completed' &&
                audioFile.recipeId != null)
              ListTile(
                leading: const Icon(Icons.restaurant_menu),
                title: const Text('생성된 레시피 보기'),
                onTap: () {
                  Navigator.pop(context);
                  _viewGeneratedRecipe(audioFile.recipeId!);
                },
              ),
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('파일 다운로드'),
              onTap: () {
                Navigator.pop(context);
                _downloadFile(audioFile);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('공유'),
              onTap: () {
                Navigator.pop(context);
                _shareFile(audioFile);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: AppTheme.errorColor),
              title: const Text('삭제',
                  style: TextStyle(color: AppTheme.errorColor)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(audioFile);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _processAudio(AudioFile audioFile) {
    final audioProvider = context.read<AudioProvider>();
    audioProvider.processAudio(audioFile.id);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('오디오 처리를 시작했습니다'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  void _downloadFile(AudioFile audioFile) {
    // TODO: Implement download functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('파일 다운로드 기능 구현 예정'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  void _shareFile(AudioFile audioFile) {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('파일 공유 기능 구현 예정'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  void _showDeleteConfirmation(AudioFile audioFile) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('파일 삭제'),
        content: const Text('정말로 이 오디오 파일을 삭제하시겠습니까?\n삭제된 파일은 복구할 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteFile(audioFile);
            },
            child:
                const Text('삭제', style: TextStyle(color: AppTheme.errorColor)),
          ),
        ],
      ),
    );
  }

  void _deleteFile(AudioFile audioFile) {
    final audioProvider = context.read<AudioProvider>();
    audioProvider.deleteAudioFile(audioFile.id);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('파일이 삭제되었습니다'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }
}
