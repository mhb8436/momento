import 'dart:io';
import 'package:dio/dio.dart';
import '../../models/recipe.dart';
import '../../config/app_config.dart';
import 'api_service.dart';

class RecipeService {
  static final RecipeService _instance = RecipeService._internal();
  factory RecipeService() => _instance;
  RecipeService._internal();

  final ApiService _apiService = ApiService();

  Future<RecipeListResult> getRecipes() async {
    try {
      print('🔍 RecipeService getRecipes 시작');
      print('🔍 API URL: ${AppConfig.baseUrl}${AppConfig.recipeEndpoint}');
      
      final response = await _apiService.get('${AppConfig.recipeEndpoint}');

      print('🔍 레시피 목록 API 응답: status=${response.statusCode}, data=${response.data}');

      if (response.statusCode == 200) {
        final List<dynamic> recipesData = response.data['recipes'] ?? [];
        final List<Recipe> recipes = recipesData
            .map((json) => Recipe.fromJson(json))
            .toList();
        
        return RecipeListResult.success(recipes: recipes);
      } else {
        final errorMsg = response.data['detail'] ?? '레시피 목록을 가져올 수 없습니다.';
        print('❌ 레시피 목록 API 오류 응답: $errorMsg');
        return RecipeListResult.failure(message: errorMsg);
      }
    } on ApiException catch (e) {
      print('❌ RecipeService getRecipes ApiException: ${e.message} (status: ${e.statusCode})');
      return RecipeListResult.failure(message: e.message);
    } catch (e) {
      print('❌ RecipeService getRecipes Exception: $e');
      return RecipeListResult.failure(message: '레시피 목록을 가져오는 중 오류가 발생했습니다: $e');
    }
  }

  Future<RecipeResult> createRecipe({
    required String title,
    required String description,
    required List<String> ingredients,
    required List<String> instructions,
    String? audioId,
    int? servings,
    int? cookingTime,
    String? difficulty,
    List<String>? tags,
  }) async {
    try {
      print('🔍 RecipeService createRecipe 시작: $title');
      print('🔍 API URL: ${AppConfig.baseUrl}${AppConfig.recipeEndpoint}');
      
      final response = await _apiService.post(
        '${AppConfig.recipeEndpoint}',
        data: {
          'title': title,
          'description': description,
          'ingredients': ingredients,
          'instructions': instructions,
          if (audioId != null) 'audio_id': audioId,
          if (servings != null) 'servings': servings,
          if (cookingTime != null) 'cooking_time': cookingTime,
          if (difficulty != null) 'difficulty': difficulty,
          if (tags != null) 'tags': tags,
        },
      );

      print('🔍 레시피 생성 API 응답: status=${response.statusCode}, data=${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final recipe = Recipe.fromJson(response.data);
        return RecipeResult.success(recipe: recipe);
      } else {
        final errorMsg = response.data['detail'] ?? '레시피 생성에 실패했습니다.';
        print('❌ 레시피 생성 API 오류 응답: $errorMsg');
        return RecipeResult.failure(message: errorMsg);
      }
    } on ApiException catch (e) {
      print('❌ RecipeService createRecipe ApiException: ${e.message} (status: ${e.statusCode})');
      return RecipeResult.failure(message: e.message);
    } catch (e) {
      print('❌ RecipeService createRecipe Exception: $e');
      return RecipeResult.failure(message: '레시피 생성 중 오류가 발생했습니다: $e');
    }
  }

  Future<RecipeResult> getRecipe(String recipeId) async {
    try {
      print('🔍 RecipeService getRecipe 시작: $recipeId');
      print('🔍 API URL: ${AppConfig.baseUrl}${AppConfig.recipeEndpoint}/$recipeId');
      
      final response = await _apiService.get('${AppConfig.recipeEndpoint}/$recipeId');

      print('🔍 레시피 조회 API 응답: status=${response.statusCode}, data=${response.data}');

      if (response.statusCode == 200) {
        final recipe = Recipe.fromJson(response.data);
        return RecipeResult.success(recipe: recipe);
      } else {
        final errorMsg = response.data['detail'] ?? '레시피를 찾을 수 없습니다.';
        print('❌ 레시피 조회 API 오류 응답: $errorMsg');
        return RecipeResult.failure(message: errorMsg);
      }
    } on ApiException catch (e) {
      print('❌ RecipeService getRecipe ApiException: ${e.message} (status: ${e.statusCode})');
      return RecipeResult.failure(message: e.message);
    } catch (e) {
      print('❌ RecipeService getRecipe Exception: $e');
      return RecipeResult.failure(message: '레시피 조회 중 오류가 발생했습니다: $e');
    }
  }

