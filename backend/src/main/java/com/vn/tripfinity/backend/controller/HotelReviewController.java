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

import com.vn.tripfinity.backend.dto.HotelReviewDTO;
import com.vn.tripfinity.backend.dto.HotelReviewReplyDTO;
import com.vn.tripfinity.backend.service.HotelReviewService;
import com.vn.tripfinity.backend.service.cloudinary.CloudinaryService;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@RestController
@RequestMapping("/api/hotel-reviews")
@RequiredArgsConstructor
@Slf4j
@CrossOrigin(origins = "*")
public class HotelReviewController {

    private final HotelReviewService reviewService;
    private final CloudinaryService cloudinaryService;

    @GetMapping
    public ResponseEntity<List<HotelReviewDTO>> getAllReviews() {
        log.info("GET /api/hotel-reviews - Lấy toàn bộ reviews");
        List<HotelReviewDTO> reviews = reviewService.getAllReviews();
        return ResponseEntity.ok(reviews);
    }

    @GetMapping("/{id}")
    public ResponseEntity<HotelReviewDTO> getReviewById(@PathVariable Integer id) {
        log.info("GET /api/hotel-reviews/{} - Lấy review theo ID", id);
        HotelReviewDTO review = reviewService.getReviewById(id);
        return ResponseEntity.ok(review);
    }

    @GetMapping("/hotel/{hotelId}")
    public ResponseEntity<List<HotelReviewDTO>> getReviewsByHotel(@PathVariable Integer hotelId) {
        log.info("GET /api/hotel-reviews/hotel/{} - Lấy reviews của hotel", hotelId);
        List<HotelReviewDTO> reviews = reviewService.getReviewsByHotel(hotelId);
        return ResponseEntity.ok(reviews);
    }

    @GetMapping("/hotel/{hotelId}/status/{status}")
    public ResponseEntity<List<HotelReviewDTO>> getReviewsByHotelAndStatus(
            @PathVariable Integer hotelId,
            @PathVariable String status) {
        log.info("GET /api/hotel-reviews/hotel/{}/status/{} - Lấy reviews theo hotel và status", hotelId, status);
        List<HotelReviewDTO> reviews = reviewService.getReviewsByHotelAndStatus(hotelId, status);
        return ResponseEntity.ok(reviews);
    }

    @PostMapping
    public ResponseEntity<HotelReviewDTO> createReview(@Valid @RequestBody HotelReviewDTO dto) {
        log.info("POST /api/hotel-reviews - Tạo review mới");
        HotelReviewDTO createdReview = reviewService.createReview(dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(createdReview);
    }

    @PutMapping("/{id}")
    public ResponseEntity<HotelReviewDTO> updateReview(
            @PathVariable Integer id,
            @Valid @RequestBody HotelReviewDTO dto) {
        log.info("PUT /api/hotel-reviews/{} - Cập nhật review", id);
        HotelReviewDTO updatedReview = reviewService.updateReview(id, dto);
        return ResponseEntity.ok(updatedReview);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteReview(@PathVariable Integer id) {
        log.info("DELETE /api/hotel-reviews/{} - Xóa review", id);
        reviewService.deleteReview(id);
        return ResponseEntity.noContent().build();
    }

    // === REPLY ENDPOINTS ===
    @PostMapping("/{reviewId}/replies")
    public ResponseEntity<HotelReviewReplyDTO> createReviewReply(
            @PathVariable Integer reviewId,
            @Valid @RequestBody HotelReviewReplyDTO dto) {
        log.info("POST /api/hotel-reviews/{}/replies - Tạo reply cho review", reviewId);
        HotelReviewReplyDTO createdReply = reviewService.createHotelReviewReply(reviewId, dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(createdReply);
    }

    @GetMapping("/{reviewId}/replies")
    public ResponseEntity<List<HotelReviewReplyDTO>> getReviewReplies(@PathVariable Integer reviewId) {
        log.info("GET /api/hotel-reviews/{}/replies - Lấy danh sách replies", reviewId);
        List<HotelReviewReplyDTO> replies = reviewService.getHotelReviewReplies(reviewId);
        return ResponseEntity.ok(replies);
    }

    // === IMAGE UPLOAD ENDPOINT ===
    @PostMapping("/upload-image")
    public ResponseEntity<Map<String, String>> uploadReviewImage(@RequestParam("file") MultipartFile file) {
        log.info("POST /api/hotel-reviews/upload-image - Upload review image");
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