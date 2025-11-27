import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app/config/app_config.dart';
import 'package:app/dto/notification_dto.dart';

class NotificationApiService {
  final Dio _dio;

  NotificationApiService({required Dio dio, required SharedPreferences prefs})
    : _dio = dio {
    _dio.options = BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      headers: {'Content-Type': 'application/json'},
    );
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            final token = prefs.getString('user_token');
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          } catch (_) {}
          handler.next(options);
        },
      ),
    );
  }

  /// Lấy danh sách notifications của user
  Future<List<NotificationDTO>> getNotificationsByUser(int userId) async {
    try {
      final res = await _dio.get('/notifications/user/$userId');
      if (res.statusCode == 200 && res.data is List) {
        return (res.data as List)
            .map((json) => NotificationDTO.fromJson(json))
            .toList();
      }
      final msg = (res.data is Map && (res.data as Map)['message'] != null)
          ? (res.data as Map)['message'].toString()
          : 'Get notifications failed with status ${res.statusCode}';
      throw Exception(msg);
    } catch (e) {
      throw Exception('Failed to get notifications: $e');
    }
  }

  /// Lấy danh sách notifications chưa đọc
  Future<List<NotificationDTO>> getUnreadNotifications(int userId) async {
    try {
      final res = await _dio.get('/notifications/user/$userId/unread');
      if (res.statusCode == 200 && res.data is List) {
        return (res.data as List)
            .map((json) => NotificationDTO.fromJson(json))
            .toList();
      }
      final msg = (res.data is Map && (res.data as Map)['message'] != null)
          ? (res.data as Map)['message'].toString()
          : 'Get unread notifications failed with status ${res.statusCode}';
      throw Exception(msg);
    } catch (e) {
      throw Exception('Failed to get unread notifications: $e');
    }
  }

  /// Đếm số notifications chưa đọc
  Future<int> getUnreadCount(int userId) async {
    try {
      final res = await _dio.get('/notifications/user/$userId/unread/count');
      if (res.statusCode == 200 && res.data is Map) {
        return (res.data['count'] as num?)?.toInt() ?? 0;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  /// Đánh dấu notification là đã đọc
  Future<bool> markAsRead(int notificationId) async {
    try {
      final res = await _dio.patch('/notifications/$notificationId/read');
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Đánh dấu tất cả notifications là đã đọc
  Future<bool> markAllAsRead(int userId) async {
    try {
      final res = await _dio.patch('/notifications/user/$userId/read-all');
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Xóa notification
  Future<bool> deleteNotification(int notificationId) async {
    try {
      final res = await _dio.delete('/notifications/$notificationId');
      return res.statusCode == 204 || res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Xóa tất cả notifications của user
  Future<bool> deleteAllNotifications(int userId) async {
    try {
      final res = await _dio.delete('/notifications/user/$userId/all');
      return res.statusCode == 204 || res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
