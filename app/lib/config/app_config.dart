import 'package:flutter/foundation.dart' show kIsWeb;

class AppConfig {
  static const String appName = 'Tripfinity Flutter Application';
  static const String appVersion = '1.0.0';

  // API Configuration - Web dùng localhost, Mobile dùng 10.0.2.2
  static String get baseUrl =>
      kIsWeb ? 'http://localhost:8080/api' : 'http://10.0.2.2:8080/api';
  static const Duration apiTimeout = Duration(seconds: 30);

  // Authentication
  static const String auth = '/auth';

  // User Roles
  static const String users = '/users';
}
