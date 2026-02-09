import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app/config/app_config.dart';

class AttractionBookingApiService {
  final Dio _dio;

  AttractionBookingApiService({
    required Dio dio,
    required SharedPreferences prefs,
  }) : _dio = dio {
    _dio.options = BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 120),
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

  Future<Map<String, dynamic>> createBooking({
    required int userId,
    required int attractionId,
    DateTime? startDate,
    DateTime? endDate,
    required int numAdults,
    required num totalPrice,
    required String currencyCode,
    String? channel,
    int? providerId,
    String? providerNotes,
    String? paymentMethod, // counter, zalopay, vnpay, etc.
  }) async {
    final body = {
      'user_id': userId,
      'attraction_id': attractionId,
      if (startDate != null) 'start_date': _formatDate(startDate),
      if (endDate != null) 'end_date': _formatDate(endDate),
      'num_adults': numAdults,
      'total_price': totalPrice,
      'currency_code': currencyCode,
      if (channel != null && channel.isNotEmpty) 'channel': channel,
      if (providerId != null) 'provider_id': providerId,
      if (providerNotes != null && providerNotes.isNotEmpty)
        'provider_notes': providerNotes,
      if (paymentMethod != null && paymentMethod.isNotEmpty)
        'payment_method': paymentMethod,
    };

    final res = await _dio.post('/attraction-bookings', data: body);
    if (res.statusCode == 201 && res.data is Map<String, dynamic>) {
      return res.data as Map<String, dynamic>;
    }
    final msg = (res.data is Map && (res.data as Map)['message'] != null)
        ? (res.data as Map)['message'].toString()
        : 'Create booking failed with status ${res.statusCode}';
    throw Exception(msg);
  }

  // Optional: list bookings for user
  Future<List<Map<String, dynamic>>> getBookingsByUser(int userId) async {
    final res = await _dio.get('/attraction-bookings/user/$userId');
    if (res.statusCode == 200 && res.data is List) {
      return List<Map<String, dynamic>>.from(res.data);
    }
    final msg = (res.data is Map && (res.data as Map)['message'] != null)
        ? (res.data as Map)['message'].toString()
        : 'Get bookings failed with status ${res.statusCode}';
    throw Exception(msg);
  }

  String _formatDate(DateTime d) {
    // yyyy-MM-dd
    return '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
}
