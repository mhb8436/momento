import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/theme.dart';
import '../../models/recipe.dart';
import '../../services/community/community_service.dart';
import '../../widgets/common/custom_icon_button.dart';
import '../../widgets/community/recipe_reaction_bar.dart';
import '../recipe/recipe_detail_screen.dart';
import 'recipe_search_screen.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final CommunityService _communityService = CommunityService();
  
  List<Recipe> _allRecipes = [];
  List<Recipe> _popularRecipes = [];
  List<Recipe> _bookmarkedRecipes = [];
  
  bool _isLoadingAll = false;
  bool _isLoadingPopular = false;
  bool _isLoadingBookmarks = false;
  
  String? _errorMessage;
  int _currentPage = 1;
  bool _hasMoreData = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAllData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    await Future.wait([
      _loadPublicRecipes(),
      _loadPopularRecipes(),
      _loadBookmarkedRecipes(),
    ]);
  }

  Future<void> _loadPublicRecipes({bool refresh = false}) async {
    if ((_isLoadingAll && !refresh) || (!_hasMoreData && !refresh)) return;
    
    setState(() {
      _isLoadingAll = true;
      if (refresh) {
        _allRecipes.clear();
        _currentPage = 1;
        _hasMoreData = true;
      }
      _errorMessage = null;
    });

    try {
      final recipes = await _communityService.getPublicRecipes(
        page: _currentPage,
        visibility: RecipeVisibility.public,
      );
      
      setState(() {
        if (refresh) {
          _allRecipes = recipes;
        } else {
          _allRecipes.addAll(recipes);
        }
        
        // 빈 결과가 반환되면 더 이상 데이터가 없음을 표시
        if (recipes.isEmpty) {
          _hasMoreData = false;
        } else {
          _currentPage++;
        }
        
        _isLoadingAll = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoadingAll = false;
      });
    }
  }

  Future<void> _loadPopularRecipes() async {
    setState(() {
      _isLoadingPopular = true;
    });

    try {
      final recipes = await _communityService.getPopularRecipes(period: 'week');
      setState(() {
        _popularRecipes = recipes;
        _isLoadingPopular = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingPopular = false;
      });
    }
  }

  Future<void> _loadBookmarkedRecipes() async {
    setState(() {
      _isLoadingBookmarks = true;
    });

    try {
      final recipes = await _communityService.getBookmarkedRecipes();
      setState(() {
        _bookmarkedRecipes = recipes;
        _isLoadingBookmarks = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingBookmarks = false;
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
          child: Column(
            children: [
              _buildAppBar(),
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildAllRecipesTab(),
                    _buildPopularRecipesTab(),
                    _buildBookmarkedRecipesTab(),
                  ],
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
          Text(
            '🍽️ MOMENTO 커뮤니티',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const Spacer(),
          CustomIconButton(
            icon: Icons.search,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RecipeSearchScreen(),
                ),
              );
            },
            backgroundColor: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
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
          Tab(text: '모든 레시피'),
          Tab(text: '인기 레시피'),
          Tab(text: '북마크'),
        ],
      ),
    );
  }

  Widget _buildAllRecipesTab() {
    if (_isLoadingAll && _allRecipes.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null && _allRecipes.isEmpty) {
      return _buildErrorState();
    }

    if (_allRecipes.isEmpty) {
      return _buildEmptyState('아직 공유된 레시피가 없어요', '첫 번째 레시피를 공유해보세요! 🍽️');
    }

    return RefreshIndicator(
      onRefresh: () => _loadPublicRecipes(refresh: true),
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _allRecipes.length + (_isLoadingAll ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _allRecipes.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            );
          }
          
          return _buildRecipeCard(_allRecipes[index], index == _allRecipes.length - 1 && _hasMoreData);
        },
      ),
    );
  }

  Widget _buildPopularRecipesTab() {
    if (_isLoadingPopular) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_popularRecipes.isEmpty) {
      return _buildEmptyState('인기 레시피가 없어요', '레시피에 리액션을 남겨보세요! ❤️');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _popularRecipes.length,
      itemBuilder: (context, index) {
        return _buildRecipeCard(_popularRecipes[index], false, showPopularBadge: true);
      },
    );
  }

  Widget _buildBookmarkedRecipesTab() {
    if (_isLoadingBookmarks) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_bookmarkedRecipes.isEmpty) {
      return _buildEmptyState('북마크한 레시피가 없어요', '마음에 드는 레시피를 북마크해보세요! 🔖');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _bookmarkedRecipes.length,
      itemBuilder: (context, index) {
        return _buildRecipeCard(_bookmarkedRecipes[index], false);
      },
    );
  }

  Widget _buildRecipeCard(Recipe recipe, bool shouldLoadMore, {bool showPopularBadge = false}) {
    // 마지막 아이템에서 추가 로드 (더 가져올 데이터가 있을 때만)
    if (shouldLoadMore && !_isLoadingAll && _hasMoreData) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadPublicRecipes();
      });
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 레시피 헤더 + 이미지
          _buildRecipeHeader(recipe, showPopularBadge),
          
          // 레시피 정보
          _buildRecipeInfo(recipe),
          
          // 리액션 바
          RecipeReactionBar(
            recipe: recipe,
            onReactionChanged: (updatedRecipe) {
              _updateRecipeInLists(updatedRecipe);
            },
          ),
          
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildRecipeHeader(Recipe recipe, bool showPopularBadge) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeDetailScreen(recipe: recipe),
          ),
        );
      },
      child: Stack(
        children: [
          // 배경 이미지
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              color: AppTheme.primaryColor.withOpacity(0.1),
            ),
            child: recipe.imageUrl != null && recipe.imageUrl!.isNotEmpty
                ? ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: CachedNetworkImage(
                      imageUrl: recipe.imageUrl!,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.restaurant,
                            size: 48,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  )
                : Container(
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.restaurant,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                  ),
          ),
          
          // 그라데이션 오버레이
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.3),
                ],
              ),
            ),
          ),
          
          // 인기 배지
          if (showPopularBadge)
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.shade500,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.local_fire_department,
                      size: 12,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '인기',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          // 북마크 버튼
          Positioned(
            top: 12,
            right: 12,
            child: GestureDetector(
              onTap: () => _toggleBookmark(recipe),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  recipe.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  size: 20,
                  color: recipe.isBookmarked ? AppTheme.primaryColor : AppTheme.textSecondary,
                ),
              ),
            ),
          ),
          
          // 레시피 제목 및 작성자
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipe.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        offset: Offset(0, 1),
                        blurRadius: 3,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (recipe.authorName != null) ...[ 
                  const SizedBox(height: 4),
                  Text(
                    'by ${recipe.authorName}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                      shadows: const [
                        Shadow(
                          offset: Offset(0, 1),
                          blurRadius: 2,
                          color: Colors.black54,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeInfo(Recipe recipe) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (recipe.description != null) ...[ 
            Text(
              recipe.description!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
          ],
          
          Row(
            children: [
              if (recipe.servings != null)
                _buildInfoChip(
                  icon: Icons.people_outline,
                  label: recipe.servings!,
                  color: AppTheme.primaryColor,
                ),
              if (recipe.cookingTime != null)
                _buildInfoChip(
                  icon: Icons.access_time,
                  label: recipe.cookingTime!,
                  color: AppTheme.secondaryColor,
                ),
              if (recipe.difficulty != null)
                _buildInfoChip(
                  icon: Icons.trending_up,
                  label: recipe.difficulty!,
                  color: _getDifficultyColor(recipe.difficulty!),
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
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppTheme.textLight,
          ),
          const SizedBox(height: 16),
          Text(
            '레시피를 불러올 수 없습니다',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? '네트워크 연결을 확인해주세요',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadAllData,
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant_menu,
            size: 64,
            color: AppTheme.textLight,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
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

  void _updateRecipeInLists(Recipe updatedRecipe) {
    setState(() {
      // 모든 레시피 리스트 업데이트
      final allIndex = _allRecipes.indexWhere((r) => r.id == updatedRecipe.id);
      if (allIndex != -1) {
        _allRecipes[allIndex] = updatedRecipe;
      }
      
      // 인기 레시피 리스트 업데이트
      final popularIndex = _popularRecipes.indexWhere((r) => r.id == updatedRecipe.id);
      if (popularIndex != -1) {
        _popularRecipes[popularIndex] = updatedRecipe;
      }
      
      // 북마크 레시피 리스트 업데이트
      final bookmarkIndex = _bookmarkedRecipes.indexWhere((r) => r.id == updatedRecipe.id);
      if (bookmarkIndex != -1) {
        _bookmarkedRecipes[bookmarkIndex] = updatedRecipe;
      }
    });
  }

  Future<void> _toggleBookmark(Recipe recipe) async {
    try {
      final success = await _communityService.toggleBookmark(recipe.id);
      if (success) {
        final updatedRecipe = recipe.copyWith(
          isBookmarked: !recipe.isBookmarked,
        );
        _updateRecipeInLists(updatedRecipe);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              recipe.isBookmarked ? '북마크에서 제거되었습니다' : '북마크에 추가되었습니다',
            ),
            backgroundColor: AppTheme.primaryColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('북마크 처리 중 오류가 발생했습니다'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }
}