package com.vn.tripfinity.backend.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.vn.tripfinity.backend.dto.NotificationDTO;
import com.vn.tripfinity.backend.service.NotificationService;

import lombok.Data;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/notifications")
@RequiredArgsConstructor
public class NotificationController {

    private final NotificationService notificationService;

    /**
     * Lấy tất cả thông báo của user
     */
    @GetMapping("/user/{userId}")
    public ResponseEntity<List<NotificationDTO>> getAllNotifications(@PathVariable Integer userId) {
        return ResponseEntity.ok(notificationService.getAllNotifications(userId));
    }

    /**
     * Lấy N thông báo mới nhất (dùng cho dashboard)
     */
    @GetMapping("/user/{userId}/recent")
    public ResponseEntity<List<NotificationDTO>> getRecentNotifications(
            @PathVariable Integer userId,
            @RequestParam(defaultValue = "4") int limit,
            @RequestParam(required = false) String categoryPrefix) {
        return ResponseEntity.ok(notificationService.getRecentNotifications(userId, limit, categoryPrefix));
    }

    /**
     * Lấy thông báo chưa đọc
     */
    @GetMapping("/user/{userId}/unread")
    public ResponseEntity<List<NotificationDTO>> getUnreadNotifications(@PathVariable Integer userId) {
        return ResponseEntity.ok(notificationService.getUnreadNotifications(userId));
    }

    /**
     * Đếm số thông báo chưa đọc (dùng cho badge)
     */
    @GetMapping("/user/{userId}/unread/count")
    public ResponseEntity<Map<String, Long>> countUnread(@PathVariable Integer userId) {
        Long count = notificationService.countUnread(userId);
        Map<String, Long> response = new HashMap<>();
        response.put("count", count);
        return ResponseEntity.ok(response);
    }

    /**
     * Đánh dấu thông báo đã đọc
     */
    @PatchMapping("/{notificationId}/read")
    public ResponseEntity<Map<String, String>> markAsRead(@PathVariable Integer notificationId) {
        notificationService.markAsRead(notificationId);
        Map<String, String> response = new HashMap<>();
        response.put("message", "Notification marked as read");
        return ResponseEntity.ok(response);
    }

    /**
     * Đánh dấu tất cả thông báo đã đọc
     */
    @PatchMapping("/user/{userId}/read-all")
    public ResponseEntity<Map<String, String>> markAllAsRead(@PathVariable Integer userId) {
        notificationService.markAllAsRead(userId);
        Map<String, String> response = new HashMap<>();
        response.put("message", "All notifications marked as read");
        return ResponseEntity.ok(response);
    }

    /**
     * Tạo thông báo mới (manual)
     */
    @PostMapping
    public ResponseEntity<NotificationDTO> createNotification(@RequestBody CreateNotificationRequest request) {
        NotificationDTO created = notificationService.createNotification(
                request.getUserId(),
                request.getNotificationType(),
                request.getCategory(),
                request.getTitle(),
                request.getContent());
        return ResponseEntity.ok(created);
    }

    /**
     * Xóa thông báo
     */
    @DeleteMapping("/{notificationId}")
    public ResponseEntity<Map<String, String>> deleteNotification(@PathVariable Integer notificationId) {
        notificationService.deleteNotification(notificationId);
        Map<String, String> response = new HashMap<>();
        response.put("message", "Notification deleted");
        return ResponseEntity.ok(response);
    }

    @Data
    public static class CreateNotificationRequest {
        private Integer userId;
        private String notificationType;
        private String category;
        private String title;
        private String content;
    }
}
