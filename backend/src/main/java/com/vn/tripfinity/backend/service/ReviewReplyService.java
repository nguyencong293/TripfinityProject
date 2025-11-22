package com.vn.tripfinity.backend.service;

import java.util.List;
import java.util.Objects;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.vn.tripfinity.backend.dto.ReviewReplyDTO;
import com.vn.tripfinity.backend.model.ReviewReply;
import com.vn.tripfinity.backend.repository.HotelReviewRepository;
import com.vn.tripfinity.backend.repository.ReviewLikeRepository;
import com.vn.tripfinity.backend.repository.ReviewReplyRepository;
import com.vn.tripfinity.backend.repository.UserRepository;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
public class ReviewReplyService {

    private final ReviewReplyRepository reviewReplyRepository;
    private final ReviewLikeRepository reviewLikeRepository;
    private final UserRepository userRepository;
    private final HotelReviewRepository hotelReviewRepository;

    @Transactional
    public ReviewReplyDTO createReply(ReviewReplyDTO dto) {
        log.info("Creating reply for review: {} {}", dto.getReviewType(), dto.getReviewId());

        // Find the replier user
        var replierUser = userRepository.findById(dto.getReplierId())
                .orElseThrow(() -> new RuntimeException("User not found: " + dto.getReplierId()));

        Integer isProviderValue = Objects.requireNonNullElse(dto.getIsProvider(), 0);

        ReviewReply reply = ReviewReply.builder()
                .reviewType(ReviewReply.ReviewType.valueOf(dto.getReviewType()))
                .reviewId(dto.getReviewId())
                .replier(replierUser)
                .content(dto.getContent())
                .isPublic(Boolean.TRUE.equals(dto.getIsPublic()))
                .isProvider(isProviderValue)
                .build();

        ReviewReply saved = reviewReplyRepository.save(reply);
        
        // 🔥 UPDATE replyCount in hotel_reviews table
        if ("hotel".equalsIgnoreCase(dto.getReviewType())) {
            hotelReviewRepository.findById(dto.getReviewId()).ifPresent(review -> {
                Integer currentCount = review.getReplyCount() != null ? review.getReplyCount() : 0;
                review.setReplyCount(currentCount + 1);
                hotelReviewRepository.save(review);
                log.info("✅ Updated replyCount for hotel review {}: {} -> {}", 
                        dto.getReviewId(), currentCount, currentCount + 1);
            });
        }
        
        return convertToDTO(saved, null);
    }

    public List<ReviewReplyDTO> getRepliesByReview(String reviewType, Integer reviewId, Integer currentUserId) {
        log.info("Getting replies for review: {} {}", reviewType, reviewId);
        
        ReviewReply.ReviewType type = ReviewReply.ReviewType.valueOf(reviewType);
        List<ReviewReply> replies = reviewReplyRepository.findByReviewTypeAndReviewIdOrderByCreatedAtDesc(type, reviewId);

        return replies.stream()
                .map(reply -> convertToDTO(reply, currentUserId))
                .collect(Collectors.toList());
    }

    public Long getReplyCount(String reviewType, Integer reviewId) {
        ReviewReply.ReviewType type = ReviewReply.ReviewType.valueOf(reviewType);
        return Long.valueOf(reviewReplyRepository.countByReviewTypeAndReviewId(type, reviewId));
    }

    @Transactional
    public ReviewReplyDTO updateReply(Integer replyId, String content) {
        log.info("Updating reply: {}", replyId);
        ReviewReply reply = reviewReplyRepository.findById(replyId)
                .orElseThrow(() -> new RuntimeException("Reply not found: " + replyId));
        reply.setContent(content);
        ReviewReply updated = reviewReplyRepository.save(reply);
        return convertToDTO(updated, null);
    }

    @Transactional
    public void deleteReply(Integer replyId) {
        log.info("Deleting reply: {}", replyId);
        ReviewReply reply = reviewReplyRepository.findById(replyId)
                .orElseThrow(() -> new RuntimeException("Reply not found: " + replyId));
        
        // Giảm replyCount trong hotel_reviews nếu là hotel reply
        if (reply.getReviewType() == ReviewReply.ReviewType.hotel) {
            hotelReviewRepository.findById(reply.getReviewId()).ifPresent(review -> {
                Integer currentCount = review.getReplyCount() != null ? review.getReplyCount() : 0;
                if (currentCount > 0) {
                    review.setReplyCount(currentCount - 1);
                    hotelReviewRepository.save(review);
                    log.info("✅ Decreased replyCount for hotel review {}: {} -> {}", 
                            reply.getReviewId(), currentCount, currentCount - 1);
                }
            });
        }
        
        reviewReplyRepository.deleteById(replyId);
    }

    private ReviewReplyDTO convertToDTO(ReviewReply reply, Integer currentUserId) {
        var replier = reply.getReplier();
        
        ReviewReplyDTO dto = ReviewReplyDTO.builder()
                .replyId(reply.getReplyId())
                .reviewType(reply.getReviewType().name())
                .reviewId(reply.getReviewId())
                .replierId(replier.getUserId())
                .content(reply.getContent())
                .isPublic(reply.getIsPublic())
                .isProvider(reply.getIsProvider())
                .createdAt(reply.getCreatedAt())
                .updatedAt(reply.getUpdatedAt())
                .replierName(replier.getFullName())
                .replierAvatar(replier.getAvatarUrl())
                .build();

        return dto;
    }
}
