import '../../models/user.dart';
import '../../config/app_config.dart';
import 'api_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ApiService _apiService = ApiService();

  Future<AuthResult> signup({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      print('🔍 AuthService signup API 호출: $email');
      print('🔍 API URL: ${AppConfig.baseUrl}${AppConfig.authEndpoint}/signup');
      
      final response = await _apiService.post(
        '${AppConfig.authEndpoint}/signup',
        data: {
          'email': email,
          'password': password,
          if (fullName != null) 'full_name': fullName,
        },
      );

      print('🔍 API 응답: status=${response.statusCode}, data=${response.data}');

      if (response.statusCode == 200) {
        final user = User.fromJson(response.data);
        return AuthResult.success(user: user);
      } else {
        final errorMsg = response.data['detail'] ?? '회원가입에 실패했습니다.';
        print('❌ API 오류 응답: $errorMsg');
        return AuthResult.failure(message: errorMsg);
      }
    } on ApiException catch (e) {
      print('❌ ApiException: ${e.message} (status: ${e.statusCode})');
      return AuthResult.failure(message: e.message);
    } catch (e) {
      print('❌ 일반 Exception: $e');
      return AuthResult.failure(message: '알 수 없는 오류가 발생했습니다: $e');
    }
  }

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        '${AppConfig.authEndpoint}/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final accessToken = data['access_token'] as String;
        final tokenType = data['token_type'] as String;

        return LoginResult.success(
          accessToken: accessToken,
          tokenType: tokenType,
        );
      } else {
        return AuthResult.failure(
          message: response.data['detail'] ?? '로그인에 실패했습니다.',
        );
      }
    } on ApiException catch (e) {
      return AuthResult.failure(message: e.message);
    } catch (e) {
      return AuthResult.failure(message: '알 수 없는 오류가 발생했습니다.');
    }
  }

  Future<AuthResult> getCurrentUser() async {
    try {
      final response = await _apiService.get('${AppConfig.authEndpoint}/me');

      if (response.statusCode == 200) {
        final user = User.fromJson(response.data);
        return AuthResult.success(user: user);
      } else {
        return AuthResult.failure(
          message: response.data['detail'] ?? '사용자 정보를 가져올 수 없습니다.',
        );
      }
    } on ApiException catch (e) {
      return AuthResult.failure(message: e.message);
    } catch (e) {
      return AuthResult.failure(message: '알 수 없는 오류가 발생했습니다.');
    }
  }

  Future<void> logout() async {
    // 로컬에서만 처리 (서버에 별도 로그아웃 엔드포인트가 없음)
    // 필요시 서버에 로그아웃 엔드포인트 추가 후 호출
  }
}

// Auth Result Classes
abstract class AuthResult {
  final bool isSuccess;
  final String? message;
  final User? user;

  AuthResult._({
    required this.isSuccess,
    this.message,
    this.user,
  });

  factory AuthResult.success({User? user}) = AuthSuccess;
  factory AuthResult.failure({required String message}) = AuthFailure;
}

class AuthSuccess extends AuthResult {
  AuthSuccess({User? user}) : super._(isSuccess: true, user: user);
}

class AuthFailure extends AuthResult {
  AuthFailure({required String message}) 
      : super._(isSuccess: false, message: message);
}

class LoginResult extends AuthResult {
  final String? accessToken;
  final String? tokenType;

  LoginResult._({
    required bool isSuccess,
    String? message,
    this.accessToken,
    this.tokenType,
  }) : super._(isSuccess: isSuccess, message: message);

  factory LoginResult.success({
    required String accessToken,
    required String tokenType,
  }) = LoginSuccess;

  factory LoginResult.failure({required String message}) = LoginFailure;
}

class LoginSuccess extends LoginResult {
  LoginSuccess({
    required String accessToken,
    required String tokenType,
  }) : super._(
          isSuccess: true,
          accessToken: accessToken,
          tokenType: tokenType,
        );
}

class LoginFailure extends LoginResult {
  LoginFailure({required String message})
      : super._(isSuccess: false, message: message);
}