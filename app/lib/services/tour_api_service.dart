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
    final res = await dio.get(
      '/tours/$tourId/reviews',
      queryParameters: status != null ? {'status': status} : null,
    );
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
    final res = await dio.get('/tours/reviews/$reviewId/replies');
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
}
