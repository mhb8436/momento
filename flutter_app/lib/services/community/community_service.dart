import 'dart:convert';
import '../../config/app_config.dart';
import '../../models/recipe.dart';
import '../../models/user.dart';
import '../api/api_service.dart';

class CommunityService {
  static final CommunityService _instance = CommunityService._internal();
  factory CommunityService() => _instance;
  CommunityService._internal();

  final ApiService _apiService = ApiService();

  // 공개 레시피 목록 가져오기
  Future<List<Recipe>> getPublicRecipes({
    int page = 1,
    int limit = 20,
    String? category,
    String? difficulty,
    RecipeVisibility? visibility,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      
      if (category != null) queryParams['category'] = category;
      if (difficulty != null) queryParams['difficulty'] = difficulty;
      if (visibility != null) {
        queryParams['visibility'] = visibility.name;
      }

      final response = await _apiService.get('/community/recipes', queryParameters: queryParams);
      
      if (response.statusCode == 200) {
        // Backend에서 직접 리스트를 반환함
        final List<dynamic> recipesData = response.data is List 
            ? response.data 
            : (response.data['recipes'] ?? []);
        
        return recipesData.map((json) => Recipe.fromJson(json)).toList();
      } else {
        throw Exception('공개 레시피를 불러오는데 실패했습니다: ${response.statusCode}');
      }
    } catch (e) {
      print('getPublicRecipes error: $e');
      throw Exception('네트워크 오류가 발생했습니다: $e');
    }
  }

  // 레시피 검색
  Future<List<Recipe>> searchRecipes(String query, {
    int page = 1,
    int limit = 20,
    String? category,
    RecipeVisibility? visibility,
  }) async {
    try {
      final queryParams = <String, String>{
        'q': query,
        'page': page.toString(),
        'limit': limit.toString(),
      };
      
      if (category != null) queryParams['category'] = category;
      if (visibility != null) queryParams['visibility'] = visibility.name;

      final response = await _apiService.get('/community/recipes/search', queryParameters: queryParams);
      
      if (response.statusCode == 200) {
        // Backend에서 직접 리스트를 반환함
        final List<dynamic> recipesData = response.data is List 
            ? response.data 
            : (response.data['recipes'] ?? []);
        
        return recipesData.map((json) => Recipe.fromJson(json)).toList();
      } else {
        throw Exception('레시피 검색에 실패했습니다: ${response.statusCode}');
      }
    } catch (e) {
      print('searchRecipes error: $e');
      throw Exception('검색 중 오류가 발생했습니다: $e');
    }
  }

  // 레시피 공개 상태 변경
  Future<bool> updateRecipeVisibility(String recipeId, RecipeVisibility visibility) async {
    try {
      final response = await _apiService.put('/recipes/$recipeId/visibility', data: {
        'visibility': visibility.name,
      });
      
      return response.statusCode == 200;
    } catch (e) {
      print('updateRecipeVisibility error: $e');
      return false;
    }
  }

  // 레시피에 리액션 추가/제거
  Future<bool> toggleReaction(String recipeId, RecipeReactionType reactionType) async {
    try {
      final response = await _apiService.post('/community/recipes/$recipeId/reactions', data: {
        'reaction_type': reactionType.name,
      });
      
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('toggleReaction error: $e');
      return false;
    }
  }

  // 레시피 북마크 토글
  Future<bool> toggleBookmark(String recipeId) async {
    try {
      final response = await _apiService.post('/community/recipes/$recipeId/bookmark');
      
      return response.statusCode == 200;
    } catch (e) {
      print('toggleBookmark error: $e');
      return false;
    }
  }

  // 사용자별 북마크된 레시피 목록
  Future<List<Recipe>> getBookmarkedRecipes({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      final response = await _apiService.get('/community/bookmarks', queryParameters: queryParams);
      
      if (response.statusCode == 200) {
        // Backend에서 직접 리스트를 반환함
        final List<dynamic> recipesData = response.data is List 
            ? response.data 
            : (response.data['recipes'] ?? []);
        
        return recipesData.map((json) => Recipe.fromJson(json)).toList();
      } else {
        throw Exception('북마크된 레시피를 불러오는데 실패했습니다: ${response.statusCode}');
      }
    } catch (e) {
      print('getBookmarkedRecipes error: $e');
      throw Exception('네트워크 오류가 발생했습니다: $e');
    }
  }

  // 인기 레시피 가져오기 (리액션 수 기준)
  Future<List<Recipe>> getPopularRecipes({
    int page = 1,
    int limit = 20,
    String period = 'week', // week, month, all
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
        'period': period,
      };

      final response = await _apiService.get('/community/recipes/popular', queryParameters: queryParams);
      
      if (response.statusCode == 200) {
        // Backend에서 직접 리스트를 반환함
        final List<dynamic> recipesData = response.data is List 
            ? response.data 
            : (response.data['recipes'] ?? []);
        
        return recipesData.map((json) => Recipe.fromJson(json)).toList();
      } else {
        throw Exception('인기 레시피를 불러오는데 실패했습니다: ${response.statusCode}');
      }
    } catch (e) {
      print('getPopularRecipes error: $e');
      throw Exception('네트워크 오류가 발생했습니다: $e');
    }
  }

  // 특정 사용자의 공개 레시피 목록
  Future<List<Recipe>> getUserPublicRecipes(String userId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      final response = await _apiService.get('/community/users/$userId/recipes', queryParameters: queryParams);
      
      if (response.statusCode == 200) {
        // Backend에서 직접 리스트를 반환함
        final List<dynamic> recipesData = response.data is List 
            ? response.data 
            : (response.data['recipes'] ?? []);
        
        return recipesData.map((json) => Recipe.fromJson(json)).toList();
      } else {
        throw Exception('사용자 레시피를 불러오는데 실패했습니다: ${response.statusCode}');
      }
    } catch (e) {
      print('getUserPublicRecipes error: $e');
      throw Exception('네트워크 오류가 발생했습니다: $e');
    }
  }
}