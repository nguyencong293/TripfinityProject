package com.vn.tripfinity.backend.service;

import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.vn.tripfinity.backend.dto.HotelReviewReplyDTO;
import com.vn.tripfinity.backend.dto.TourReviewDTO;
import com.vn.tripfinity.backend.exception.ResourceNotFoundException;
import com.vn.tripfinity.backend.model.ReviewReply;
import com.vn.tripfinity.backend.model.Tour;
import com.vn.tripfinity.backend.model.TourReview;
import com.vn.tripfinity.backend.model.TourReviewAspects;
import com.vn.tripfinity.backend.model.User;
import com.vn.tripfinity.backend.repository.ReviewReplyRepository;
import com.vn.tripfinity.backend.repository.TourRepository;
import com.vn.tripfinity.backend.repository.TourReviewAspectsRepository;
import com.vn.tripfinity.backend.repository.TourReviewRepository;
import com.vn.tripfinity.backend.repository.UserRepository;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class TourReviewService {

    private final TourReviewRepository reviewRepository;
    private final TourReviewAspectsRepository aspectsRepository;
    private final TourRepository tourRepository;
    private final UserRepository userRepository;
    private final ReviewReplyRepository reviewReplyRepository;

    public List<TourReviewDTO> getAllReviews() {
        log.debug("Lấy toàn bộ tour reviews");
        return reviewRepository.findAll().stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public TourReviewDTO getReviewById(Integer reviewId) {
        log.debug("Lấy tour review theo ID: {}", reviewId);
        TourReview review = reviewRepository.findById(reviewId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Review id: " + reviewId));
        return convertToDTO(review);
    }

    public List<TourReviewDTO> getReviewsByTour(Integer tourId) {
        log.debug("Lấy danh sách reviews của Tour ID: {}", tourId);
        tourRepository.findById(tourId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Tour id: " + tourId));

        List<TourReview> reviews = reviewRepository.findByTour_TourId(tourId);
        log.info("Tìm thấy {} reviews của Tour ID: {}", reviews.size(), tourId);

        return reviews.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public List<TourReviewDTO> getReviewsByTourAndStatus(Integer tourId, String status) {
        log.debug("Lấy danh sách reviews của Tour ID: {} với status: {}", tourId, status);
        tourRepository.findById(tourId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Tour id: " + tourId));

        TourReview.ReviewStatus reviewStatus = TourReview.ReviewStatus.valueOf(status);
        List<TourReview> reviews = reviewRepository.findByTourAndStatus(tourId, reviewStatus);
        log.info("Tìm thấy {} reviews của Tour ID: {} với status: {}", reviews.size(), tourId, status);

        return reviews.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public TourReviewDTO createReview(TourReviewDTO dto) {
        log.debug("Tạo Review: {}", dto);

        Tour tour = tourRepository.findById(dto.getTourId())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Tour id: " + dto.getTourId()));

        User user = userRepository.findById(dto.getUserId())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy User id: " + dto.getUserId()));

        TourReview review = TourReview.builder()
                .reviewId(null)
                .tour(tour)
                .user(user)
                .rating(java.util.Objects.requireNonNullElse(dto.getRating(), 0))
                .title(dto.getTitle())
                .content(dto.getContent())
                .imageUrls(dto.getImageUrls() != null ? String.join(",", dto.getImageUrls()) : null)
                .likesCount(java.util.Objects.requireNonNullElse(dto.getLikesCount(), 0))
                .replyCount(java.util.Objects.requireNonNullElse(dto.getReplyCount(), 0))
                .reviewStatus(dto.getReviewStatus() != null
                        ? TourReview.ReviewStatus.valueOf(dto.getReviewStatus())
                        : TourReview.ReviewStatus.approved)
                .build();

        TourReview savedReview = reviewRepository.save(review);
        log.info("✅ Tạo Review ID: {}", savedReview.getReviewId());

        // Save aspects if provided
        if (dto.getAspects() != null) {
            TourReviewAspects aspects = TourReviewAspects.builder()
                    .review(savedReview)
                    .guideQuality(dto.getAspects().getGuideQuality())
                    .itineraryQuality(dto.getAspects().getItineraryQuality())
                    .valueForMoney(dto.getAspects().getValueForMoney())
                    .organization(dto.getAspects().getOrganization())
                    .safety(dto.getAspects().getSafety())
                    .build();
            TourReviewAspects savedAspects = aspectsRepository.save(aspects);
            log.info("✅ Tạo Review Aspects cho Review ID: {}", savedAspects.getReviewId());
        }

        return convertToDTO(savedReview);
    }

    public TourReviewDTO updateReview(Integer reviewId, TourReviewDTO dto) {
        log.debug("Cập nhật Review ID: {}", reviewId);

        TourReview review = reviewRepository.findById(reviewId)
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
            review.setReviewStatus(TourReview.ReviewStatus.valueOf(dto.getReviewStatus()));

        TourReview updatedReview = reviewRepository.save(review);
        log.info("✅ Cập nhật Review ID: {}", updatedReview.getReviewId());

        // Update aspects if provided
        if (dto.getAspects() != null) {
            TourReviewAspects aspects = aspectsRepository.findById(reviewId)
                    .orElse(TourReviewAspects.builder()
                            .reviewId(reviewId)
                            .review(updatedReview)
                            .build());

            aspects.setGuideQuality(dto.getAspects().getGuideQuality());
            aspects.setItineraryQuality(dto.getAspects().getItineraryQuality());
            aspects.setValueForMoney(dto.getAspects().getValueForMoney());
            aspects.setOrganization(dto.getAspects().getOrganization());
            aspects.setSafety(dto.getAspects().getSafety());
            aspectsRepository.save(aspects);
        }

        return convertToDTO(updatedReview);
    }

    public void deleteReview(Integer reviewId) {
        log.debug("Xóa Review ID: {}", reviewId);
        TourReview review = reviewRepository.findById(reviewId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Review id: " + reviewId));

        reviewRepository.delete(review);
        log.info("✅ Đã xóa Review ID: {}", reviewId);
    }

    private TourReviewDTO convertToDTO(TourReview review) {
        TourReviewDTO dto = TourReviewDTO.builder()
                .reviewId(review.getReviewId())
                .tourId(review.getTour().getTourId())
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
            TourReviewDTO.TourReviewAspectsDTO aspectsDTO = TourReviewDTO.TourReviewAspectsDTO.builder()
                    .guideQuality(aspects.getGuideQuality())
                    .itineraryQuality(aspects.getItineraryQuality())
                    .valueForMoney(aspects.getValueForMoney())
                    .organization(aspects.getOrganization())
                    .safety(aspects.getSafety())
                    .build();
            dto.setAspects(aspectsDTO);
        });

        return dto;
    }

    // === REPLY METHODS ===
    public HotelReviewReplyDTO createTourReviewReply(Integer reviewId, HotelReviewReplyDTO dto) {
        log.debug("Tạo reply cho Tour Review ID: {}", reviewId);
        
        TourReview review = reviewRepository.findById(reviewId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Review id: " + reviewId));
        
        User replier = userRepository.findById(dto.getReplierId())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy User id: " + dto.getReplierId()));
        
        ReviewReply reply = ReviewReply.builder()
                .reviewType(ReviewReply.ReviewType.tour)
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
        
        log.info("✅ Tạo reply ID: {} cho Tour Review ID: {}", saved.getReplyId(), reviewId);
        return toReviewReplyDTO(saved);
    }

    public List<HotelReviewReplyDTO> getTourReviewReplies(Integer reviewId) {
        log.debug("Lấy danh sách replies của Tour Review ID: {}", reviewId);
        
        List<ReviewReply> replies = reviewReplyRepository.findByReviewTypeAndReviewIdOrderByCreatedAtDesc(
                ReviewReply.ReviewType.tour, reviewId);
        
        log.info("Tìm thấy {} replies của Tour Review ID: {}", replies.size(), reviewId);
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
        log.info("🔄 Syncing reply counts for all tour reviews from review_replies table");
        
        List<TourReview> allReviews = reviewRepository.findAll();
        int updated = 0;
        
        for (TourReview review : allReviews) {
            int actualCount = reviewReplyRepository.countByReviewTypeAndReviewId(
                    ReviewReply.ReviewType.tour, review.getReviewId());
            
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
        Long count = reviewRepository.countByTour_Provider_ProviderId(providerId);
        if (count == null) {
            count = 0L;
        }
        log.info("Tìm thấy {} reviews của Provider ID: {}", count, providerId);
        return count;
    }
}
