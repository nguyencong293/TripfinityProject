import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/config/theme/app_colors.dart';
import 'package:app/config/theme/app_text_styles.dart';
import 'package:app/providers/chat_provider.dart';
import 'package:app/services/chat_api_service.dart';

/// Screen chat với Provider (nhân viên supplier)
/// Được gọi từ TripBot khi user muốn chuyển hướng đến hỗ trợ nhân viên
class ChatWithProviderScreen extends StatefulWidget {
  final int userId;
  final int providerId;
  final String? providerName;
  final String? providerLogo;
  final String? subject;

  const ChatWithProviderScreen({
    super.key,
    required this.userId,
    required this.providerId,
    this.providerName,
    this.providerLogo,
    this.subject,
  });

  @override
  State<ChatWithProviderScreen> createState() => _ChatWithProviderScreenState();
}

class _ChatWithProviderScreenState extends State<ChatWithProviderScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();
  final FocusNode _focusNode = FocusNode();

  bool _isLoading = false;
  bool _isSending = false;
  late ChatProvider _chatProvider;
  ChatApiService? _chatApiService;

  @override
  void initState() {
    super.initState();
    _chatProvider = ChatProvider();
    _initServices();
    _initChat();
  }

  Future<void> _initServices() async {
    final prefs = await SharedPreferences.getInstance();
    final dio = Dio();
    _chatApiService = ChatApiService(dio: dio, prefs: prefs);
  }

  Future<void> _initChat() async {
    setState(() => _isLoading = true);

    try {
      // Tạo hoặc lấy conversation
      await _chatProvider.getOrCreateConversation(
        userId: widget.userId,
        providerId: widget.providerId,
        subject: widget.subject ?? 'Hỗ trợ từ TripBot',
      );

      // Load messages nếu có
      if (_chatProvider.currentConversation != null) {
        await _chatProvider.loadMessages(
          _chatProvider.currentConversation!.conversationId,
        );
        // Đánh dấu đã đọc
        await _chatProvider.markAsRead(widget.userId);
      }

      // Bắt đầu polling tin nhắn mới
      _chatProvider.startPolling();

      // Listen changes
      _chatProvider.addListener(_onProviderChange);
    } catch (e) {
      debugPrint('❌ Error initializing chat: $e');
    } finally {
      setState(() => _isLoading = false);
      _scrollToBottom();
    }
  }

  void _onProviderChange() {
    if (mounted) {
      setState(() {});
      _scrollToBottom();
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _chatProvider.stopPolling();
    _chatProvider.removeListener(_onProviderChange);
    _chatProvider.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() => _isSending = true);
    _messageController.clear();

    try {
      await _chatProvider.sendMessage(userId: widget.userId, content: text);
      _scrollToBottom();
    } catch (e) {
      debugPrint('❌ Error sending message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể gửi tin nhắn. Vui lòng thử lại.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSending = false);
    }
  }

  Future<void> _sendImageMessage(String imagePath) async {
    setState(() => _isSending = true);

    try {
      // Upload qua backend API (backend sẽ upload lên Cloudinary)
      String imageUrl;
      if (_chatApiService != null) {
        imageUrl = await _chatApiService!.uploadChatImage(imagePath);
      } else {
        throw Exception('Chat service chưa được khởi tạo');
      }

      // Gửi message với image URL
      await _chatProvider.sendMessage(
        userId: widget.userId,
        content: 'Đã gửi một hình ảnh',
        messageType: 'image',
        imageUrl: imageUrl,
      );

      _scrollToBottom();
    } catch (e) {
      debugPrint('❌ Error uploading image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể gửi hình ảnh. Vui lòng thử lại.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isSending = false);
    }
  }

  void _showImagePickerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: context.cardBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Chọn hình ảnh',
            style: context.h5Style.copyWith(
              color: context.textPrimaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(LucideIcons.camera, color: context.primaryColor),
                title: Text(
                  'Chụp ảnh',
                  style: context.bodyOneStyle.copyWith(
                    color: context.textPrimaryColor,
                  ),
                ),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickImageFromCamera();
                },
              ),
              ListTile(
                leading: Icon(LucideIcons.image, color: context.primaryColor),
                title: Text(
                  'Chọn từ thư viện',
                  style: context.bodyOneStyle.copyWith(
                    color: context.textPrimaryColor,
                  ),
                ),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickImageFromGallery();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 80,
      );

      if (image != null) {
        _sendImageMessage(image.path);
      }
    } on PlatformException catch (e) {
      String errorMessage = 'Không thể chụp ảnh';
      if (e.code == 'camera_access_denied') {
        errorMessage = 'Quyền truy cập camera bị từ chối.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 80,
      );

      if (image != null) {
        _sendImageMessage(image.path);
      }
    } on PlatformException catch (e) {
      String errorMessage = 'Không thể chọn ảnh từ thư viện';
      if (e.code == 'photo_access_denied') {
        errorMessage = 'Quyền truy cập thư viện ảnh bị từ chối.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          _buildInputArea(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final conversation = _chatProvider.currentConversation;
    final providerName =
        conversation?.providerName ?? widget.providerName ?? 'Nhân viên hỗ trợ';

    return AppBar(
      backgroundColor: context.cardBackgroundColor,
      elevation: 0,
      leading: IconButton(
        icon: Icon(LucideIcons.arrowLeft, color: context.textPrimaryColor),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 18,
            backgroundColor: context.primaryColor.withOpacity(0.1),
            backgroundImage: conversation?.providerLogo != null
                ? NetworkImage(conversation!.providerLogo!)
                : (widget.providerLogo != null
                      ? NetworkImage(widget.providerLogo!)
                      : null),
            child:
                (conversation?.providerLogo == null &&
                    widget.providerLogo == null)
                ? Icon(
                    LucideIcons.building2,
                    size: 18,
                    color: context.primaryColor,
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  providerName,
                  style: context.bodyOneStyle.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.textPrimaryColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Đang hoạt động',
                  style: context.captionStyle.copyWith(color: Colors.green),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(LucideIcons.phone, color: context.textPrimaryColor),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Tính năng gọi điện sẽ được cập nhật'),
                backgroundColor: context.primaryColor,
              ),
            );
          },
        ),
        IconButton(
          icon: Icon(LucideIcons.moreVertical, color: context.textPrimaryColor),
          onPressed: () {
            // Show more options
          },
        ),
      ],
    );
  }

  Widget _buildMessageList() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: context.primaryColor),
      );
    }

    if (_chatProvider.messages.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _chatProvider.messages.length,
      itemBuilder: (context, index) {
        final message = _chatProvider.messages[index];
        final isFromUser = message.isFromUser;

        // Show date separator if needed
        Widget? dateSeparator;
        if (index == 0 || _shouldShowDateSeparator(index)) {
          dateSeparator = _buildDateSeparator(message.createdAt);
        }

        return Column(
          children: [
            if (dateSeparator != null) dateSeparator,
            _buildMessageBubble(message, isFromUser),
          ],
        );
      },
    );
  }

  bool _shouldShowDateSeparator(int index) {
    final currentMessage = _chatProvider.messages[index];
    final previousMessage = _chatProvider.messages[index - 1];

    return currentMessage.createdAt.day != previousMessage.createdAt.day ||
        currentMessage.createdAt.month != previousMessage.createdAt.month ||
        currentMessage.createdAt.year != previousMessage.createdAt.year;
  }

  Widget _buildDateSeparator(DateTime date) {
    String dateText;
    final now = DateTime.now();

    if (date.day == now.day &&
        date.month == now.month &&
        date.year == now.year) {
      dateText = 'Hôm nay';
    } else if (date.day == now.day - 1 &&
        date.month == now.month &&
        date.year == now.year) {
      dateText = 'Hôm qua';
    } else {
      dateText = '${date.day}/${date.month}/${date.year}';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: context.dividerColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            dateText,
            style: context.captionStyle.copyWith(
              color: context.textSecondaryColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ConversationMessage message, bool isFromUser) {
    return Align(
      alignment: isFromUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: EdgeInsets.only(
          top: 4,
          bottom: 4,
          left: isFromUser ? 48 : 0,
          right: isFromUser ? 0 : 48,
        ),
        child: Column(
          crossAxisAlignment: isFromUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            // Sender name (only for provider)
            if (!isFromUser && message.senderName != null)
              Padding(
                padding: const EdgeInsets.only(left: 12, bottom: 4),
                child: Text(
                  message.senderName!,
                  style: context.captionStyle.copyWith(
                    color: context.textSecondaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

            // Message bubble
            Container(
              padding: message.isImage
                  ? const EdgeInsets.all(4)
                  : const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isFromUser
                    ? context.primaryColor
                    : context.cardBackgroundColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isFromUser ? 16 : 4),
                  bottomRight: Radius.circular(isFromUser ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: message.isImage
                  ? _buildImageMessage(message)
                  : Text(
                      message.content,
                      style: context.bodyOneStyle.copyWith(
                        color: isFromUser
                            ? Colors.white
                            : context.textPrimaryColor,
                      ),
                    ),
            ),

            // Time and read status
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatTime(message.createdAt),
                    style: context.captionStyle.copyWith(
                      color: context.textSecondaryColor,
                      fontSize: 10,
                    ),
                  ),
                  if (isFromUser) ...[
                    const SizedBox(width: 4),
                    Icon(
                      message.isRead
                          ? LucideIcons.checkCheck
                          : LucideIcons.check,
                      size: 14,
                      color: message.isRead
                          ? Colors.blue
                          : context.textSecondaryColor,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageMessage(ConversationMessage message) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: GestureDetector(
        onTap: () => _showFullImage(message.imageUrl!),
        child: Image.network(
          message.imageUrl!,
          width: 200,
          height: 200,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: 200,
              height: 200,
              color: context.dividerColor,
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                      : null,
                  color: context.primaryColor,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 200,
              height: 200,
              color: context.dividerColor,
              child: Center(
                child: Icon(
                  LucideIcons.imageOff,
                  color: context.textSecondaryColor,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showFullImage(String imageUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            leading: IconButton(
              icon: const Icon(LucideIcons.x, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: Center(
            child: InteractiveViewer(child: Image.network(imageUrl)),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: context.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              LucideIcons.messageSquare,
              size: 48,
              color: context.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Bắt đầu cuộc trò chuyện',
            style: context.h5Style.copyWith(
              color: context.textPrimaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Gửi tin nhắn để được hỗ trợ từ nhân viên',
            style: context.bodyTwoStyle.copyWith(
              color: context.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.only(
        left: 8,
        right: 8,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: context.cardBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Image button
          IconButton(
            icon: Icon(LucideIcons.image, color: context.primaryColor),
            onPressed: _isSending ? null : _showImagePickerDialog,
          ),

          // Text input
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: context.backgroundColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _messageController,
                focusNode: _focusNode,
                enabled: !_isSending,
                decoration: InputDecoration(
                  hintText: 'Nhập tin nhắn...',
                  hintStyle: context.bodyTwoStyle.copyWith(
                    color: context.textSecondaryColor,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                style: context.bodyOneStyle.copyWith(
                  color: context.textPrimaryColor,
                ),
                textCapitalization: TextCapitalization.sentences,
                maxLines: 4,
                minLines: 1,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Send button
          Container(
            decoration: BoxDecoration(
              color: context.primaryColor,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: _isSending
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(LucideIcons.send, color: Colors.white),
              onPressed: _isSending ? null : _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
