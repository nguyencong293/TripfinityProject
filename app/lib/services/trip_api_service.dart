import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';

class TripApiService {
  final Dio _dio;
  final SharedPreferences _prefs;

  TripApiService({required Dio dio, required SharedPreferences prefs})
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

  /// Create a new trip
  /// POST /api/trips
  Future<Map<String, dynamic>> createTrip({
    required int userId,
    required String tripName,
    required String startDate, // Format: YYYY-MM-DD
    required String endDate, // Format: YYYY-MM-DD
    String? coverImage,
  }) async {
    final res = await _dio.post(
      '/trips',
      data: {
        'userId': userId,
        'tripName': tripName,
        'startDate': startDate,
        'endDate': endDate,
        if (coverImage != null) 'coverImage': coverImage,
      },
    );

    if (res.statusCode == 201 && res.data is Map<String, dynamic>) {
      final responseData = res.data as Map<String, dynamic>;
      if (responseData['success'] == true && responseData['data'] != null) {
        return responseData['data'] as Map<String, dynamic>;
      }
    }

    final msg = (res.data is Map && (res.data as Map)['message'] != null)
        ? (res.data as Map)['message'].toString()
        : 'Create trip failed with status ${res.statusCode}';
    throw Exception(msg);
  }

  /// Get all active trips for a user (auto-updates expired trips)
  /// GET /api/trips/user/{userId}
  Future<List<Map<String, dynamic>>> getUserTrips(int userId) async {
    final res = await _dio.get('/trips/user/$userId');

    if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
      final responseData = res.data as Map<String, dynamic>;
      if (responseData['success'] == true && responseData['data'] is List) {
        return List<Map<String, dynamic>>.from(responseData['data']);
      }
    }

