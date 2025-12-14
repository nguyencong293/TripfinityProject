import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';

class FavoriteApiService {
  final Dio _dio;
  final SharedPreferences _prefs;

  FavoriteApiService({required Dio dio, required SharedPreferences prefs})
    : _dio = dio
        ..options = BaseOptions(
          baseUrl: AppConfig.baseUrl,
          connectTimeout: AppConfig.apiTimeout,
          sendTimeout: AppConfig.apiTimeout,
          receiveTimeout: AppConfig.apiTimeout,
          contentType: Headers.jsonContentType,
          validateStatus: (status) => status != null && status < 500,
        ),
      _prefs = prefs {
    _addInterceptors();
  }

  void _addInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _prefs.getString('user_token');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  /// Add service to favorites
  /// POST /api/favorites
  Future<Map<String, dynamic>> addFavorite({
    required int userId,
    required String serviceType,
    required int serviceId,
  }) async {
    final body = {
      'userId': userId,
      'serviceType': serviceType,
      'serviceId': serviceId,
    };

    final res = await _dio.post('/favorites', data: body);

    if (res.statusCode == 201 && res.data is Map<String, dynamic>) {
      return res.data as Map<String, dynamic>;
    }

    final msg = (res.data is Map && (res.data as Map)['message'] != null)
        ? (res.data as Map)['message'].toString()
        : 'Add favorite failed with status ${res.statusCode}';
    throw Exception(msg);
  }

  /// Remove service from favorites
  /// DELETE /api/favorites/{userId}/{serviceType}/{serviceId}
  Future<void> removeFavorite({
    required int userId,
    required String serviceType,
    required int serviceId,
  }) async {
    final res = await _dio.delete('/favorites/$userId/$serviceType/$serviceId');

    if (res.statusCode == 200) {
      return;
    }

    final msg = (res.data is Map && (res.data as Map)['message'] != null)
        ? (res.data as Map)['message'].toString()
        : 'Remove favorite failed with status ${res.statusCode}';
    throw Exception(msg);
  }

  /// Get all favorites for a user
  /// GET /api/favorites/user/{userId}
  Future<List<Map<String, dynamic>>> getUserFavorites(int userId) async {
    final res = await _dio.get('/favorites/user/$userId');

    if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
      final data = res.data as Map<String, dynamic>;
      if (data['data'] is List) {
        return List<Map<String, dynamic>>.from(data['data']);
      }
    }

    return [];
  }

  /// Get favorites by service type
  /// GET /api/favorites/user/{userId}/type?type={serviceType}
  Future<List<Map<String, dynamic>>> getUserFavoritesByType({
    required int userId,
    required String serviceType,
  }) async {
    final res = await _dio.get(
      '/favorites/user/$userId/type',
      queryParameters: {'type': serviceType},
    );

    if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
      final data = res.data as Map<String, dynamic>;
      if (data['data'] is List) {
        return List<Map<String, dynamic>>.from(data['data']);
      }
    }

    return [];
  }

  /// Check if service is favorited
  /// GET /api/favorites/check?userId={userId}&serviceType={serviceType}&serviceId={serviceId}
  Future<bool> isFavorite({
    required int userId,
    required String serviceType,
    required int serviceId,
  }) async {
    debugPrint('🔍 API isFavorite: userId=$userId, type=$serviceType, id=$serviceId');
    
    final res = await _dio.get(
      '/favorites/check',
      queryParameters: {
        'userId': userId,
        'serviceType': serviceType,
        'serviceId': serviceId,
      },
    );

    debugPrint('📡 Response status: ${res.statusCode}, data: ${res.data}');

    if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
      final data = res.data as Map<String, dynamic>;
      final isFav = data['isFavorite'] == true;
      debugPrint('✅ isFavorite result: $isFav');
      return isFav;
    }

    debugPrint('⚠️ Unexpected response format, returning false');
    return false;
  }

  /// Get list of favorite service IDs for a specific type
  /// GET /api/favorites/user/{userId}/ids?type={serviceType}
  Future<List<int>> getFavoriteServiceIds({
    required int userId,
    required String serviceType,
  }) async {
    final res = await _dio.get(
      '/favorites/user/$userId/ids',
      queryParameters: {'type': serviceType},
    );

    if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
      final data = res.data as Map<String, dynamic>;
      if (data['data'] is List) {
        return List<int>.from(data['data']);
      }
    }

    return [];
  }

  /// Get favorite count for a service
  /// GET /api/favorites/count?serviceType={serviceType}&serviceId={serviceId}
  Future<int> getFavoriteCount({
    required String serviceType,
    required int serviceId,
  }) async {
    final res = await _dio.get(
      '/favorites/count',
      queryParameters: {'serviceType': serviceType, 'serviceId': serviceId},
    );

    if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
      final data = res.data as Map<String, dynamic>;
      return (data['count'] ?? 0) as int;
    }

    return 0;
  }
}
