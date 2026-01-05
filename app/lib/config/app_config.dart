import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class AppConfig {
  static const String appName = 'Tripfinity Flutter Application';
  static const String appVersion = '1.0.0';

  // ============================================================
  // 🔧 ENVIRONMENT CONFIGURATION
  // ============================================================
  // Đổi thành true khi muốn dùng Ngrok (test trên Appetize.io, thiết bị thật qua internet)
  // Đổi thành false khi chạy local (emulator, localhost)
  static const bool useNgrok = false;

  // 🌐 NGROK URL - Cập nhật URL này mỗi khi chạy ngrok
  // Chạy trên Windows: ngrok http 8080
  // Copy URL từ terminal ngrok paste vào đây
  static const String ngrokUrl = 'https://3da856b2701b.ngrok-free.app';

  // ============================================================
  // API CONFIGURATION
  // ============================================================
  static String get baseUrl {
    // Nếu dùng Ngrok -> dùng URL public
    if (useNgrok) {
      return '$ngrokUrl/api';
    }

    // Nếu chạy trên Web -> localhost
    if (kIsWeb) {
      return 'http://localhost:8080/api';
    }

    // Nếu chạy trên mobile
    try {
      // Android Emulator dùng 10.0.2.2
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:8080/api';
      }
      // iOS Simulator dùng localhost
      if (Platform.isIOS) {
        return 'http://localhost:8080/api';
      }
    } catch (e) {
      // Fallback nếu không detect được platform
    }

    return 'http://localhost:8080/api';
  }

  static const Duration apiTimeout = Duration(seconds: 30);

  // Authentication
  static const String auth = '/auth';

  // User Roles
  static const String users = '/users';
}
