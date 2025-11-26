package com.vn.tripfinity.backend.model;

import java.time.LocalDateTime;

import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;
import lombok.ToString;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Entity
@Table(name = "notifications")
public class Notification {

    // Constants for notification types
    public static final String TYPE_IN_APP = "in_app";
    public static final String TYPE_EMAIL = "email";
    public static final String TYPE_PUSH = "push";
    public static final String TYPE_SMS = "sms";

    // Constants for categories
    // Service categories
    public static final String CATEGORY_SERVICE_HOTEL_NEW = "service_hotel_new";
    public static final String CATEGORY_SERVICE_HOTEL_UPDATE = "service_hotel_update";
    public static final String CATEGORY_SERVICE_HOTEL_BOOKING = "service_hotel_booking";
    public static final String CATEGORY_SERVICE_TOUR_NEW = "service_tour_new";
    public static final String CATEGORY_SERVICE_TOUR_UPDATE = "service_tour_update";
    public static final String CATEGORY_SERVICE_TOUR_BOOKING = "service_tour_booking";
    
    // Payment categories
    public static final String CATEGORY_PAYMENT_SUCCESS = "payment_success";
    public static final String CATEGORY_PAYMENT_FAILED = "payment_failed";
    public static final String CATEGORY_PAYMENT_REFUND = "payment_refund";
    
    // System categories
    public static final String CATEGORY_SYSTEM_ALERT = "system_alert";
    public static final String CATEGORY_SYSTEM_MAINTENANCE = "system_maintenance";
    public static final String CATEGORY_PROMOTION = "promotion";

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "notification_id")
    private Integer notificationId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private User user;

    @Column(name = "notification_type", nullable = false, length = 50)
    private String notificationType;

    @Column(name = "category", nullable = false, length = 100)
    private String category;

    @Column(name = "title", length = 255)
    private String title;

    @Column(name = "content", columnDefinition = "TEXT", nullable = false)
    private String content;

    @Column(name = "is_read", nullable = false)
    private Boolean isRead;

    @Column(name = "read_at")
    private LocalDateTime readAt;

    @Column(name = "sent_at", nullable = false)
    private LocalDateTime sentAt;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    @PrePersist
    public void prePersist() {
        if (isRead == null) isRead = false;
        if (sentAt == null) sentAt = LocalDateTime.now();
    }
}
