import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/config/app_config.dart';

/// Service để tracking các hành động người dùng cho AI Recommendation
class UserInteractionService {
  final Dio dio;
  final SharedPreferences prefs;

  UserInteractionService._({required this.dio, required this.prefs});

  /// Factory method to create instance with async dependencies
  static Future<UserInteractionService> create() async {
    final prefs = await SharedPreferences.getInstance();
    final dio = Dio();
    return UserInteractionService._(dio: dio, prefs: prefs);
  }

  /// Sync factory with provided dependencies (for existing code)
  factory UserInteractionService.withDeps({
    required Dio dio,
    required SharedPreferences prefs,
  }) {
    return UserInteractionService._(dio: dio, prefs: prefs);
  }

  /// Base URL - lấy từ AppConfig (không có /api vì sẽ thêm sau)
  String get _baseUrl {
    final url = AppConfig.baseUrl;
    // Remove /api suffix vì các endpoint sẽ thêm /api/...
    return url.replaceAll('/api', '');
  }

  /// Get user ID
  int? get _userId => prefs.getInt('user_id');

  /// Record VIEW action
  Future<void> recordView({
    required int itemId,
    required String itemType, // 'tour', 'hotel', 'attraction', 'restaurant'
  }) async {
    if (_userId == null) return;

    try {
      await dio.post(
        '$_baseUrl/api/user-interactions/view',
        data: {'userId': _userId, 'itemId': itemId, 'itemType': itemType},
      );
    } catch (e) {
      // Silent fail - không làm gián đoạn UX
      debugPrint('❌ Failed to record view: $e');
    }
  }

  /// Record CLICK action
  Future<void> recordClick({
    required int itemId,
    required String itemType,
  }) async {
    if (_userId == null) return;

    try {
      await dio.post(
        '$_baseUrl/api/user-interactions/click',
        data: {'userId': _userId, 'itemId': itemId, 'itemType': itemType},
      );
    } catch (e) {
      debugPrint('❌ Failed to record click: $e');
    }
  }

  /// Record FAVORITE action
  Future<void> recordFavorite({
    required int itemId,
    required String itemType,
  }) async {
    if (_userId == null) return;

    try {
      await dio.post(
        '$_baseUrl/api/user-interactions/favorite',
        data: {'userId': _userId, 'itemId': itemId, 'itemType': itemType},
      );
    } catch (e) {
      debugPrint('❌ Failed to record favorite: $e');
    }
  }

  /// Record BOOK action
  Future<void> recordBook({
    required int itemId,
    required String itemType,
  }) async {
    if (_userId == null) return;

    try {
      await dio.post(
        '$_baseUrl/api/user-interactions/book',
        data: {'userId': _userId, 'itemId': itemId, 'itemType': itemType},
      );
    } catch (e) {
      debugPrint('❌ Failed to record book: $e');
    }
  }

  /// Record SEARCH action
  Future<void> recordSearch({required String itemType}) async {
    if (_userId == null) return;

    try {
      await dio.post(
        '$_baseUrl/api/user-interactions/search',
        data: {'userId': _userId, 'itemType': itemType},
      );
    } catch (e) {
      debugPrint('❌ Failed to record search: $e');
    }
  }
}
