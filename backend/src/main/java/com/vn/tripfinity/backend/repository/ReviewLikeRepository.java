package com.vn.tripfinity.backend.repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.vn.tripfinity.backend.model.ReviewLike;

@Repository
public interface ReviewLikeRepository extends JpaRepository<ReviewLike, Integer> {
    
    // Check if user liked a review
    Optional<ReviewLike> findByUserIdAndReviewTypeAndReviewId(
        Integer userId, String reviewType, Integer reviewId
    );

    // Count likes for a review
    Long countByReviewTypeAndReviewId(String reviewType, Integer reviewId);

    // Delete like for review
    void deleteByUserIdAndReviewTypeAndReviewId(
        Integer userId, String reviewType, Integer reviewId
    );
}
