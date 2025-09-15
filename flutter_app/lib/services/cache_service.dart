import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';
import '../models/user.dart';
import '../config/app_config.dart';

class CacheService {
  static const String _recipesBoxName = 'recipes';
  static const String _userBoxName = 'user';
  static const String _settingsBoxName = 'settings';
  
  static Box<Recipe>? _recipesBox;
  static Box<User>? _userBox;
  static Box? _settingsBox;

  /// 캐시 서비스 초기화
  static Future<void> initialize() async {
    try {
      // 스키마 변경으로 인한 기존 캐시 삭제
      await _clearIncompatibleCache();
      
      // Hive 어댑터 등록
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(RecipeIngredientAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(RecipeStepAdapter());
      }
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(RecipeAdapter());
      }
      if (!Hive.isAdapterRegistered(4)) {
        Hive.registerAdapter(RecipeVisibilityAdapter());
      }
      if (!Hive.isAdapterRegistered(5)) {
        Hive.registerAdapter(RecipeReactionTypeAdapter());
      }
      if (!Hive.isAdapterRegistered(6)) {
        Hive.registerAdapter(RecipeReactionAdapter());
      }
      if (!Hive.isAdapterRegistered(7)) {
        Hive.registerAdapter(UserAdapter());
      }

      // 박스 열기
      _recipesBox = await Hive.openBox<Recipe>(_recipesBoxName);
      _userBox = await Hive.openBox<User>(_userBoxName);
      _settingsBox = await Hive.openBox(_settingsBoxName);
      
      print('✅ CacheService 초기화 완료');
    } catch (e) {
      print('❌ CacheService 초기화 실패: $e');
      // 캐시 초기화 실패 시 모든 캐시를 강제로 삭제하고 재시도
      await _forceClearAndRetry();
    }
  }

  /// 호환되지 않는 기존 캐시 삭제
  static Future<void> _clearIncompatibleCache() async {
    try {
      // 스키마 버전 확인
      final settingsBox = await Hive.openBox('settings');
      final int? schemaVersion = settingsBox.get('schema_version');
      const int currentSchemaVersion = 2; // RecipeVisibility 추가로 버전 업
      
      if (schemaVersion == null || schemaVersion < currentSchemaVersion) {
        print('🔄 스키마 변경 감지 - 기존 캐시 삭제 중...');
        
        // 기존 박스들 삭제
        await Hive.deleteBoxFromDisk(_recipesBoxName);
        await Hive.deleteBoxFromDisk(_userBoxName);
        
        // 스키마 버전 업데이트
        await settingsBox.put('schema_version', currentSchemaVersion);
        print('✅ 기존 캐시 삭제 및 스키마 버전 업데이트 완료');
      }
      
      await settingsBox.close();
    } catch (e) {
      print('⚠️ 캐시 삭제 중 오류 (무시): $e');
    }
  }

  /// 강제 캐시 삭제 및 재시도
  static Future<void> _forceClearAndRetry() async {
    try {
      print('🔄 강제 캐시 삭제 후 재시도...');
      
      // 모든 박스 강제 삭제
      await Hive.deleteBoxFromDisk(_recipesBoxName);
      await Hive.deleteBoxFromDisk(_userBoxName);
      await Hive.deleteBoxFromDisk(_settingsBoxName);
      
      // 어댑터 등록
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(RecipeIngredientAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(RecipeStepAdapter());
      }
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(RecipeAdapter());
      }
      if (!Hive.isAdapterRegistered(4)) {
        Hive.registerAdapter(RecipeVisibilityAdapter());
      }
      if (!Hive.isAdapterRegistered(5)) {
        Hive.registerAdapter(RecipeReactionTypeAdapter());
      }
      if (!Hive.isAdapterRegistered(6)) {
        Hive.registerAdapter(RecipeReactionAdapter());
      }
      if (!Hive.isAdapterRegistered(7)) {
        Hive.registerAdapter(UserAdapter());
      }
      
      // 박스 다시 열기
      _recipesBox = await Hive.openBox<Recipe>(_recipesBoxName);
      _userBox = await Hive.openBox<User>(_userBoxName);
      _settingsBox = await Hive.openBox(_settingsBoxName);
      
      // 스키마 버전 설정
      await _settingsBox!.put('schema_version', 2);
      
      print('✅ 강제 캐시 삭제 후 재초기화 완료');
    } catch (e) {
      print('❌ 강제 캐시 삭제 후 재시도 실패: $e');
      rethrow;
    }
  }

  /// 레시피 캐싱
  static Future<void> cacheRecipes(List<Recipe> recipes) async {
    try {
      if (_recipesBox == null) {
        await initialize();
      }
      
      // 기존 캐시 삭제
      await _recipesBox!.clear();
      
      // 새 레시피들 저장
      final recipeMap = {for (var recipe in recipes) recipe.id: recipe};
      await _recipesBox!.putAll(recipeMap);
      
      // 캐시 타임스탬프 저장
      await _settingsBox!.put('recipes_cached_at', DateTime.now().millisecondsSinceEpoch);
      
      print('✅ ${recipes.length}개 레시피 캐시 저장 완료');
    } catch (e) {
      print('❌ 레시피 캐시 저장 실패: $e');
      rethrow;
    }
  }

  /// 캐시된 레시피 조회
  static Future<List<Recipe>> getCachedRecipes() async {
    try {
      if (_recipesBox == null) {
        await initialize();
      }
      
      final List<Recipe> recipes = _recipesBox!.values.toList();
      
      // 최신순으로 정렬
      recipes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      print('✅ ${recipes.length}개 캐시된 레시피 조회 완료');
      return recipes;
    } catch (e) {
      print('❌ 캐시된 레시피 조회 실패: $e');
      return [];
    }
  }

  /// 단일 레시피 캐시에 추가
  static Future<void> addRecipeToCache(Recipe recipe) async {
    try {
      if (_recipesBox == null) {
        await initialize();
      }
      
      await _recipesBox!.put(recipe.id, recipe);
      print('✅ 레시피 캐시에 추가: ${recipe.title}');
    } catch (e) {
      print('❌ 레시피 캐시 추가 실패: $e');
    }
  }

  /// 캐시에서 레시피 제거
  static Future<void> removeRecipeFromCache(String recipeId) async {
    try {
      if (_recipesBox == null) {
        await initialize();
      }
      
      await _recipesBox!.delete(recipeId);
      print('✅ 레시피 캐시에서 제거: $recipeId');
    } catch (e) {
      print('❌ 레시피 캐시 제거 실패: $e');
    }
  }

  /// 사용자 정보 캐싱
  static Future<void> cacheUser(User user) async {
    try {
      if (_userBox == null) {
        await initialize();
      }
      
      await _userBox!.put('current_user', user);
      await _settingsBox!.put('user_cached_at', DateTime.now().millisecondsSinceEpoch);
      
      print('✅ 사용자 정보 캐시 저장 완료: ${user.email}');
    } catch (e) {
      print('❌ 사용자 정보 캐시 저장 실패: $e');
    }
  }

  /// 캐시된 사용자 정보 조회
  static Future<User?> getCachedUser() async {
    try {
      if (_userBox == null) {
        await initialize();
      }
      
      final User? user = _userBox!.get('current_user');
      if (user != null) {
        print('✅ 캐시된 사용자 정보 조회 완료: ${user.email}');
      }
      return user;
    } catch (e) {
      print('❌ 캐시된 사용자 정보 조회 실패: $e');
      return null;
    }
  }

  /// 사용자 캐시 삭제
  static Future<void> clearUserCache() async {
    try {
      if (_userBox == null) {
        await initialize();
      }
      
      await _userBox!.clear();
      await _settingsBox!.delete('user_cached_at');
      
      print('✅ 사용자 캐시 삭제 완료');
    } catch (e) {
      print('❌ 사용자 캐시 삭제 실패: $e');
    }
  }

  /// 서버 연결 상태 확인 (Health Check)
  static Future<bool> isOnline() async {
    try {
      print('🔍 서버 health check 시작: ${AppConfig.baseUrl}/health');
      
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/health'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
      ).timeout(
        const Duration(seconds: 3), // 3초 타임아웃
        onTimeout: () {
          throw Exception('Health check timeout');
        },
      );
      
      final isHealthy = response.statusCode == 200;
      print(isHealthy ? '✅ 서버 연결 가능' : '❌ 서버 응답 오류: ${response.statusCode}');
      return isHealthy;
      
    } catch (e) {
      print('❌ 서버 health check 실패: $e');
      return false; // 오류 시 오프라인으로 간주
    }
  }

  /// 오프라인 상태 확인
  static Future<bool> isOffline() async {
    return !(await isOnline());
  }

  /// 캐시가 유효한지 확인 (24시간 이내)
  static Future<bool> isCacheValid({String cacheKey = 'recipes_cached_at'}) async {
    try {
      if (_settingsBox == null) {
        await initialize();
      }
      
      final int? cachedAt = _settingsBox!.get(cacheKey);
      if (cachedAt == null) return false;
      
      final DateTime cacheTime = DateTime.fromMillisecondsSinceEpoch(cachedAt);
      final Duration timeDiff = DateTime.now().difference(cacheTime);
      
      // 24시간 이내면 유효
      return timeDiff.inHours < 24;
    } catch (e) {
      print('❌ 캐시 유효성 확인 실패: $e');
      return false;
    }
  }

  /// 캐시 통계 정보
  static Future<Map<String, dynamic>> getCacheStats() async {
    try {
      if (_recipesBox == null || _settingsBox == null) {
        await initialize();
      }
      
      final int recipeCount = _recipesBox!.length;
      final bool hasUser = _userBox!.containsKey('current_user');
      final int? recipesCachedAt = _settingsBox!.get('recipes_cached_at');
      final int? userCachedAt = _settingsBox!.get('user_cached_at');
      
      return {
        'recipe_count': recipeCount,
        'has_user': hasUser,
        'recipes_cached_at': recipesCachedAt != null 
            ? DateTime.fromMillisecondsSinceEpoch(recipesCachedAt).toIso8601String()
            : null,
        'user_cached_at': userCachedAt != null 
            ? DateTime.fromMillisecondsSinceEpoch(userCachedAt).toIso8601String()
            : null,
        'is_cache_valid': await isCacheValid(),
      };
    } catch (e) {
      print('❌ 캐시 통계 조회 실패: $e');
      return {};
    }
  }

  /// 모든 캐시 삭제
  static Future<void> clearAllCache() async {
    try {
      await _recipesBox?.clear();
      await _userBox?.clear();
      await _settingsBox?.clear();
      
      print('✅ 모든 캐시 삭제 완료');
    } catch (e) {
      print('❌ 캐시 삭제 실패: $e');
    }
  }

  /// 캐시 서비스 종료
  static Future<void> dispose() async {
    try {
      await _recipesBox?.close();
      await _userBox?.close();
      await _settingsBox?.close();
      
      _recipesBox = null;
      _userBox = null;
      _settingsBox = null;
      
      print('✅ CacheService 종료 완료');
    } catch (e) {
      print('❌ CacheService 종료 실패: $e');
    }
  }
}