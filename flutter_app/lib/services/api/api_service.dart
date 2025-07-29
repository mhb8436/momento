import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import '../../config/app_config.dart';
import '../storage/local_storage_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late final Dio _dio;

  void initialize() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Request Interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Add auth token if available
        final token = LocalStorageService.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        
        print('📤 REQUEST: ${options.method} ${options.path}');
        print('📤 HEADERS: ${options.headers}');
        if (options.data != null) {
          print('📤 DATA: ${options.data}');
        }
        
        handler.next(options);
      },
      onResponse: (response, handler) {
        print('📥 RESPONSE: ${response.statusCode} ${response.requestOptions.path}');
        print('📥 DATA: ${response.data}');
        handler.next(response);
      },
      onError: (error, handler) {
        print('❌ ERROR: ${error.requestOptions.path}');
        print('❌ MESSAGE: ${error.message}');
        print('❌ RESPONSE: ${error.response?.data}');
        handler.next(error);
      },
    ));
  }

  // GET Request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // POST Request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PUT Request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE Request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Upload File
  Future<Response<T>> uploadFile<T>(
    String path,
    File file, {
    String fieldName = 'file',
    Map<String, dynamic>? data,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final formData = FormData();
      
      // Add file
      formData.files.add(MapEntry(
        fieldName,
        await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
      ));
      
      // Add additional data
      if (data != null) {
        data.forEach((key, value) {
          formData.fields.add(MapEntry(key, value.toString()));
        });
      }

      return await _dio.post<T>(
        path,
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
        onSendProgress: onSendProgress,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Error Handler
  ApiException _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          message: '연결 시간이 초과되었습니다. 네트워크를 확인해주세요.',
          statusCode: null,
        );
      
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;
        
        String message = '알 수 없는 오류가 발생했습니다.';
        
        if (data is Map<String, dynamic> && data.containsKey('detail')) {
          message = data['detail'].toString();
        } else if (statusCode != null) {
          switch (statusCode) {
            case 400:
              message = '잘못된 요청입니다.';
              break;
            case 401:
              message = '인증이 필요합니다.';
              break;
            case 403:
              message = '접근 권한이 없습니다.';
              break;
            case 404:
              message = '요청한 리소스를 찾을 수 없습니다.';
              break;
            case 422:
              message = '입력 데이터를 확인해주세요.';
              break;
            case 500:
              message = '서버 오류가 발생했습니다.';
              break;
          }
        }
        
        return ApiException(message: message, statusCode: statusCode);
      
      case DioExceptionType.cancel:
        return ApiException(message: '요청이 취소되었습니다.', statusCode: null);
      
      case DioExceptionType.unknown:
      default:
        if (error.error is SocketException) {
          return ApiException(
            message: '네트워크 연결을 확인해주세요.',
            statusCode: null,
          );
        }
        return ApiException(
          message: '알 수 없는 오류가 발생했습니다: ${error.message}',
          statusCode: null,
        );
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException({required this.message, this.statusCode});

  @override
  String toString() => 'ApiException: $message (Status Code: $statusCode)';
}