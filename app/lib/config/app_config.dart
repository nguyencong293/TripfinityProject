import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class AppConfig {
  static const String appName = 'Tripfinity Flutter Application';
  static const String appVersion = '1.0.0';

  // ============================================================
  // 🔧 ENVIRONMENT CONFIGURATION
  // ============================================================
  // 🌐 NGROK URL - Cập nhật URL này mỗi khi chạy ngrok mới
  // Chạy lệnh: ngrok http 8080
  // Copy URL từ terminal ngrok paste vào đây
  static const String ngrokUrl =
      'https://unprotrusively-nonreportable-kingston.ngrok-free.dev';

  // 🔄 MODE: true = luôn dùng ngrok (đơn giản, hoạt động mọi nơi)
  //          false = tự động detect (localhost cho local, ngrok cho remote)
  static const bool alwaysUseNgrok = true;

  // ============================================================
  // API CONFIGURATION
  // ============================================================
  // Ngrok forward về localhost:8080, nên dùng ngrok URL sẽ hoạt động
  // trên TẤT CẢ nền tảng: Android, iOS, Web, Appetize.io, thiết bị thật
  // ============================================================

  static String get baseUrl {
    // Luôn dùng ngrok -> đơn giản và hoạt động mọi nơi
    if (alwaysUseNgrok) {
      return '$ngrokUrl/api';
    }

    // === CHẾ ĐỘ TỰ ĐỘNG (khi alwaysUseNgrok = false) ===

    // Web browser chạy trên cùng máy -> dùng localhost
    if (kIsWeb) {
      return 'http://localhost:8080/api';
    }

    // Mobile platforms
    try {
      // Android Emulator dùng 10.0.2.2 để trỏ về host machine
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:8080/api';
      }

      // iOS Simulator dùng localhost
      if (Platform.isIOS) {
        return 'http://localhost:8080/api';
      }

      // macOS, Windows, Linux desktop
      if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
        return 'http://localhost:8080/api';
      }
    } catch (e) {
      // Fallback về ngrok
    }

    return '$ngrokUrl/api';
  }

  static const Duration apiTimeout = Duration(seconds: 30);

  // Authentication
  static const String auth = '/auth';

  // User Roles
  static const String users = '/users';
}
