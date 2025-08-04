import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
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

  Future<AuthResult> updateProfile({
    String? fullName,
  }) async {
    try {
      print('🔍 AuthService updateProfile 시작');
      
      final Map<String, dynamic> updateData = {};
      if (fullName != null) {
        updateData['full_name'] = fullName;
      }
      
      if (updateData.isEmpty) {
        return AuthResult.failure(message: '업데이트할 정보가 없습니다.');
      }
      
      final response = await _apiService.put(
        '${AppConfig.authEndpoint}/me',
        data: updateData,
      );

      print('🔍 프로필 업데이트 API 응답: status=${response.statusCode}, data=${response.data}');

      if (response.statusCode == 200) {
        final user = User.fromJson(response.data);
        print('✅ 프로필 업데이트 성공');
        return AuthResult.success(user: user);
      } else {
        final errorMsg = response.data['detail'] ?? '프로필 업데이트에 실패했습니다.';
        print('❌ 프로필 업데이트 API 오류: $errorMsg');
        return AuthResult.failure(message: errorMsg);
      }
    } on ApiException catch (e) {
      print('❌ AuthService updateProfile ApiException: ${e.message}');
      return AuthResult.failure(message: e.message);
    } catch (e) {
      print('❌ AuthService updateProfile Exception: $e');
      return AuthResult.failure(message: '프로필 업데이트 중 오류가 발생했습니다.');
    }
  }

  Future<AuthResult> uploadProfileImage(String filePath) async {
    try {
      print('🔍 AuthService uploadProfileImage 시작: $filePath');
      
      final file = File(filePath);
      if (!await file.exists()) {
        return AuthResult.failure(message: '파일을 찾을 수 없습니다.');
      }

      final fileName = filePath.split('/').last;
      final fileExtension = fileName.split('.').last.toLowerCase();
      
      // 이미지 파일 확장자에 따른 MIME type 설정
      MediaType? mediaType;
      switch (fileExtension) {
        case 'jpg':
        case 'jpeg':
          mediaType = MediaType('image', 'jpeg');
          break;
        case 'png':
          mediaType = MediaType('image', 'png');
          break;
        case 'gif':
          mediaType = MediaType('image', 'gif');
          break;
        case 'webp':
          mediaType = MediaType('image', 'webp');
          break;
        default:
          mediaType = MediaType('image', 'jpeg'); // 기본값
      }
      
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          filePath,
          filename: fileName,
          contentType: mediaType,
        ),
      });

      print('🔍 API URL: ${AppConfig.baseUrl}${AppConfig.authEndpoint}/profile-image');
      print('🔍 파일명: $fileName, 파일 크기: ${await file.length()} bytes');
      print('🔍 MIME Type: ${mediaType.toString()}');
      
      final response = await _apiService.post(
        '${AppConfig.authEndpoint}/profile-image',
        data: formData,
      );

      print('🔍 프로필 이미지 업로드 API 응답: status=${response.statusCode}, data=${response.data}');

      if (response.statusCode == 200) {
        final user = User.fromJson(response.data);
        print('✅ 프로필 이미지 업로드 성공');
        return AuthResult.success(user: user);
      } else {
        final errorMsg = response.data['detail'] ?? '프로필 이미지 업로드에 실패했습니다.';
        print('❌ 프로필 이미지 업로드 API 오류: $errorMsg');
        return AuthResult.failure(message: errorMsg);
      }
    } on ApiException catch (e) {
      print('❌ AuthService uploadProfileImage ApiException: ${e.message}');
      return AuthResult.failure(message: e.message);
    } catch (e) {
      print('❌ AuthService uploadProfileImage Exception: $e');
      return AuthResult.failure(message: '프로필 이미지 업로드 중 오류가 발생했습니다.');
    }
  }

  Future<AuthResult> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      print('🔍 AuthService changePassword 시작');
      
      final response = await _apiService.post(
        '${AppConfig.authEndpoint}/change-password',
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );

      print('🔍 비밀번호 변경 API 응답: status=${response.statusCode}, data=${response.data}');

      if (response.statusCode == 200) {
        print('✅ 비밀번호 변경 성공');
        return AuthResult.success();
      } else {
        final errorMsg = response.data['detail'] ?? '비밀번호 변경에 실패했습니다.';
        print('❌ 비밀번호 변경 API 오류: $errorMsg');
        return AuthResult.failure(message: errorMsg);
      }
    } on ApiException catch (e) {
      print('❌ AuthService changePassword ApiException: ${e.message}');
      return AuthResult.failure(message: e.message);
    } catch (e) {
      print('❌ AuthService changePassword Exception: $e');
      return AuthResult.failure(message: '비밀번호 변경 중 오류가 발생했습니다.');
    }
  }

  Future<AuthResult> deleteAccount({
    required String password,
    required String confirmation,
  }) async {
    try {
      print('🔍 AuthService deleteAccount 시작');
      
      final response = await _apiService.post(
        '${AppConfig.authEndpoint}/delete-account',
        data: {
          'password': password,
          'confirmation': confirmation,
        },
      );

      print('🔍 계정 삭제 API 응답: status=${response.statusCode}, data=${response.data}');

      if (response.statusCode == 200) {
        print('✅ 계정 삭제 성공');
        return AuthResult.success();
      } else {
        final errorMsg = response.data['detail'] ?? '계정 삭제에 실패했습니다.';
        print('❌ 계정 삭제 API 오류: $errorMsg');
        return AuthResult.failure(message: errorMsg);
      }
    } on ApiException catch (e) {
      print('❌ AuthService deleteAccount ApiException: ${e.message}');
      return AuthResult.failure(message: e.message);
    } catch (e) {
      print('❌ AuthService deleteAccount Exception: $e');
      return AuthResult.failure(message: '계정 삭제 중 오류가 발생했습니다.');
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