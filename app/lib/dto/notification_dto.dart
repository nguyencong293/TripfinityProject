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
    if (category.contains('booking')) return '🏨';
    if (category.contains('payment')) return '💳';
    if (category.contains('hotel')) return '🏨';
    if (category.contains('promotion')) return '🎁';
    if (category.contains('system')) return '🔔';
    return '📬';
  }
}
