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

import com.vn.tripfinity.backend.dto.RestaurantReviewDTO;
import com.vn.tripfinity.backend.dto.RestaurantReviewReplyDTO;
import com.vn.tripfinity.backend.service.RestaurantReviewService;
import com.vn.tripfinity.backend.service.cloudinary.CloudinaryService;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@RestController
@RequestMapping("/api/restaurant-reviews")
@RequiredArgsConstructor
@Slf4j
@CrossOrigin(origins = "*")
public class RestaurantReviewController {

    private final RestaurantReviewService reviewService;
    private final CloudinaryService cloudinaryService;

    @GetMapping
    public ResponseEntity<List<RestaurantReviewDTO>> getAllReviews() {
        log.info("GET /api/restaurant-reviews - Lấy toàn bộ reviews");
        List<RestaurantReviewDTO> reviews = reviewService.getAllReviews();
        return ResponseEntity.ok(reviews);
    }

    @GetMapping("/{id}")
    public ResponseEntity<RestaurantReviewDTO> getReviewById(@PathVariable Integer id) {
        log.info("GET /api/restaurant-reviews/{} - Lấy review theo ID", id);
        RestaurantReviewDTO review = reviewService.getReviewById(id);
        return ResponseEntity.ok(review);
    }

    @GetMapping("/restaurant/{restaurantId}")
    public ResponseEntity<List<RestaurantReviewDTO>> getReviewsByRestaurant(@PathVariable Integer restaurantId) {
        log.info("📥 GET /api/restaurant-reviews/restaurant/{} - Lấy reviews của restaurant", restaurantId);
        List<RestaurantReviewDTO> reviews = reviewService.getReviewsByRestaurant(restaurantId);
        log.info("📤 Trả về {} reviews cho restaurant {}", reviews.size(), restaurantId);
        if (!reviews.isEmpty()) {
            RestaurantReviewDTO first = reviews.get(0);
            log.info("🔍 Sample review: reviewId={}, likesCount={}, replyCount={}", 
                    first.getReviewId(), first.getLikesCount(), first.getReplyCount());
        }
        return ResponseEntity.ok(reviews);
    }

    @GetMapping("/provider/{providerId}/count")
    public ResponseEntity<Map<String, Long>> getReviewsCountByProvider(@PathVariable Integer providerId) {
        log.info("📥 GET /api/restaurant-reviews/provider/{}/count - Lấy tổng số reviews của provider", providerId);
        Long count = reviewService.getTotalReviewsByProvider(providerId);
        Map<String, Long> response = new HashMap<>();
        response.put("totalReviews", count);
        log.info("📤 Trả về tổng số {} reviews cho provider {}", count, providerId);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/restaurant/{restaurantId}/status/{status}")
    public ResponseEntity<List<RestaurantReviewDTO>> getReviewsByRestaurantAndStatus(
            @PathVariable Integer restaurantId,
            @PathVariable String status) {
        log.info("GET /api/restaurant-reviews/restaurant/{}/status/{} - Lấy reviews theo restaurant và status", restaurantId, status);
        List<RestaurantReviewDTO> reviews = reviewService.getReviewsByRestaurantAndStatus(restaurantId, status);
        return ResponseEntity.ok(reviews);
    }

    @PostMapping
    public ResponseEntity<RestaurantReviewDTO> createReview(@Valid @RequestBody RestaurantReviewDTO dto) {
        log.info("POST /api/restaurant-reviews - Tạo review mới");
        RestaurantReviewDTO createdReview = reviewService.createReview(dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(createdReview);
    }

    @PutMapping("/{id}")
    public ResponseEntity<RestaurantReviewDTO> updateReview(
            @PathVariable Integer id,
            @Valid @RequestBody RestaurantReviewDTO dto) {
        log.info("PUT /api/restaurant-reviews/{} - Cập nhật review", id);
        RestaurantReviewDTO updatedReview = reviewService.updateReview(id, dto);
        return ResponseEntity.ok(updatedReview);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteReview(@PathVariable Integer id) {
        log.info("DELETE /api/restaurant-reviews/{} - Xóa review", id);
        reviewService.deleteReview(id);
        return ResponseEntity.noContent().build();
    }

    // === SYNC REPLY COUNT ===
    @PostMapping("/sync-reply-counts")
    public ResponseEntity<Map<String, Object>> syncReplyCounts() {
        log.info("POST /api/restaurant-reviews/sync-reply-counts - Sync reply counts from review_replies");
        int updated = reviewService.syncReplyCountsFromReplies();
        Map<String, Object> response = new HashMap<>();
        response.put("updated", updated);
        response.put("message", "Synced reply counts for " + updated + " reviews");
        return ResponseEntity.ok(response);
    }

    // === REPLY ENDPOINTS ===
    @PostMapping("/{reviewId}/replies")
    public ResponseEntity<RestaurantReviewReplyDTO> createReviewReply(
            @PathVariable Integer reviewId,
            @Valid @RequestBody RestaurantReviewReplyDTO dto) {
        log.info("POST /api/restaurant-reviews/{}/replies - Tạo reply cho review", reviewId);
        RestaurantReviewReplyDTO createdReply = reviewService.createRestaurantReviewReply(reviewId, dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(createdReply);
    }

    @GetMapping("/{reviewId}/replies")
    public ResponseEntity<List<RestaurantReviewReplyDTO>> getReviewReplies(@PathVariable Integer reviewId) {
        log.info("GET /api/restaurant-reviews/{}/replies - Lấy danh sách replies", reviewId);
        List<RestaurantReviewReplyDTO> replies = reviewService.getRestaurantReviewReplies(reviewId);
        return ResponseEntity.ok(replies);
    }

    // === IMAGE UPLOAD ENDPOINT ===
    @PostMapping("/upload-image")
    public ResponseEntity<Map<String, String>> uploadReviewImage(@RequestParam("file") MultipartFile file) {
        log.info("POST /api/restaurant-reviews/upload-image - Upload review image");
        try {
            Map<String, Object> uploadResult = cloudinaryService.uploadImage(file);
            String imageUrl = (String) uploadResult.get("secure_url");
            
            Map<String, String> response = new HashMap<>();
            response.put("imageUrl", imageUrl);
            
            log.info("✅ Upload review image successful: {}", imageUrl);
            return ResponseEntity.ok(response);
        } catch (IOException e) {
            log.error("Error uploading review image: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }
}
