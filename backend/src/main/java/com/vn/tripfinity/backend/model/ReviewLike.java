package com.vn.tripfinity.backend.model;

import java.time.LocalDateTime;

import org.hibernate.annotations.CreationTimestamp;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Entity
@Table(name = "review_likes", uniqueConstraints = {
    @UniqueConstraint(name = "unique_review_like", 
        columnNames = {"user_id", "review_type", "review_id", "reply_id"})
})
public class ReviewLike {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "like_id")
    private Integer likeId;

    @Column(name = "user_id", nullable = false)
    private Integer userId;

    @Column(name = "review_type", nullable = false, length = 20)
    private String reviewType; // 'hotel', 'restaurant', 'tour', 'attraction', 'provider'

    @Column(name = "review_id", nullable = false)
    private Integer reviewId;

    @Column(name = "reply_id")
    private Integer replyId; // NULL for review like, set for reply like

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;
}
