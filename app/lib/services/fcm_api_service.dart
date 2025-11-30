import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class FCMApiService {
  /// Gửi FCM token lên backend để lưu vào database
  static Future<bool> updateFCMToken({
    required int userId,
    required String fcmToken,
    String? authToken,
  }) async {
    try {
      print('🔄 FCMApiService: Calling PUT /fcm/token');
      print('   userId: $userId');
      print('   fcmToken: ${fcmToken.substring(0, 20)}...');
      print('   authToken: ${authToken != null ? "present" : "null"}');

      final url = Uri.parse('${AppConfig.baseUrl}/fcm/token');
      print('   URL: $url');

      final headers = {
        'Content-Type': 'application/json',
        if (authToken != null) 'Authorization': 'Bearer $authToken',
      };

      final body = jsonEncode({'userId': userId, 'fcmToken': fcmToken});

      final response = await http.put(url, headers: headers, body: body);
      print('   Response status: ${response.statusCode}');
      print('   Response body: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ FCM token updated successfully');
        return true;
      } else {
        print('❌ Failed to update FCM token: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Error updating FCM token: $e');
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
        print('✅ FCM token deleted successfully');
        return true;
      } else {
        print('❌ Failed to delete FCM token: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Error deleting FCM token: $e');
      return false;
    }
  }
}
