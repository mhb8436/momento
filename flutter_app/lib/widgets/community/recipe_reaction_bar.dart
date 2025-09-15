import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/recipe.dart';
import '../../services/community/community_service.dart';

class RecipeReactionBar extends StatefulWidget {
  final Recipe recipe;
  final Function(Recipe)? onReactionChanged;

  const RecipeReactionBar({
    super.key,
    required this.recipe,
    this.onReactionChanged,
  });

  @override
  State<RecipeReactionBar> createState() => _RecipeReactionBarState();
}

class _RecipeReactionBarState extends State<RecipeReactionBar> {
  final CommunityService _communityService = CommunityService();
  bool _isUpdating = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '이 레시피는 어떠세요?',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildReactionButton(
                type: RecipeReactionType.warm,
                emoji: '❤️',
                label: '따뜻해요',
                color: Colors.red.shade400,
              ),
              _buildReactionButton(
                type: RecipeReactionType.delicious,
                emoji: '👍',
                label: '맛있어요',
                color: Colors.orange.shade400,
              ),
              _buildReactionButton(
                type: RecipeReactionType.nostalgic,
                emoji: '🥰',
                label: '추억이에요',
                color: Colors.pink.shade400,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildReactionButton(
                type: RecipeReactionType.familyLoved,
                emoji: '💝',
                label: '가족이 좋아해요',
                color: Colors.purple.shade400,
              ),
              _buildReactionButton(
                type: RecipeReactionType.wantToTry,
                emoji: '🔥',
                label: '도전해볼게요',
                color: Colors.blue.shade400,
              ),
              const SizedBox(width: 80), // 균형을 위한 빈 공간
            ],
          ),
          if (widget.recipe.totalReactions > 0) ...[ 
            const SizedBox(height: 16),
            _buildReactionSummary(),
          ],
        ],
      ),
    );
  }

  Widget _buildReactionButton({
    required RecipeReactionType type,
    required String emoji,
    required String label,
    required Color color,
  }) {
    final count = widget.recipe.reactionCounts?[type.name] ?? 0;
    final hasReacted = false; // TODO: 사용자가 이미 리액션했는지 체크
    
    return GestureDetector(
      onTap: _isUpdating ? null : () => _handleReaction(type),
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: hasReacted ? color.withOpacity(0.1) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: hasReacted ? Border.all(color: color, width: 1) : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: hasReacted ? FontWeight.w600 : FontWeight.normal,
                color: hasReacted ? color : AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (count > 0) ...[ 
              const SizedBox(height: 2),
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: hasReacted ? color : AppTheme.textLight,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReactionSummary() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.favorite_outline,
            size: 16,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(width: 8),
          Text(
            '${widget.recipe.totalReactions}명이 이 레시피를 좋아해요',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          _buildTopReactions(),
        ],
      ),
    );
  }

  Widget _buildTopReactions() {
    if (widget.recipe.reactionCounts == null) return const SizedBox();
    
    final sortedReactions = widget.recipe.reactionCounts!.entries
        .where((entry) => entry.value > 0)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final topReactions = sortedReactions.take(3).toList();
    
    return Row(
      children: topReactions.map((entry) {
        final emoji = _getReactionEmoji(entry.key);
        return Padding(
          padding: const EdgeInsets.only(left: 2),
          child: Text(
            emoji,
            style: const TextStyle(fontSize: 14),
          ),
        );
      }).toList(),
    );
  }

  String _getReactionEmoji(String reactionType) {
    switch (reactionType) {
      case 'warm':
        return '❤️';
      case 'delicious':
        return '👍';
      case 'nostalgic':
        return '🥰';
      case 'familyLoved':
        return '💝';
      case 'wantToTry':
        return '🔥';
      default:
        return '👍';
    }
  }

  Future<void> _handleReaction(RecipeReactionType type) async {
    if (_isUpdating) return;
    
    setState(() {
      _isUpdating = true;
    });

    try {
      final success = await _communityService.toggleReaction(widget.recipe.id, type);
      
      if (success) {
        // 리액션 수 업데이트 (실제로는 서버에서 새 데이터를 받아와야 함)
        final currentCount = widget.recipe.reactionCounts?[type.name] ?? 0;
        final newReactionCounts = Map<String, int>.from(widget.recipe.reactionCounts ?? {});
        newReactionCounts[type.name] = currentCount + 1;
        
        final updatedRecipe = widget.recipe.copyWith(
          reactionCounts: newReactionCounts,
          totalReactions: widget.recipe.totalReactions + 1,
        );
        
        widget.onReactionChanged?.call(updatedRecipe);
        
        // 햅틱 피드백
        _showReactionFeedback(type);
      } else {
        _showErrorSnackbar('리액션을 추가할 수 없습니다. 다시 시도해주세요.');
      }
    } catch (e) {
      _showErrorSnackbar('네트워크 오류가 발생했습니다.');
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  void _showReactionFeedback(RecipeReactionType type) {
    String message;
    switch (type) {
      case RecipeReactionType.warm:
        message = '❤️ 따뜻한 마음을 전했어요!';
        break;
      case RecipeReactionType.delicious:
        message = '👍 맛있다고 표현했어요!';
        break;
      case RecipeReactionType.nostalgic:
        message = '🥰 추억이 담긴 레시피네요!';
        break;
      case RecipeReactionType.familyLoved:
        message = '💝 가족이 좋아할 레시피로 저장했어요!';
        break;
      case RecipeReactionType.wantToTry:
        message = '🔥 도전할 레시피로 북마크했어요!';
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}