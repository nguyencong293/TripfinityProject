package com.vn.tripfinity.backend.repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.vn.tripfinity.backend.model.ReviewLike;

@Repository
public interface ReviewLikeRepository extends JpaRepository<ReviewLike, Integer> {
    
    // Check if user liked a review (replyId is NULL)
    Optional<ReviewLike> findByUserIdAndReviewTypeAndReviewIdAndReplyIdIsNull(
        Integer userId, String reviewType, Integer reviewId
    );

    // Check if user liked a reply
    Optional<ReviewLike> findByUserIdAndReviewTypeAndReviewIdAndReplyId(
        Integer userId, String reviewType, Integer reviewId, Integer replyId
    );

    // Count likes for a review
    Long countByReviewTypeAndReviewIdAndReplyIdIsNull(String reviewType, Integer reviewId);

    // Count likes for a reply
    Long countByReviewTypeAndReviewIdAndReplyId(String reviewType, Integer reviewId, Integer replyId);

    // Delete like for review
    void deleteByUserIdAndReviewTypeAndReviewIdAndReplyIdIsNull(
        Integer userId, String reviewType, Integer reviewId
    );

    // Delete like for reply
    void deleteByUserIdAndReviewTypeAndReviewIdAndReplyId(
        Integer userId, String reviewType, Integer reviewId, Integer replyId
    );
}
