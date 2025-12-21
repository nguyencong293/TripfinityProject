import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/config/app_config.dart';

/// Service để giao tiếp với API chat backend
/// Hỗ trợ chat giữa user và provider (nhân viên supplier)
class ChatApiService {
  final Dio _dio;

  ChatApiService({required Dio dio, required SharedPreferences prefs})
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

  // ==================== IMAGE UPLOAD ====================

  /// Upload hình ảnh chat lên Cloudinary qua backend
  Future<String> uploadChatImage(String filePath) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        filePath,
        filename: filePath.split('/').last,
      ),
    });

    final res = await _dio.post(
      '/chat/upload-image',
      data: formData,
      options: Options(headers: {'Content-Type': 'multipart/form-data'}),
    );

    if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
      final imageUrl = res.data['imageUrl'] as String?;
      if (imageUrl != null && imageUrl.isNotEmpty) {
        return imageUrl;
      }
    }

    final msg = (res.data is Map && (res.data as Map)['message'] != null)
        ? (res.data as Map)['message'].toString()
        : 'Upload chat image failed with status ${res.statusCode}';
    throw Exception(msg);
  }

  // ==================== CONVERSATION METHODS ====================

  /// Tạo hoặc lấy conversation giữa user và provider
  Future<Map<String, dynamic>> getOrCreateConversation({
    required int userId,
    required int providerId,
    String? subject,
  }) async {
    final body = {
      'user_id': userId,
      'provider_id': providerId,
      if (subject != null && subject.isNotEmpty) 'subject': subject,
    };

    final res = await _dio.post('/chat/conversations', data: body);
    if ((res.statusCode == 200 || res.statusCode == 201) &&
        res.data is Map<String, dynamic>) {
      return res.data as Map<String, dynamic>;
    }
    final msg = (res.data is Map && (res.data as Map)['message'] != null)
        ? (res.data as Map)['message'].toString()
        : 'Không thể tạo cuộc hội thoại với status ${res.statusCode}';
    throw Exception(msg);
  }

  /// Lấy danh sách conversations của user
  Future<List<Map<String, dynamic>>> getConversationsByUser(int userId) async {
    final res = await _dio.get('/chat/conversations/user/$userId');
    if (res.statusCode == 200 && res.data is List) {
      return List<Map<String, dynamic>>.from(res.data);
    }
    throw Exception('Không thể lấy danh sách cuộc hội thoại');
  }

  /// Lấy chi tiết conversation
  Future<Map<String, dynamic>> getConversationById(int conversationId) async {
    final res = await _dio.get('/chat/conversations/$conversationId');
    if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
      return res.data as Map<String, dynamic>;
    }
    throw Exception('Không tìm thấy cuộc hội thoại');
  }

  /// Tìm kiếm conversations
  Future<List<Map<String, dynamic>>> searchConversations({
    required int id,
    required String type, // "user" hoặc "provider"
    required String keyword,
  }) async {
    final res = await _dio.get(
      '/chat/conversations/search',
      queryParameters: {'id': id, 'type': type, 'keyword': keyword},
    );
    if (res.statusCode == 200 && res.data is List) {
      return List<Map<String, dynamic>>.from(res.data);
    }
    throw Exception('Không thể tìm kiếm cuộc hội thoại');
  }

  // ==================== MESSAGE METHODS ====================

  /// Lấy danh sách tin nhắn của conversation
  Future<List<Map<String, dynamic>>> getMessages(int conversationId) async {
    final res = await _dio.get('/chat/conversations/$conversationId/messages');
    if (res.statusCode == 200 && res.data is List) {
      return List<Map<String, dynamic>>.from(res.data);
    }
    throw Exception('Không thể lấy tin nhắn');
  }

  /// Gửi tin nhắn mới
  Future<Map<String, dynamic>> sendMessage({
    required int conversationId,
    required String senderType, // "user" hoặc "provider"
    required int senderId,
    required String content,
    String messageType = 'text', // "text", "image", "file"
    String? imageUrl,
  }) async {
    final body = {
      'sender_type': senderType,
      'sender_id': senderId,
      'content': content,
      'message_type': messageType,
      if (imageUrl != null && imageUrl.isNotEmpty) 'image_url': imageUrl,
    };

    final res = await _dio.post(
      '/chat/conversations/$conversationId/messages',
      data: body,
    );
    if ((res.statusCode == 200 || res.statusCode == 201) &&
        res.data is Map<String, dynamic>) {
      return res.data as Map<String, dynamic>;
    }
    final msg = (res.data is Map && (res.data as Map)['message'] != null)
        ? (res.data as Map)['message'].toString()
        : 'Không thể gửi tin nhắn';
    throw Exception(msg);
  }

  /// Lấy tin nhắn mới (polling)
  Future<List<Map<String, dynamic>>> getNewMessages({
    required int conversationId,
    required DateTime afterTime,
  }) async {
    final res = await _dio.get(
      '/chat/conversations/$conversationId/messages/new',
      queryParameters: {'after': afterTime.toIso8601String()},
    );
    if (res.statusCode == 200 && res.data is List) {
      return List<Map<String, dynamic>>.from(res.data);
    }
    throw Exception('Không thể lấy tin nhắn mới');
  }

  /// Đánh dấu đã đọc tin nhắn
  Future<void> markAsRead({
    required int conversationId,
    required String readerType, // "user" hoặc "provider"
  }) async {
    final res = await _dio.put(
      '/chat/conversations/$conversationId/read',
      queryParameters: {'readerType': readerType},
    );
    if (res.statusCode != 200) {
      throw Exception('Không thể đánh dấu đã đọc');
    }
  }

  // ==================== UNREAD COUNT METHODS ====================

  /// Đếm số conversations chưa đọc
  Future<int> getUnreadConversationsCount({
    required int id,
    required String type, // "user" hoặc "provider"
  }) async {
    final res = await _dio.get(
      '/chat/unread/count',
      queryParameters: {'id': id, 'type': type},
    );
    if (res.statusCode == 200 && res.data is Map) {
      return (res.data['unreadConversations'] as num?)?.toInt() ?? 0;
    }
    throw Exception('Không thể đếm conversations chưa đọc');
  }

  /// Tổng số tin nhắn chưa đọc
  Future<int> getUnreadMessagesCount({
    required int id,
    required String type, // "user" hoặc "provider"
  }) async {
    final res = await _dio.get(
      '/chat/unread/messages',
      queryParameters: {'id': id, 'type': type},
    );
    if (res.statusCode == 200 && res.data is Map) {
      return (res.data['unreadMessages'] as num?)?.toInt() ?? 0;
    }
    throw Exception('Không thể đếm tin nhắn chưa đọc');
  }

  // ==================== PROVIDER METHODS ====================

  /// Lấy danh sách tất cả providers (để user chọn chat)
  Future<List<Map<String, dynamic>>> getAllProviders() async {
    final res = await _dio.get('/providers');
    if (res.statusCode == 200 && res.data is List) {
      return List<Map<String, dynamic>>.from(res.data);
    }
    throw Exception('Không thể lấy danh sách nhà cung cấp');
  }

  /// Lấy thông tin provider theo ID
  Future<Map<String, dynamic>> getProviderById(int providerId) async {
    final res = await _dio.get('/providers/$providerId');
    if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
      return res.data as Map<String, dynamic>;
    }
    throw Exception('Không tìm thấy nhà cung cấp');
  }
}
