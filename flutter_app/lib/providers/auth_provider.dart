import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/api/auth_service.dart';
import '../services/storage/local_storage_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null && LocalStorageService.hasAccessToken();

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
      final result = await _authService.getCurrentUser();
      if (result.isSuccess && result.user != null) {
        _user = result.user;
        await LocalStorageService.saveUserData(_user!);
        notifyListeners();
      } else {
        // Token is invalid, logout
        await logout();
      }
    } catch (e) {
      // Token might be invalid, logout
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