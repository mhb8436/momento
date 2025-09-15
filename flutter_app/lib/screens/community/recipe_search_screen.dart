import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/theme.dart';
import '../../models/recipe.dart';
import '../../services/community/community_service.dart';
import '../../widgets/common/custom_icon_button.dart';
import '../../widgets/community/recipe_reaction_bar.dart';
import '../recipe/recipe_detail_screen.dart';

class RecipeSearchScreen extends StatefulWidget {
  const RecipeSearchScreen({super.key});

  @override
  State<RecipeSearchScreen> createState() => _RecipeSearchScreenState();
}

class _RecipeSearchScreenState extends State<RecipeSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final CommunityService _communityService = CommunityService();
  
  List<Recipe> _searchResults = [];
  List<String> _recentSearches = [];
  List<String> _popularKeywords = ['김치찌개', '불고기', '된장찌개', '닭갈비', '비빔밥', '떡볶이'];
  
  bool _isSearching = false;
  bool _hasSearched = false;
  String? _currentQuery;
  
  // 필터 옵션들
  String? _selectedCategory;
  String? _selectedDifficulty;
  RecipeVisibility? _selectedVisibility;
  
  final List<String> _categories = ['한식', '중식', '일식', '양식', '분식', '디저트', '음료'];
  final List<String> _difficulties = ['쉬움', '보통', '어려움'];

  @override
  void dispose() {
    _searchController.dispose();
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
              _buildSearchBar(),
              _buildFilters(),
              Expanded(
                child: _hasSearched 
                    ? _buildSearchResults() 
                    : _buildSearchSuggestions(),
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
          const SizedBox(width: 16),
          Text(
            '레시피 검색',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: '어떤 레시피를 찾고 계세요?',
                prefixIcon: Icon(Icons.search, color: AppTheme.textSecondary),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: (value) => _performSearch(value),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, color: AppTheme.textSecondary),
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _hasSearched = false;
                  _searchResults.clear();
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _buildFilterChip(
            label: '카테고리',
            selected: _selectedCategory,
            onTap: () => _showCategoryFilter(),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: '난이도',
            selected: _selectedDifficulty,
            onTap: () => _showDifficultyFilter(),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: '공개 범위',
            selected: _selectedVisibility?.name,
            onTap: () => _showVisibilityFilter(),
          ),
          const SizedBox(width: 8),
          if (_hasActiveFilters())
            GestureDetector(
              onTap: _clearFilters,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.errorColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.clear,
                      size: 16,
                      color: AppTheme.errorColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '필터 지우기',
                      style: TextStyle(
                        color: AppTheme.errorColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    String? selected,
    required VoidCallback onTap,
  }) {
    final isSelected = selected != null;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : AppTheme.textLight,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              selected ?? label,
              style: TextStyle(
                color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSuggestions() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_recentSearches.isNotEmpty) ...[ 
            _buildSectionTitle('최근 검색어', Icons.history),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _recentSearches.map((keyword) => 
                _buildKeywordChip(keyword, isRecent: true)
              ).toList(),
            ),
            const SizedBox(height: 24),
          ],
          
          _buildSectionTitle('인기 검색어', Icons.trending_up),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _popularKeywords.map((keyword) => 
              _buildKeywordChip(keyword)
            ).toList(),
          ),
          
          const SizedBox(height: 24),
          _buildSectionTitle('카테고리별 찾기', Icons.category),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              return _buildCategoryCard(_categories[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppTheme.primaryColor,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildKeywordChip(String keyword, {bool isRecent = false}) {
    return GestureDetector(
      onTap: () => _performSearch(keyword),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isRecent 
              ? AppTheme.secondaryColor.withOpacity(0.1)
              : AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isRecent)
              Icon(
                Icons.access_time,
                size: 12,
                color: AppTheme.secondaryColor,
              ),
            if (isRecent) const SizedBox(width: 4),
            Text(
              keyword,
              style: TextStyle(
                color: isRecent ? AppTheme.secondaryColor : AppTheme.primaryColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(String category) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category;
        });
        _performSearch('', applyFilters: true);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
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
        child: Row(
          children: [
            Text(
              _getCategoryEmoji(category),
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                category,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 12,
              color: AppTheme.textLight,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchResults.isEmpty) {
      return _buildNoResultsState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        return _buildSearchResultCard(_searchResults[index]);
      },
    );
  }

  Widget _buildSearchResultCard(Recipe recipe) {
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
        children: [
          _buildRecipeHeader(recipe),
          _buildRecipeInfo(recipe),
          RecipeReactionBar(
            recipe: recipe,
            onReactionChanged: (updatedRecipe) {
              setState(() {
                final index = _searchResults.indexWhere((r) => r.id == updatedRecipe.id);
                if (index != -1) {
                  _searchResults[index] = updatedRecipe;
                }
              });
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildRecipeHeader(Recipe recipe) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeDetailScreen(recipe: recipe),
          ),
        );
      },
      child: Container(
        height: 120,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Row(
          children: [
            // 이미지
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(16)),
              ),
              child: recipe.imageUrl != null && recipe.imageUrl!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(16)),
                      child: CachedNetworkImage(
                        imageUrl: recipe.imageUrl!,
                        width: 120,
                        height: 120,
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
                            borderRadius: const BorderRadius.only(topLeft: Radius.circular(16)),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.restaurant,
                              size: 32,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(16)),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.restaurant,
                          size: 32,
                          color: Colors.white,
                        ),
                      ),
                    ),
            ),
            
            // 레시피 정보
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (recipe.authorName != null)
                      Text(
                        'by ${recipe.authorName}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    const Spacer(),
                    Row(
                      children: [
                        if (recipe.totalReactions > 0) ...[ 
                          Icon(
                            Icons.favorite,
                            size: 14,
                            color: Colors.red.shade400,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            recipe.totalReactions.toString(),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Text(
                          recipe.visibilityDisplay,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeInfo(Recipe recipe) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
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
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: AppTheme.textLight,
          ),
          const SizedBox(height: 16),
          Text(
            '검색 결과가 없습니다',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _currentQuery != null 
                ? '"$_currentQuery"에 대한 레시피를 찾을 수 없어요'
                : '다른 검색어로 시도해보세요',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getCategoryEmoji(String category) {
    switch (category) {
      case '한식':
        return '🍚';
      case '중식':
        return '🥢';
      case '일식':
        return '🍣';
      case '양식':
        return '🍝';
      case '분식':
        return '🍢';
      case '디저트':
        return '🧁';
      case '음료':
        return '🥤';
      default:
        return '🍽️';
    }
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

  bool _hasActiveFilters() {
    return _selectedCategory != null || 
           _selectedDifficulty != null || 
           _selectedVisibility != null;
  }

  void _clearFilters() {
    setState(() {
      _selectedCategory = null;
      _selectedDifficulty = null;
      _selectedVisibility = null;
    });
    
    if (_hasSearched && _currentQuery != null) {
      _performSearch(_currentQuery!, applyFilters: true);
    }
  }

  Future<void> _performSearch(String query, {bool applyFilters = false}) async {
    if (query.trim().isEmpty && !applyFilters) return;
    
    setState(() {
      _isSearching = true;
      _hasSearched = true;
      _currentQuery = query.trim().isEmpty ? null : query.trim();
    });

    try {
      final results = await _communityService.searchRecipes(
        query.trim().isEmpty ? '' : query.trim(),
        category: _selectedCategory,
        visibility: _selectedVisibility,
      );
      
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
      
      // 최근 검색어 추가
      if (query.trim().isNotEmpty) {
        _addToRecentSearches(query.trim());
      }
      
    } catch (e) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('검색 중 오류가 발생했습니다: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  void _addToRecentSearches(String query) {
    setState(() {
      _recentSearches.removeWhere((item) => item == query);
      _recentSearches.insert(0, query);
      if (_recentSearches.length > 5) {
        _recentSearches = _recentSearches.take(5).toList();
      }
    });
  }

  void _showCategoryFilter() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '카테고리 선택',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _categories.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildFilterOption(
                    '전체',
                    _selectedCategory == null,
                    () {
                      setState(() {
                        _selectedCategory = null;
                      });
                      Navigator.pop(context);
                      if (_hasSearched) {
                        _performSearch(_currentQuery ?? '', applyFilters: true);
                      }
                    },
                  );
                }
                
                final category = _categories[index - 1];
                return _buildFilterOption(
                  category,
                  _selectedCategory == category,
                  () {
                    setState(() {
                      _selectedCategory = category;
                    });
                    Navigator.pop(context);
                    if (_hasSearched) {
                      _performSearch(_currentQuery ?? '', applyFilters: true);
                    }
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDifficultyFilter() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '난이도 선택',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildFilterOption(
              '전체',
              _selectedDifficulty == null,
              () {
                setState(() {
                  _selectedDifficulty = null;
                });
                Navigator.pop(context);
                if (_hasSearched) {
                  _performSearch(_currentQuery ?? '', applyFilters: true);
                }
              },
            ),
            ..._difficulties.map((difficulty) => _buildFilterOption(
              difficulty,
              _selectedDifficulty == difficulty,
              () {
                setState(() {
                  _selectedDifficulty = difficulty;
                });
                Navigator.pop(context);
                if (_hasSearched) {
                  _performSearch(_currentQuery ?? '', applyFilters: true);
                }
              },
            )),
          ],
        ),
      ),
    );
  }

  void _showVisibilityFilter() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '공개 범위 선택',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildFilterOption(
              '전체',
              _selectedVisibility == null,
              () {
                setState(() {
                  _selectedVisibility = null;
                });
                Navigator.pop(context);
                if (_hasSearched) {
                  _performSearch(_currentQuery ?? '', applyFilters: true);
                }
              },
            ),
            // 나만 보기와 모든 사용자만 표시
            _buildFilterOption(
              _getVisibilityDisplay(RecipeVisibility.private),
              _selectedVisibility == RecipeVisibility.private,
              () {
                setState(() {
                  _selectedVisibility = RecipeVisibility.private;
                });
                Navigator.pop(context);
                if (_hasSearched) {
                  _performSearch(_currentQuery ?? '', applyFilters: true);
                }
              },
            ),
            _buildFilterOption(
              _getVisibilityDisplay(RecipeVisibility.public),
              _selectedVisibility == RecipeVisibility.public,
              () {
                setState(() {
                  _selectedVisibility = RecipeVisibility.public;
                });
                Navigator.pop(context);
                if (_hasSearched) {
                  _performSearch(_currentQuery ?? '', applyFilters: true);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(String title, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : AppTheme.textLight,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check,
                size: 20,
                color: AppTheme.primaryColor,
              ),
          ],
        ),
      ),
    );
  }

  String _getVisibilityDisplay(RecipeVisibility visibility) {
    switch (visibility) {
      case RecipeVisibility.private:
        return '🔒 나만 보기';
      case RecipeVisibility.public:
        return '🌍 모든 사용자';
      default:
        // family, neighborhood는 UI에 표시하지 않지만 기존 데이터 호환성을 위해 유지
        return '🔒 나만 보기';
    }
  }
}