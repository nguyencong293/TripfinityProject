import 'package:dio/dio.dart';
import '../config/app_config.dart';

class PointsService {
  final Dio _dio;

  PointsService() : _dio = Dio(BaseOptions(baseUrl: AppConfig.baseUrl));

  /// Get user's total points
  Future<int> getTotalPoints(int userId) async {
    try {
      final response = await _dio.get('/points/user/$userId/total');
      return response.data as int;
    } catch (e) {
      throw Exception('Failed to get total points: $e');
    }
  }

  /// Get user's points history
  Future<List<Map<String, dynamic>>> getPointsHistory(int userId) async {
    try {
      final response = await _dio.get('/points/user/$userId/history');
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      throw Exception('Failed to get points history: $e');
    }
  }

  /// Get user's unlocked badges
  Future<List<Map<String, dynamic>>> getUnlockedBadges(int userId) async {
    try {
      final response = await _dio.get('/points/user/$userId/badges');
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      throw Exception('Failed to get unlocked badges: $e');
    }
  }

  /// Get all available badges
  Future<List<Map<String, dynamic>>> getAllBadges() async {
    try {
      final response = await _dio.get('/points/badges');
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      throw Exception('Failed to get all badges: $e');
    }
  }

  /// Get complete user points summary
  Future<Map<String, dynamic>> getUserPointsSummary(int userId) async {
    try {
      final response = await _dio.get('/points/user/$userId/summary');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to get points summary: $e');
    }
  }
}
