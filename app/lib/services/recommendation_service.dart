import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';
import '../dto/recommendation/recommendation_response.dart';
import '../exceptions/api_exceptions.dart';

class RecommendationService {
  final Dio _dio;

  RecommendationService({required Dio dio}) : _dio = dio;

  /// Lấy gợi ý từ AI model cho user
  /// Throws ApiException nếu có lỗi
  Future<RecommendationResponse> getRecommendations(int userId) async {
    try {
      debugPrint(
        '📞 Flutter API Request - Getting recommendations for User ID: $userId',
      );

      final response = await _dio.get(
        '${AppConfig.baseUrl}/recommendations/$userId',
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.statusCode == 200) {
        final recommendationResponse = RecommendationResponse.fromJson(
          response.data,
        );

        if (recommendationResponse.success) {
          final itemCount = recommendationResponse.data?.length ?? 0;
          debugPrint('✅ Successfully fetched $itemCount recommendations');
        } else {
          debugPrint(
            '⚠️ No recommendations: ${recommendationResponse.message}',
          );
        }

        return recommendationResponse;
      } else {
        throw ApiException(
          'Failed to fetch recommendations',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      debugPrint('❌ Dio Error in RecommendationService: ${e.message}');

      if (e.response != null) {
        throw ApiException(
          e.response?.data['message'] ?? 'Failed to fetch recommendations',
          e.response?.statusCode,
        );
      } else {
        throw ApiException('Network error: ${e.message}');
      }
    } catch (e) {
      debugPrint('❌ Unexpected error in RecommendationService: $e');
      throw ApiException('Unexpected error: $e');
    }
  }
}
