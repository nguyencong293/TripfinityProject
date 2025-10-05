package com.vn.tripfinity.backend.controller;

import com.vn.tripfinity.backend.dto.HotelReviewDTO;
import com.vn.tripfinity.backend.service.HotelReviewService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/hotel-reviews")
@RequiredArgsConstructor
@Slf4j
@CrossOrigin(origins = "*")
public class HotelReviewController {

    private final HotelReviewService reviewService;

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
}