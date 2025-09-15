import 'package:flutter/foundation.dart';
import '../models/recipe.dart';
import '../services/api/recipe_service.dart';
import '../services/cache_service.dart';
import '../services/credit/credit_service.dart';

class RecipeProvider extends ChangeNotifier {
  final RecipeService _recipeService = RecipeService();
  final CreditService _creditService = CreditService();
  
  List<Recipe> _recipes = [];
  bool _isLoading = false;
  bool _isCreating = false;
  String? _errorMessage;
  Recipe? _currentRecipe;
  bool _isOfflineMode = false;
  bool _needsCreditPurchase = false;

  List<Recipe> get recipes => _recipes;
  bool get isLoading => _isLoading;
  bool get isCreating => _isCreating;
  String? get errorMessage => _errorMessage;
  Recipe? get currentRecipe => _currentRecipe;
  bool get isOfflineMode => _isOfflineMode;
  bool get needsCreditPurchase => _needsCreditPurchase;

  Future<void> loadRecipes() async {
    _setLoading(true);
    _clearError();

    try {
      print('🔍 RecipeProvider loadRecipes 시작');
      
      // 네트워크 상태 확인
      final isOnline = await CacheService.isOnline();
      _isOfflineMode = !isOnline;
      
      if (isOnline) {
        print('📶 온라인 모드: 서버에서 레시피 로드');
        await _loadRecipesFromServer();
      } else {
        print('📵 오프라인 모드: 캐시에서 레시피 로드');
        await _loadRecipesFromCache();
      }
      
    } catch (e) {
      print('❌ RecipeProvider loadRecipes exception: $e');
      _setError('레시피를 불러오는데 실패했습니다: $e');
      
      // 오류 발생 시 캐시에서 시도
      try {
        await _loadRecipesFromCache();
        _isOfflineMode = true;
      } catch (cacheError) {
        print('❌ 캐시에서도 로드 실패: $cacheError');
        _recipes = [];
      }
    } finally {
      _setLoading(false);
    }
  }
  
  Future<void> _loadRecipesFromServer() async {
    final result = await _recipeService.getRecipes();
    
    if (result.isSuccess && result.recipes != null) {
      _recipes = result.recipes!;
      // 최신순으로 정렬 (createdAt 기준)
      _recipes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      // 서버에서 성공적으로 로드했으면 캐시에 저장
      await CacheService.cacheRecipes(_recipes);
      
      print('✅ 레시피 ${_recipes.length}개 로드 완료 (서버)');
    } else {
      final errorMsg = result.message ?? '레시피를 불러오는데 실패했습니다.';
      print('❌ 레시피 로드 실패: $errorMsg');
      _setError(errorMsg);
      
      // 서버 로드 실패 시 캐시에서 시도
      await _loadRecipesFromCache();
      _isOfflineMode = true;
    }
  }
  
  Future<void> _loadRecipesFromCache() async {
    _recipes = await CacheService.getCachedRecipes();
    print('✅ 캐시된 레시피 ${_recipes.length}개 로드 완료');
    
    if (_recipes.isEmpty) {
      _setError('오프라인 상태이며 저장된 레시피가 없습니다.');
    }
  }

  /// 크레딧 사용 가능 여부 확인
  Future<bool> canUseCreditsForRecipe() async {
    try {
      return await _creditService.checkCreditAvailability();
    } catch (e) {
      print('❌ 크레딧 확인 실패: $e');
      return false;
    }
  }

  /// 크레딧 차감 및 레시피 생성 권한 확인
  Future<bool> _checkAndDeductCredits() async {
    try {
      // 1. 크레딧 사용 가능 여부 체크
      final canUse = await canUseCreditsForRecipe();
      if (!canUse) {
        _needsCreditPurchase = true;
        _setError('크레딧이 부족합니다. 크레딧을 구매하거나 무료 크레딧을 기다려주세요.');
        notifyListeners();
        return false;
      }

      // 2. 실제 크레딧 차감은 백엔드에서 처리되므로 여기서는 체크만
      _needsCreditPurchase = false;
      return true;
    } catch (e) {
      print('❌ 크레딧 확인/차감 실패: $e');
      _setError('크레딧 확인 중 오류가 발생했습니다.');
      return false;
    }
  }

