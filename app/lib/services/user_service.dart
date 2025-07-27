import 'package:app/dto/user_dto.dart';
import 'package:dio/dio.dart';

import '../config/app_config.dart';
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
}
