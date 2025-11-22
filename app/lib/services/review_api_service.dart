import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/config/app_config.dart';

class ReviewApiService {
  final Dio _dio;

  ReviewApiService({required Dio dio, required SharedPreferences prefs})
    : _dio = dio {
    _dio.options = BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
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

  // ==================== Review Likes ====================

  /// Toggle like on a review or reply
  /// Returns: {isLiked: bool, likeCount: int}
  Future<Map<String, dynamic>> toggleReviewLike({
    required int userId,
    required String reviewType,
    required int reviewId,
    int? replyId,
  }) async {
    final payload = {
      'userId': userId,
      'reviewType': reviewType,
      'reviewId': reviewId,
      if (replyId != null) 'replyId': replyId,
    };

    final res = await _dio.post('/review-likes/toggle', data: payload);
    if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
      return res.data as Map<String, dynamic>;
    }
    throw Exception('Toggle like failed with status ${res.statusCode}');
  }

  /// Get like count for a review or reply
  Future<int> getLikeCount({
    required String reviewType,
    required int reviewId,
    int? replyId,
  }) async {
    final params = {
      'reviewType': reviewType,
      'reviewId': reviewId,
      if (replyId != null) 'replyId': replyId,
    };

    final res = await _dio.get('/review-likes/count', queryParameters: params);
    if (res.statusCode == 200) {
      return res.data as int;
    }
    throw Exception('Get like count failed with status ${res.statusCode}');
  }

  /// Check if user has liked a review or reply
  Future<bool> checkIsLiked({
    required int userId,
    required String reviewType,
    required int reviewId,
    int? replyId,
  }) async {
    final params = {
      'userId': userId,
      'reviewType': reviewType,
      'reviewId': reviewId,
      if (replyId != null) 'replyId': replyId,
    };

    final res = await _dio.get('/review-likes/check', queryParameters: params);
    if (res.statusCode == 200) {
      return res.data as bool;
    }
    throw Exception('Check liked failed with status ${res.statusCode}');
  }

  // ==================== Review Replies ====================

  /// Get all replies for a review
  Future<List<Map<String, dynamic>>> getReviewReplies({
    required String reviewType,
    required int reviewId,
    int? currentUserId,
  }) async {
    final params = {
      'reviewType': reviewType,
      'reviewId': reviewId,
      if (currentUserId != null) 'currentUserId': currentUserId,
    };

    final res = await _dio.get('/review-replies', queryParameters: params);
    if (res.statusCode == 200 && res.data is List) {
      return (res.data as List).cast<Map<String, dynamic>>();
    }
    throw Exception('Get replies failed with status ${res.statusCode}');
  }

  /// Get reply count for a review
  Future<int> getReplyCount({
    required String reviewType,
    required int reviewId,
  }) async {
    final params = {'reviewType': reviewType, 'reviewId': reviewId};

    final res = await _dio.get(
      '/review-replies/count',
      queryParameters: params,
    );
    if (res.statusCode == 200) {
      return res.data as int;
    }
    throw Exception('Get reply count failed with status ${res.statusCode}');
  }
}
