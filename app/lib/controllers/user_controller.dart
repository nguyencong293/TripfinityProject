import 'package:app/dto/user_dto.dart';
import 'package:app/services/user_service.dart';
import 'package:flutter/cupertino.dart';

import '../exceptions/api_exceptions.dart';

class UserController with ChangeNotifier {
  final UserService _userService;

  UserController({required UserService userService})
    : _userService = userService;

  bool _isLoading = false;
  String? _errorMessage;
  UserDTO? _currentUser;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  UserDTO? get currentUser => _currentUser;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> register(UserDTO user) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _userService.registerUser(user);
      return true;
    } on PasswordMismatchException catch (e) {
      _errorMessage = e.message;
    } on DuplicateEmailException catch (e) {
      _errorMessage = e.message;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Đã xảy ra lỗi không xác định';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }

  Future<bool> forgotPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _userService.forgotPassword(email);
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Email không hợp lệ hoặc không tồn tại';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }

  Future<bool> verifyOtp(String email, String otp) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final isValid = await _userService.verifyOtp(email, otp);
      return isValid;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Lỗi xác thực';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }

  Future<bool> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
    required String newConfirmPassword,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _userService.resetPassword(
        email,
        otp,
        newPassword,
        newConfirmPassword,
      );
      return true;
    } on PasswordMismatchException catch (e) {
      _errorMessage = e.message;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Lỗi cập nhật mật khẩu';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }
}
