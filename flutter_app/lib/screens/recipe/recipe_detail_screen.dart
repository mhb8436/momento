import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/theme.dart';
import '../../models/recipe.dart';
import '../../providers/recipe_provider.dart';
import '../../services/tts/tts_service.dart';
import '../../services/share/recipe_share_service.dart';
import '../../services/community/community_service.dart';
import '../../widgets/common/custom_icon_button.dart';
import 'recipe_edit_screen.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailScreen({
    super.key,
    required this.recipe,
  });

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isFavorite = false;
  final TTSService _ttsService = TTSService();
  final CommunityService _communityService = CommunityService();
  TtsState _ttsState = TtsState.stopped;
  int _currentStepIndex = -1; // -1: 재료/요약, 0이상: 조리 단계
  bool _isRepeating = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeTTS();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _ttsService.dispose();
    super.dispose();
  }

  void _initializeTTS() async {
    await _ttsService.initialize();
    _ttsService.onStateChanged = (state) {
      if (mounted) {
        setState(() {
          _ttsState = state;
        });
      }
    };
    _ttsService.onStepChanged = (stepIndex) {
      if (mounted) {
        setState(() {
          _currentStepIndex = stepIndex;
        });
      }
    };
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
                  child: Column(
                    children: [
                      _buildHeader(),
                      _buildTTSControls(),
                      _buildTabBar(),
                      SizedBox(
                        height: 400, // 고정 높이로 TabBarView 제한
                        child: _buildTabBarView(),
                      ),
                    ],
                  ),
                ),
              ),
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
          CustomIconButton(
            icon: _isFavorite ? Icons.favorite : Icons.favorite_border,
            onPressed: _toggleFavorite,
            backgroundColor: Colors.white,
            iconColor: _isFavorite ? AppTheme.errorColor : null,
          ),
          const SizedBox(width: 8),
          CustomIconButton(
            icon: Icons.share,
            onPressed: _shareRecipe,
            backgroundColor: Colors.white,
          ),
          const SizedBox(width: 8),
          CustomIconButton(
            icon: Icons.more_vert,
            onPressed: _showMoreOptions,
            backgroundColor: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
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
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: widget.recipe.imageUrl != null && widget.recipe.imageUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: CachedNetworkImage(
                          imageUrl: widget.recipe.imageUrl!,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.restaurant,
                              color: Colors.white,
                              size: 36,
                            ),
                          ),
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.restaurant,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.recipe.title,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (widget.recipe.description != null)
                      Text(
                        widget.recipe.description!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              if (widget.recipe.servings != null)
                _buildInfoChip(
                  icon: Icons.people_outline,
                  label: widget.recipe.servings!,
                  color: AppTheme.primaryColor,
                ),
              if (widget.recipe.cookingTime != null)
                _buildInfoChip(
                  icon: Icons.access_time,
                  label: widget.recipe.cookingTime!,
                  color: AppTheme.secondaryColor,
                ),
              if (widget.recipe.difficulty != null)
                _buildInfoChip(
                  icon: Icons.trending_up,
                  label: widget.recipe.difficulty!,
                  color: _getDifficultyColor(widget.recipe.difficulty!),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 4),
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

  Widget _buildTTSControls() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
        children: [
          Row(
            children: [
              Icon(
                Icons.volume_up,
                color: AppTheme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '음성 안내',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const Spacer(),
              if (_ttsState == TtsState.playing) ...[
                Text(
                  '단계 ${_currentStepIndex + 1}/${widget.recipe.steps?.length ?? 0}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 플레이/정지 토글 버튼
              GestureDetector(
                onTap: _toggleRecipeReading,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: _isRepeating 
                        ? LinearGradient(
                            colors: [Colors.red.shade400, Colors.red.shade600],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : AppTheme.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (_isRepeating ? Colors.red : AppTheme.primaryColor).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    _isRepeating ? Icons.stop : Icons.play_arrow,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              // 상태 텍스트
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isRepeating ? '재생 중...' : '전체 레시피 읽기',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isRepeating 
                          ? (_ttsState == TtsState.playing 
                              ? (_currentStepIndex < 0 
                                  ? '제목·재료 읽는 중...'
                                  : '조리 단계 ${_currentStepIndex + 1}/${widget.recipe.steps?.length ?? 0}')
                              : '일시정지')
                          : '제목 → 재료 → 조리법 → 팁 반복',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppTheme.primaryColor,
        unselectedLabelColor: AppTheme.textLight,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 14,
        ),
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppTheme.primaryColor.withOpacity(0.1),
        ),
        indicatorPadding: const EdgeInsets.symmetric(horizontal: -8, vertical: 4),
        tabs: const [
          Tab(text: '재료'),
          Tab(text: '조리법'),
          Tab(text: '팁'),
        ],
      ),
    );
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildIngredientsTab(),
        _buildStepsTab(),
        _buildTipsTab(),
      ],
    );
  }

  Widget _buildIngredientsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '재료 (${widget.recipe.ingredients?.length ?? 0}개)',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...(widget.recipe.ingredients ?? []).map((ingredient) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                ingredient.name,
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ),
                            if (ingredient.amount != null)
                              Text(
                                ingredient.amount!,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                          ],
                        ),
                        if (ingredient.notes != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            ingredient.notes!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 100), // Space for FAB
        ],
      ),
    );
  }

  Widget _buildStepsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '조리 순서 (${widget.recipe.steps?.length ?? 0}단계)',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...(widget.recipe.steps ?? []).asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            final isCurrentStep = _isRepeating && _currentStepIndex == index;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isCurrentStep ? AppTheme.primaryColor.withOpacity(0.1) : Colors.white,
                border: isCurrentStep ? Border.all(color: AppTheme.primaryColor, width: 2) : null,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${step.step}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step.instruction,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.textPrimary,
                            height: 1.5,
                          ),
                        ),
                        if (step.time != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 16,
                                color: AppTheme.textLight,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                step.time!,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppTheme.textLight,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _ttsService.readStep(widget.recipe, index),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.volume_up,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 100), // Space for FAB
        ],
      ),
    );
  }

  Widget _buildTipsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '요리 팁',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          if (widget.recipe.tips != null) ...[
            Container(
              padding: const EdgeInsets.all(20),
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
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: AppTheme.accentColor,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.recipe.tips!,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textPrimary,
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 48,
                    color: AppTheme.textLight,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '아직 등록된 팁이 없어요',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 100), // Space for FAB
        ],
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case '쉬움':
        return Colors.green;
      case '보통':
        return Colors.orange;
      case '어려움':
        return Colors.red;
      default:
        return AppTheme.textLight;
    }
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
    
    // TODO: Implement favorite functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isFavorite ? '즐겨찾기에 추가했습니다' : '즐겨찾기에서 제거했습니다'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  void _shareRecipe() {
    // 안정성을 위해 텍스트 공유만 제공
    RecipeShareService().shareRecipeText(widget.recipe, context);
  }

  void _showMoreOptions() {
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
            ListTile(
              leading: Icon(
                widget.recipe.isPublic ? Icons.public : Icons.lock,
                color: widget.recipe.isPublic ? AppTheme.primaryColor : AppTheme.textSecondary,
              ),
              title: Text('공개 설정: ${widget.recipe.visibilityDisplay}'),
              subtitle: Text(widget.recipe.isPublic ? '다른 사용자들이 볼 수 있어요' : '나만 볼 수 있어요'),
              onTap: () {
                Navigator.pop(context);
                _showVisibilitySettings();
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('레시피 수정'),
              onTap: () {
                Navigator.pop(context);
                _editRecipe();
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('레시피 복사'),
              onTap: () {
                Navigator.pop(context);
                _copyRecipe();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: AppTheme.errorColor),
              title: const Text('레시피 삭제', style: TextStyle(color: AppTheme.errorColor)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _editRecipe() async {
    final result = await Navigator.push<Recipe>(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeEditScreen(recipe: widget.recipe),
      ),
    );
    
    if (result != null) {
      // 수정된 레시피로 현재 화면 업데이트
      Navigator.pop(context, result);
    }
  }

  void _copyRecipe() {
    // TODO: Implement copy functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('레시피 복사 기능 구현 예정'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('레시피 삭제'),
        content: const Text('정말로 이 레시피를 삭제하시겠습니까?\n삭제된 레시피는 복구할 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              _deleteRecipe();
            },
            child: const Text('삭제', style: TextStyle(color: AppTheme.errorColor)),
          ),
        ],
      ),
    );
  }

  void _toggleRecipeReading() {
    setState(() {
      _isRepeating = !_isRepeating;
      if (!_isRepeating) {
        _currentStepIndex = -1; // 정지시 초기화
      }
    });

    if (_isRepeating) {
      _ttsService.startReadingRecipe(widget.recipe);
    } else {
      _ttsService.stop();
    }
  }

  void _showVisibilitySettings() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.visibility,
                      color: AppTheme.primaryColor,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '공개 설정',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '레시피를 누구와 공유할지 선택해주세요',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),
                
                // 나만 보기와 모든 사용자 보기만 표시
                _buildVisibilityOption(RecipeVisibility.private),
                _buildVisibilityOption(RecipeVisibility.public),
                
                // 하단 여백 추가 (안전 영역 확보)
                SizedBox(height: MediaQuery.of(context).padding.bottom + 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVisibilityOption(RecipeVisibility visibility) {
    final isSelected = widget.recipe.visibility == visibility;
    String title, subtitle, emoji;
    
    switch (visibility) {
      case RecipeVisibility.private:
        title = '나만 보기';
        subtitle = '레시피를 비공개로 보관합니다';
        emoji = '🔒';
        break;
      case RecipeVisibility.public:
        title = '모든 사용자';
        subtitle = '모든 MOMENTO 사용자와 공유합니다';
        emoji = '🌍';
        break;
      default:
        // family, neighborhood는 UI에 표시하지 않지만 기존 데이터 호환성을 위해 유지
        title = '나만 보기';
        subtitle = '레시피를 비공개로 보관합니다';
        emoji = '🔒';
        break;
    }

    return GestureDetector(
      onTap: () => _updateVisibility(visibility),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : AppTheme.textLight,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppTheme.primaryColor,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateVisibility(RecipeVisibility newVisibility) async {
    if (widget.recipe.visibility == newVisibility) {
      Navigator.pop(context);
      return;
    }

    // 로딩 다이얼로그 표시
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
              '공개 설정을 업데이트하고 있습니다...',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );

    try {
      final success = await _communityService.updateRecipeVisibility(
        widget.recipe.id,
        newVisibility,
      );

      if (mounted) {
        Navigator.pop(context); // 로딩 다이얼로그 닫기
        Navigator.pop(context); // 설정 다이얼로그 닫기

        if (success) {
          // 성공 메시지 표시
          String message;
          switch (newVisibility) {
            case RecipeVisibility.private:
              message = '레시피를 비공개로 설정했습니다';
              break;
            case RecipeVisibility.family:
              message = '가족들과만 공유하도록 설정했습니다';
              break;
            case RecipeVisibility.neighborhood:
              message = '동네 맘들과 공유하도록 설정했습니다';
              break;
            case RecipeVisibility.public:
              message = '모든 사용자와 공유하도록 설정했습니다';
              break;
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: AppTheme.primaryColor,
              behavior: SnackBarBehavior.floating,
            ),
          );

          // 상태 업데이트 (실제 앱에서는 Provider나 상태 관리를 통해)
          setState(() {
            // widget.recipe = widget.recipe.copyWith(visibility: newVisibility);
            // 실제로는 Recipe 객체를 직접 수정할 수 없으므로, 
            // Provider나 상태 관리 시스템을 통해 업데이트해야 합니다.
          });

        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('공개 설정 변경에 실패했습니다'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // 로딩 다이얼로그 닫기
        Navigator.pop(context); // 설정 다이얼로그 닫기

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('오류가 발생했습니다: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  void _deleteRecipe() async {
    final recipeProvider = context.read<RecipeProvider>();
    
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('레시피를 삭제하고 있습니다...'),
          ],
        ),
      ),
    );

    final success = await recipeProvider.deleteRecipe(widget.recipe.id);
    
    if (mounted) {
      Navigator.pop(context); // Close loading dialog
      
      if (success) {
        Navigator.pop(context); // Go back to list
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('레시피가 삭제되었습니다'),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('삭제 실패: ${recipeProvider.errorMessage}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }
}