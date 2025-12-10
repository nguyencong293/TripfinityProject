import 'package:app/config/theme/app_colors.dart';
import 'package:app/config/theme/app_text_styles.dart';
import 'package:app/services/localization_service.dart';
import 'package:app/services/notification_api_service.dart';
import 'package:app/dto/notification_dto.dart';
import 'package:app/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Dynamic Notification screen với real API integration
class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late NotificationApiService _notificationService;
  List<NotificationDTO> _notifications = [];
  List<NotificationDTO> _filteredNotifications = [];
  bool _isLoading = true;
  bool _isActionLoading = false; // Loading for actions (mark as read, delete)
  String _errorMessage = '';
  int _filterIndex = 0; // 0=All, 1=Latest, 2=Unread

  @override
  void initState() {
    super.initState();
    _initService();
  }

  Future<void> _initService() async {
    final prefs = await SharedPreferences.getInstance();
    final dio = Dio();
    _notificationService = NotificationApiService(dio: dio, prefs: prefs);
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final authController = context.read<AuthController>();
      final user = authController.currentUser;

      if (user == null || user.userId == null) {
        setState(() {
          _errorMessage = 'Vui lòng đăng nhập để xem thông báo';
          _isLoading = false;
        });
        return;
      }

      final userId = user.userId!;
      final notifications = await _notificationService.getNotificationsByUser(
        userId,
      );

      setState(() {
        _notifications = notifications;
        _applyFilter();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Không thể tải thông báo: $e';
        _isLoading = false;
      });
    }
  }

  void _applyFilter() {
    switch (_filterIndex) {
      case 0: // All
        _filteredNotifications = _notifications;
        break;
      case 1: // Latest (7 days)
        final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
        _filteredNotifications = _notifications.where((n) {
          try {
            final date = DateTime.parse(n.createdAt);
            return date.isAfter(sevenDaysAgo);
          } catch (e) {
            return true;
          }
        }).toList();
        break;
      case 2: // Unread
        _filteredNotifications = _notifications
            .where((n) => !n.isRead)
            .toList();
        break;
    }
  }

  Future<void> _markAsRead(NotificationDTO notification) async {
    if (notification.isRead) return;

    setState(() => _isActionLoading = true);
    final success = await _notificationService.markAsRead(
      notification.notificationId,
    );
    if (success) {
      _loadNotifications(); // Reload để cập nhật UI
    }
    setState(() => _isActionLoading = false);
  }

  Future<void> _deleteNotification(NotificationDTO notification) async {
    setState(() => _isActionLoading = true);
    final success = await _notificationService.deleteNotification(
      notification.notificationId,
    );
    if (success) {
      setState(() {
        _notifications.removeWhere(
          (n) => n.notificationId == notification.notificationId,
        );
        _applyFilter();
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Đã xóa thông báo')));
      }
    }
    setState(() => _isActionLoading = false);
  }

  Future<void> _markAllAsRead() async {
    final authController = context.read<AuthController>();
    final user = authController.currentUser;
    if (user == null || user.userId == null) return;

    setState(() => _isActionLoading = true);
    final userId = user.userId!;
    final success = await _notificationService.markAllAsRead(userId);
    if (success) {
      _loadNotifications();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã đánh dấu tất cả là đã đọc')),
        );
      }
    }
    setState(() => _isActionLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: context.backgroundColor,
          appBar: AppBar(
            backgroundColor: context.backgroundColor,
            elevation: 0,
            iconTheme: IconThemeData(color: context.textPrimaryColor),
            title: Text('notifications_title'.tr, style: context.h5Style),
            actions: [
              if (_notifications.any((n) => !n.isRead))
                IconButton(
                  icon: const Icon(Icons.done_all),
                  tooltip: 'Đánh dấu tất cả là đã đọc',
                  onPressed: _isActionLoading ? null : _markAllAsRead,
                ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _isActionLoading ? null : _loadNotifications,
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: _loadNotifications,
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  _buildTabs(),
                  const SizedBox(height: 8),
                  Expanded(child: _buildContent()),
                ],
              ),
            ),
          ),
        ),
        // Loading overlay
        if (_isActionLoading)
          Container(
            color: Colors.black26,
            child: const Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Đang xử lý...'),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTabs() {
    final tabs = [
      'notif_tab_all'.tr,
      'notif_tab_latest'.tr,
      'notif_tab_unread'.tr,
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final selected = _filterIndex == i;
          return Padding(
            padding: EdgeInsets.only(right: i == tabs.length - 1 ? 0 : 8),
            child: ChoiceChip(
              label: Text(tabs[i]),
              selected: selected,
              onSelected: (_) {
                setState(() {
                  _filterIndex = i;
                  _applyFilter();
                });
              },
              labelStyle: selected
                  ? context.bodyOneStyle.copyWith(
                      color: context.buttonTextColor,
                    )
                  : context.bodyOneStyle,
              selectedColor: context.primaryColor,
              backgroundColor: context.cardBackgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: context.borderLineColor),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage, style: context.bodyOneStyle),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadNotifications,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (_filteredNotifications.isEmpty) {
      return Center(
        child: Text(
          'Không có thông báo',
          style: context.bodyOneStyle.copyWith(
            color: context.textSecondaryColor,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredNotifications.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final notification = _filteredNotifications[index];
        return _NotificationItem(
          notification: notification,
          onTap: () => _markAsRead(notification),
          onDelete: () => _deleteNotification(notification),
        );
      },
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final NotificationDTO notification;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _NotificationItem({
    required this.notification,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.notificationId.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.white
                : context.cardBackgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: notification.isRead
                ? null
                : Border.all(
                    color: context.primaryColor.withOpacity(0.3),
                    width: 2,
                  ),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon emoji
              Container(
                margin: const EdgeInsets.only(top: 4, right: 12),
                child: Text(
                  notification.getIconByCategory(),
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: context.subTitleOneStyle.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Category badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: context.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        notification.getCategoryText(),
                        style: context.captionStyle.copyWith(
                          color: context.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      notification.content,
                      style: context.bodyTwoStyle.copyWith(
                        color: context.textSecondaryColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          notification.getFormattedDate(),
                          style: context.captionStyle.copyWith(
                            color: context.textSecondaryColor,
                          ),
                        ),
                        if (notification.isRead)
                          Text(
                            'Đã đọc',
                            style: context.captionStyle.copyWith(
                              color: Colors.green,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