    return [];
  }

  /// Get completed trips for a user
  /// GET /api/trips/user/{userId}/completed
  Future<List<Map<String, dynamic>>> getUserCompletedTrips(int userId) async {
    final res = await _dio.get('/trips/user/$userId/completed');

    if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
      final responseData = res.data as Map<String, dynamic>;
      if (responseData['success'] == true && responseData['data'] is List) {
        return List<Map<String, dynamic>>.from(responseData['data']);
      }
    }

    return [];
  }

  /// Get trip detail with itineraries
  /// GET /api/trips/{tripId}
  Future<Map<String, dynamic>> getTripDetail(int tripId) async {
    final res = await _dio.get('/trips/$tripId');

    if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
      final responseData = res.data as Map<String, dynamic>;
      if (responseData['success'] == true && responseData['data'] != null) {
        return responseData['data'] as Map<String, dynamic>;
      }
    }

    final msg = (res.data is Map && (res.data as Map)['message'] != null)
        ? (res.data as Map)['message'].toString()
        : 'Get trip detail failed with status ${res.statusCode}';
    throw Exception(msg);
  }

  /// Update trip dates
  /// PUT /api/trips/{tripId}/dates
  Future<Map<String, dynamic>> updateTripDates({
    required int tripId,
    required String startDate, // Format: YYYY-MM-DD
    required String endDate, // Format: YYYY-MM-DD
  }) async {
    final res = await _dio.put(
      '/trips/$tripId/dates',
      queryParameters: {'startDate': startDate, 'endDate': endDate},
    );

    if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
      final responseData = res.data as Map<String, dynamic>;
      if (responseData['success'] == true && responseData['data'] != null) {
        return responseData['data'] as Map<String, dynamic>;
      }
    }

    final msg = (res.data is Map && (res.data as Map)['message'] != null)
        ? (res.data as Map)['message'].toString()
        : 'Update trip dates failed with status ${res.statusCode}';
    throw Exception(msg);
  }

  /// Delete/Cancel a trip
  /// DELETE /api/trips/{tripId}
  Future<void> deleteTrip(int tripId) async {
    final res = await _dio.delete('/trips/$tripId');

    if (res.statusCode == 200) {
      return;
    }

    final msg = (res.data is Map && (res.data as Map)['message'] != null)
        ? (res.data as Map)['message'].toString()
        : 'Delete trip failed with status ${res.statusCode}';
    throw Exception(msg);
  }

  /// Create or get itinerary for a specific date
  /// POST /api/trips/{tripId}/itineraries
  Future<Map<String, dynamic>> createOrGetItinerary({
    required int tripId,
    required String date, // Format: YYYY-MM-DD
  }) async {
    final res = await _dio.post(
      '/trips/$tripId/itineraries',
      queryParameters: {'date': date},
    );

    if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
      final responseData = res.data as Map<String, dynamic>;
      if (responseData['success'] == true && responseData['data'] != null) {
        return responseData['data'] as Map<String, dynamic>;
      }
    }

    final msg = (res.data is Map && (res.data as Map)['message'] != null)
        ? (res.data as Map)['message'].toString()
        : 'Create/Get itinerary failed with status ${res.statusCode}';
    throw Exception(msg);
  }

  /// Add item to itinerary
  /// POST /api/trips/itineraries/items
  Future<Map<String, dynamic>> addItineraryItem({
    required int itineraryId,
    required String serviceType, // hotel, restaurant, attraction, tour
    required int serviceId,
    String? startTime, // Format: HH:mm:ss
    String? endTime, // Format: HH:mm:ss
  }) async {
    final res = await _dio.post(
      '/trips/itineraries/items',
      data: {
        'itineraryId': itineraryId,
        'serviceType': serviceType,
        'serviceId': serviceId,
        if (startTime != null) 'startTime': startTime,
        if (endTime != null) 'endTime': endTime,
      },
    );

    if (res.statusCode == 201 && res.data is Map<String, dynamic>) {
      final responseData = res.data as Map<String, dynamic>;
      if (responseData['success'] == true && responseData['data'] != null) {
        return responseData['data'] as Map<String, dynamic>;
      }
    }

    final msg = (res.data is Map && (res.data as Map)['message'] != null)
        ? (res.data as Map)['message'].toString()
        : 'Add itinerary item failed with status ${res.statusCode}';
    throw Exception(msg);
  }

  /// Remove item from itinerary
  /// DELETE /api/trips/itineraries/items/{itemId}
  Future<void> removeItineraryItem(int itemId) async {
    final res = await _dio.delete('/trips/itineraries/items/$itemId');

    if (res.statusCode == 200) {
      return;
    }

    final msg = (res.data is Map && (res.data as Map)['message'] != null)
        ? (res.data as Map)['message'].toString()
        : 'Remove itinerary item failed with status ${res.statusCode}';
    throw Exception(msg);
  }

  /// Helper: Add item to itinerary using tripId and date
  /// Auto-creates itinerary for the date if it doesn't exist
  Future<Map<String, dynamic>> addItemToItinerary({
    required int tripId,
    required DateTime date,
    required int serviceId,
    required String serviceType,
    String? startTime,
    String? endTime,
  }) async {
    final dateStr = date.toIso8601String().split('T')[0];

    final res = await _dio.post(
      '/trips/$tripId/dates/$dateStr/items',
      data: {
        'serviceType': serviceType,
        'serviceId': serviceId,
        if (startTime != null) 'startTime': startTime,
        if (endTime != null) 'endTime': endTime,
      },
    );

    if (res.statusCode == 201 && res.data is Map<String, dynamic>) {
      final responseData = res.data as Map<String, dynamic>;
      if (responseData['success'] == true && responseData['data'] != null) {
        return responseData['data'] as Map<String, dynamic>;
      }
    }

    final msg = (res.data is Map && (res.data as Map)['message'] != null)
        ? (res.data as Map)['message'].toString()
        : 'Add item to itinerary failed with status ${res.statusCode}';
    throw Exception(msg);
  }

  /// Get itinerary items for a specific date
  Future<List<Map<String, dynamic>>> getItineraryItemsByDate({
    required int tripId,
    required DateTime date,
  }) async {
    final trip = await getTripDetail(tripId);
    final itineraries = trip['itineraries'] as List?;

    if (itineraries == null) return [];

    // Find itinerary matching the date
    final dateStr = date.toIso8601String().split('T')[0];

    for (var itinerary in itineraries) {
      final itinDate = itinerary['itineraryDate'] as String?;
      if (itinDate != null && itinDate.startsWith(dateStr)) {
        final items = itinerary['items'] as List?;
        if (items != null) {
          return List<Map<String, dynamic>>.from(items);
        }
        return [];
      }
    }

    return [];
  }

  /// Update itinerary notes
  /// PATCH /api/trips/itineraries/{itineraryId}
  Future<Map<String, dynamic>> updateItineraryNotes({
    required int itineraryId,
    String? notes,
  }) async {
    debugPrint(
      '🔄 Updating itinerary notes: itineraryId=$itineraryId, notes=$notes',
    );

    final res = await _dio.patch(
      '/trips/itineraries/$itineraryId',
      data: {'notes': notes},
    );

    debugPrint('📡 Response status: ${res.statusCode}');
    debugPrint('📡 Response data: ${res.data}');

    if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
      final responseData = res.data as Map<String, dynamic>;
      if (responseData['success'] == true && responseData['data'] != null) {
        debugPrint('✅ Notes updated successfully');
        return responseData['data'] as Map<String, dynamic>;
      }
    }

    final msg = (res.data is Map && (res.data as Map)['message'] != null)
        ? (res.data as Map)['message'].toString()
        : 'Không thể cập nhật ghi chú';
    debugPrint('❌ Failed to update notes: $msg');
    throw Exception(msg);
  }
}
