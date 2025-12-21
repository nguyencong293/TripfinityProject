import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/services/chat_api_service.dart';

/// Model cho Conversation
class Conversation {
  final int conversationId;
  final int userId;
  final int providerId;
  final String? subject;
  final String status;
  final DateTime? lastMessageAt;
  final String? lastMessageContent;
  final int userUnreadCount;
  final int providerUnreadCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  // Info bổ sung
  final String? userName;
  final String? userAvatar;
  final String? providerName;
  final String? providerLogo;

  Conversation({
    required this.conversationId,
    required this.userId,
    required this.providerId,
    this.subject,
    required this.status,
    this.lastMessageAt,
    this.lastMessageContent,
    required this.userUnreadCount,
    required this.providerUnreadCount,
    required this.createdAt,
    required this.updatedAt,
    this.userName,
    this.userAvatar,
    this.providerName,
    this.providerLogo,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      conversationId: json['conversationId'] ?? json['conversation_id'] ?? 0,
      userId: json['userId'] ?? json['user_id'] ?? 0,
      providerId: json['providerId'] ?? json['provider_id'] ?? 0,
      subject: json['subject'],
      status:
          json['conversationStatus'] ?? json['conversation_status'] ?? 'active',
      lastMessageAt: json['lastMessageAt'] != null
          ? DateTime.parse(json['lastMessageAt'])
          : (json['last_message_at'] != null
                ? DateTime.parse(json['last_message_at'])
                : null),
      lastMessageContent:
          json['lastMessageContent'] ?? json['last_message_content'],
      userUnreadCount:
          json['userUnreadCount'] ?? json['user_unread_count'] ?? 0,
      providerUnreadCount:
          json['providerUnreadCount'] ?? json['provider_unread_count'] ?? 0,
      createdAt: DateTime.parse(
        json['createdAt'] ??
            json['created_at'] ??
            DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ??
            json['updated_at'] ??
            DateTime.now().toIso8601String(),
      ),
      userName: json['userName'] ?? json['user_name'],
      userAvatar: json['userAvatar'] ?? json['user_avatar'],
      providerName: json['providerName'] ?? json['provider_name'],
      providerLogo: json['providerLogo'] ?? json['provider_logo'],
    );
  }
}

/// Model cho ConversationMessage
class ConversationMessage {
  final int messageId;
  final int conversationId;
  final String senderType; // "user" hoặc "provider"
  final int senderId;
  final String content;
  final String messageType; // "text", "image", "file", "system"
  final String? imageUrl;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;
  // Info bổ sung
  final String? senderName;
  final String? senderAvatar;

  ConversationMessage({
    required this.messageId,
    required this.conversationId,
    required this.senderType,
    required this.senderId,
    required this.content,
    required this.messageType,
    this.imageUrl,
    required this.isRead,
    this.readAt,
    required this.createdAt,
    this.senderName,
    this.senderAvatar,
  });

  factory ConversationMessage.fromJson(Map<String, dynamic> json) {
    return ConversationMessage(
      messageId: json['messageId'] ?? json['message_id'] ?? 0,
      conversationId: json['conversationId'] ?? json['conversation_id'] ?? 0,
      senderType: json['senderType'] ?? json['sender_type'] ?? 'user',
      senderId: json['senderId'] ?? json['sender_id'] ?? 0,
      content: json['content'] ?? '',
      messageType: json['messageType'] ?? json['message_type'] ?? 'text',
      imageUrl: json['imageUrl'] ?? json['image_url'],
      isRead: json['isRead'] ?? json['is_read'] ?? false,
      readAt: json['readAt'] != null
          ? DateTime.parse(json['readAt'])
          : (json['read_at'] != null ? DateTime.parse(json['read_at']) : null),
      createdAt: DateTime.parse(
        json['createdAt'] ??
            json['created_at'] ??
            DateTime.now().toIso8601String(),
      ),
      senderName: json['senderName'] ?? json['sender_name'],
      senderAvatar: json['senderAvatar'] ?? json['sender_avatar'],
    );
  }

  bool get isFromUser => senderType == 'user';
  bool get isFromProvider => senderType == 'provider';
  bool get isImage => messageType == 'image';
  bool get isSystem => messageType == 'system';
}

/// Provider quản lý state chat
class ChatProvider extends ChangeNotifier {
  ChatApiService? _chatService;

  // State
  List<Conversation> _conversations = [];
  List<ConversationMessage> _messages = [];
  Conversation? _currentConversation;
  bool _isLoading = false;
  String? _error;
  int _unreadCount = 0;
  Timer? _pollingTimer;
  DateTime? _lastMessageTime;

  // Getters
  List<Conversation> get conversations => _conversations;
  List<ConversationMessage> get messages => _messages;
  Conversation? get currentConversation => _currentConversation;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _unreadCount;

  /// Khởi tạo service
  Future<void> init() async {
    if (_chatService != null) return;

    final prefs = await SharedPreferences.getInstance();
    final dio = Dio();
    _chatService = ChatApiService(dio: dio, prefs: prefs);
  }

