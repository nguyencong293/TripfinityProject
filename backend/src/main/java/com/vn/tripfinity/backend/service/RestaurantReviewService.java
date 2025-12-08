package com.vn.tripfinity.backend.service;

import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.vn.tripfinity.backend.dto.RestaurantReviewDTO;
import com.vn.tripfinity.backend.dto.RestaurantReviewReplyDTO;
import com.vn.tripfinity.backend.exception.ResourceNotFoundException;
import com.vn.tripfinity.backend.model.Restaurant;
import com.vn.tripfinity.backend.model.RestaurantReview;
import com.vn.tripfinity.backend.model.RestaurantReviewAspects;
import com.vn.tripfinity.backend.model.ReviewReply;
import com.vn.tripfinity.backend.model.User;
import com.vn.tripfinity.backend.repository.RestaurantRepository;
import com.vn.tripfinity.backend.repository.RestaurantReviewAspectsRepository;
import com.vn.tripfinity.backend.repository.RestaurantReviewRepository;
import com.vn.tripfinity.backend.repository.ReviewReplyRepository;
import com.vn.tripfinity.backend.repository.UserRepository;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class RestaurantReviewService {

    private final RestaurantReviewRepository reviewRepository;
    private final RestaurantReviewAspectsRepository aspectsRepository;
    private final RestaurantRepository restaurantRepository;
    private final UserRepository userRepository;
    private final ReviewReplyRepository reviewReplyRepository;

    public List<RestaurantReviewDTO> getAllReviews() {
        log.debug("Lấy toàn bộ restaurant reviews");
        return reviewRepository.findAll().stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public RestaurantReviewDTO getReviewById(Integer reviewId) {
        log.debug("Lấy restaurant review theo ID: {}", reviewId);
        RestaurantReview review = reviewRepository.findById(reviewId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Review id: " + reviewId));
        return convertToDTO(review);
    }

    public List<RestaurantReviewDTO> getReviewsByRestaurant(Integer restaurantId) {
        log.debug("Lấy danh sách reviews của Restaurant ID: {}", restaurantId);
        restaurantRepository.findById(restaurantId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Restaurant id: " + restaurantId));

        List<RestaurantReview> reviews = reviewRepository.findByRestaurant_RestaurantId(restaurantId);
        log.info("Tìm thấy {} reviews của Restaurant ID: {}", reviews.size(), restaurantId);

        return reviews.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public List<RestaurantReviewDTO> getReviewsByRestaurantAndStatus(Integer restaurantId, String status) {
        log.debug("Lấy danh sách reviews của Restaurant ID: {} với status: {}", restaurantId, status);
        restaurantRepository.findById(restaurantId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Restaurant id: " + restaurantId));

        RestaurantReview.ReviewStatus reviewStatus = RestaurantReview.ReviewStatus.valueOf(status);
        List<RestaurantReview> reviews = reviewRepository.findByRestaurantAndStatus(restaurantId, reviewStatus);
        log.info("Tìm thấy {} reviews của Restaurant ID: {} với status: {}", reviews.size(), restaurantId, status);

        return reviews.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public RestaurantReviewDTO createReview(RestaurantReviewDTO dto) {
        log.debug("Tạo Review: {}", dto);

        Restaurant restaurant = restaurantRepository.findById(dto.getRestaurantId())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Restaurant id: " + dto.getRestaurantId()));

        User user = userRepository.findById(dto.getUserId())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy User id: " + dto.getUserId()));

        RestaurantReview review = RestaurantReview.builder()
                .reviewId(null)
                .restaurant(restaurant)
                .user(user)
                .rating(dto.getRating())
                .title(dto.getTitle())
                .content(dto.getContent())
                .imageUrls(dto.getImageUrls() != null ? String.join(",", dto.getImageUrls()) : null)
                .likesCount(dto.getLikesCount() != null ? dto.getLikesCount() : 0)
                .replyCount(dto.getReplyCount() != null ? dto.getReplyCount() : 0)
                .reviewStatus(dto.getReviewStatus() != null
                        ? RestaurantReview.ReviewStatus.valueOf(dto.getReviewStatus())
                        : RestaurantReview.ReviewStatus.approved)
                .build();

        RestaurantReview savedReview = reviewRepository.save(review);
        log.info("✅ Tạo Review ID: {}", savedReview.getReviewId());

        // Save aspects if provided
        if (dto.getAspects() != null) {
            RestaurantReviewAspects aspects = RestaurantReviewAspects.builder()
                    .review(savedReview)
                    .quality(dto.getAspects().getQuality())
                    .service(dto.getAspects().getService())
                    .price(dto.getAspects().getPrice())
                    .location(dto.getAspects().getLocation())
                    .ambience(dto.getAspects().getAmbience())
                    .build();
            RestaurantReviewAspects savedAspects = aspectsRepository.save(aspects);
            log.info("✅ Tạo Review Aspects cho Review ID: {}", savedAspects.getReviewId());
        }

        return convertToDTO(savedReview);
    }

    public RestaurantReviewDTO updateReview(Integer reviewId, RestaurantReviewDTO dto) {
        log.debug("Cập nhật Review ID: {}", reviewId);

        RestaurantReview review = reviewRepository.findById(reviewId)
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
            review.setReviewStatus(RestaurantReview.ReviewStatus.valueOf(dto.getReviewStatus()));

        RestaurantReview updatedReview = reviewRepository.save(review);
        log.info("✅ Cập nhật Review ID: {}", updatedReview.getReviewId());

        // Update aspects if provided
        if (dto.getAspects() != null) {
            RestaurantReviewAspects aspects = aspectsRepository.findById(reviewId)
                    .orElse(RestaurantReviewAspects.builder()
                            .reviewId(reviewId)
                            .review(updatedReview)
                            .build());

            aspects.setQuality(dto.getAspects().getQuality());
            aspects.setService(dto.getAspects().getService());
            aspects.setPrice(dto.getAspects().getPrice());
            aspects.setLocation(dto.getAspects().getLocation());
            aspects.setAmbience(dto.getAspects().getAmbience());
            aspectsRepository.save(aspects);
        }

        return convertToDTO(updatedReview);
    }

    public void deleteReview(Integer reviewId) {
        log.debug("Xóa Review ID: {}", reviewId);
        RestaurantReview review = reviewRepository.findById(reviewId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Review id: " + reviewId));

        reviewRepository.delete(review);
        log.info("✅ Đã xóa Review ID: {}", reviewId);
    }

    private RestaurantReviewDTO convertToDTO(RestaurantReview review) {
        RestaurantReviewDTO dto = RestaurantReviewDTO.builder()
                .reviewId(review.getReviewId())
                .restaurantId(review.getRestaurant().getRestaurantId())
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
            RestaurantReviewDTO.RestaurantReviewAspectsDTO aspectsDTO = RestaurantReviewDTO.RestaurantReviewAspectsDTO.builder()
                    .quality(aspects.getQuality())
                    .service(aspects.getService())
                    .price(aspects.getPrice())
                    .location(aspects.getLocation())
                    .ambience(aspects.getAmbience())
                    .build();
            dto.setAspects(aspectsDTO);
        });

        return dto;
    }

    // === REPLY METHODS ===
    public RestaurantReviewReplyDTO createRestaurantReviewReply(Integer reviewId, RestaurantReviewReplyDTO dto) {
        log.debug("Tạo reply cho Restaurant Review ID: {}", reviewId);
        
        RestaurantReview review = reviewRepository.findById(reviewId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Review id: " + reviewId));
        
        User replier = userRepository.findById(dto.getReplierId())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy User id: " + dto.getReplierId()));
        
        ReviewReply reply = ReviewReply.builder()
                .reviewType(ReviewReply.ReviewType.restaurant)
                .reviewId(reviewId)
                .replier(replier)
                .content(dto.getContent())
                .isPublic(Boolean.TRUE.equals(dto.getIsPublic()))
                .isProvider(dto.getIsProvider() == null ? 0 : dto.getIsProvider())
                .build();
        
        ReviewReply saved = reviewReplyRepository.save(reply);
        
        // Tăng reply count
        Integer currentCount = review.getReplyCount();
        review.setReplyCount(currentCount == null ? 1 : currentCount + 1);
        reviewRepository.save(review);
        
        log.info("✅ Tạo reply ID: {} cho Restaurant Review ID: {}", saved.getReplyId(), reviewId);
        return toRestaurantReviewReplyDTO(saved);
    }

    public List<RestaurantReviewReplyDTO> getRestaurantReviewReplies(Integer reviewId) {
        log.debug("Lấy danh sách replies của Restaurant Review ID: {}", reviewId);
        
        List<ReviewReply> replies = reviewReplyRepository.findByReviewTypeAndReviewIdOrderByCreatedAtDesc(
                ReviewReply.ReviewType.restaurant, reviewId);
        
        log.info("Tìm thấy {} replies của Restaurant Review ID: {}", replies.size(), reviewId);
        return replies.stream()
                .map(this::toRestaurantReviewReplyDTO)
                .collect(Collectors.toList());
    }

    private RestaurantReviewReplyDTO toRestaurantReviewReplyDTO(ReviewReply reply) {
        return RestaurantReviewReplyDTO.builder()
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
        log.info("🔄 Syncing reply counts for all restaurant reviews from review_replies table");
        
        List<RestaurantReview> allReviews = reviewRepository.findAll();
        int updated = 0;
        
        for (RestaurantReview review : allReviews) {
            int actualCount = reviewReplyRepository.countByReviewTypeAndReviewId(
                    ReviewReply.ReviewType.restaurant, review.getReviewId());
            
            Integer currentCount = review.getReplyCount();
            int countValue = currentCount != null ? currentCount : 0;
            
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
        Long count = reviewRepository.countByRestaurant_Provider_ProviderId(providerId);
        if (count == null) {
            count = 0L;
        }
        log.info("Tìm thấy {} reviews của Provider ID: {}", count, providerId);
        return count;
    }
}
