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

  // NOTE: Attraction reviews chưa có trong backend, sẽ implement sau
  // Hiện tại return empty list để tránh error
  Future<List<Map<String, dynamic>>> getAttractionReviews(
    int attractionId, {
    String? status,
  }) async {
    return [];
  }
}
