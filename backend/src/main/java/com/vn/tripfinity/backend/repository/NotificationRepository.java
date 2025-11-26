package com.vn.tripfinity.backend.repository;

import java.util.List;

import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.vn.tripfinity.backend.model.Notification;

@Repository
public interface NotificationRepository extends JpaRepository<Notification, Integer> {

    // Lấy tất cả thông báo của user, sắp xếp mới nhất trước
    @Query("SELECT n FROM Notification n WHERE n.user.userId = :userId ORDER BY n.createdAt DESC")
    List<Notification> findByUserIdOrderByCreatedAtDesc(@Param("userId") Integer userId);

    // Lấy thông báo chưa đọc
    @Query("SELECT n FROM Notification n WHERE n.user.userId = :userId AND n.isRead = false ORDER BY n.createdAt DESC")
    List<Notification> findUnreadByUserId(@Param("userId") Integer userId);

    // Đếm số thông báo chưa đọc
    @Query("SELECT COUNT(n) FROM Notification n WHERE n.user.userId = :userId AND n.isRead = false")
    Long countUnreadByUserId(@Param("userId") Integer userId);

    // Lấy N thông báo mới nhất
    @Query("SELECT n FROM Notification n WHERE n.user.userId = :userId ORDER BY n.createdAt DESC")
    List<Notification> findTopNByUserId(@Param("userId") Integer userId, Pageable pageable);

    // Lấy thông báo theo category
    @Query("SELECT n FROM Notification n WHERE n.user.userId = :userId AND n.category = :category ORDER BY n.createdAt DESC")
    List<Notification> findByCategoryAndUserId(@Param("userId") Integer userId, @Param("category") String category);

    // Đánh dấu đã đọc
    @Modifying
    @Query("UPDATE Notification n SET n.isRead = true, n.readAt = CURRENT_TIMESTAMP WHERE n.notificationId = :notificationId")
    void markAsRead(@Param("notificationId") Integer notificationId);

    // Đánh dấu tất cả đã đọc
    @Modifying
    @Query("UPDATE Notification n SET n.isRead = true, n.readAt = CURRENT_TIMESTAMP WHERE n.user.userId = :userId AND n.isRead = false")
    void markAllAsReadByUserId(@Param("userId") Integer userId);
}
