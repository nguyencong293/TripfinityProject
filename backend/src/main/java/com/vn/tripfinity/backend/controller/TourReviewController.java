package com.vn.tripfinity.backend.controller;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import com.vn.tripfinity.backend.dto.HotelReviewReplyDTO;
import com.vn.tripfinity.backend.dto.TourRatingSummaryDTO;
import com.vn.tripfinity.backend.dto.TourReviewDTO;
import com.vn.tripfinity.backend.service.TourReviewService;
import com.vn.tripfinity.backend.service.TourService;
import com.vn.tripfinity.backend.service.cloudinary.CloudinaryService;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@RestController
@RequestMapping("/api/tour-reviews")
@RequiredArgsConstructor
@Slf4j
@CrossOrigin(origins = "*")
public class TourReviewController {

    private final TourReviewService reviewService;
    private final TourService tourService;
    private final CloudinaryService cloudinaryService;

    @GetMapping
    public ResponseEntity<List<TourReviewDTO>> getAllReviews() {
        log.info("GET /api/tour-reviews - Lấy toàn bộ reviews");
        List<TourReviewDTO> reviews = reviewService.getAllReviews();
        return ResponseEntity.ok(reviews);
    }

    @GetMapping("/{id}")
    public ResponseEntity<TourReviewDTO> getReviewById(@PathVariable Integer id) {
        log.info("GET /api/tour-reviews/{} - Lấy review theo ID", id);
        TourReviewDTO review = reviewService.getReviewById(id);
        return ResponseEntity.ok(review);
    }

    @GetMapping("/tour/{tourId}")
    public ResponseEntity<List<TourReviewDTO>> getReviewsByTour(@PathVariable Integer tourId) {
        log.info("📥 GET /api/tour-reviews/tour/{} - Lấy reviews của tour", tourId);
        List<TourReviewDTO> reviews = reviewService.getReviewsByTour(tourId);
        log.info("📤 Trả về {} reviews cho tour {}", reviews.size(), tourId);
        if (!reviews.isEmpty()) {
            TourReviewDTO first = reviews.get(0);
            log.info("🔍 Sample review: reviewId={}, likesCount={}, replyCount={}", 
                    first.getReviewId(), first.getLikesCount(), first.getReplyCount());
        }
        return ResponseEntity.ok(reviews);
    }

    @GetMapping("/tour/{tourId}/summary")
    public ResponseEntity<TourRatingSummaryDTO> getTourRatingSummary(@PathVariable Integer tourId) {
        log.info("📥 GET /api/tour-reviews/tour/{}/summary - Lấy rating summary của tour", tourId);
        TourRatingSummaryDTO summary = tourService.calculateRatingSummary(tourId);
        log.info("📤 Trả về rating summary: avgRating={}, totalReviews={}", 
                summary.getAvgRating(), summary.getTotalReviews());
        return ResponseEntity.ok(summary);
    }

    @GetMapping("/provider/{providerId}/count")
    public ResponseEntity<Map<String, Long>> getReviewsCountByProvider(@PathVariable Integer providerId) {
        log.info("📥 GET /api/tour-reviews/provider/{}/count - Lấy tổng số reviews của provider", providerId);
        Long count = reviewService.getTotalReviewsByProvider(providerId);
        Map<String, Long> response = new HashMap<>();
        response.put("totalReviews", count);
        log.info("📤 Trả về tổng số {} reviews cho provider {}", count, providerId);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/tour/{tourId}/status/{status}")
    public ResponseEntity<List<TourReviewDTO>> getReviewsByTourAndStatus(
            @PathVariable Integer tourId,
            @PathVariable String status) {
        log.info("GET /api/tour-reviews/tour/{}/status/{} - Lấy reviews theo tour và status", tourId, status);
        List<TourReviewDTO> reviews = reviewService.getReviewsByTourAndStatus(tourId, status);
        return ResponseEntity.ok(reviews);
    }

    @PostMapping
    public ResponseEntity<TourReviewDTO> createReview(@Valid @RequestBody TourReviewDTO dto) {
        log.info("POST /api/tour-reviews - Tạo review mới");
        TourReviewDTO createdReview = reviewService.createReview(dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(createdReview);
    }

    @PutMapping("/{id}")
    public ResponseEntity<TourReviewDTO> updateReview(
            @PathVariable Integer id,
            @Valid @RequestBody TourReviewDTO dto) {
        log.info("PUT /api/tour-reviews/{} - Cập nhật review", id);
        TourReviewDTO updatedReview = reviewService.updateReview(id, dto);
        return ResponseEntity.ok(updatedReview);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteReview(@PathVariable Integer id) {
        log.info("DELETE /api/tour-reviews/{} - Xóa review", id);
        reviewService.deleteReview(id);
        return ResponseEntity.noContent().build();
    }

    // === SYNC REPLY COUNT ===
    @PostMapping("/sync-reply-counts")
    public ResponseEntity<Map<String, Object>> syncReplyCounts() {
        log.info("POST /api/tour-reviews/sync-reply-counts - Sync reply counts from review_replies");
        int updated = reviewService.syncReplyCountsFromReplies();
        Map<String, Object> response = new HashMap<>();
        response.put("updated", updated);
        response.put("message", "Synced reply counts for " + updated + " reviews");
        return ResponseEntity.ok(response);
    }

    // === REPLY ENDPOINTS ===
    @PostMapping("/{reviewId}/replies")
    public ResponseEntity<HotelReviewReplyDTO> createReviewReply(
            @PathVariable Integer reviewId,
            @Valid @RequestBody HotelReviewReplyDTO dto) {
        log.info("POST /api/tour-reviews/{}/replies - Tạo reply cho review", reviewId);
        HotelReviewReplyDTO createdReply = reviewService.createTourReviewReply(reviewId, dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(createdReply);
    }

    @GetMapping("/{reviewId}/replies")
    public ResponseEntity<List<HotelReviewReplyDTO>> getReviewReplies(@PathVariable Integer reviewId) {
        log.info("GET /api/tour-reviews/{}/replies - Lấy danh sách replies", reviewId);
        List<HotelReviewReplyDTO> replies = reviewService.getTourReviewReplies(reviewId);
        return ResponseEntity.ok(replies);
    }

    // === IMAGE UPLOAD ENDPOINT ===
    @PostMapping("/upload-image")
    public ResponseEntity<Map<String, String>> uploadReviewImage(@RequestParam("file") MultipartFile file) {
        log.info("POST /api/tour-reviews/upload-image - Upload review image");
        try {
            Map<String, Object> uploadResult = cloudinaryService.uploadImage(file);
            String imageUrl = (String) uploadResult.get("secure_url");
            
            Map<String, String> response = new HashMap<>();
            response.put("imageUrl", imageUrl);
            
            log.info("✅ Upload review image successful: {}", imageUrl);
            return ResponseEntity.ok(response);
        } catch (IOException e) {
            log.error("❌ Upload review image failed: {}", e.getMessage());
            Map<String, String> error = new HashMap<>();
            error.put("error", "Upload failed: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
        }
    }
}
