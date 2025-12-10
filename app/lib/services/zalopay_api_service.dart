import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app/config/app_config.dart';

class ZaloPayApiService {
  final Dio _dio;

  ZaloPayApiService({required Dio dio, required SharedPreferences prefs})
    : _dio = dio {
    _dio.options = BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: AppConfig.apiTimeout,
      receiveTimeout: AppConfig.apiTimeout,
      headers: {'Content-Type': 'application/json'},
    );
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

  /// Creates ZaloPay order and returns Map with 'order_url' and 'apptransid'
  Future<Map<String, String>> createOrder({
    required num amount,
    required int userId,
    required int hotelId,
    required DateTime startDate,
    required DateTime endDate,
    required int numAdults,
    required int numChildren,
    String? providerNotes,
    String? description,
  }) async {
    final res = await _dio.post(
      '/zalopay/create-order',
      queryParameters: {
        'amount': amount,
        'userId': userId,
        'hotelId': hotelId,
        'startDate': startDate.toIso8601String().split('T')[0], // YYYY-MM-DD
        'endDate': endDate.toIso8601String().split('T')[0],
        'numAdults': numAdults,
        'numChildren': numChildren,
        if (providerNotes != null && providerNotes.isNotEmpty)
          'providerNotes': providerNotes,
        if (description != null && description.isNotEmpty)
          'description': description,
      },
    );
    if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
      final map = res.data as Map<String, dynamic>;
      final url = map['order_url']?.toString();
      final transId = map['apptransid']
          ?.toString(); // Note: lowercase 'apptransid' from backend
      if (url != null && url.isNotEmpty && transId != null) {
        return {'order_url': url, 'apptransid': transId};
      }
    }
    final msg = (res.data is Map && (res.data as Map)['message'] != null)
        ? (res.data as Map)['message'].toString()
        : 'Create ZaloPay order failed (${res.statusCode})';
    throw Exception(msg);
  }

  /// Creates ZaloPay order for Restaurant booking
  Future<Map<String, String>> createRestaurantOrder({
    required num amount,
    required int userId,
    required int restaurantId,
    required DateTime reservationDate,
    required int numAdults,
    String? providerNotes,
    String? description,
  }) async {
    final res = await _dio.post(
      '/zalopay/create-restaurant-order',
      queryParameters: {
        'amount': amount,
        'userId': userId,
        'restaurantId': restaurantId,
        'reservationDate': reservationDate.toIso8601String().split(
          'T',
        )[0], // YYYY-MM-DD
        'numAdults': numAdults,
        if (providerNotes != null && providerNotes.isNotEmpty)
          'providerNotes': providerNotes,
        if (description != null && description.isNotEmpty)
          'description': description,
      },
    );
    if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
      final map = res.data as Map<String, dynamic>;
      final url = map['order_url']?.toString();
      final transId = map['apptransid']?.toString();
      if (url != null && url.isNotEmpty && transId != null) {
        return {'order_url': url, 'apptransid': transId};
      }
    }
    final msg = (res.data is Map && (res.data as Map)['message'] != null)
        ? (res.data as Map)['message'].toString()
        : 'Create ZaloPay restaurant order failed (${res.statusCode})';
    throw Exception(msg);
  }

  /// Creates ZaloPay order for Tour booking
  Future<Map<String, String>> createTourOrder({
    required num amount,
    required int userId,
    required int tourId,
    required DateTime startDate,
    required DateTime endDate,
    required int numAdults,
    String? providerNotes,
    String? description,
  }) async {
    final res = await _dio.post(
      '/zalopay/create-tour-order',
      queryParameters: {
        'amount': amount,
        'userId': userId,
        'tourId': tourId,
        'startDate': startDate.toIso8601String().split('T')[0], // YYYY-MM-DD
        'endDate': endDate.toIso8601String().split('T')[0],
        'numAdults': numAdults,
        if (providerNotes != null && providerNotes.isNotEmpty)
          'providerNotes': providerNotes,
        if (description != null && description.isNotEmpty)
          'description': description,
      },
    );
    if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
      final map = res.data as Map<String, dynamic>;
      final url = map['order_url']?.toString();
      final transId = map['apptransid']?.toString();
      if (url != null && url.isNotEmpty && transId != null) {
        return {'order_url': url, 'apptransid': transId};
      }
    }
    final msg = (res.data is Map && (res.data as Map)['message'] != null)
        ? (res.data as Map)['message'].toString()
        : 'Create ZaloPay tour order failed (${res.statusCode})';
    throw Exception(msg);
  }

  /// Creates ZaloPay order for Attraction booking
  Future<Map<String, String>> createAttractionOrder({
    required num amount,
    required int userId,
    required int attractionId,
    required DateTime startDate,
    required int numAdults,
    String? providerNotes,
    String? description,
  }) async {
    final res = await _dio.post(
      '/zalopay/create-attraction-order',
      queryParameters: {
        'amount': amount,
        'userId': userId,
        'attractionId': attractionId,
        'startDate': startDate.toIso8601String().split('T')[0], // YYYY-MM-DD
        'numAdults': numAdults,
        if (providerNotes != null && providerNotes.isNotEmpty)
          'providerNotes': providerNotes,
        if (description != null && description.isNotEmpty)
          'description': description,
      },
    );
    if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
      final map = res.data as Map<String, dynamic>;
      final url = map['order_url']?.toString();
      final transId = map['apptransid']?.toString();
      if (url != null && url.isNotEmpty && transId != null) {
        return {'order_url': url, 'apptransid': transId};
      }
    }
    final msg = (res.data is Map && (res.data as Map)['message'] != null)
        ? (res.data as Map)['message'].toString()
        : 'Create ZaloPay attraction order failed (${res.statusCode})';
    throw Exception(msg);
  }
}
