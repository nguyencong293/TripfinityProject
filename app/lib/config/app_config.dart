class AppConfig {
  static const String appName = 'Tripfinity Flutter Application';
  static const String appVersion = '1.0.0';

  // API Configuration
  static const String baseUrl = 'http://192.168.1.11:8080/api';
  static const Duration apiTimeout = Duration(seconds: 30);

  // Authentication
  static const String auth = '/auth';

  // User Roles
  static const String users = '/users';
}
