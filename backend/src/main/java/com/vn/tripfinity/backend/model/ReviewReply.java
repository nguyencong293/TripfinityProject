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
@Table(name = "review_replies")
public class ReviewReply {

    public enum ReviewType {
        hotel, restaurant, tour, attraction, provider
    }

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "reply_id")
    private Integer replyId;

    @Enumerated(EnumType.STRING)
    @Column(name = "review_type", nullable = false, length = 20)
    private ReviewType reviewType;

    @Column(name = "review_id", nullable = false)
    private Integer reviewId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "replier_id", nullable = false)
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private User replier;

    @Column(name = "content", columnDefinition = "TEXT", nullable = false)
    private String content;

    @Column(name = "is_public", nullable = false)
    private Boolean isPublic;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    @PrePersist
    public void prePersist() {
        if (isPublic == null)
            isPublic = true;
    }
}
