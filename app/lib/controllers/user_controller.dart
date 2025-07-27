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
}
