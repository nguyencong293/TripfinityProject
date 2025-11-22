package com.vn.tripfinity.backend.service;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.vn.tripfinity.backend.dto.ReviewLikeDTO;
import com.vn.tripfinity.backend.model.ReviewLike;
import com.vn.tripfinity.backend.repository.ReviewLikeRepository;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
public class ReviewLikeService {

    private final ReviewLikeRepository reviewLikeRepository;

    @Transactional
    public boolean toggleLike(ReviewLikeDTO dto) {
        log.info("Toggling like for user {} on review {} {}", dto.getUserId(), dto.getReviewType(), dto.getReviewId());

        if (dto.getReplyId() == null) {
            // Like/unlike review
            var existing = reviewLikeRepository.findByUserIdAndReviewTypeAndReviewIdAndReplyIdIsNull(
                    dto.getUserId(), dto.getReviewType(), dto.getReviewId());

            if (existing.isPresent()) {
                // Unlike
                reviewLikeRepository.deleteByUserIdAndReviewTypeAndReviewIdAndReplyIdIsNull(
                        dto.getUserId(), dto.getReviewType(), dto.getReviewId());
                log.info("Unliked review");
                return false;
            } else {
                // Like
                ReviewLike like = ReviewLike.builder()
                        .userId(dto.getUserId())
                        .reviewType(dto.getReviewType())
                        .reviewId(dto.getReviewId())
                        .replyId(null)
                        .build();
                reviewLikeRepository.save(like);
                log.info("Liked review");
                return true;
            }
        } else {
            // Like/unlike reply
            var existing = reviewLikeRepository.findByUserIdAndReviewTypeAndReviewIdAndReplyId(
                    dto.getUserId(), dto.getReviewType(), dto.getReviewId(), dto.getReplyId());

            if (existing.isPresent()) {
                // Unlike
                reviewLikeRepository.deleteByUserIdAndReviewTypeAndReviewIdAndReplyId(
                        dto.getUserId(), dto.getReviewType(), dto.getReviewId(), dto.getReplyId());
                log.info("Unliked reply");
                return false;
            } else {
                // Like
                ReviewLike like = ReviewLike.builder()
                        .userId(dto.getUserId())
                        .reviewType(dto.getReviewType())
                        .reviewId(dto.getReviewId())
                        .replyId(dto.getReplyId())
                        .build();
                reviewLikeRepository.save(like);
                log.info("Liked reply");
                return true;
            }
        }
    }

    public Long getLikeCount(String reviewType, Integer reviewId, Integer replyId) {
        if (replyId == null) {
            return reviewLikeRepository.countByReviewTypeAndReviewIdAndReplyIdIsNull(reviewType, reviewId);
        } else {
            return reviewLikeRepository.countByReviewTypeAndReviewIdAndReplyId(reviewType, reviewId, replyId);
        }
    }

    public boolean isLiked(Integer userId, String reviewType, Integer reviewId, Integer replyId) {
        if (replyId == null) {
            return reviewLikeRepository.findByUserIdAndReviewTypeAndReviewIdAndReplyIdIsNull(
                    userId, reviewType, reviewId).isPresent();
        } else {
            return reviewLikeRepository.findByUserIdAndReviewTypeAndReviewIdAndReplyId(
                    userId, reviewType, reviewId, replyId).isPresent();
        }
    }
}
