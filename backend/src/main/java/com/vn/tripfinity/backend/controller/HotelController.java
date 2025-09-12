package com.vn.tripfinity.backend.controller;

import com.vn.tripfinity.backend.dto.HotelDTO;
import com.vn.tripfinity.backend.dto.HotelReviewDTO;
import com.vn.tripfinity.backend.dto.HotelReviewReplyDTO;
import com.vn.tripfinity.backend.sevice.HotelService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;

@RestController
@RequestMapping("/api/hotels")
@RequiredArgsConstructor
@Slf4j
@CrossOrigin(origins = "*")
public class HotelController {

    private final HotelService hotelService;

    private void requireBearer(String authorization) {
        if (authorization == null || !authorization.startsWith("Bearer ") || authorization.length() <= 7) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Missing or invalid Authorization header");
        }
    }

    @GetMapping
    public ResponseEntity<List<HotelDTO>> getAllHotels(@RequestHeader("Authorization") String authorization) {
        requireBearer(authorization);
        return ResponseEntity.ok(hotelService.getAllHotels());
    }

    @GetMapping("/{id}")
    public ResponseEntity<HotelDTO> getHotelById(@RequestHeader("Authorization") String authorization,
            @PathVariable Integer id) {
        requireBearer(authorization);
        return ResponseEntity.ok(hotelService.getHotelById(id));
    }

    @GetMapping("/provider/{providerId}")
    public ResponseEntity<List<HotelDTO>> getHotelsByProvider(@RequestHeader("Authorization") String authorization,
            @PathVariable Integer providerId) {
        requireBearer(authorization);
        return ResponseEntity.ok(hotelService.getHotelsByProviderId(providerId));
    }

    @PostMapping
    public ResponseEntity<HotelDTO> createHotel(@RequestHeader("Authorization") String authorization,
            @Valid @RequestBody HotelDTO dto) {
        requireBearer(authorization);
        HotelDTO created = hotelService.createHotel(dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @PutMapping("/{id}")
    public ResponseEntity<HotelDTO> updateHotel(@RequestHeader("Authorization") String authorization,
            @PathVariable Integer id,
            @Valid @RequestBody HotelDTO dto) {
        requireBearer(authorization);
        return ResponseEntity.ok(hotelService.updateHotel(id, dto));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteHotel(@RequestHeader("Authorization") String authorization,
            @PathVariable Integer id) {
        requireBearer(authorization);
        hotelService.deleteHotel(id);
        return ResponseEntity.noContent().build();
    }

    // ===== Reviews =====
    @PostMapping("/{id}/reviews")
    public ResponseEntity<HotelReviewDTO> createHotelReview(
            @RequestHeader("Authorization") String authorization,
            @PathVariable("id") Integer hotelId,
            @Valid @RequestBody HotelReviewDTO dto) {
        requireBearer(authorization);
        // ensure path id matches body or set it
        if (dto.getHotelId() == null)
            dto.setHotelId(hotelId);
        if (!hotelId.equals(dto.getHotelId())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "hotelId path/body không khớp");
        }
        HotelReviewDTO created = hotelService.createHotelReview(dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @GetMapping("/{id}/reviews")
    public ResponseEntity<List<HotelReviewDTO>> getHotelReviews(
            @RequestHeader("Authorization") String authorization,
            @PathVariable("id") Integer hotelId,
            @RequestParam(value = "status", required = false) String status) {
        requireBearer(authorization);
        return ResponseEntity.ok(hotelService.getHotelReviews(hotelId, status));
    }

    // ===== Review Replies =====
    @PostMapping("/reviews/{reviewId}/replies")
    public ResponseEntity<HotelReviewReplyDTO> createHotelReviewReply(
            @RequestHeader("Authorization") String authorization,
            @PathVariable Integer reviewId,
            @Valid @RequestBody HotelReviewReplyDTO dto) {
        requireBearer(authorization);
        HotelReviewReplyDTO created = hotelService.createHotelReviewReply(reviewId, dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @GetMapping("/reviews/{reviewId}/replies")
    public ResponseEntity<List<HotelReviewReplyDTO>> getHotelReviewReplies(
            @RequestHeader("Authorization") String authorization,
            @PathVariable Integer reviewId) {
        requireBearer(authorization);
        return ResponseEntity.ok(hotelService.getHotelReviewReplies(reviewId));
    }
}