import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';

class FCMApiService {
  /// Gửi FCM token lên backend để lưu vào database
  static Future<bool> updateFCMToken({
    required int userId,
    required String fcmToken,
    String? authToken,
  }) async {
    try {
      debugPrint('🔄 FCMApiService: Calling PUT /fcm/token');
      debugPrint('   userId: $userId');
      debugPrint('   fcmToken: ${fcmToken.substring(0, 20)}...');
      debugPrint('   authToken: ${authToken != null ? "present" : "null"}');

      final url = Uri.parse('${AppConfig.baseUrl}/fcm/token');
      debugPrint('   URL: $url');

      final headers = {
        'Content-Type': 'application/json',
        if (authToken != null) 'Authorization': 'Bearer $authToken',
      };

      final body = jsonEncode({'userId': userId, 'fcmToken': fcmToken});

      final response = await http.put(url, headers: headers, body: body);
      debugPrint('   Response status: ${response.statusCode}');
      debugPrint('   Response body: ${response.body}');

      if (response.statusCode == 200) {
        debugPrint('✅ FCM token updated successfully');
        return true;
      } else {
        debugPrint('❌ Failed to update FCM token: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error updating FCM token: $e');
      return false;
    }
  }

  /// Xóa FCM token khi logout
  static Future<bool> deleteFCMToken({
    required int userId,
    String? authToken,
  }) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}/fcm/token/$userId');

      final headers = {
        'Content-Type': 'application/json',
        if (authToken != null) 'Authorization': 'Bearer $authToken',
      };

      final response = await http.delete(url, headers: headers);

      if (response.statusCode == 200) {
        debugPrint('✅ FCM token deleted successfully');
        return true;
      } else {
        debugPrint('❌ Failed to delete FCM token: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error deleting FCM token: $e');
      return false;
    }
  }
}
