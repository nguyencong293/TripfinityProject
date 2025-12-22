import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/config/app_config.dart';

class TourApiService {
  final Dio dio;
  final SharedPreferences prefs;

  TourApiService({required this.dio, required this.prefs}) {
    dio.options.baseUrl = AppConfig.baseUrl;
    dio.interceptors.clear();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = prefs.getString('user_token');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }

  Future<Map<String, dynamic>> getTourById(int tourId) async {
    final res = await dio.get('/tours/$tourId');
    if (res.statusCode == 200 && res.data is Map) {
      return Map<String, dynamic>.from(res.data as Map);
    }
    throw DioException(
      requestOptions: res.requestOptions,
      response: res,
      error: 'Failed to load tour $tourId',
    );
  }

  Future<List<Map<String, dynamic>>> getTourReviews(
    int tourId, {
    String? status,
  }) async {
    final String path = (status != null && status.isNotEmpty)
        ? '/tour-reviews/tour/$tourId/status/$status'
        : '/tour-reviews/tour/$tourId';

    final res = await dio.get(path);
    if (res.statusCode == 200 && res.data is List) {
      return List<Map<String, dynamic>>.from(
        (res.data as List).map((e) => Map<String, dynamic>.from(e as Map)),
      );
    }
    throw DioException(
      requestOptions: res.requestOptions,
      response: res,
      error: 'Failed to load reviews for tour $tourId',
    );
  }

  Future<List<Map<String, dynamic>>> getReviewReplies(int reviewId) async {
    final res = await dio.get('/tour-reviews/$reviewId/replies');
    if (res.statusCode == 200 && res.data is List) {
      return List<Map<String, dynamic>>.from(
        (res.data as List).map((e) => Map<String, dynamic>.from(e as Map)),
      );
    }
    throw DioException(
      requestOptions: res.requestOptions,
      response: res,
      error: 'Failed to load replies for review $reviewId',
    );
  }

  // Get rating summary for a tour
  Future<Map<String, dynamic>> getRatingSummary(int tourId) async {
    final res = await dio.get('/tours/$tourId/rating-summary');

    if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
      return res.data as Map<String, dynamic>;
    }

    final msg = (res.data is Map && (res.data as Map)['message'] != null)
        ? (res.data as Map)['message'].toString()
        : 'Get rating summary failed with status ${res.statusCode}';
    throw Exception(msg);
  }

  // Create tour review
  Future<Map<String, dynamic>> createTourReview({
    required int tourId,
    required int userId,
    required int rating,
    String? title,
    String? content,
    List<String>? imageUrls,
    Map<String, int>? aspects,
  }) async {
    final body = {
      'tourId': tourId,
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
        'guideQuality': aspects['guideQuality'] ?? 0,
        'itineraryQuality': aspects['itineraryQuality'] ?? 0,
        'valueForMoney': aspects['valueForMoney'] ?? 0,
        'organization': aspects['organization'] ?? 0,
        'safety': aspects['safety'] ?? 0,
      };
    }

    final res = await dio.post('/tour-reviews', data: body);
    if (res.statusCode == 201 && res.data is Map<String, dynamic>) {
      return res.data as Map<String, dynamic>;
    }
    final msg = (res.data is Map && (res.data as Map)['message'] != null)
        ? (res.data as Map)['message'].toString()
        : 'Create tour review failed with status ${res.statusCode}';
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

    final res = await dio.post(
      '/tour-reviews/upload-image',
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
