// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationDTO _$NotificationDTOFromJson(Map<String, dynamic> json) =>
    NotificationDTO(
      notificationId: (json['notification_id'] as num).toInt(),
      userId: (json['user_id'] as num).toInt(),
      notificationType: json['notification_type'] as String,
      category: json['category'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      relatedId: (json['related_id'] as num?)?.toInt(),
      isRead: json['is_read'] as bool,
      createdAt: json['created_at'] as String,
      readAt: json['read_at'] as String?,
    );

Map<String, dynamic> _$NotificationDTOToJson(NotificationDTO instance) =>
    <String, dynamic>{
      'notification_id': instance.notificationId,
      'user_id': instance.userId,
      'notification_type': instance.notificationType,
      'category': instance.category,
      'title': instance.title,
      'content': instance.content,
      'related_id': instance.relatedId,
      'is_read': instance.isRead,
      'created_at': instance.createdAt,
      'read_at': instance.readAt,
    };
