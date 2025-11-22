package com.vn.tripfinity.backend.service;

import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.vn.tripfinity.backend.dto.HotelReviewDTO;
import com.vn.tripfinity.backend.dto.HotelReviewReplyDTO;
import com.vn.tripfinity.backend.exception.ResourceNotFoundException;
import com.vn.tripfinity.backend.model.Hotel;
import com.vn.tripfinity.backend.model.HotelReview;
import com.vn.tripfinity.backend.model.HotelReviewAspects;
import com.vn.tripfinity.backend.model.ReviewReply;
import com.vn.tripfinity.backend.model.User;
import com.vn.tripfinity.backend.repository.HotelRepository;
import com.vn.tripfinity.backend.repository.HotelReviewAspectsRepository;
import com.vn.tripfinity.backend.repository.HotelReviewRepository;
import com.vn.tripfinity.backend.repository.ReviewReplyRepository;
import com.vn.tripfinity.backend.repository.UserRepository;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class HotelReviewService {

    private final HotelReviewRepository reviewRepository;
    private final HotelReviewAspectsRepository aspectsRepository;
    private final HotelRepository hotelRepository;
    private final UserRepository userRepository;
    private final ReviewReplyRepository reviewReplyRepository;

    public List<HotelReviewDTO> getAllReviews() {
        log.debug("Lấy toàn bộ hotel reviews");
        return reviewRepository.findAll().stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public HotelReviewDTO getReviewById(Integer reviewId) {
        log.debug("Lấy hotel review theo ID: {}", reviewId);
        HotelReview review = reviewRepository.findById(reviewId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Review id: " + reviewId));
        return convertToDTO(review);
    }

    public List<HotelReviewDTO> getReviewsByHotel(Integer hotelId) {
        log.debug("Lấy danh sách reviews của Hotel ID: {}", hotelId);
        hotelRepository.findById(hotelId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Hotel id: " + hotelId));

        List<HotelReview> reviews = reviewRepository.findByHotel_HotelId(hotelId);
        log.info("Tìm thấy {} reviews của Hotel ID: {}", reviews.size(), hotelId);

        return reviews.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public List<HotelReviewDTO> getReviewsByHotelAndStatus(Integer hotelId, String status) {
        log.debug("Lấy danh sách reviews của Hotel ID: {} với status: {}", hotelId, status);
        hotelRepository.findById(hotelId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Hotel id: " + hotelId));

        HotelReview.ReviewStatus reviewStatus = HotelReview.ReviewStatus.valueOf(status);
        List<HotelReview> reviews = reviewRepository.findByHotelAndStatus(hotelId, reviewStatus);
        log.info("Tìm thấy {} reviews của Hotel ID: {} với status: {}", reviews.size(), hotelId, status);

        return reviews.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public HotelReviewDTO createReview(HotelReviewDTO dto) {
        log.debug("Tạo Review: {}", dto);

        Hotel hotel = hotelRepository.findById(dto.getHotelId())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Hotel id: " + dto.getHotelId()));

        User user = userRepository.findById(dto.getUserId())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy User id: " + dto.getUserId()));

        HotelReview review = HotelReview.builder()
                .reviewId(null)
                .hotel(hotel)
                .user(user)
                .rating(dto.getRating() != null ? dto.getRating() : 0)
                .title(dto.getTitle())
                .content(dto.getContent())
                .imageUrls(dto.getImageUrls() != null ? String.join(",", dto.getImageUrls()) : null)
                .likesCount(dto.getLikesCount() != null ? dto.getLikesCount() : 0)
                .replyCount(dto.getReplyCount() != null ? dto.getReplyCount() : 0)
                .reviewStatus(dto.getReviewStatus() != null
                        ? HotelReview.ReviewStatus.valueOf(dto.getReviewStatus())
                        : HotelReview.ReviewStatus.approved)
                .build();

        HotelReview savedReview = reviewRepository.save(review);
        log.info("✅ Tạo Review ID: {}", savedReview.getReviewId());

        // Save aspects if provided
        if (dto.getAspects() != null) {
            HotelReviewAspects aspects = HotelReviewAspects.builder()
                    .review(savedReview) // Only set review, reviewId will be auto-mapped via @MapsId
                    .cleanliness(dto.getAspects().getCleanliness())
                    .service(dto.getAspects().getService())
                    .valueForMoney(dto.getAspects().getValueForMoney())
                    .location(dto.getAspects().getLocation())
                    .facilities(dto.getAspects().getFacilities())
                    .build();
            HotelReviewAspects savedAspects = aspectsRepository.save(aspects);
            log.info("✅ Tạo Review Aspects cho Review ID: {}", savedAspects.getReviewId());
        }

        return convertToDTO(savedReview);
    }

    public HotelReviewDTO updateReview(Integer reviewId, HotelReviewDTO dto) {
        log.debug("Cập nhật Review ID: {}", reviewId);

        HotelReview review = reviewRepository.findById(reviewId)
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
            review.setReviewStatus(HotelReview.ReviewStatus.valueOf(dto.getReviewStatus()));

        HotelReview updatedReview = reviewRepository.save(review);
        log.info("✅ Cập nhật Review ID: {}", updatedReview.getReviewId());

        // Update aspects if provided
        if (dto.getAspects() != null) {
            HotelReviewAspects aspects = aspectsRepository.findById(reviewId)
                    .orElse(HotelReviewAspects.builder()
                            .reviewId(reviewId)
                            .review(updatedReview)
                            .build());

            aspects.setCleanliness(dto.getAspects().getCleanliness());
            aspects.setService(dto.getAspects().getService());
            aspects.setValueForMoney(dto.getAspects().getValueForMoney());
            aspects.setLocation(dto.getAspects().getLocation());
            aspects.setFacilities(dto.getAspects().getFacilities());
            aspectsRepository.save(aspects);
        }

        return convertToDTO(updatedReview);
    }

    public void deleteReview(Integer reviewId) {
        log.debug("Xóa Review ID: {}", reviewId);
        HotelReview review = reviewRepository.findById(reviewId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Review id: " + reviewId));

        reviewRepository.delete(review);
        log.info("✅ Đã xóa Review ID: {}", reviewId);
    }

    private HotelReviewDTO convertToDTO(HotelReview review) {
        HotelReviewDTO dto = HotelReviewDTO.builder()
                .reviewId(review.getReviewId())
                .hotelId(review.getHotel().getHotelId())
                .userId(review.getUser().getUserId())
                .userName(review.getUser().getFullName()) // Add user name
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
            HotelReviewDTO.HotelReviewAspectsDTO aspectsDTO = HotelReviewDTO.HotelReviewAspectsDTO.builder()
                    .cleanliness(aspects.getCleanliness())
                    .service(aspects.getService())
                    .valueForMoney(aspects.getValueForMoney())
                    .location(aspects.getLocation())
                    .facilities(aspects.getFacilities())
                    .build();
            dto.setAspects(aspectsDTO);
        });

        return dto;
    }

    // === REPLY METHODS ===
    public HotelReviewReplyDTO createHotelReviewReply(Integer reviewId, HotelReviewReplyDTO dto) {
        log.debug("Tạo reply cho Hotel Review ID: {}", reviewId);
        
        HotelReview review = reviewRepository.findById(reviewId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy Review id: " + reviewId));
        
        User replier = userRepository.findById(dto.getReplierId())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy User id: " + dto.getReplierId()));
        
        ReviewReply reply = ReviewReply.builder()
                .reviewType(ReviewReply.ReviewType.hotel)
                .reviewId(reviewId)
                .replier(replier)
                .content(dto.getContent())
                .isPublic(Boolean.TRUE.equals(dto.getIsPublic()))
                .isProvider(dto.getIsProvider() != null ? dto.getIsProvider() : 0)
                .build();
        
        ReviewReply saved = reviewReplyRepository.save(reply);
        
        // Tăng reply count
        Integer currentCount = review.getReplyCount();
        review.setReplyCount(currentCount == null ? 1 : currentCount + 1);
        reviewRepository.save(review);
        
        log.info("✅ Tạo reply ID: {} cho Hotel Review ID: {}", saved.getReplyId(), reviewId);
        return toHotelReviewReplyDTO(saved);
    }

    public List<HotelReviewReplyDTO> getHotelReviewReplies(Integer reviewId) {
        log.debug("Lấy danh sách replies của Hotel Review ID: {}", reviewId);
        
        List<ReviewReply> replies = reviewReplyRepository.findByReviewTypeAndReviewIdOrderByCreatedAtDesc(
                ReviewReply.ReviewType.hotel, reviewId);
        
        log.info("Tìm thấy {} replies của Hotel Review ID: {}", replies.size(), reviewId);
        return replies.stream()
                .map(this::toHotelReviewReplyDTO)
                .collect(Collectors.toList());
    }

    private HotelReviewReplyDTO toHotelReviewReplyDTO(ReviewReply reply) {
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
        log.info("🔄 Syncing reply counts for all hotel reviews from review_replies table");
        
        List<HotelReview> allReviews = reviewRepository.findAll();
        int updated = 0;
        
        for (HotelReview review : allReviews) {
            int actualCount = reviewReplyRepository.countByReviewTypeAndReviewId(
                    ReviewReply.ReviewType.hotel, review.getReviewId());
            
            Integer currentCount = review.getReplyCount() != null ? review.getReplyCount() : 0;
            
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
}