  Future<bool> createRecipeFromAudio(String audioId) async {
    _setCreating(true);
    _clearError();
    _needsCreditPurchase = false;

    try {
      print('🔍 RecipeProvider createRecipeFromAudio 시작: $audioId');
      
      // 오프라인에서는 레시피 생성 불가능
      if (await CacheService.isOffline()) {
        _setError('오프라인 상태에서는 새로운 레시피를 생성할 수 없습니다.');
        return false;
      }

      // 크레딧 확인 및 차감
      if (!await _checkAndDeductCredits()) {
        return false;
      }
      
      // Note: This method will be called after audio processing is complete
      // The backend should already have the transcribed text and structured recipe data
      // We need to create a recipe using basic info and let the backend fill in details
      final result = await _recipeService.createRecipe(
        title: 'AI 생성 레시피',
        description: '음성으로부터 생성된 레시피입니다.',
        ingredients: [], // Backend will populate from audio processing
        instructions: [], // Backend will populate from audio processing
        audioId: audioId,
      );
      
      if (result.isSuccess && result.recipe != null) {
        _recipes.insert(0, result.recipe!);
        _currentRecipe = result.recipe!;
        
        // 새 레시피를 캐시에 추가
        await CacheService.addRecipeToCache(result.recipe!);
        
        print('✅ 레시피 생성 완료: ${result.recipe!.title}');
        notifyListeners();
        return true;
      } else {
        final errorMsg = result.message ?? '레시피 생성에 실패했습니다.';
        print('❌ 레시피 생성 실패: $errorMsg');
        _setError(errorMsg);
        return false;
      }
    } catch (e) {
      print('❌ RecipeProvider createRecipeFromAudio exception: $e');
      _setError('레시피 생성 중 오류가 발생했습니다: $e');
      return false;
    } finally {
      _setCreating(false);
    }
  }

  Future<bool> createRecipe({
    required String title,
    required String description,
    required List<String> ingredients,
    required List<String> instructions,
    int? servings,
    int? cookingTime,
    String? difficulty,
    List<String>? tags,
  }) async {
    _setCreating(true);
    _clearError();
    _needsCreditPurchase = false;

    // 크레딧 확인 및 차감
    if (!await _checkAndDeductCredits()) {
      _setCreating(false);
      return false;
    }
    _clearError();

    try {
      print('🔍 RecipeProvider createRecipe 시작: $title');
      
      // 오프라인에서는 레시피 생성 불가능
      if (await CacheService.isOffline()) {
        _setError('오프라인 상태에서는 새로운 레시피를 생성할 수 없습니다.');
        return false;
      }
      
      final result = await _recipeService.createRecipe(
        title: title,
        description: description,
        ingredients: ingredients,
        instructions: instructions,
        servings: servings,
        cookingTime: cookingTime,
        difficulty: difficulty,
        tags: tags,
      );
      
      if (result.isSuccess && result.recipe != null) {
        _recipes.insert(0, result.recipe!);
        _currentRecipe = result.recipe!;
        
        // 새 레시피를 캐시에 추가
        await CacheService.addRecipeToCache(result.recipe!);
        
        print('✅ 레시피 생성 완료: ${result.recipe!.title}');
        notifyListeners();
        return true;
      } else {
        final errorMsg = result.message ?? '레시피 생성에 실패했습니다.';
        print('❌ 레시피 생성 실패: $errorMsg');
        _setError(errorMsg);
        return false;
      }
    } catch (e) {
      print('❌ RecipeProvider createRecipe exception: $e');
      _setError('레시피 생성 중 오류가 발생했습니다: $e');
      return false;
    } finally {
      _setCreating(false);
    }
  }

  Future<bool> updateRecipe(Recipe updatedRecipe) async {
    _clearError();

    try {
      print('🔍 RecipeProvider updateRecipe 시작: ${updatedRecipe.id}');
      
      final recipeIndex = _recipes.indexWhere((recipe) => recipe.id == updatedRecipe.id);
      if (recipeIndex == -1) {
        _setError('레시피를 찾을 수 없습니다.');
        return false;
      }

      // 오프라인에서는 레시피 수정 불가능
      if (await CacheService.isOffline()) {
        _setError('오프라인 상태에서는 레시피를 수정할 수 없습니다.');
        return false;
      }

      final result = await _recipeService.updateRecipeWithObject(updatedRecipe);
      
      if (result.isSuccess && result.recipe != null) {
        _recipes[recipeIndex] = result.recipe!;
        if (_currentRecipe?.id == updatedRecipe.id) {
          _currentRecipe = result.recipe!;
        }
        
        // 수정된 레시피를 캐시에도 업데이트
        await CacheService.addRecipeToCache(result.recipe!);
        
        print('✅ 레시피 수정 완료: ${result.recipe!.title}');
        notifyListeners();
        return true;
      } else {
        final errorMsg = result.message ?? '레시피 수정에 실패했습니다.';
        print('❌ 레시피 수정 실패: $errorMsg');
        _setError(errorMsg);
        return false;
      }
    } catch (e) {
      print('❌ RecipeProvider updateRecipe exception: $e');
      _setError('레시피 수정 중 오류가 발생했습니다: $e');
      return false;
    }
  }

