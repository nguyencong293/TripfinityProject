package com.vn.tripfinity.backend.service;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.vn.tripfinity.backend.dto.ReviewLikeDTO;
import com.vn.tripfinity.backend.model.ReviewLike;
import com.vn.tripfinity.backend.repository.HotelReviewRepository;
import com.vn.tripfinity.backend.repository.ReviewLikeRepository;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
public class ReviewLikeService {

    private final ReviewLikeRepository reviewLikeRepository;
    private final HotelReviewRepository hotelReviewRepository;

    @Transactional
    public boolean toggleLike(ReviewLikeDTO dto) {
        log.info("Toggling like for user {} on review {} {}", dto.getUserId(), dto.getReviewType(), dto.getReviewId());

        // Like/unlike review
        var existing = reviewLikeRepository.findByUserIdAndReviewTypeAndReviewId(
                dto.getUserId(), dto.getReviewType(), dto.getReviewId());

        if (existing.isPresent()) {
            // Unlike
            reviewLikeRepository.deleteByUserIdAndReviewTypeAndReviewId(
                    dto.getUserId(), dto.getReviewType(), dto.getReviewId());
            log.info("Unliked review");
            
            // Update likesCount in hotel_reviews if reviewType is hotel
            if ("hotel".equals(dto.getReviewType())) {
                hotelReviewRepository.findById(dto.getReviewId()).ifPresent(review -> {
                    Integer currentCount = review.getLikesCount();
                    review.setLikesCount(currentCount != null && currentCount > 0 ? currentCount - 1 : 0);
                    hotelReviewRepository.save(review);
                    log.info("✅ Updated likesCount to {} for review {}", review.getLikesCount(), dto.getReviewId());
                });
            }
            
            return false;
        } else {
            // Like
            ReviewLike like = ReviewLike.builder()
                    .userId(dto.getUserId())
                    .reviewType(dto.getReviewType())
                    .reviewId(dto.getReviewId())
                    .build();
            reviewLikeRepository.save(like);
            log.info("Liked review");
            
            // Update likesCount in hotel_reviews if reviewType is hotel
            if ("hotel".equals(dto.getReviewType())) {
                hotelReviewRepository.findById(dto.getReviewId()).ifPresent(review -> {
                    Integer currentCount = review.getLikesCount();
                    review.setLikesCount(currentCount == null ? 1 : currentCount + 1);
                    hotelReviewRepository.save(review);
                    log.info("✅ Updated likesCount to {} for review {}", review.getLikesCount(), dto.getReviewId());
                });
            }
            
            return true;
        }
    }

    public Long getLikeCount(String reviewType, Integer reviewId) {
        return reviewLikeRepository.countByReviewTypeAndReviewId(reviewType, reviewId);
    }

    public boolean checkIsLiked(Integer userId, String reviewType, Integer reviewId) {
        return reviewLikeRepository.findByUserIdAndReviewTypeAndReviewId(
                userId, reviewType, reviewId).isPresent();
    }
}
