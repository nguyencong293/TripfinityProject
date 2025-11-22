package com.vn.tripfinity.backend.service;

import java.util.List;
import java.util.Objects;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.vn.tripfinity.backend.dto.ReviewReplyDTO;
import com.vn.tripfinity.backend.model.ReviewReply;
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
        return convertToDTO(saved, null);
    }

    public List<ReviewReplyDTO> getRepliesByReview(String reviewType, Integer reviewId, Integer currentUserId) {
        log.info("Getting replies for review: {} {}", reviewType, reviewId);
        
        ReviewReply.ReviewType type = ReviewReply.ReviewType.valueOf(reviewType);
        List<ReviewReply> replies = reviewReplyRepository.findByReviewTypeAndReviewIdOrderByCreatedAtAsc(type, reviewId);

        return replies.stream()
                .map(reply -> convertToDTO(reply, currentUserId))
                .collect(Collectors.toList());
    }

    public Long getReplyCount(String reviewType, Integer reviewId) {
        ReviewReply.ReviewType type = ReviewReply.ReviewType.valueOf(reviewType);
        return Long.valueOf(reviewReplyRepository.countByReviewTypeAndReviewId(type, reviewId));
    }

    @Transactional
    public void deleteReply(Integer replyId) {
        log.info("Deleting reply: {}", replyId);
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

        // Get like count
        Long likeCount = reviewLikeRepository.countByReviewTypeAndReviewIdAndReplyId(
                reply.getReviewType().name(), reply.getReviewId(), reply.getReplyId());
        dto.setLikeCount(likeCount.intValue());

        // Check if current user liked this reply
        if (currentUserId != null) {
            boolean isLiked = reviewLikeRepository.findByUserIdAndReviewTypeAndReviewIdAndReplyId(
                    currentUserId, reply.getReviewType().name(), reply.getReviewId(), reply.getReplyId()).isPresent();
            dto.setIsLikedByCurrentUser(isLiked);
        }

        return dto;
    }
}
