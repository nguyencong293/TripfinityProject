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
    final res = await _dio.get(
      '/hotels/$hotelId/reviews',
      queryParameters: {
        if (status != null && status.isNotEmpty) 'status': status,
      },
    );
    if (res.statusCode == 200 && res.data is List) {
      return List<Map<String, dynamic>>.from(res.data);
    }
    final msg = (res.data is Map && (res.data as Map)['message'] != null)
        ? (res.data as Map)['message'].toString()
        : 'Get hotel reviews failed with status ${res.statusCode}';
    throw Exception(msg);
  }
}
