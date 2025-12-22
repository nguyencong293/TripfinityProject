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
      '/restaurant-reviews/restaurant/$restaurantId',
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
    final res = await _dio.get('/restaurant-reviews/$reviewId/replies');

    if (res.statusCode == 200 && res.data is List) {
      return List<Map<String, dynamic>>.from(res.data);
    }

    final msg = (res.data is Map && (res.data as Map)['message'] != null)
        ? (res.data as Map)['message'].toString()
        : 'Get review replies failed with status ${res.statusCode}';
    throw Exception(msg);
  }

  // Upload review image to Cloudinary
  Future<String> uploadReviewImage(String imagePath) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(imagePath),
    });

    final res = await _dio.post(
      '/restaurant-reviews/upload-image',
      data: formData,
    );

    if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
      final url = res.data['imageUrl'] ?? res.data['url'];
      if (url != null && url is String) {
        return url;
      }
    }

    final msg = (res.data is Map && (res.data as Map)['message'] != null)
        ? (res.data as Map)['message'].toString()
        : 'Upload image failed with status ${res.statusCode}';
    throw Exception(msg);
  }

  // Get rating summary for a restaurant
  Future<Map<String, dynamic>> getRatingSummary(int restaurantId) async {
    final res = await _dio.get('/restaurants/$restaurantId/rating-summary');

    if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
      return res.data as Map<String, dynamic>;
    }

    final msg = (res.data is Map && (res.data as Map)['message'] != null)
        ? (res.data as Map)['message'].toString()
        : 'Get rating summary failed with status ${res.statusCode}';
    throw Exception(msg);
  }

  // Create restaurant review
  Future<Map<String, dynamic>> createRestaurantReview({
    required int restaurantId,
    required int userId,
    required int rating,
    String? title,
    String? content,
    List<String>? imageUrls,
    Map<String, int>? aspects,
  }) async {
    final res = await _dio.post(
      '/restaurant-reviews',
      data: {
        'restaurantId': restaurantId,
        'userId': userId,
        'rating': rating,
        if (title != null && title.isNotEmpty) 'title': title,
        if (content != null && content.isNotEmpty) 'content': content,
        if (imageUrls != null && imageUrls.isNotEmpty) 'imageUrls': imageUrls,
        if (aspects != null) 'aspects': aspects,
      },
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      if (res.data is Map<String, dynamic>) {
        return res.data as Map<String, dynamic>;
      }
    }

    final msg = (res.data is Map && (res.data as Map)['message'] != null)
        ? (res.data as Map)['message'].toString()
        : 'Create review failed with status ${res.statusCode}';
    throw Exception(msg);
  }
}
