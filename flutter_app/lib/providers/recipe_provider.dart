import 'package:flutter/foundation.dart';
import '../models/recipe.dart';
import '../services/api/recipe_service.dart';

class RecipeProvider extends ChangeNotifier {
  final RecipeService _recipeService = RecipeService();
  
  List<Recipe> _recipes = [];
  bool _isLoading = false;
  bool _isCreating = false;
  String? _errorMessage;
  Recipe? _currentRecipe;

  List<Recipe> get recipes => _recipes;
  bool get isLoading => _isLoading;
  bool get isCreating => _isCreating;
  String? get errorMessage => _errorMessage;
  Recipe? get currentRecipe => _currentRecipe;

  Future<void> loadRecipes() async {
    _setLoading(true);
    _clearError();

    try {
      print('🔍 RecipeProvider loadRecipes 시작');
      final result = await _recipeService.getRecipes();
      
      if (result.isSuccess && result.recipes != null) {
        _recipes = result.recipes!;
        print('✅ 레시피 ${_recipes.length}개 로드 완료');
      } else {
        final errorMsg = result.message ?? '레시피를 불러오는데 실패했습니다.';
        print('❌ 레시피 로드 실패: $errorMsg');
        _setError(errorMsg);
        _recipes = []; // Clear on error
      }
      
    } catch (e) {
      print('❌ RecipeProvider loadRecipes exception: $e');
      _setError('레시피를 불러오는데 실패했습니다: $e');
      _recipes = [];
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createRecipeFromAudio(String audioId) async {
    _setCreating(true);
    _clearError();

    try {
      print('🔍 RecipeProvider createRecipeFromAudio 시작: $audioId');
      
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

    try {
      print('🔍 RecipeProvider createRecipe 시작: $title');
      
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

  Future<bool> updateRecipe(String recipeId, Map<String, dynamic> updates) async {
    _clearError();

    try {
      print('🔍 RecipeProvider updateRecipe 시작: $recipeId');
      
      final recipeIndex = _recipes.indexWhere((recipe) => recipe.id == recipeId);
      if (recipeIndex == -1) {
        _setError('레시피를 찾을 수 없습니다.');
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

  Future<bool> deleteRecipe(String recipeId) async {
    _clearError();

    try {
      print('🔍 RecipeProvider deleteRecipe 시작: $recipeId');
      
      final result = await _recipeService.deleteRecipe(recipeId);
      
      if (result.isSuccess) {
        _recipes.removeWhere((recipe) => recipe.id == recipeId);
        if (_currentRecipe?.id == recipeId) {
          _currentRecipe = null;
        }
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
}