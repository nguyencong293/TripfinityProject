import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';
import '../dto/auth/login_request.dart';
import '../dto/auth/login_response.dart';
import '../exceptions/api_exceptions.dart';

class AuthService {
  final Dio _dio;
  final SharedPreferences _prefs;

  AuthService({required Dio dio, required SharedPreferences prefs})
    : _dio = dio
        ..options = BaseOptions(
          baseUrl: AppConfig.baseUrl,
          connectTimeout: AppConfig.apiTimeout,
          sendTimeout: AppConfig.apiTimeout,
          receiveTimeout: AppConfig.apiTimeout,
          contentType: Headers.jsonContentType,
          validateStatus: (status) => status != null && status < 500,
        ),
      _prefs = prefs {
    _addInterceptors();
  }

  void _addInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = _prefs.getString('user_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            // await _prefs.clear();
            await _prefs.remove('user_token');
            await _prefs.remove('user_id');
            await _prefs.remove('user_email');
            await _prefs.remove('user_name');
          }
          return handler.next(error);
        },
      ),
    );
  }

  Future<LoginResponse> login(LoginRequest loginRequest) async {
    try {
      final response = await _dio.post(
        '${AppConfig.auth}/login',
        data: loginRequest.toJson(),
      );

      if (response.statusCode == 200) {
        return LoginResponse.fromJson(response.data);
      } else {
        final errorMessage = response.data is String
            ? response.data
            : response.data['message'] ?? 'Đăng nhập thất bại';

        throw ApiException(errorMessage, response.statusCode);
      }
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data?['message'] ?? 'Lỗi đăng nhập',
        e.response?.statusCode,
      );
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post('${AppConfig.auth}/logout');
    } finally {
      await _prefs.remove('user_token');
      await _prefs.remove('user_id');
      await _prefs.remove('user_email');
      await _prefs.remove('user_name');
    }
  }

  Future<LoginResponse> googleLogin(String idToken) async {
    try {
      final response = await _dio.post(
        '${AppConfig.auth}/oauth-login',
        data: {'id_token': idToken},
      );

      if (response.statusCode == 200) {
        return LoginResponse.fromJson(response.data);
      } else {
        throw ApiException(
          response.data['message'] ?? 'Đăng nhập Google thất bại',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data?['message'] ?? 'Lỗi đăng nhập Google',
        e.response?.statusCode,
      );
    }
  }
}
