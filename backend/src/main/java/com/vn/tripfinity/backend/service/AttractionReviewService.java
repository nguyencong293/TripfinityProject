package com.vn.tripfinity.backend.service;

import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.vn.tripfinity.backend.dto.AttractionReviewDTO;
import com.vn.tripfinity.backend.dto.HotelReviewReplyDTO;
import com.vn.tripfinity.backend.exception.ResourceNotFoundException;
import com.vn.tripfinity.backend.model.Attraction;
import com.vn.tripfinity.backend.model.AttractionReview;
import com.vn.tripfinity.backend.model.AttractionReviewAspects;
import com.vn.tripfinity.backend.model.ReviewReply;
import com.vn.tripfinity.backend.model.User;
import com.vn.tripfinity.backend.repository.AttractionRepository;
import com.vn.tripfinity.backend.repository.AttractionReviewAspectsRepository;
import com.vn.tripfinity.backend.repository.AttractionReviewRepository;
import com.vn.tripfinity.backend.repository.ReviewReplyRepository;
import com.vn.tripfinity.backend.repository.UserRepository;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class AttractionReviewService {

    private final AttractionReviewRepository reviewRepository;
    private final AttractionReviewAspectsRepository aspectsRepository;
    private final AttractionRepository attractionRepository;
    private final UserRepository userRepository;
    private final ReviewReplyRepository reviewReplyRepository;

    public List<AttractionReviewDTO> getAllReviews() {
        log.debug("Lấy toàn bộ attraction reviews");
        return reviewRepository.findAll().stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public AttractionReviewDTO getReviewById(Integer reviewId) {
        log.debug("Lấy attraction review theo ID: {}", reviewId);
        AttractionReview review = reviewRepository.findById(reviewId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Review id: " + reviewId));
        return convertToDTO(review);
    }

    public List<AttractionReviewDTO> getReviewsByAttraction(Integer attractionId) {
        log.debug("Lấy danh sách reviews của Attraction ID: {}", attractionId);
        attractionRepository.findById(attractionId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Attraction id: " + attractionId));

        List<AttractionReview> reviews = reviewRepository.findByAttraction_AttractionId(attractionId);
        log.info("Tìm thấy {} reviews của Attraction ID: {}", reviews.size(), attractionId);

        return reviews.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public List<AttractionReviewDTO> getReviewsByAttractionAndStatus(Integer attractionId, String status) {
        log.debug("Lấy danh sách reviews của Attraction ID: {} với status: {}", attractionId, status);
        attractionRepository.findById(attractionId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Attraction id: " + attractionId));

        AttractionReview.ReviewStatus reviewStatus = AttractionReview.ReviewStatus.valueOf(status);
        List<AttractionReview> reviews = reviewRepository.findByAttractionAndStatus(attractionId, reviewStatus);
        log.info("Tìm thấy {} reviews của Attraction ID: {} với status: {}", reviews.size(), attractionId, status);

        return reviews.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public AttractionReviewDTO createReview(AttractionReviewDTO dto) {
        log.debug("Tạo Review: {}", dto);

        Attraction attraction = attractionRepository.findById(dto.getAttractionId())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Attraction id: " + dto.getAttractionId()));

        User user = userRepository.findById(dto.getUserId())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy User id: " + dto.getUserId()));

        AttractionReview review = AttractionReview.builder()
                .reviewId(null)
                .attraction(attraction)
                .user(user)
                .rating(java.util.Objects.requireNonNullElse(dto.getRating(), 0))
                .title(dto.getTitle())
                .content(dto.getContent())
                .imageUrls(dto.getImageUrls() != null ? String.join(",", dto.getImageUrls()) : null)
                .likesCount(java.util.Objects.requireNonNullElse(dto.getLikesCount(), 0))
                .replyCount(java.util.Objects.requireNonNullElse(dto.getReplyCount(), 0))
                .reviewStatus(dto.getReviewStatus() != null
                        ? AttractionReview.ReviewStatus.valueOf(dto.getReviewStatus())
                        : AttractionReview.ReviewStatus.approved)
                .build();

        AttractionReview savedReview = reviewRepository.save(review);
        log.info("✅ Tạo Review ID: {}", savedReview.getReviewId());

        // Save aspects if provided
        if (dto.getAspects() != null) {
            AttractionReviewAspects aspects = AttractionReviewAspects.builder()
                    .review(savedReview)
                    .beauty(dto.getAspects().getBeauty())
                    .culture(dto.getAspects().getCulture())
                    .accessibility(dto.getAspects().getAccessibility())
                    .price(dto.getAspects().getPrice())
                    .facilities(dto.getAspects().getFacilities())
                    .build();
            AttractionReviewAspects savedAspects = aspectsRepository.save(aspects);
            log.info("✅ Tạo Review Aspects cho Review ID: {}", savedAspects.getReviewId());
        }

        return convertToDTO(savedReview);
    }

    public AttractionReviewDTO updateReview(Integer reviewId, AttractionReviewDTO dto) {
        log.debug("Cập nhật Review ID: {}", reviewId);

        AttractionReview review = reviewRepository.findById(reviewId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Review id: " + reviewId));

        if (dto.getRating() != null)
            review.setRating(dto.getRating());
        if (dto.getTitle() != null)
            review.setTitle(dto.getTitle());
        if (dto.getContent() != null)
            review.setContent(dto.getContent());
        if (dto.getImageUrls() != null)
            review.setImageUrls(String.join(",", dto.getImageUrls()));
        if (dto.getLikesCount() != null)
            review.setLikesCount(dto.getLikesCount());
        if (dto.getReplyCount() != null)
            review.setReplyCount(dto.getReplyCount());
        if (dto.getReviewStatus() != null)
            review.setReviewStatus(AttractionReview.ReviewStatus.valueOf(dto.getReviewStatus()));

        AttractionReview updatedReview = reviewRepository.save(review);
        log.info("✅ Cập nhật Review ID: {}", updatedReview.getReviewId());

        // Update aspects if provided
        if (dto.getAspects() != null) {
            AttractionReviewAspects aspects = aspectsRepository.findById(reviewId)
                    .orElse(AttractionReviewAspects.builder()
                            .reviewId(reviewId)
                            .review(updatedReview)
                            .build());

            aspects.setBeauty(dto.getAspects().getBeauty());
            aspects.setCulture(dto.getAspects().getCulture());
            aspects.setAccessibility(dto.getAspects().getAccessibility());
            aspects.setPrice(dto.getAspects().getPrice());
            aspects.setFacilities(dto.getAspects().getFacilities());
            aspectsRepository.save(aspects);
        }

        return convertToDTO(updatedReview);
    }

    public void deleteReview(Integer reviewId) {
        log.debug("Xóa Review ID: {}", reviewId);
        AttractionReview review = reviewRepository.findById(reviewId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Review id: " + reviewId));

        reviewRepository.delete(review);
        log.info("✅ Đã xóa Review ID: {}", reviewId);
    }

    private AttractionReviewDTO convertToDTO(AttractionReview review) {
        AttractionReviewDTO dto = AttractionReviewDTO.builder()
                .reviewId(review.getReviewId())
                .attractionId(review.getAttraction().getAttractionId())
                .userId(review.getUser().getUserId())
                .userName(review.getUser().getFullName())
                .rating(review.getRating())
                .title(review.getTitle())
                .content(review.getContent())
                .imageUrls(review.getImageUrls() != null && !review.getImageUrls().isEmpty()
                        ? Arrays.asList(review.getImageUrls().split(","))
                        : null)
                .likesCount(review.getLikesCount())
                .replyCount(review.getReplyCount())
                .reviewStatus(review.getReviewStatus().name())
                .createdAt(review.getCreatedAt())
                .updatedAt(review.getUpdatedAt())
                .build();

        log.debug("🔍 convertToDTO: reviewId={}, likesCount={}, replyCount={}", 
                review.getReviewId(), review.getLikesCount(), review.getReplyCount());

        // Load aspects if exists
        aspectsRepository.findById(review.getReviewId()).ifPresent(aspects -> {
            AttractionReviewDTO.AttractionReviewAspectsDTO aspectsDTO = AttractionReviewDTO.AttractionReviewAspectsDTO.builder()
                    .beauty(aspects.getBeauty())
                    .culture(aspects.getCulture())
                    .accessibility(aspects.getAccessibility())
                    .price(aspects.getPrice())
                    .facilities(aspects.getFacilities())
                    .build();
            dto.setAspects(aspectsDTO);
        });

        return dto;
    }

    // === REPLY METHODS ===
    public HotelReviewReplyDTO createAttractionReviewReply(Integer reviewId, HotelReviewReplyDTO dto) {
        log.debug("Tạo reply cho Attraction Review ID: {}", reviewId);
        
        AttractionReview review = reviewRepository.findById(reviewId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Review id: " + reviewId));
        
        User replier = userRepository.findById(dto.getReplierId())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy User id: " + dto.getReplierId()));
        
        ReviewReply reply = ReviewReply.builder()
                .reviewType(ReviewReply.ReviewType.attraction)
                .reviewId(reviewId)
                .replier(replier)
                .content(dto.getContent())
                .isPublic(Boolean.TRUE.equals(dto.getIsPublic()))
                .isProvider(java.util.Objects.requireNonNullElse(dto.getIsProvider(), 0))
                .build();
        
        ReviewReply saved = reviewReplyRepository.save(reply);
        
        // Tăng reply count
        Integer currentCount = review.getReplyCount();
        review.setReplyCount(currentCount == null ? 1 : currentCount + 1);
        reviewRepository.save(review);
        
        log.info("✅ Tạo reply ID: {} cho Attraction Review ID: {}", saved.getReplyId(), reviewId);
        return toReviewReplyDTO(saved);
    }

    public List<HotelReviewReplyDTO> getAttractionReviewReplies(Integer reviewId) {
        log.debug("Lấy danh sách replies của Attraction Review ID: {}", reviewId);
        
        List<ReviewReply> replies = reviewReplyRepository.findByReviewTypeAndReviewIdOrderByCreatedAtDesc(
                ReviewReply.ReviewType.attraction, reviewId);
        
        log.info("Tìm thấy {} replies của Attraction Review ID: {}", replies.size(), reviewId);
        return replies.stream()
                .map(this::toReviewReplyDTO)
                .collect(Collectors.toList());
    }

    private HotelReviewReplyDTO toReviewReplyDTO(ReviewReply reply) {
        return HotelReviewReplyDTO.builder()
                .replyId(reply.getReplyId())
                .reviewId(reply.getReviewId())
                .replierId(reply.getReplier().getUserId())
                .content(reply.getContent())
                .isPublic(reply.getIsPublic())
                .isProvider(reply.getIsProvider())
                .createdAt(reply.getCreatedAt())
                .updatedAt(reply.getUpdatedAt())
                .build();
    }

    // === SYNC REPLY COUNTS FROM review_replies TABLE ===
    @Transactional
    public int syncReplyCountsFromReplies() {
        log.info("🔄 Syncing reply counts for all attraction reviews from review_replies table");
        
        List<AttractionReview> allReviews = reviewRepository.findAll();
        int updated = 0;
        
        for (AttractionReview review : allReviews) {
            int actualCount = reviewReplyRepository.countByReviewTypeAndReviewId(
                    ReviewReply.ReviewType.attraction, review.getReviewId());
            
            Integer currentCount = java.util.Objects.requireNonNullElse(review.getReplyCount(), 0);
            
            if (currentCount != actualCount) {
                review.setReplyCount(actualCount);
                reviewRepository.save(review);
                log.info("✅ Updated review {} replyCount: {} -> {}", 
                        review.getReviewId(), currentCount, actualCount);
                updated++;
            }
        }
        
        log.info("🎉 Synced reply counts for {} reviews", updated);
        return updated;
    }

    // === GET TOTAL REVIEWS COUNT BY PROVIDER ===
    public Long getTotalReviewsByProvider(Integer providerId) {
        log.debug("Lấy tổng số reviews của Provider ID: {}", providerId);
        Long count = reviewRepository.countByAttraction_Provider_ProviderId(providerId);
        if (count == null) {
            count = 0L;
        }
        log.info("Tìm thấy {} reviews của Provider ID: {}", count, providerId);
        return count;
    }
}
