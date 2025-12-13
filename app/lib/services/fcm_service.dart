import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'fcm_api_service.dart';
import '../controllers/auth_controller.dart';

/// Firebase Cloud Messaging Service
/// Xử lý push notification khi app ở foreground, background, terminated
class FCMService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final AuthController? _authController;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  FCMService({AuthController? authController})
    : _authController = authController;

  /// Khởi tạo FCM và xin quyền notification
  Future<void> initialize() async {
    // Xin quyền notification (iOS)
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('✅ User granted notification permission');
    } else {
      debugPrint('❌ User declined notification permission');
      return;
    }

    // Lấy FCM token
    String? token = await getFCMToken();
    if (token != null) {
      debugPrint('📱 FCM Token: $token');
      await _saveFCMTokenToLocal(token);

      // Gửi token lên backend nếu user đã login
      await _sendTokenToBackend(token);
    }

    // Lắng nghe khi token refresh (thay đổi)
    _firebaseMessaging.onTokenRefresh.listen((newToken) async {
      debugPrint('🔄 FCM Token refreshed: $newToken');
      await _saveFCMTokenToLocal(newToken);
      await _sendTokenToBackend(newToken);
    });

    // Xử lý notification khi app ở foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Xử lý khi user click vào notification (app ở background)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationClick);

    // Kiểm tra xem app có được mở từ notification không (terminated state)
    RemoteMessage? initialMessage = await _firebaseMessaging
        .getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationClick(initialMessage);
    }
  }

  /// Lấy FCM token của thiết bị
  Future<String?> getFCMToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      return token;
    } catch (e) {
      debugPrint('❌ Error getting FCM token: $e');
      return null;
    }
  }

  /// Lưu FCM token vào local storage
  Future<void> _saveFCMTokenToLocal(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fcm_token', token);
  }

  /// Lấy FCM token từ local storage
  Future<String?> getLocalFCMToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('fcm_token');
  }

  /// Xử lý notification khi app đang mở (foreground)
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('📬 Foreground notification: ${message.data['title']}');

    // Hiển thị local notification từ data payload
    if (message.data.containsKey('title') && message.data.containsKey('body')) {
      _showLocalNotification(
        title: message.data['title']!,
        body: message.data['body']!,
        payload: message.data.toString(),
      );
    }
  }

  /// Hiển thị local notification
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'tripfinity_notifications',
          'TripFinity Notifications',
          importance: Importance.high,
          priority: Priority.high,
        );

    await _localNotifications.show(
      DateTime.now().millisecond,
      title,
      body,
      const NotificationDetails(android: androidDetails),
      payload: payload,
    );
  }

  /// Xử lý khi user click vào notification
  void _handleNotificationClick(RemoteMessage message) {
    debugPrint('🔔 Notification clicked: ${message.data}');

    // Navigate đến màn hình tương ứng dựa vào data
    if (message.data.containsKey('bookingId')) {
      String bookingId = message.data['bookingId'];
      debugPrint('Navigate to booking: $bookingId');
    }
  }

  /// Public method: Gửi FCM token lên backend (được gọi từ auth flow)
  Future<void> sendTokenToBackend(String token) async {
    debugPrint('🔑 Sending FCM token to backend');
    await _sendTokenToBackend(token);
  }

  /// Gửi FCM token lên backend
  Future<void> _sendTokenToBackend(String token) async {
    if (_authController == null) {
      debugPrint('⚠️ AuthController is null, skip sending token');
      return;
    }

    final user = _authController.currentUser;
    if (user == null || user.userId == null) {
      debugPrint('⚠️ User not logged in, skip sending token');
      return;
    }

    final authToken = _authController.rawToken;
    await FCMApiService.updateFCMToken(
      userId: user.userId!,
      fcmToken: token,
      authToken: authToken,
    );
  }

  /// Xóa FCM token khỏi backend khi logout
  Future<void> clearTokenFromBackend() async {
    if (_authController == null) return;

    final user = _authController.currentUser;
    if (user == null || user.userId == null) return;

    final authToken = _authController.rawToken;
    await FCMApiService.deleteFCMToken(
      userId: user.userId!,
      authToken: authToken,
    );
  }

  /// Subscribe vào topic (cho notification broadcast)
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      debugPrint('✅ Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('❌ Error subscribing to topic: $e');
    }
  }

  /// Unsubscribe khỏi topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      debugPrint('✅ Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('❌ Error unsubscribing from topic: $e');
    }
  }
}