  Future<RecipeResult> updateRecipe({
    required String recipeId,
    String? title,
    String? description,
    List<String>? ingredients,
    List<String>? instructions,
    int? servings,
    int? cookingTime,
    String? difficulty,
    List<String>? tags,
  }) async {
    try {
      print('🔍 RecipeService updateRecipe 시작: $recipeId');
      print('🔍 API URL: ${AppConfig.baseUrl}${AppConfig.recipeEndpoint}/$recipeId');
      
      final Map<String, dynamic> updateData = {};
      if (title != null) updateData['title'] = title;
      if (description != null) updateData['description'] = description;
      if (ingredients != null) updateData['ingredients'] = ingredients;
      if (instructions != null) updateData['instructions'] = instructions;
      if (servings != null) updateData['servings'] = servings;
      if (cookingTime != null) updateData['cooking_time'] = cookingTime;
      if (difficulty != null) updateData['difficulty'] = difficulty;
      if (tags != null) updateData['tags'] = tags;
      
      final response = await _apiService.put(
        '${AppConfig.recipeEndpoint}/$recipeId',
        data: updateData,
      );

      print('🔍 레시피 수정 API 응답: status=${response.statusCode}, data=${response.data}');

      if (response.statusCode == 200) {
        final recipe = Recipe.fromJson(response.data);
        return RecipeResult.success(recipe: recipe);
      } else {
        final errorMsg = response.data['detail'] ?? '레시피 수정에 실패했습니다.';
        print('❌ 레시피 수정 API 오류 응답: $errorMsg');
        return RecipeResult.failure(message: errorMsg);
      }
    } on ApiException catch (e) {
      print('❌ RecipeService updateRecipe ApiException: ${e.message} (status: ${e.statusCode})');
      return RecipeResult.failure(message: e.message);
    } catch (e) {
      print('❌ RecipeService updateRecipe Exception: $e');
      return RecipeResult.failure(message: '레시피 수정 중 오류가 발생했습니다: $e');
    }
  }

  Future<RecipeDeleteResult> deleteRecipe(String recipeId) async {
    try {
      print('🔍 RecipeService deleteRecipe 시작: $recipeId');
      print('🔍 API URL: ${AppConfig.baseUrl}${AppConfig.recipeEndpoint}/$recipeId');
      
      final response = await _apiService.delete('${AppConfig.recipeEndpoint}/$recipeId');

      print('🔍 레시피 삭제 API 응답: status=${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return RecipeDeleteResult.success();
      } else {
        final errorMsg = response.data['detail'] ?? '레시피 삭제에 실패했습니다.';
        print('❌ 레시피 삭제 API 오류 응답: $errorMsg');
        return RecipeDeleteResult.failure(message: errorMsg);
      }
    } on ApiException catch (e) {
      print('❌ RecipeService deleteRecipe ApiException: ${e.message} (status: ${e.statusCode})');
      return RecipeDeleteResult.failure(message: e.message);
    } catch (e) {
      print('❌ RecipeService deleteRecipe Exception: $e');
      return RecipeDeleteResult.failure(message: '레시피 삭제 중 오류가 발생했습니다: $e');
    }
  }

  Future<RecipeListResult> searchRecipes({
    String? query,
    List<String>? tags,
    String? difficulty,
    int? maxCookingTime,
  }) async {
    try {
      print('🔍 RecipeService searchRecipes 시작: query=$query');
      
      final Map<String, dynamic> queryParams = {};
      if (query != null && query.isNotEmpty) queryParams['q'] = query;
      if (tags != null && tags.isNotEmpty) queryParams['tags'] = tags.join(',');
      if (difficulty != null) queryParams['difficulty'] = difficulty;
      if (maxCookingTime != null) queryParams['max_cooking_time'] = maxCookingTime.toString();
      
      final response = await _apiService.get(
        '${AppConfig.recipeEndpoint}/search',
        queryParameters: queryParams,
      );

      print('🔍 레시피 검색 API 응답: status=${response.statusCode}, data=${response.data}');

      if (response.statusCode == 200) {
        final List<dynamic> recipesData = response.data['recipes'] ?? [];
        final List<Recipe> recipes = recipesData
            .map((json) => Recipe.fromJson(json))
            .toList();
        
        return RecipeListResult.success(recipes: recipes);
      } else {
        final errorMsg = response.data['detail'] ?? '레시피 검색에 실패했습니다.';
        print('❌ 레시피 검색 API 오류 응답: $errorMsg');
        return RecipeListResult.failure(message: errorMsg);
      }
    } on ApiException catch (e) {
      print('❌ RecipeService searchRecipes ApiException: ${e.message} (status: ${e.statusCode})');
      return RecipeListResult.failure(message: e.message);
    } catch (e) {
      print('❌ RecipeService searchRecipes Exception: $e');
      return RecipeListResult.failure(message: '레시피 검색 중 오류가 발생했습니다: $e');
    }
  }