  /// Lấy danh sách conversations của user
  Future<void> loadConversations(int userId) async {
    await init();
    _setLoading(true);
    _error = null;

    try {
      final data = await _chatService!.getConversationsByUser(userId);
      _conversations = data.map((json) => Conversation.fromJson(json)).toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      debugPrint('❌ Error loading conversations: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Tạo hoặc lấy conversation với provider
  Future<Conversation?> getOrCreateConversation({
    required int userId,
    required int providerId,
    String? subject,
  }) async {
    await init();
    _setLoading(true);
    _error = null;

    try {
      final data = await _chatService!.getOrCreateConversation(
        userId: userId,
        providerId: providerId,
        subject: subject,
      );
      final conversation = Conversation.fromJson(data);
      _currentConversation = conversation;

      // Thêm vào danh sách nếu chưa có
      if (!_conversations.any(
        (c) => c.conversationId == conversation.conversationId,
      )) {
        _conversations.insert(0, conversation);
      }

      notifyListeners();
      return conversation;
    } catch (e) {
      _error = e.toString();
      debugPrint('❌ Error creating conversation: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Chọn conversation để chat
  Future<void> selectConversation(Conversation conversation) async {
    _currentConversation = conversation;
    _messages = [];
    notifyListeners();

    await loadMessages(conversation.conversationId);
  }

  /// Lấy tin nhắn của conversation
  Future<void> loadMessages(int conversationId) async {
    await init();
    _setLoading(true);
    _error = null;

    try {
      final data = await _chatService!.getMessages(conversationId);
      _messages = data
          .map((json) => ConversationMessage.fromJson(json))
          .toList();

      if (_messages.isNotEmpty) {
        _lastMessageTime = _messages.last.createdAt;
      }

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      debugPrint('❌ Error loading messages: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Gửi tin nhắn
  Future<bool> sendMessage({
    required int userId,
    required String content,
    String messageType = 'text',
    String? imageUrl,
  }) async {
    if (_currentConversation == null) return false;
    await init();

    try {
      final data = await _chatService!.sendMessage(
        conversationId: _currentConversation!.conversationId,
        senderType: 'user',
        senderId: userId,
        content: content,
        messageType: messageType,
        imageUrl: imageUrl,
      );

      final message = ConversationMessage.fromJson(data);
      _messages.add(message);
      _lastMessageTime = message.createdAt;

      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('❌ Error sending message: $e');
      return false;
    }
  }

  /// Đánh dấu đã đọc
  Future<void> markAsRead(int userId) async {
    if (_currentConversation == null) return;
    await init();

    try {
      await _chatService!.markAsRead(
        conversationId: _currentConversation!.conversationId,
        readerType: 'user',
      );

      // Cập nhật unread count local
      final index = _conversations.indexWhere(
        (c) => c.conversationId == _currentConversation!.conversationId,
      );
      if (index != -1) {
        // Tạo conversation mới với unread = 0
        final old = _conversations[index];
        _conversations[index] = Conversation(
          conversationId: old.conversationId,
          userId: old.userId,
          providerId: old.providerId,
          subject: old.subject,
          status: old.status,
          lastMessageAt: old.lastMessageAt,
          lastMessageContent: old.lastMessageContent,
          userUnreadCount: 0,
          providerUnreadCount: old.providerUnreadCount,
          createdAt: old.createdAt,
          updatedAt: old.updatedAt,
          userName: old.userName,
          userAvatar: old.userAvatar,
          providerName: old.providerName,
          providerLogo: old.providerLogo,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ Error marking as read: $e');
    }
  }

  /// Bắt đầu polling tin nhắn mới
  void startPolling() {
    stopPolling();
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _pollNewMessages();
    });
  }

  /// Dừng polling
  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  /// Poll tin nhắn mới
  Future<void> _pollNewMessages() async {
    if (_currentConversation == null || _lastMessageTime == null) return;
    await init();

    try {
      final data = await _chatService!.getNewMessages(
        conversationId: _currentConversation!.conversationId,
        afterTime: _lastMessageTime!,
      );

      if (data.isNotEmpty) {
        for (final json in data) {
          final message = ConversationMessage.fromJson(json);
          // Chỉ thêm nếu chưa có
          if (!_messages.any((m) => m.messageId == message.messageId)) {
            _messages.add(message);
            _lastMessageTime = message.createdAt;
          }
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ Error polling messages: $e');
    }
  }

  /// Lấy số tin nhắn chưa đọc
  Future<void> loadUnreadCount(int userId) async {
    await init();

    try {
      _unreadCount = await _chatService!.getUnreadMessagesCount(
        id: userId,
        type: 'user',
      );
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error loading unread count: $e');
    }
  }

  /// Tìm kiếm conversations
  Future<void> searchConversations(int userId, String keyword) async {
    if (keyword.isEmpty) {
      await loadConversations(userId);
      return;
    }

    await init();
    _setLoading(true);
    _error = null;

    try {
      final data = await _chatService!.searchConversations(
        id: userId,
        type: 'user',
        keyword: keyword,
      );
      _conversations = data.map((json) => Conversation.fromJson(json)).toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      debugPrint('❌ Error searching conversations: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Clear current conversation
  void clearCurrentConversation() {
    stopPolling();
    _currentConversation = null;
    _messages = [];
    _lastMessageTime = null;
    notifyListeners();
  }

  /// Clear all state
  void clear() {
    stopPolling();
    _conversations = [];
    _messages = [];
    _currentConversation = null;
    _error = null;
    _unreadCount = 0;
    _lastMessageTime = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}
