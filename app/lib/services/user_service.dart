import 'package:app/dto/forgot/forgot_password.dart';
import 'package:app/dto/user_dto.dart';
import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../dto/forgot/reset_password.dart';
import '../dto/forgot/verify_otp.dart';
import '../exceptions/api_exceptions.dart';

class UserService {
  final Dio _dio;

  UserService({required Dio dio})
    : _dio = dio
        ..options = BaseOptions(
          baseUrl: AppConfig.baseUrl,
          connectTimeout: AppConfig.apiTimeout,
          sendTimeout: AppConfig.apiTimeout,
          receiveTimeout: AppConfig.apiTimeout,
          contentType: Headers.jsonContentType,
          validateStatus: (status) => status != null && status < 500,
        );

  Future<UserDTO> registerUser(UserDTO user) async {
    if (user.passwordHash != user.confirmPassword) {
      throw const PasswordMismatchException('Mật khẩu nhập lại không khớp');
    }

    final data = {
      ...user.toJson(),
      'accountRole': user.accountRole.name,
      'accountStatus': user.accountStatus.name,
    };

    try {
      final response = await _dio.post('/users', data: data);

      switch (response.statusCode) {
        case 201:
          return UserDTO.fromJson(response.data);
        case 409:
          throw const DuplicateEmailException('Email đã tồn tại');
        default:
          throw ApiException(
            'Đăng ký thất bại: ${response.data?['message'] ?? 'Lỗi không xác định'}',
            response.statusCode,
          );
      }
    } on DioException catch (e) {
      final msg = e.message ?? 'Lỗi kết nối';
      throw ApiException(msg, e.response?.statusCode);
    }
  }

  Future<String> forgotPassword(String email) async {
    try {
      final response = await _dio.post(
        '${AppConfig.users}/forgot-password',
        data: ForgotPassword(email: email).toJson(),
      );
      return response.data as String;
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data?['message'] ?? 'Lỗi hệ thống',
        e.response?.statusCode,
      );
    }
  }

  Future<bool> verifyOtp(String email, String otp) async {
    try {
      final response = await _dio.post(
        '${AppConfig.users}/verify-otp',
        data: VerifyOtp(email: email, otp: otp).toJson(),
      );
      if (response.statusCode == 200) {
        return true;
      } else {
        final errorMessage = response.data is String
            ? response.data
            : response.data['message'] ?? 'Mã OTP không hợp lệ';

        throw ApiException(errorMessage, response.statusCode);
      }
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data?['message'] ?? 'Lỗi xác thực OTP',
        e.response?.statusCode,
      );
    }
  }

  Future<String> resetPassword(
    String email,
    String otp,
    String newPassword,
    String newConfirmPassword,
  ) async {
    try {
      final response = await _dio.post(
        '${AppConfig.users}/reset-password',
        data: ResetPassword(
          email: email,
          otp: otp,
          newPassword: newPassword,
          newConfirmPassword: newConfirmPassword,
        ).toJson(),
      );
      return response.data as String;
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data?['message'] ?? 'Lỗi cập nhật mật khẩu',
        e.response?.statusCode,
      );
    }
  }

  /// Lấy thông tin user đầy đủ theo ID
  Future<UserDTO> getUserById(int userId, String authToken) async {
    try {
      final response = await _dio.get(
        '${AppConfig.users}/$userId',
        options: Options(headers: {'Authorization': 'Bearer $authToken'}),
      );

      if (response.statusCode == 200) {
        return UserDTO.fromJson(response.data);
      } else {
        throw ApiException('Không thể lấy thông tin user', response.statusCode);
      }
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data?['message'] ?? 'Lỗi kết nối server',
        e.response?.statusCode,
      );
    }
  }
}
