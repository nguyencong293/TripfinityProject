import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/config/app_config.dart';

/// Service để giao tiếp với API blogs
/// Chỉ hỗ trợ xem blog (user chỉ đọc, không tương tác)
class BlogApiService {
  final Dio _dio;

  BlogApiService({required Dio dio, required SharedPreferences prefs})
    : _dio = dio {
    _dio.options = BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      headers: {'Content-Type': 'application/json'},
    );
  }

  // ==================== PUBLIC APIs ====================

  /// Lấy tất cả blogs đã publish
  Future<List<Map<String, dynamic>>> getAllPublishedBlogs() async {
    final res = await _dio.get('/blogs/public');
    if (res.statusCode == 200 && res.data is List) {
      return List<Map<String, dynamic>>.from(res.data);
    }
    throw Exception('Không thể tải danh sách bài viết');
  }

  /// Lấy blog mới nhất (cho home page)
  Future<Map<String, dynamic>?> getLatestBlog() async {
    final res = await _dio.get('/blogs/public/latest');
    if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
      return res.data as Map<String, dynamic>;
    }
    if (res.statusCode == 204) {
      return null; // No content
    }
    throw Exception('Không thể tải bài viết mới nhất');
  }

  /// Lấy N blog mới nhất
  Future<List<Map<String, dynamic>>> getLatestBlogs({int limit = 5}) async {
    final res = await _dio.get('/blogs/public/latest/list?limit=$limit');
    if (res.statusCode == 200 && res.data is List) {
      return List<Map<String, dynamic>>.from(res.data);
    }
    throw Exception('Không thể tải danh sách bài viết');
  }

  /// Lấy blog theo slug
  Future<Map<String, dynamic>> getBlogBySlug(String slug) async {
    final res = await _dio.get('/blogs/public/slug/$slug');
    if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
      return res.data as Map<String, dynamic>;
    }
    throw Exception('Không tìm thấy bài viết');
  }

  /// Lấy blog theo ID
  Future<Map<String, dynamic>> getBlogById(int blogId) async {
    final res = await _dio.get('/blogs/public/$blogId');
    if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
      return res.data as Map<String, dynamic>;
    }
    throw Exception('Không tìm thấy bài viết');
  }

  /// Tìm kiếm blogs
  Future<List<Map<String, dynamic>>> searchBlogs(String keyword) async {
    final res = await _dio.get(
      '/blogs/public/search',
      queryParameters: {'keyword': keyword},
    );
    if (res.statusCode == 200 && res.data is List) {
      return List<Map<String, dynamic>>.from(res.data);
    }
    throw Exception('Không thể tìm kiếm bài viết');
  }

  /// Lấy blogs theo tag
  Future<List<Map<String, dynamic>>> getBlogsByTag(String tag) async {
    final res = await _dio.get('/blogs/public/tag/$tag');
    if (res.statusCode == 200 && res.data is List) {
      return List<Map<String, dynamic>>.from(res.data);
    }
    throw Exception('Không thể tải bài viết theo tag');
  }
}