  Future<ImageUploadResult> uploadRecipeImage(File imageFile) async {
    try {
      print('🔍 RecipeService uploadRecipeImage 시작');
      print('🔍 API URL: ${AppConfig.baseUrl}/uploads/recipe-image');
      
      // FormData 생성
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });

      final response = await _apiService.post(
        '/uploads/recipe-image',
        data: formData,
      );

      print('🔍 이미지 업로드 API 응답: status=${response.statusCode}, data=${response.data}');

      if (response.statusCode == 200) {
        final imageUrl = response.data['image_url'] as String?;
        if (imageUrl != null) {
          return ImageUploadResult.success(imageUrl: imageUrl);
        } else {
          return ImageUploadResult.failure(message: '이미지 URL을 받을 수 없습니다.');
        }
      } else {
        final errorMsg = response.data['detail'] ?? '이미지 업로드에 실패했습니다.';
        print('❌ 이미지 업로드 API 오류 응답: $errorMsg');
        return ImageUploadResult.failure(message: errorMsg);
      }
    } on ApiException catch (e) {
      print('❌ RecipeService uploadRecipeImage ApiException: ${e.message} (status: ${e.statusCode})');
      return ImageUploadResult.failure(message: e.message);
    } catch (e) {
      print('❌ RecipeService uploadRecipeImage Exception: $e');
      return ImageUploadResult.failure(message: '이미지 업로드 중 오류가 발생했습니다: $e');
    }
  }
}

// Recipe Service Result Classes
abstract class RecipeResult {
  final bool isSuccess;
  final String? message;
  final Recipe? recipe;

  RecipeResult._({
    required this.isSuccess,
    this.message,
    this.recipe,
  });

  factory RecipeResult.success({required Recipe recipe}) = RecipeSuccess;
  factory RecipeResult.failure({required String message}) = RecipeFailure;
}

class RecipeSuccess extends RecipeResult {
  RecipeSuccess({required Recipe recipe}) 
      : super._(isSuccess: true, recipe: recipe);
}

class RecipeFailure extends RecipeResult {
  RecipeFailure({required String message}) 
      : super._(isSuccess: false, message: message);
}

abstract class RecipeListResult {
  final bool isSuccess;
  final String? message;
  final List<Recipe>? recipes;

  RecipeListResult._({
    required this.isSuccess,
    this.message,
    this.recipes,
  });

  factory RecipeListResult.success({required List<Recipe> recipes}) = RecipeListSuccess;
  factory RecipeListResult.failure({required String message}) = RecipeListFailure;
}

class RecipeListSuccess extends RecipeListResult {
  RecipeListSuccess({required List<Recipe> recipes})
      : super._(isSuccess: true, recipes: recipes);
}

class RecipeListFailure extends RecipeListResult {
  RecipeListFailure({required String message})
      : super._(isSuccess: false, message: message);
}

abstract class RecipeDeleteResult {
  final bool isSuccess;
  final String? message;

  RecipeDeleteResult._({
    required this.isSuccess,
    this.message,
  });

  factory RecipeDeleteResult.success() = RecipeDeleteSuccess;
  factory RecipeDeleteResult.failure({required String message}) = RecipeDeleteFailure;
}

class RecipeDeleteSuccess extends RecipeDeleteResult {
  RecipeDeleteSuccess() : super._(isSuccess: true);
}

class RecipeDeleteFailure extends RecipeDeleteResult {
  RecipeDeleteFailure({required String message})
      : super._(isSuccess: false, message: message);
}

abstract class ImageUploadResult {
  final bool isSuccess;
  final String? message;
  final String? imageUrl;

  ImageUploadResult._({
    required this.isSuccess,
    this.message,
    this.imageUrl,
  });

  factory ImageUploadResult.success({required String imageUrl}) = ImageUploadSuccess;
  factory ImageUploadResult.failure({required String message}) = ImageUploadFailure;
}

class ImageUploadSuccess extends ImageUploadResult {
  ImageUploadSuccess({required String imageUrl}) 
      : super._(isSuccess: true, imageUrl: imageUrl);
}

class ImageUploadFailure extends ImageUploadResult {
  ImageUploadFailure({required String message}) 
      : super._(isSuccess: false, message: message);
}