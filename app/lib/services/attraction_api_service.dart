import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';

class AttractionApiService {
  final Dio _dio;
  final SharedPreferences _prefs;

  AttractionApiService({required Dio dio, required SharedPreferences prefs})
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

  // Fetch attraction detail by ID
  Future<Map<String, dynamic>> getAttractionById(int attractionId) async {
    final res = await _dio.get('/attractions/$attractionId');

    if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
      return res.data as Map<String, dynamic>;
    }

    final msg = (res.data is Map && (res.data as Map)['message'] != null)
        ? (res.data as Map)['message'].toString()
        : 'Get attraction failed with status ${res.statusCode}';
    throw Exception(msg);
  }

  // Fetch attraction reviews
  Future<List<Map<String, dynamic>>> getAttractionReviews(
    int attractionId, {
    String? status,
  }) async {
    final String path = (status != null && status.isNotEmpty)
        ? '/attraction-reviews/attraction/$attractionId/status/$status'
        : '/attraction-reviews/attraction/$attractionId';

    final res = await _dio.get(path);
    if (res.statusCode == 200 && res.data is List) {
      return List<Map<String, dynamic>>.from(res.data);
    }
    final msg = (res.data is Map && (res.data as Map)['message'] != null)
        ? (res.data as Map)['message'].toString()
        : 'Get attraction reviews failed with status ${res.statusCode}';
    throw Exception(msg);
  }

  // Get rating summary for an attraction
  Future<Map<String, dynamic>> getRatingSummary(int attractionId) async {
    final res = await _dio.get('/attractions/$attractionId/rating-summary');

    if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
      return res.data as Map<String, dynamic>;
    }

    final msg = (res.data is Map && (res.data as Map)['message'] != null)
        ? (res.data as Map)['message'].toString()
        : 'Get rating summary failed with status ${res.statusCode}';
    throw Exception(msg);
  }

  // Create attraction review
  Future<Map<String, dynamic>> createAttractionReview({
    required int attractionId,
    required int userId,
    required int rating,
    String? title,
    String? content,
    List<String>? imageUrls,
    Map<String, int>? aspects,
  }) async {
    final body = {
      'attractionId': attractionId,
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
        'beauty': aspects['beauty'] ?? 0,
        'culture': aspects['culture'] ?? 0,
        'accessibility': aspects['accessibility'] ?? 0,
        'price': aspects['price'] ?? 0,
        'facilities': aspects['facilities'] ?? 0,
      };
    }

    final res = await _dio.post('/attraction-reviews', data: body);
    if (res.statusCode == 201 && res.data is Map<String, dynamic>) {
      return res.data as Map<String, dynamic>;
    }
    final msg = (res.data is Map && (res.data as Map)['message'] != null)
        ? (res.data as Map)['message'].toString()
        : 'Create attraction review failed with status ${res.statusCode}';
    throw Exception(msg);
  }

  // Upload review image to Cloudinary
  Future<String> uploadReviewImage(String filePath) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        filePath,
        filename: filePath.split('/').last,
      ),
    });

    final res = await _dio.post(
      '/attraction-reviews/upload-image',
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
