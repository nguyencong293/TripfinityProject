import 'dart:io';
import 'package:app/services/trip_bot_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:app/config/theme/app_colors.dart';
import 'package:app/config/theme/app_text_styles.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:app/views/screens/hotel_detail_overview_screen.dart';
import 'package:app/views/screens/restaurant_overview_detail_screen.dart';
import 'package:app/views/screens/attractions_overview_detail_screen.dart';
import 'package:app/views/screens/tour_service_detail_overview_screen.dart';

class ChatHelpBotScreen extends StatefulWidget {
  final bool isFromBottomBar;

  const ChatHelpBotScreen({super.key, this.isFromBottomBar = false});

  @override
  State<ChatHelpBotScreen> createState() => _ChatHelpBotScreenState();
}

class _ChatHelpBotScreenState extends State<ChatHelpBotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();
  bool _isConnectedToStaff = false;
  bool _isLoading = false;
  final List<ChatMessage> _messages = [];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Convert format từ bot thành markdown chuẩn
  String _convertToMarkdown(String text) {
    // Convert *** thành ** cho bold
    text = text.replaceAllMapped(RegExp(r'\*\*\*(.*?)\*\*\*'), (match) {
      return '**${match.group(1)}**';
    });

    // Convert format danh sách
    text = text.replaceAllMapped(RegExp(r'^(\s*)\* (.+)', multiLine: true), (
      match,
    ) {
      return '${match.group(1)}- ${match.group(2)}';
    });

    // Convert numbered lists
    text = text.replaceAllMapped(
      RegExp(r'^(\s*)(\d+)\. (.+)', multiLine: true),
      (match) {
        return '${match.group(1)}${match.group(2)}. ${match.group(3)}';
      },
    );

    return text;
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

  /// Kiểm tra xem user có muốn chuyển sang nhân viên không
  bool _shouldTransferToStaff(String message) {
    final lowerMessage = message.toLowerCase().trim();

    // Danh sách các từ khóa đa ngôn ngữ
    final transferKeywords = [
      // Tiếng Việt
      'tôi muốn gặp nhân viên',
      'gặp nhân viên',
      'muốn gặp người thật',
      'nói chuyện với nhân viên',
      'chat với nhân viên',
      'kết nối nhân viên',
      'tôi cần hỗ trợ',
      'cần người hỗ trợ',
      'muốn được tư vấn',
      'gọi nhân viên',
      'chuyển nhân viên',

      // English
      'i want to talk to human',
      'talk to human',
      'speak to agent',
      'connect to staff',
      'human support',
      'live chat',
      'customer service',
      'talk to someone',
      'need help from staff',
      'transfer to agent',

      // 中文
      '我想和人工客服聊天',
      '转人工',
      '人工服务',
      '联系客服',

      // 日本語
      'スタッフと話したい',
      '人間のサポート',
      'オペレーターに繋いで',

      // 한국어
      '직원과 대화하고 싶어요',
      '상담원 연결',
      '사람과 이야기하고 싶어요',

      // Français
      'parler à un humain',
      'service client',
      'agent en direct',

      // Español
      'hablar con humano',
      'atención al cliente',
      'agente en vivo',

      // Deutsch
      'mit mensch sprechen',
      'kundenservice',
      'live support',
    ];

    return transferKeywords.any((keyword) => lowerMessage.contains(keyword));
  }

  /// Xử lý gửi tin nhắn
  void _onSendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isLoading) return;

    // Thêm message của user
    setState(() {
      _messages.add(
        ChatMessage(text: text, isFromUser: true, timestamp: DateTime.now()),
      );
      _isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    if (!_isConnectedToStaff) {
      // Kiểm tra xem user có muốn chuyển sang nhân viên không
      if (_shouldTransferToStaff(text)) {
        setState(() {
          _isLoading = false;
        });
        _showStaffTransferDialog();
        return;
      }

      await _handleBotResponse(text);
    } else {
      // Logic chat với staff (giữ nguyên)
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Xử lý phản hồi từ TripBot
  Future<void> _handleBotResponse(String userMessage) async {
    debugPrint('📤 Sending to TripBot: $userMessage');
    try {
      // Hiển thị typing indicator
      setState(() {
        _messages.add(
          ChatMessage(
            text: 'TripBot đang soạn tin...',
            isFromUser: false,
            timestamp: DateTime.now(),
            isTyping: true,
          ),
        );
      });
      _scrollToBottom();

      // Gọi TripBot service
      final response = await TripBotService.sendMessage(userMessage);
      debugPrint('📥 TripBot response success: ${response.isSuccess}');
      debugPrint('📥 TripBot response message: ${response.message}');

      // Xóa typing indicator
      setState(() {
        _messages.removeWhere((msg) => msg.isTyping);
      });

      // Kiểm tra xem bot có gợi ý chuyển nhân viên không
      bool shouldShowTransferDialog = false;
      String botResponse = response.isSuccess
          ? response.message
          : response.userFriendlyErrorMessage;

      if (botResponse.contains('[TRANSFER_TO_STAFF]')) {
        shouldShowTransferDialog = true;
        botResponse = botResponse.replaceAll('[TRANSFER_TO_STAFF]', '').trim();
      }

      // Thêm phản hồi từ bot với items nếu có
      setState(() {
        _messages.add(
          ChatMessage(
            text: botResponse.isNotEmpty
                ? botResponse
                : 'Tôi hiểu bạn cần hỗ trợ thêm. Bạn có muốn tôi kết nối với nhân viên không?',
            isFromUser: false,
            timestamp: DateTime.now(),
            isError: !response.isSuccess,
            serviceItems: response.items, // NEW: Lưu items từ response
          ),
        );
        _isLoading = false;
      });
      _scrollToBottom();

      // Hiển thị dialog chuyển nhân viên nếu cần
      if (shouldShowTransferDialog) {
        Future.delayed(const Duration(milliseconds: 500), () {
          _showStaffTransferDialog();
        });
      }
    } catch (e, stackTrace) {
      // Xử lý lỗi không mong muốn
      debugPrint('❌ Exception in _handleBotResponse: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      setState(() {
        _messages.removeWhere((msg) => msg.isTyping);
        _messages.add(
          ChatMessage(
            text: 'Đã xảy ra lỗi không mong muốn. Vui lòng thử lại.',
            isFromUser: false,
            timestamp: DateTime.now(),
            isError: true,
          ),
        );
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _onContactStaff() {
    if (_isConnectedToStaff) {
      _switchToBotMode();
    } else {
      _showStaffConfirmationDialog();
    }
  }

  void _switchToBotMode() {
    setState(() {
      _isConnectedToStaff = false;
      _messages.add(
        ChatMessage(
          text: 'Đã chuyển về chế độ chat với TripBOT.',
          isFromUser: false,
          timestamp: DateTime.now(),
          isSystemMessage: true,
        ),
      );
    });
    _scrollToBottom();
  }

  void _showStaffTransferDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: context.cardBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(LucideIcons.users2, color: context.primaryColor, size: 24),
              const SizedBox(width: 8),
              Text(
                'Chuyển đến nhân viên',
                style: context.h5Style.copyWith(
                  color: context.textPrimaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Text(
            'Tôi nhận thấy bạn cần hỗ trợ từ nhân viên. Bạn có muốn tôi kết nối bạn với nhân viên hỗ trợ không?',
            style: context.bodyOneStyle.copyWith(
              color: context.textPrimaryColor,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Tiếp tục với TripBOT',
                style: context.bodyOneStyle.copyWith(
                  color: context.textSecondaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _connectToStaff();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: context.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Kết nối nhân viên',
                style: context.bodyOneStyle.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showStaffConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: context.cardBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Xác nhận',
            style: context.h5Style.copyWith(
              color: context.textPrimaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Bạn có muốn trò chuyện trực tiếp với nhân viên không?',
            style: context.bodyOneStyle.copyWith(
              color: context.textPrimaryColor,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Quay lại',
                style: context.bodyOneStyle.copyWith(
                  color: context.textSecondaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _connectToStaff();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: context.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Có',
                style: context.bodyOneStyle.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _connectToStaff() {
    setState(() {
      _isConnectedToStaff = true;
      _messages.add(
        ChatMessage(
          text:
              'Đã chuyển hướng đến nhân viên hỗ trợ. Vui lòng chờ trong giây lát...',
          isFromUser: false,
          timestamp: DateTime.now(),
          isSystemMessage: true,
        ),
      );
    });
    _scrollToBottom();

    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _messages.add(
          ChatMessage(
            text:
                'Xin chào! Tôi là nhân viên hỗ trợ. Tôi có thể giúp gì cho bạn?',
            isFromUser: false,
            timestamp: DateTime.now(),
            senderName: 'Nhân viên hỗ trợ',
          ),
        );
      });
      _scrollToBottom();
    });
  }

  void _onChatHistory() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Lịch sử chat'),
        backgroundColor: context.primaryColor,
      ),
    );
  }

  void _onNewChat() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: context.cardBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Cuộc trò chuyện mới',
            style: context.h5Style.copyWith(
              color: context.textPrimaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Bạn có muốn bắt đầu cuộc trò chuyện mới không? Tất cả tin nhắn hiện tại sẽ bị xóa.',
            style: context.bodyOneStyle.copyWith(
              color: context.textPrimaryColor,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Hủy',
                style: context.bodyOneStyle.copyWith(
                  color: context.textSecondaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _messages.clear();
                  _isConnectedToStaff = false;
                  _isLoading = false;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: context.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Bắt đầu mới',
                style: context.bodyOneStyle.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _onAttachImage() {
    if (!_isConnectedToStaff) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng kết nối với nhân viên để gửi hình ảnh'),
          backgroundColor: context.primaryColor,
        ),
      );
      return;
    }

    _showImagePickerDialog();
  }

  void _showImagePickerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
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
                  Navigator.of(context).pop();
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
                  Navigator.of(context).pop();
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
        errorMessage =
            'Quyền truy cập camera bị từ chối. Vui lòng cấp quyền trong cài đặt.';
      } else if (e.code == 'permission_denied') {
        errorMessage = 'Cần cấp quyền truy cập camera để chụp ảnh.';
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã xảy ra lỗi: $e'),
          backgroundColor: Colors.red,
        ),
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
      String errorMessage = 'Không thể chọn ảnh';
      if (e.code == 'photo_access_denied') {
        errorMessage =
            'Quyền truy cập thư viện ảnh bị từ chối. Vui lòng cấp quyền trong cài đặt.';
      } else if (e.code == 'permission_denied') {
        errorMessage = 'Cần cấp quyền truy cập thư viện ảnh để chọn hình.';
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã xảy ra lỗi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _sendImageMessage(String imagePath) {
    setState(() {
      _messages.add(
        ChatMessage(
          text: '',
          isFromUser: true,
          timestamp: DateTime.now(),
          isImage: true,
          imagePath: imagePath,
        ),
      );
    });
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: widget.isFromBottomBar ? null : _buildAppBar(context),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? _buildMainContent(context)
                : _buildChatArea(context),
          ),
          _buildBottomInputArea(context),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: context.backgroundColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: Icon(
          LucideIcons.chevronLeft,
          color: context.textPrimaryColor,
          size: 24,
        ),
      ),
      title: Text(
        _isConnectedToStaff ? 'Chat với nhân viên' : 'Trò chuyện/ Hỗ trợ',
        style: context.h5Style.copyWith(
          fontWeight: FontWeight.w600,
          color: context.textPrimaryColor,
        ),
      ),
      centerTitle: true,
      actions: [
        if (_isConnectedToStaff)
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Online',
                      style: context.captionStyle.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: context.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(LucideIcons.bot, size: 40, color: context.primaryColor),
          ),
          const SizedBox(height: 24),
          Text(
            'Xin chào tôi là',
            style: context.subTitleOneStyle.copyWith(
              color: context.textPrimaryColor,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'TripBOT',
            style: context.h2Style.copyWith(
              color: context.textPrimaryColor,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Trợ lý thông minh cho chuyến du lịch của bạn',
            style: context.bodyOneStyle.copyWith(
              color: context.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Text(
            'Tôi có thể giúp gì cho bạn?',
            style: context.h5Style.copyWith(
              color: context.textPrimaryColor,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          _buildSuggestedQuestions(context),
          const SizedBox(height: 32),
          _buildContactStaffButton(context),
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  Widget _buildSuggestedQuestions(BuildContext context) {
    final suggestions = [
      'Tìm tour du lịch phù hợp',
      'Địa điểm nổi tiếng ở Việt Nam',
      'Lên kế hoạch chuyến đi',
      'Khách sạn tốt nhất',
    ];

    return Column(
      children: [
        Text(
          'Câu hỏi gợi ý:',
          style: context.bodyOneStyle.copyWith(
            color: context.textSecondaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: suggestions.map((suggestion) {
            return GestureDetector(
              onTap: () {
                _messageController.text = suggestion;
                _onSendMessage();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: context.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: context.primaryColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  suggestion,
                  style: context.captionStyle.copyWith(
                    color: context.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildChatArea(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return _buildMessageBubble(context, message);
      },
    );
  }

  Widget _buildMessageBubble(BuildContext context, ChatMessage message) {
    final isUser = message.isFromUser;
    final screenWidth = MediaQuery.of(context).size.width;

    // Khoảng cách margin từ cạnh màn hình
    const double sideMargin = 80.0; // Tin nhắn sẽ cách cạnh màn hình 80px

    IconData getMessageIcon() {
      if (isUser) {
        return LucideIcons.user;
      } else {
        if (message.isSystemMessage) {
          return LucideIcons.info;
        }
        return _isConnectedToStaff ? LucideIcons.users2 : LucideIcons.bot;
      }
    }

    Color getAvatarColor() {
      if (message.isError) return Colors.red;
      if (message.isSystemMessage) return Colors.orange;
      if (_isConnectedToStaff && !isUser) return Colors.green;
      return context.primaryColor;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Avatar cho tin nhắn từ bot/staff (bên trái)
          if (!isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: getAvatarColor(),
              child: Icon(getMessageIcon(), size: 16, color: Colors.white),
            ),
            const SizedBox(width: 8),
          ],

          // Container chứa tin nhắn với width được giới hạn
          Container(
            constraints: BoxConstraints(
              maxWidth: screenWidth - sideMargin - 40, // Trừ avatar và spacing
            ),
            child: message.isImage && message.imagePath != null
                ? _buildPureImageMessage(context, message)
                : _buildTextMessage(context, message),
          ),

          // Avatar cho tin nhắn từ user (bên phải)
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: context.primaryColor,
              child: Icon(getMessageIcon(), size: 16, color: Colors.white),
            ),
          ],

          // Spacing để tạo khoảng cách với cạnh màn hình
          if (isUser)
            const SizedBox(width: 0) // User message đã có avatar làm spacing
          else
            SizedBox(
              width: sideMargin - 32,
            ), // Bot message cần thêm spacing để cách xa bên phải
        ],
      ),
    );
  }

  Widget _buildPureImageMessage(BuildContext context, ChatMessage message) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 220, maxHeight: 280),
        child: Image.file(
          File(message.imagePath!),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 220,
              height: 160,
              decoration: BoxDecoration(
                color: context.cardBackgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.borderLineColor),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.imageOff,
                    size: 40,
                    color: context.textSecondaryColor,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Không thể tải ảnh',
                    style: context.captionStyle.copyWith(
                      color: context.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextMessage(BuildContext context, ChatMessage message) {
    final isUser = message.isFromUser;

    // Typing indicator
    if (message.isTyping) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: context.cardBackgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.borderLineColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(context.primaryColor),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              message.text,
              style: context.bodyOneStyle.copyWith(
                color: context.textSecondaryColor,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isUser
            ? context.primaryColor
            : (message.isError
                  ? Colors.red.shade50
                  : (message.isSystemMessage
                        ? Colors.orange.shade50
                        : context.cardBackgroundColor)),
        borderRadius: BorderRadius.circular(12),
        border: isUser
            ? null
            : Border.all(
                color: message.isError
                    ? Colors.red.shade300
                    : (message.isSystemMessage
                          ? Colors.orange.shade300
                          : context.borderLineColor),
              ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (message.senderName != null) ...[
            Text(
              message.senderName!,
              style: context.captionStyle.copyWith(
                color: isUser ? Colors.white : context.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
          ],

          // Sử dụng Markdown cho tin nhắn từ bot, Text thường cho user
          if (isUser)
            Text(
              message.text,
              style: context.bodyOneStyle.copyWith(color: Colors.white),
            )
          else
            MarkdownBody(
              data: _convertToMarkdown(message.text),
              styleSheet: MarkdownStyleSheet(
                p: context.bodyOneStyle.copyWith(
                  color: message.isError
                      ? Colors.red.shade700
                      : (message.isSystemMessage
                            ? Colors.orange.shade700
                            : context.textPrimaryColor),
                ),
                strong: context.bodyOneStyle.copyWith(
                  color: message.isError
                      ? Colors.red.shade700
                      : (message.isSystemMessage
                            ? Colors.orange.shade700
                            : context.textPrimaryColor),
                  fontWeight: FontWeight.bold,
                ),
                em: context.bodyOneStyle.copyWith(
                  color: message.isError
                      ? Colors.red.shade700
                      : (message.isSystemMessage
                            ? Colors.orange.shade700
                            : context.textPrimaryColor),
                  fontStyle: FontStyle.italic,
                ),
                listBullet: context.bodyOneStyle.copyWith(
                  color: message.isError
                      ? Colors.red.shade700
                      : (message.isSystemMessage
                            ? Colors.orange.shade700
                            : context.textPrimaryColor),
                ),
                code: context.bodyOneStyle.copyWith(
                  color: message.isError
                      ? Colors.red.shade700
                      : (message.isSystemMessage
                            ? Colors.orange.shade700
                            : context.textPrimaryColor),
                  backgroundColor: context.backgroundColor,
                  fontFamily: 'monospace',
                ),
                codeblockDecoration: BoxDecoration(
                  color: context.backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: context.borderLineColor),
                ),
              ),
              selectable: true,
            ),

          // Timestamp
          if (!message.isTyping) ...[
            const SizedBox(height: 4),
            Text(
              '${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}',
              style: context.captionStyle.copyWith(
                color: isUser
                    ? Colors.white.withValues(alpha: 0.7)
                    : context.textSecondaryColor,
                fontSize: 10,
              ),
            ),
          ],

          // NEW: Hiển thị service items cards nếu có
          if (!isUser && message.hasServiceItems) ...[
            const SizedBox(height: 12),
            _buildServiceItemsGrid(context, message.serviceItems),
          ],
        ],
      ),
    );
  }

  /// NEW: Widget hiển thị grid các service items
  Widget _buildServiceItemsGrid(
    BuildContext context,
    List<ChatServiceItem> items,
  ) {
    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final item = items[index];
          return _buildServiceItemCard(context, item);
        },
      ),
    );
  }

  /// NEW: Widget card cho mỗi service item - Với hình ảnh
  Widget _buildServiceItemCard(BuildContext context, ChatServiceItem item) {
    return InkWell(
      onTap: () => _showServiceDetailDialog(context, item),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          color: context.backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.borderLineColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon theo loại dịch vụ
            Container(
              height: 60,
              width: double.infinity,
              decoration: BoxDecoration(
                color: _getServiceColor(item.itemType).withValues(alpha: 0.15),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: Center(
                child: Icon(
                  _getServiceIcon(item.itemType),
                  size: 28,
                  color: _getServiceColor(item.itemType),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.captionStyle.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                    ),
                    const Spacer(),
                    // Location
                    Row(
                      children: [
                        Icon(
                          LucideIcons.mapPin,
                          size: 10,
                          color: context.textSecondaryColor,
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            item.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.captionStyle.copyWith(
                              fontSize: 9,
                              color: context.textSecondaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    // Price
                    Text(
                      item.formattedPrice,
                      style: context.captionStyle.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// NEW: Get icon theo loại dịch vụ
  IconData _getServiceIcon(String itemType) {
    switch (itemType) {
      case 'hotel':
        return LucideIcons.hotel;
      case 'restaurant':
        return LucideIcons.utensils;
      case 'attraction':
        return LucideIcons.landmark;
      case 'tour':
        return LucideIcons.compass;
      default:
        return LucideIcons.mapPin;
    }
  }

  /// NEW: Get color theo loại dịch vụ
  Color _getServiceColor(String itemType) {
    switch (itemType) {
      case 'hotel':
        return Colors.blue;
      case 'restaurant':
        return Colors.orange;
      case 'attraction':
        return Colors.purple;
      case 'tour':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  /// NEW: Hiển thị dialog chi tiết dịch vụ
  void _showServiceDetailDialog(BuildContext context, ChatServiceItem item) {
    // Navigate đến trang detail tương ứng
    // Khi back sẽ quay lại trang chat
    Widget detailScreen;

    switch (item.itemType) {
      case 'hotel':
        detailScreen = HotelDetailOverviewScreen(hotelId: item.itemId);
        break;
      case 'restaurant':
        detailScreen = RestaurantDetailScreen(restaurantId: item.itemId);
        break;
      case 'attraction':
        detailScreen = AttractionsOverviewDetailScreen(
          attractionId: item.itemId,
        );
        break;
      case 'tour':
        detailScreen = TourServiceDetailScreen(tourId: item.itemId);
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể mở chi tiết dịch vụ: ${item.itemType}'),
            backgroundColor: Colors.red,
          ),
        );
        return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => detailScreen),
    );
  }

  Widget _buildContactStaffButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _onContactStaff,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: context.borderLineColor, width: 1),
            borderRadius: BorderRadius.circular(24),
            color: context.backgroundColor,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _isConnectedToStaff ? LucideIcons.bot : LucideIcons.users,
                size: 20,
                color: context.textSecondaryColor,
              ),
              const SizedBox(width: 10),
              Text(
                _isConnectedToStaff
                    ? 'Quay về TripBOT'
                    : 'Trò chuyện trực tiếp với nhân viên',
                style: context.bodyOneStyle.copyWith(
                  color: context.textSecondaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomInputArea(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.backgroundColor,
        border: Border(
          top: BorderSide(color: context.borderLineColor, width: 0.5),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                _buildActionButton(
                  icon: LucideIcons.history,
                  onTap: _onChatHistory,
                  backgroundColor: context.primaryColor.withValues(alpha: 0.1),
                  iconColor: context.primaryColor,
                ),
                const SizedBox(width: 8),
                _buildActionButton(
                  icon: _isConnectedToStaff
                      ? LucideIcons.bot
                      : LucideIcons.users2,
                  onTap: _onContactStaff,
                  backgroundColor: _isConnectedToStaff
                      ? Colors.green.withValues(alpha: 0.1)
                      : context.primaryColor.withValues(alpha: 0.1),
                  iconColor: _isConnectedToStaff
                      ? Colors.green
                      : context.primaryColor,
                ),
                const SizedBox(width: 8),
                _buildActionButton(
                  icon: LucideIcons.plus,
                  onTap: _onNewChat,
                  backgroundColor: context.primaryColor.withValues(alpha: 0.1),
                  iconColor: context.primaryColor,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildMessageInput(context),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color backgroundColor,
    required Color iconColor,
  }) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
          child: Icon(icon, size: 16, color: iconColor),
        ),
      ),
    );
  }

  Widget _buildMessageInput(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardBackgroundColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: context.borderLineColor, width: 1),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _onAttachImage,
            child: Icon(
              LucideIcons.image,
              size: 20,
              color: _isConnectedToStaff
                  ? context.primaryColor
                  : context.textSecondaryColor,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _messageController,
              enabled: !_isLoading,
              style: context.bodyOneStyle.copyWith(
                color: context.textPrimaryColor,
              ),
              maxLines: null,
              decoration: InputDecoration(
                hintText: _isLoading ? 'Đang gửi...' : 'Nhập câu hỏi của bạn',
                hintStyle: context.bodyOneStyle.copyWith(
                  color: context.textSecondaryColor,
                ),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _onSendMessage(),
            ),
          ),
          GestureDetector(
            onTap: _isLoading ? null : _onSendMessage,
            child: Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 6),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
              ),
              child: _isLoading
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          context.textSecondaryColor,
                        ),
                      ),
                    )
                  : Icon(
                      LucideIcons.send,
                      size: 18,
                      color: context.textPrimaryColor,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// Updated ChatMessage model
class ChatMessage {
  final String text;
  final bool isFromUser;
  final DateTime timestamp;
  final String? senderName;
  final bool isSystemMessage;
  final bool isImage;
  final String? imagePath;
  final bool isTyping;
  final bool isError;
  final List<ChatServiceItem> serviceItems; // NEW: danh sách items từ bot

  ChatMessage({
    required this.text,
    required this.isFromUser,
    required this.timestamp,
    this.senderName,
    this.isSystemMessage = false,
    this.isImage = false,
    this.imagePath,
    this.isTyping = false,
    this.isError = false,
    this.serviceItems = const [], // NEW
  });

  bool get hasServiceItems => serviceItems.isNotEmpty;
}
