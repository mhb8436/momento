import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/api/auth_service.dart';
import '../services/storage/local_storage_service.dart';
import '../services/cache_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isOfflineMode = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get error => _errorMessage;
  bool get isAuthenticated => _user != null && LocalStorageService.hasAccessToken();
  bool get isOfflineMode => _isOfflineMode;

  AuthProvider() {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    // Check if user is already logged in
    if (LocalStorageService.hasAccessToken()) {
      final savedUser = LocalStorageService.getUserData();
      if (savedUser != null) {
        _user = savedUser;
        notifyListeners();
        
        // Verify token is still valid
        await _verifyCurrentUser();
      }
    }
  }

  Future<void> _verifyCurrentUser() async {
    try {
      // 먼저 서버 연결 상태 확인
      final isServerOnline = await CacheService.isOnline();
      
      if (!isServerOnline) {
        print('🔍 서버 오프라인 - 기존 사용자 정보 유지');
        // 서버가 다운된 경우 기존 토큰과 사용자 정보 유지
        _isOfflineMode = true;
        notifyListeners();
        return;
      }
      
      final result = await _authService.getCurrentUser();
      if (result.isSuccess && result.user != null) {
        _user = result.user;
        await LocalStorageService.saveUserData(_user!);
        _isOfflineMode = false; // 서버 연결 성공
        notifyListeners();
        print('✅ 사용자 정보 검증 완료');
      } else {
        // Token is invalid (서버는 정상이지만 토큰이 만료된 경우)
        print('❌ 토큰 만료 - 로그아웃');
        await logout();
      }
    } catch (e) {
      print('❌ 사용자 검증 중 오류: $e');
      
      // 서버 연결 상태 재확인
      final isServerOnline = await CacheService.isOnline();
      if (!isServerOnline) {
        print('🔍 서버 연결 불가 - 기존 사용자 정보 유지');
        // 서버 문제인 경우 기존 토큰과 사용자 정보 유지
        _isOfflineMode = true;
        notifyListeners();
        return;
      }
      
      // 서버는 정상인데 다른 오류인 경우만 로그아웃
      print('❌ 인증 오류 - 로그아웃');
      await logout();
    }
  }

  Future<bool> signup({
    required String email,
    required String password,
    String? fullName,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      print('🔍 AuthProvider signup 시작: $email');
      
      final result = await _authService.signup(
        email: email,
        password: password,
        fullName: fullName,
      );

      print('🔍 AuthService signup 결과: success=${result.isSuccess}, message=${result.message}');

      if (result.isSuccess && result.user != null) {
        // After successful signup, automatically login
        print('🔍 회원가입 성공, 자동 로그인 시도');
        return await login(email: email, password: password);
      } else {
        final errorMsg = result.message ?? '회원가입에 실패했습니다.';
        print('❌ 회원가입 실패: $errorMsg');
        _setError(errorMsg);
        return false;
      }
    } catch (e) {
      print('❌ AuthProvider signup exception: $e');
      _setError('알 수 없는 오류가 발생했습니다: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.login(email: email, password: password);

      if (result.isSuccess && result is LoginSuccess) {
        // Save access token
        await LocalStorageService.saveAccessToken(result.accessToken!);
        
        // Get user data
        final userResult = await _authService.getCurrentUser();
        if (userResult.isSuccess && userResult.user != null) {
          _user = userResult.user;
          await LocalStorageService.saveUserData(_user!);
          notifyListeners();
          return true;
        } else {
          _setError('사용자 정보를 가져올 수 없습니다.');
          return false;
        }
      } else {
        _setError(result.message ?? '로그인에 실패했습니다.');
        return false;
      }
    } catch (e) {
      _setError('알 수 없는 오류가 발생했습니다.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);

    try {
      await _authService.logout();
    } catch (e) {
      // Continue with logout even if server call fails
      debugPrint('Logout error: $e');
    }

    // Clear local data
    await LocalStorageService.removeAccessToken();
    await LocalStorageService.removeUserData();
    
    _user = null;
    _clearError();
    _setLoading(false);
    notifyListeners();
  }

  Future<void> refreshUser() async {
    if (!isAuthenticated) return;

    try {
      final result = await _authService.getCurrentUser();
      if (result.isSuccess && result.user != null) {
        _user = result.user;
        await LocalStorageService.saveUserData(_user!);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Refresh user error: $e');
    }
  }

  Future<bool> updateProfile({String? fullName}) async {
    if (!isAuthenticated) {
      _setError('로그인이 필요합니다.');
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.updateProfile(fullName: fullName);
      
      if (result.isSuccess && result.user != null) {
        _user = result.user;
        await LocalStorageService.saveUserData(_user!);
        notifyListeners();
        return true;
      } else {
        _setError(result.message ?? '프로필 업데이트에 실패했습니다.');
        return false;
      }
    } catch (e) {
      _setError('프로필 업데이트 중 오류가 발생했습니다.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> uploadProfileImage(String filePath) async {
    if (!isAuthenticated) {
      _setError('로그인이 필요합니다.');
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.uploadProfileImage(filePath);
      
      if (result.isSuccess && result.user != null) {
        _user = result.user;
        await LocalStorageService.saveUserData(_user!);
        notifyListeners();
        return true;
      } else {
        _setError(result.message ?? '프로필 이미지 업로드에 실패했습니다.');
        return false;
      }
    } catch (e) {
      _setError('프로필 이미지 업로드 중 오류가 발생했습니다.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (!isAuthenticated) {
      _setError('로그인이 필요합니다.');
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      
      if (result.isSuccess) {
        return true;
      } else {
        _setError(result.message ?? '비밀번호 변경에 실패했습니다.');
        return false;
      }
    } catch (e) {
      _setError('비밀번호 변경 중 오류가 발생했습니다.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteAccount({
    required String password,
    required String confirmation,
  }) async {
    if (!isAuthenticated) {
      _setError('로그인이 필요합니다.');
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.deleteAccount(
        password: password,
        confirmation: confirmation,
      );
      
      if (result.isSuccess) {
        // Account deleted successfully, perform logout
        await logout();
        return true;
      } else {
        _setError(result.message ?? '계정 삭제에 실패했습니다.');
        return false;
      }
    } catch (e) {
      _setError('계정 삭제 중 오류가 발생했습니다.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
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