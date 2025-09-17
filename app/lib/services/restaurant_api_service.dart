import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';

class RestaurantApiService {
  final Dio _dio;
  final SharedPreferences _prefs;

  RestaurantApiService({required Dio dio, required SharedPreferences prefs})
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

  // Fetch restaurant detail by ID
  Future<Map<String, dynamic>> getRestaurantById(int restaurantId) async {
    final res = await _dio.get('/restaurants/$restaurantId');

    if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
      return res.data as Map<String, dynamic>;
    }

    final msg = (res.data is Map && (res.data as Map)['message'] != null)
        ? (res.data as Map)['message'].toString()
        : 'Get restaurant failed with status ${res.statusCode}';
    throw Exception(msg);
  }

  // Fetch restaurant reviews
  Future<List<Map<String, dynamic>>> getRestaurantReviews(
    int restaurantId, {
    String? status,
  }) async {
    final res = await _dio.get(
      '/api/restaurants/$restaurantId/reviews',
      queryParameters: {
        if (status != null && status.isNotEmpty) 'status': status,
      },
    );

    if (res.statusCode == 200 && res.data is List) {
      return List<Map<String, dynamic>>.from(res.data);
    }

    final msg = (res.data is Map && (res.data as Map)['message'] != null)
        ? (res.data as Map)['message'].toString()
        : 'Get restaurant reviews failed with status ${res.statusCode}';
    throw Exception(msg);
  }

  // Fetch review replies
  Future<List<Map<String, dynamic>>> getReviewReplies(int reviewId) async {
    final res = await _dio.get('/api/restaurants/reviews/$reviewId/replies');

    if (res.statusCode == 200 && res.data is List) {
      return List<Map<String, dynamic>>.from(res.data);
    }

    final msg = (res.data is Map && (res.data as Map)['message'] != null)
        ? (res.data as Map)['message'].toString()
        : 'Get review replies failed with status ${res.statusCode}';
    throw Exception(msg);
  }
}
