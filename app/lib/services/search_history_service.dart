import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';

class SearchHistoryService {
  final Dio dio;
  final SharedPreferences prefs;
  late final String baseUrl;

  SearchHistoryService({required this.dio, required this.prefs}) {
    // Use same config as other services
    baseUrl = AppConfig.baseUrl;
  }

  /// Get JWT token from SharedPreferences
  String? _getToken() {
    return prefs.getString('user_token');
  }

  /// Get authorization headers
  Map<String, String> _getHeaders() {
    final token = _getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  /// Save a search query (when user searches)
  Future<Map<String, dynamic>> saveSearchQuery({
    required String searchQuery,
    String searchType = 'general',
  }) async {
    try {
      final response = await dio.post(
        '$baseUrl/search-history/search',
        data: {'searchQuery': searchQuery, 'searchType': searchType},
        options: Options(headers: _getHeaders()),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Authentication required');
      }
      throw Exception('Failed to save search query: ${e.message}');
    }
  }

  /// Save a clicked item (when user views detail)
  Future<Map<String, dynamic>> saveClickedItem({
    required String searchQuery,
    String searchType = 'general',
    required String itemType,
    int? itemId,
    String? itemTitle,
    String? itemLocation,
    String? itemThumbnailUrl,
  }) async {
    try {
      final response = await dio.post(
        '$baseUrl/search-history/click',
        data: {
          'searchQuery': searchQuery,
          'searchType': searchType,
          'itemType': itemType,
          if (itemId != null) 'itemId': itemId,
          if (itemTitle != null) 'itemTitle': itemTitle,
          if (itemLocation != null) 'itemLocation': itemLocation,
          if (itemThumbnailUrl != null) 'itemThumbnailUrl': itemThumbnailUrl,
        },
        options: Options(headers: _getHeaders()),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Authentication required');
      }
      throw Exception('Failed to save clicked item: ${e.message}');
    }
  }

  /// Get recent search history
  Future<List<Map<String, dynamic>>> getRecentSearchHistory({
    int limit = 50,
  }) async {
    try {
      final response = await dio.get(
        '$baseUrl/search-history/recent',
        queryParameters: {'limit': limit},
        options: Options(headers: _getHeaders()),
      );
      return List<Map<String, dynamic>>.from(response.data as List);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Authentication required');
      }
      throw Exception('Failed to get search history: ${e.message}');
    }
  }

  /// Get recently viewed items
  Future<List<Map<String, dynamic>>> getRecentViewedItems({
    int limit = 10,
  }) async {
    try {
      final response = await dio.get(
        '$baseUrl/search-history/viewed',
        queryParameters: {'limit': limit},
        options: Options(headers: _getHeaders()),
      );
      return List<Map<String, dynamic>>.from(response.data as List);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        // User not logged in - return empty list
        return [];
      }
      throw Exception('Failed to get viewed items: ${e.message}');
    }
  }

  /// Get search query suggestions
  Future<List<String>> getSearchSuggestions({int limit = 5}) async {
    try {
      final response = await dio.get(
        '$baseUrl/search-history/suggestions',
        queryParameters: {'limit': limit},
        options: Options(headers: _getHeaders()),
      );
      return List<String>.from(response.data as List);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        // User not logged in - return empty list
        return [];
      }
      throw Exception('Failed to get search suggestions: ${e.message}');
    }
  }

  /// Clear all search history
  Future<void> clearSearchHistory() async {
    try {
      await dio.delete(
        '$baseUrl/search-history/clear',
        options: Options(headers: _getHeaders()),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Authentication required');
      }
      throw Exception('Failed to clear search history: ${e.message}');
    }
  }
}
