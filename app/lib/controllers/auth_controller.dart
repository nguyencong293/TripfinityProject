import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../dto/auth/login_request.dart';
import '../dto/auth/login_response.dart';
import '../dto/user_dto.dart';
import '../exceptions/api_exceptions.dart';
import '../services/auth_service.dart';
import '../services/fcm_service.dart';
import '../services/user_service.dart';
import '../services/recommendation_service.dart';

class AuthController with ChangeNotifier {
  final AuthService _authService;
  final SharedPreferences _prefs;
  final UserService _userService;
  final RecommendationService _recommendationService;
  FCMService? _fcmService;

  String? _rawToken;
  UserDTO? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AuthController({
    required AuthService authService,
    required SharedPreferences prefs,
    required UserService userService,
    required RecommendationService recommendationService,
  }) : _authService = authService,
       _prefs = prefs,
       _userService = userService,
       _recommendationService = recommendationService {
    _loadFromPrefs();
  }

  /// Set FCM service sau khi khởi tạo
  void setFCMService(FCMService fcmService) {
    _fcmService = fcmService;
  }

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  UserDTO? get currentUser => _currentUser;

  String? get rawToken => _rawToken;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Token valid if present and exp > now
  bool get isTokenValid {
    if (_rawToken == null) return false;
    try {
      final parts = _rawToken!.split('.');
      final payload = utf8.decode(base64Url.decode(_normalize(parts[1])));
      final exp = jsonDecode(payload)['exp'] as int;
      return DateTime.fromMillisecondsSinceEpoch(
        exp * 1000,
      ).isAfter(DateTime.now());
    } catch (_) {
      return false;
    }
  }

  /// Chỉ đăng nhập khi có token hợp lệ và user đã được xác thực
  bool get isLoggedIn => _currentUser != null && isTokenValid;

  String _normalize(String str) => str + '=' * ((4 - str.length % 4) % 4);

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final req = LoginRequest(email: email, password: password);
      final resp = await _authService.login(req);
      await _saveUserData(resp);

      // Gửi FCM token lên backend sau khi login thành công
      debugPrint('🔑 Login successful, sending FCM token to backend...');
      if (_fcmService != null) {
        debugPrint('✅ FCM service is available');
        final token = await _fcmService!.getFCMToken();
        debugPrint('📱 FCM Token: ${token?.substring(0, 20)}...');
        if (token != null) {
          await _fcmService!.sendTokenToBackend(token);
          debugPrint('✅ FCM token sent to backend');
        } else {
          debugPrint('⚠️ FCM token is null');
        }
      } else {
        debugPrint('❌ FCM service is null!');
      }

      // Gọi API gợi ý sau khi login thành công
      _fetchRecommendations(resp.userId);

      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Lỗi không xác định';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }

  Future<void> _saveUserData(LoginResponse resp) async {
    _rawToken = resp.token;

    // Lưu token và basic info vào prefs
    await _prefs.setString('user_token', resp.token);
    await _prefs.setInt('user_id', resp.userId);
    await _prefs.setString('user_email', resp.email);
    await _prefs.setString('user_name', resp.name);

    // Load FULL user data từ API (bao gồm phone, dob, gender)
    try {
      debugPrint('📥 Loading full user data from API...');
      final fullUser = await _userService.getUserById(resp.userId, resp.token);
      _currentUser = fullUser;
      debugPrint(
        '✅ Full user data loaded: phone=${fullUser.phoneNumber}, dob=${fullUser.dateOfBirth}',
      );
    } catch (e) {
      debugPrint('⚠️ Failed to load full user data, using token data: $e');
      // Fallback: Sử dụng thông tin từ token nếu API fail
      _currentUser = UserDTO(
        userId: resp.userId,
        email: resp.email,
        fullName: resp.name,
      );
    }
  }

  Future<void> _loadFromPrefs() async {
    final token = _prefs.getString('user_token');
    if (token != null) {
      _rawToken = token;
      final id = _prefs.getInt('user_id');
      final email = _prefs.getString('user_email');
      final name = _prefs.getString('user_name');
      if (id != null && email != null && name != null && isTokenValid) {
        // Load FULL user data từ API thay vì chỉ dùng cache
        try {
          debugPrint('📥 Loading full user data from API on app start...');
          final fullUser = await _userService.getUserById(id, token);
          _currentUser = fullUser;
          debugPrint('✅ Full user data loaded: phone=${fullUser.phoneNumber}');
        } catch (e) {
          debugPrint('⚠️ Failed to load full user, using cached data: $e');
          // Fallback: Sử dụng data từ prefs nếu API fail
          _currentUser = UserDTO(userId: id, email: email, fullName: name);
        }
      } else {
        await logout();
      }
    }
    notifyListeners();
  }

  Future<void> logout() async {
    try {
      // Xóa FCM token khỏi backend trước khi logout
      if (_fcmService != null) {
        await _fcmService!.clearTokenFromBackend();
      }

      await _authService.logout();
    } finally {
      _rawToken = null;
      _currentUser = null;
      notifyListeners();
    }
  }

  Future<bool> googleLogin() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Khởi tạo Google Sign-In
      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId:
            '173444476399-srrjbrmg2c0rsatfd4498t0499gmn104.apps.googleusercontent.com',
        scopes: ['email', 'profile'],
      );

      // Thực hiện đăng nhập
      final GoogleSignInAccount? account = await googleSignIn.signIn();
      if (account == null) return false;

      // Lấy ID token
      final GoogleSignInAuthentication auth = await account.authentication;
      final String? idToken = auth.idToken;

      if (idToken == null) {
        throw ApiException('Không nhận ID Google');
      }

      final resp = await _authService.googleLogin(idToken);
      await _saveUserData(resp);

      // Gửi FCM token lên backend sau khi Google login thành công
      if (_fcmService != null) {
        final token = await _fcmService!.getFCMToken();
        if (token != null) {
          await _fcmService!.sendTokenToBackend(token);
        }
      }

      // Gọi API gợi ý sau khi Google login thành công
      _fetchRecommendations(resp.userId);

      return true;
    } on PlatformException catch (e) {
      _errorMessage = 'Lỗi Google Sign-In: [${e.code}] ${e.message}';
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Lỗi đăng nhập Google: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }

  /// Cập nhật thông tin user hiện tại
  void updateCurrentUser(UserDTO user) {
    _currentUser = user;
    notifyListeners();
  }

  /// Gọi API gợi ý (không chặn flow đăng nhập)
  void _fetchRecommendations(int userId) {
    // Chạy async mà không await để không chặn đăng nhập
    _recommendationService
        .getRecommendations(userId)
        .then((response) {
          if (response.success && response.data != null) {
            debugPrint(
              '✅ Fetched ${response.data!.length} recommendations for user $userId',
            );
            // Có thể lưu vào state hoặc cache nếu cần
            // Ở đây chỉ log ra console
            for (var item in response.data!) {
              debugPrint(
                '  - ${item.title} (${item.itemType}) - ${item.priceFmt}',
              );
            }
          } else {
            debugPrint(
              'ℹ️ No recommendations for user $userId: ${response.message}',
            );
          }
        })
        .catchError((error) {
          debugPrint('⚠️ Failed to fetch recommendations: $error');
          // Không hiển thị lỗi cho user, chỉ log
        });
  }
}
