import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class AppConfig {
  static const String appName = 'Tripfinity Flutter Application';
  static const String appVersion = '1.0.0';

  // ============================================================
  // 🔧 CẤU HÌNH KẾT NỐI - TẤT CẢ DÙNG LOCAL, CHỈ iOS DÙNG NGROK
  // ============================================================
  // - Android/Web/Supplier: Kết nối trực tiếp localhost
  // - iOS: Dùng ngrok (vì chạy từ xa qua Appetize.io/thiết bị thật)
  // - Đổi mạng WiFi không ảnh hưởng gì (localhost = nội bộ máy)
  // ============================================================

  // === NGROK URL (CHỈ DÀNH CHO iOS) ===
  static const String ngrokBackendUrl =
      'https://unprotrusively-nonreportable-kingston.ngrok-free.dev';

  // === LOCAL URLs ===
  // Android Emulator: 10.0.2.2 trỏ về localhost của máy host
  // Web/Desktop: localhost trực tiếp
  static String get _localBackendUrl {
    if (kIsWeb) return 'http://localhost:8080';
    if (Platform.isAndroid) return 'http://10.0.2.2:8080';
    return 'http://localhost:8080';
  }

  static String get _localChatbotUrl {
    if (kIsWeb) return 'http://localhost:8000';
    if (Platform.isAndroid) return 'http://10.0.2.2:8000';
    return 'http://localhost:8000';
  }

  // ============================================================
  // 🎯 API URLs - TỰ ĐỘNG CHỌN THEO NỀN TẢNG
  // ============================================================

  /// Backend API URL (iOS → Ngrok, còn lại → Local)
  static String get baseUrl {
    if (!kIsWeb && Platform.isIOS) {
      return '$ngrokBackendUrl/api';
    }
    return '$_localBackendUrl/api';
  }

  /// Chatbot API URL (Luôn dùng Local - demo trên Android)
  static String get chatbotUrl => _localChatbotUrl;

  static const Duration apiTimeout = Duration(seconds: 30);

  // Authentication
  static const String auth = '/auth';

  // User Roles
  static const String users = '/users';
}