  // 기존 Map 방식도 호환성을 위해 유지
  Future<bool> updateRecipeWithMap(String recipeId, Map<String, dynamic> updates) async {
    _clearError();

    try {
      print('🔍 RecipeProvider updateRecipeWithMap 시작: $recipeId');
      
      final recipeIndex = _recipes.indexWhere((recipe) => recipe.id == recipeId);
      if (recipeIndex == -1) {
        _setError('레시피를 찾을 수 없습니다.');
        return false;
      }

      // 오프라인에서는 레시피 수정 불가능
      if (await CacheService.isOffline()) {
        _setError('오프라인 상태에서는 레시피를 수정할 수 없습니다.');
        return false;
      }

      final result = await _recipeService.updateRecipe(
        recipeId: recipeId,
        title: updates['title'],
        description: updates['description'],
        ingredients: updates['ingredients'],
        instructions: updates['instructions'],
        servings: updates['servings'],
        cookingTime: updates['cooking_time'],
        difficulty: updates['difficulty'],
        tags: updates['tags'],
      );
      
      if (result.isSuccess && result.recipe != null) {
        _recipes[recipeIndex] = result.recipe!;
        if (_currentRecipe?.id == recipeId) {
          _currentRecipe = result.recipe!;
        }
        
        // 수정된 레시피를 캐시에도 업데이트
        await CacheService.addRecipeToCache(result.recipe!);
        
        print('✅ 레시피 수정 완료: ${result.recipe!.title}');
        notifyListeners();
        return true;
      } else {
        final errorMsg = result.message ?? '레시피 수정에 실패했습니다.';
        print('❌ 레시피 수정 실패: $errorMsg');
        _setError(errorMsg);
        return false;
      }
    } catch (e) {
      print('❌ RecipeProvider updateRecipeWithMap exception: $e');
      _setError('레시피 수정 중 오류가 발생했습니다: $e');
      return false;
    }
  }

  Future<bool> deleteRecipe(String recipeId) async {
    _clearError();

    try {
      print('🔍 RecipeProvider deleteRecipe 시작: $recipeId');
      
      // 오프라인에서는 레시피 삭제 불가능
      if (await CacheService.isOffline()) {
        _setError('오프라인 상태에서는 레시피를 삭제할 수 없습니다.');
        return false;
      }
      
      final result = await _recipeService.deleteRecipe(recipeId);
      
      if (result.isSuccess) {
        _recipes.removeWhere((recipe) => recipe.id == recipeId);
        if (_currentRecipe?.id == recipeId) {
          _currentRecipe = null;
        }
        
        // 캐시에서도 삭제
        await CacheService.removeRecipeFromCache(recipeId);
        
        print('✅ 레시피 삭제 완료: $recipeId');
        notifyListeners();
        return true;
      } else {
        final errorMsg = result.message ?? '레시피 삭제에 실패했습니다.';
        print('❌ 레시피 삭제 실패: $errorMsg');
        _setError(errorMsg);
        return false;
      }
    } catch (e) {
      print('❌ RecipeProvider deleteRecipe exception: $e');
      _setError('레시피 삭제 중 오류가 발생했습니다: $e');
      return false;
    }
  }

  void setCurrentRecipe(Recipe recipe) {
    _currentRecipe = recipe;
    notifyListeners();
  }

  void clearCurrentRecipe() {
    _currentRecipe = null;
    notifyListeners();
  }

  Recipe? getRecipeById(String recipeId) {
    try {
      return _recipes.firstWhere((recipe) => recipe.id == recipeId);
    } catch (e) {
      return null;
    }
  }

  List<Recipe> getRecipesByCategory(String category) {
    return _recipes.where((recipe) => recipe.category == category).toList();
  }

  List<Recipe> searchRecipes(String query) {
    final lowerQuery = query.toLowerCase();
    return _recipes.where((recipe) {
      return recipe.title.toLowerCase().contains(lowerQuery) ||
             (recipe.description?.toLowerCase().contains(lowerQuery) ?? false) ||
             (recipe.category?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setCreating(bool creating) {
    _isCreating = creating;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }
  
  /// 강제로 서버에서 레시피 새로고침 (풀 투 리프레시 용)
  Future<void> forceRefreshFromServer() async {
    if (await CacheService.isOffline()) {
      _setError('서버에 연결할 수 없어 새로고침할 수 없습니다.');
      return;
    }
    
    _setLoading(true);
    _clearError();
    _isOfflineMode = false;
    
    try {
      await _loadRecipesFromServer();
    } catch (e) {
      print('❌ 강제 새로고침 실패: $e');
      _setError('새로고침에 실패했습니다: $e');
    } finally {
      _setLoading(false);
    }
  }
}