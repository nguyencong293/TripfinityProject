import 'package:json_annotation/json_annotation.dart';

part 'notification_dto.g.dart';

@JsonSerializable()
class NotificationDTO {
  @JsonKey(name: 'notification_id')
  final int notificationId;

  @JsonKey(name: 'user_id')
  final int userId;

  @JsonKey(name: 'notification_type')
  final String notificationType;

  @JsonKey(name: 'category')
  final String category;

  @JsonKey(name: 'title')
  final String title;

  @JsonKey(name: 'content')
  final String content;

  @JsonKey(name: 'related_id')
  final int? relatedId;

  @JsonKey(name: 'is_read')
  final bool isRead;

  @JsonKey(name: 'created_at')
  final String createdAt;

  @JsonKey(name: 'read_at')
  final String? readAt;

  NotificationDTO({
    required this.notificationId,
    required this.userId,
    required this.notificationType,
    required this.category,
    required this.title,
    required this.content,
    this.relatedId,
    required this.isRead,
    required this.createdAt,
    this.readAt,
  });

  factory NotificationDTO.fromJson(Map<String, dynamic> json) =>
      _$NotificationDTOFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationDTOToJson(this);

  /// Helper để format ngày tháng
  String getFormattedDate() {
    try {
      final date = DateTime.parse(createdAt);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inDays == 0) {
        if (diff.inHours == 0) {
          return '${diff.inMinutes} phút trước';
        }
        return '${diff.inHours} giờ trước';
      } else if (diff.inDays == 1) {
        return 'Hôm qua';
      } else if (diff.inDays < 7) {
        return '${diff.inDays} ngày trước';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return createdAt;
    }
  }

  /// Helper để lấy icon theo category
  String getIconByCategory() {
    if (category.contains('hotel')) return '🏨';
    if (category.contains('attraction')) return '🎡';
    if (category.contains('restaurant')) return '🍽️';
    if (category.contains('tour')) return '✈️';
    if (category.contains('booking')) return '📅';
    if (category.contains('payment')) return '💳';
    if (category.contains('promotion')) return '🎁';
    if (category.contains('system')) return '🔔';
    return '📬';
  }

  /// Helper để lấy text category tiếng Việt
  String getCategoryText() {
    switch (category) {
      case 'service_hotel_new':
        return 'Khách sạn mới';
      case 'service_hotel_update':
        return 'Cập nhật khách sạn';
      case 'service_hotel_booking':
        return 'Đặt phòng';
      case 'service_attraction_new':
        return 'Điểm tham quan mới';
      case 'service_attraction_update':
        return 'Cập nhật điểm tham quan';
      case 'service_attraction_booking':
        return 'Đặt điểm tham quan';
      case 'service_restaurant_new':
        return 'Nhà hàng mới';
      case 'service_restaurant_update':
        return 'Cập nhật nhà hàng';
      case 'service_restaurant_booking':
        return 'Đặt bàn';
      case 'service_tour_new':
        return 'Tour mới';
      case 'service_tour_update':
        return 'Cập nhật tour';
      case 'service_tour_booking':
        return 'Đặt tour';
      case 'payment_success':
        return 'Thanh toán thành công';
      case 'payment_failed':
        return 'Thanh toán thất bại';
      case 'payment_refund':
        return 'Hoàn tiền';
      case 'system_alert':
        return 'Cảnh báo hệ thống';
      case 'system_maintenance':
        return 'Bảo trì hệ thống';
      case 'promotion':
        return 'Khuyến mãi';
      default:
        return 'Thông báo';
    }
  }
}
