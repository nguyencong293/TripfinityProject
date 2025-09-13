package com.vn.tripfinity.backend.model;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Entity
@Table(name = "tour_reviews")
public class TourReview {

    public enum ReviewStatus {
        approved, rejected
    }

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "review_id")
    private Integer reviewId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "tour_id", nullable = false)
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private Tour tour;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private User user;

    @Column(name = "rating", nullable = false)
    private Integer rating; // 1..5

    @Column(name = "title", length = 255)
    private String title;

    @Column(name = "content", columnDefinition = "TEXT", nullable = false)
    private String content;

    @Column(name = "image_urls", columnDefinition = "TEXT")
    private String imageUrls; // CSV

    @Column(name = "likes_count", nullable = false)
    private Integer likesCount;

    @Column(name = "reply_count", nullable = false)
    private Integer replyCount;

    @Enumerated(EnumType.STRING)
    @Column(name = "review_status", nullable = false, length = 16)
    private ReviewStatus reviewStatus;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    @PrePersist
    public void prePersist() {
        if (likesCount == null)
            likesCount = 0;
        if (replyCount == null)
            replyCount = 0;
        if (reviewStatus == null)
            reviewStatus = ReviewStatus.approved;
    }
}
