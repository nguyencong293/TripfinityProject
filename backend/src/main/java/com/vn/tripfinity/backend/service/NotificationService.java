package com.vn.tripfinity.backend.service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.vn.tripfinity.backend.dto.NotificationDTO;
import com.vn.tripfinity.backend.model.Notification;
import com.vn.tripfinity.backend.model.User;
import com.vn.tripfinity.backend.repository.NotificationRepository;
import com.vn.tripfinity.backend.repository.UserRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class NotificationService {

    private static final Logger log = LoggerFactory.getLogger(NotificationService.class);

    private final NotificationRepository notificationRepository;
    private final UserRepository userRepository;

    /**
     * Tạo thông báo mới
     */
    @Transactional
    public NotificationDTO createNotification(
            Integer userId,
            String notificationType,
            String category,
            String title,
            String content) {

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("User not found: " + userId));

        Notification notification = Notification.builder()
                .user(user)
                .notificationType(notificationType)
                .category(category)
                .title(title)
                .content(content)
                .isRead(false)
                .sentAt(LocalDateTime.now())
                .build();

        Notification saved = notificationRepository.save(notification);
        log.info("✅ Created notification #{} for user {}: {}", saved.getNotificationId(), userId, title);

        return NotificationDTO.fromEntity(saved);
    }

    /**
     * Lấy tất cả thông báo của user
     */
    public List<NotificationDTO> getAllNotifications(Integer userId) {
        return notificationRepository.findByUserIdOrderByCreatedAtDesc(userId)
                .stream()
                .map(NotificationDTO::fromEntity)
                .collect(Collectors.toList());
    }

    /**
     * Lấy N thông báo mới nhất
     */
    public List<NotificationDTO> getRecentNotifications(Integer userId, int limit) {
        return notificationRepository.findTopNByUserId(userId, PageRequest.of(0, limit))
                .stream()
                .map(NotificationDTO::fromEntity)
                .collect(Collectors.toList());
    }

    /**
     * Lấy thông báo chưa đọc
     */
    public List<NotificationDTO> getUnreadNotifications(Integer userId) {
        return notificationRepository.findUnreadByUserId(userId)
                .stream()
                .map(NotificationDTO::fromEntity)
                .collect(Collectors.toList());
    }

    /**
     * Đếm số thông báo chưa đọc
     */
    public Long countUnread(Integer userId) {
        return notificationRepository.countUnreadByUserId(userId);
    }

    /**
     * Đánh dấu đã đọc
     */
    @Transactional
    public void markAsRead(Integer notificationId) {
        notificationRepository.markAsRead(notificationId);
        log.info("✅ Marked notification #{} as read", notificationId);
    }

    /**
     * Đánh dấu tất cả đã đọc
     */
    @Transactional
    public void markAllAsRead(Integer userId) {
        notificationRepository.markAllAsReadByUserId(userId);
        log.info("✅ Marked all notifications as read for user {}", userId);
    }

    /**
     * Xóa thông báo
     */
    @Transactional
    public void deleteNotification(Integer notificationId) {
        notificationRepository.deleteById(notificationId);
        log.info("✅ Deleted notification #{}", notificationId);
    }

    /**
     * Helper: Tạo thông báo khi tạo hotel mới
     */
    @Transactional
    public void notifyHotelCreated(Integer userId, String hotelTitle) {
        createNotification(
                userId,
                Notification.TYPE_IN_APP,
                Notification.CATEGORY_SERVICE_HOTEL_NEW,
                "Khách sạn mới đã được tạo",
                String.format("Khách sạn '%s' đã được tạo thành công.", hotelTitle));
    }

    /**
     * Helper: Tạo thông báo khi cập nhật hotel
     */
    @Transactional
    public void notifyHotelUpdated(Integer userId, String hotelTitle) {
        createNotification(
                userId,
                Notification.TYPE_IN_APP,
                Notification.CATEGORY_SERVICE_HOTEL_UPDATE,
                "Khách sạn đã được cập nhật",
                String.format("Thông tin khách sạn '%s' đã được cập nhật thành công.", hotelTitle));
    }
}
