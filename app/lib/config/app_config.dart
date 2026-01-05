class AppConfig {
  static const String appName = 'Tripfinity Flutter Application';
  static const String appVersion = '1.0.0';

  // ============================================================
  // 🔧 NGROK CONFIGURATION - CHỈ CẦN CẬP NHẬT 2 URL NÀY
  // ============================================================
  // Chạy lệnh: start_all.bat để khởi động tất cả services
  // Xem URLs tại dashboard:
  //   - Backend:  http://127.0.0.1:4040
  //   - Chatbot:  http://127.0.0.1:4041
  //
  // Ngrok là cầu nối → dùng ngrok URL cho TẤT CẢ nền tảng:
  //   Android, iOS, Web, Emulator, Simulator, Appetize.io, thiết bị thật
  // ============================================================

  // Backend API (Spring Boot - Port 8080)
  static const String ngrokBackendUrl =
      'https://unprotrusively-nonreportable-kingston.ngrok-free.dev';

  // Chatbot API (Python FastAPI - Port 8000)
  static const String ngrokChatbotUrl = 'https://ceef2ffd62e1.ngrok-free.app';

  // ============================================================
  // API URLs - LUÔN DÙNG NGROK (đơn giản, hoạt động mọi nơi)
  // ============================================================

  /// Backend API URL
  static String get baseUrl => '$ngrokBackendUrl/api';

  /// Chatbot API URL
  static String get chatbotUrl => ngrokChatbotUrl;

  static const Duration apiTimeout = Duration(seconds: 30);

  // Authentication
  static const String auth = '/auth';

  // User Roles
  static const String users = '/users';
}
