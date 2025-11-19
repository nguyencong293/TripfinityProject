import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app/config/app_config.dart';

class HotelApiService {
  final Dio _dio;

  HotelApiService({required Dio dio, required SharedPreferences prefs})
    : _dio = dio {
    _dio.options = BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      headers: {'Content-Type': 'application/json'},
    );
    // Inject Authorization Bearer token if present
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

  Future<Map<String, dynamic>> getHotelById(int hotelId) async {
    final res = await _dio.get('/hotels/$hotelId');
    if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
      return res.data as Map<String, dynamic>;
    }
    final msg = (res.data is Map && (res.data as Map)['message'] != null)
        ? (res.data as Map)['message'].toString()
        : 'Get hotel failed with status ${res.statusCode}';
    throw Exception(msg);
  }

  Future<List<Map<String, dynamic>>> getHotelReviews(
    int hotelId, {
    String? status,
  }) async {
    // Backend endpoints:
    // - GET /api/hotel-reviews/hotel/{hotelId}
    // - GET /api/hotel-reviews/hotel/{hotelId}/status/{status}
    final String path = (status != null && status.isNotEmpty)
        ? '/hotel-reviews/hotel/$hotelId/status/$status'
        : '/hotel-reviews/hotel/$hotelId';

    final res = await _dio.get(path);
    if (res.statusCode == 200 && res.data is List) {
      return List<Map<String, dynamic>>.from(res.data);
    }
    final msg = (res.data is Map && (res.data as Map)['message'] != null)
        ? (res.data as Map)['message'].toString()
        : 'Get hotel reviews failed with status ${res.statusCode}';
    throw Exception(msg);
  }

  /// GET /api/hotels/{hotelId}/rating-summary
  /// Tính toán động từ hotel_reviews và hotel_review_aspects
  Future<Map<String, dynamic>> getRatingSummary(int hotelId) async {
    final res = await _dio.get('/hotels/$hotelId/rating-summary');
    if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
      return res.data as Map<String, dynamic>;
    }
    final msg = (res.data is Map && (res.data as Map)['message'] != null)
        ? (res.data as Map)['message'].toString()
        : 'Get rating summary failed with status ${res.statusCode}';
    throw Exception(msg);
  }

  /// POST /api/hotel-reviews
  /// Tạo hotel review mới với aspects
  Future<Map<String, dynamic>> createHotelReview({
    required int hotelId,
    required int userId,
    required int rating,
    String? title,
    String? content,
    List<String>? imageUrls,
    Map<String, int>? aspects,
  }) async {
    final body = {
      'hotelId': hotelId,
      'userId': userId,
      'rating': rating,
      'title': title,
      'content': content,
      'imageUrls': imageUrls,
      'reviewStatus': 'approved',
    };

    // Add aspects if provided
    if (aspects != null) {
      body['aspects'] = {
        'cleanliness': aspects['cleanliness'] ?? 0,
        'service': aspects['service'] ?? 0,
        'valueForMoney': aspects['valueForMoney'] ?? 0,
        'location': aspects['location'] ?? 0,
        'facilities': aspects['facilities'] ?? 0,
      };
    }

    final res = await _dio.post('/hotel-reviews', data: body);
    if (res.statusCode == 201 && res.data is Map<String, dynamic>) {
      return res.data as Map<String, dynamic>;
    }
    final msg = (res.data is Map && (res.data as Map)['message'] != null)
        ? (res.data as Map)['message'].toString()
        : 'Create hotel review failed with status ${res.statusCode}';
    throw Exception(msg);
  }

  /// POST /api/hotel-reviews/upload-image
  /// Upload hình ảnh review lên Cloudinary
  Future<String> uploadReviewImage(String filePath) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        filePath,
        filename: filePath.split('/').last,
      ),
    });

    final res = await _dio.post(
      '/hotel-reviews/upload-image',
      data: formData,
      options: Options(headers: {'Content-Type': 'multipart/form-data'}),
    );

    if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
      final imageUrl = res.data['imageUrl'] as String?;
      if (imageUrl != null && imageUrl.isNotEmpty) {
        return imageUrl;
      }
    }

    final msg = (res.data is Map && (res.data as Map)['message'] != null)
        ? (res.data as Map)['message'].toString()
        : 'Upload review image failed with status ${res.statusCode}';
    throw Exception(msg);
  }
}
