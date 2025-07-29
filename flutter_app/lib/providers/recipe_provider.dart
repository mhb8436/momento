import 'package:flutter/foundation.dart';
import '../models/recipe.dart';

class RecipeProvider extends ChangeNotifier {
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
      // TODO: Implement API call to load recipes
      // final result = await _recipeService.getRecipes();
      // if (result.isSuccess) {
      //   _recipes = result.recipes;
      // } else {
      //   _setError(result.message);
      // }
      
      // Temporary mock data
      _recipes = [];
      
    } catch (e) {
      _setError('레시피를 불러오는데 실패했습니다.');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createRecipeFromAudio(String audioId) async {
    _setCreating(true);
    _clearError();

    try {
      // TODO: Implement API call to create recipe
      // final result = await _recipeService.createRecipeFromAudio(audioId);
      // if (result.isSuccess) {
      //   final recipe = result.recipe;
      //   _recipes.insert(0, recipe);
      //   _currentRecipe = recipe;
      //   notifyListeners();
      //   return true;
      // } else {
      //   _setError(result.message);
      //   return false;
      // }

      // Mock recipe creation
      await Future.delayed(const Duration(seconds: 2));
      
      final mockRecipe = Recipe(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: 'user1',
        sourceAudioId: audioId,
        title: 'AI가 정리한 엄마표 김치찌개',
        description: '엄마가 해주시던 그 맛 그대로, 따뜻한 사랑이 담긴 김치찌개 레시피입니다.',
        ingredients: [
          RecipeIngredient(name: '김치', amount: '1컵', notes: '신김치 사용'),
          RecipeIngredient(name: '돼지고기', amount: '200g'),
          RecipeIngredient(name: '두부', amount: '1/2모'),
          RecipeIngredient(name: '대파', amount: '1대'),
        ],
        steps: [
          RecipeStep(step: 1, instruction: '김치를 적당한 크기로 썰어주세요', time: '5분'),
          RecipeStep(step: 2, instruction: '돼지고기를 볶아주세요', time: '3분'),
          RecipeStep(step: 3, instruction: '김치를 넣고 함께 볶아주세요', time: '5분'),
          RecipeStep(step: 4, instruction: '물을 넣고 끓여주세요', time: '15분'),
        ],
        tips: '김치가 너무 시면 설탕을 조금 넣어주세요',
        servings: '2-3인분',
        cookingTime: '30분',
        difficulty: '쉬움',
        category: '한식',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      _recipes.insert(0, mockRecipe);
      _currentRecipe = mockRecipe;
      notifyListeners();
      return true;

    } catch (e) {
      _setError('레시피 생성에 실패했습니다.');
      return false;
    } finally {
      _setCreating(false);
    }
  }

  Future<bool> updateRecipe(String recipeId, Map<String, dynamic> updates) async {
    _clearError();

    try {
      final recipeIndex = _recipes.indexWhere((recipe) => recipe.id == recipeId);
      if (recipeIndex == -1) {
        _setError('레시피를 찾을 수 없습니다.');
        return false;
      }

      // TODO: Implement API call to update recipe
      // final result = await _recipeService.updateRecipe(recipeId, updates);
      // if (result.isSuccess) {
      //   _recipes[recipeIndex] = result.recipe;
      //   if (_currentRecipe?.id == recipeId) {
      //     _currentRecipe = result.recipe;
      //   }
      //   notifyListeners();
      //   return true;
      // } else {
      //   _setError(result.message);
      //   return false;
      // }

      // Mock update
      final originalRecipe = _recipes[recipeIndex];
      _recipes[recipeIndex] = originalRecipe.copyWith(
        title: updates['title'] ?? originalRecipe.title,
        description: updates['description'] ?? originalRecipe.description,
        tips: updates['tips'] ?? originalRecipe.tips,
        updatedAt: DateTime.now(),
      );

      if (_currentRecipe?.id == recipeId) {
        _currentRecipe = _recipes[recipeIndex];
      }

      notifyListeners();
      return true;

    } catch (e) {
      _setError('레시피 수정에 실패했습니다.');
      return false;
    }
  }

  Future<bool> deleteRecipe(String recipeId) async {
    _clearError();

    try {
      // TODO: Implement API call to delete recipe
      // final result = await _recipeService.deleteRecipe(recipeId);
      // if (!result.isSuccess) {
      //   _setError(result.message);
      //   return false;
      // }

      _recipes.removeWhere((recipe) => recipe.id == recipeId);
      if (_currentRecipe?.id == recipeId) {
        _currentRecipe = null;
      }
      notifyListeners();
      return true;

    } catch (e) {
      _setError('레시피 삭제에 실패했습니다.');
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