package com.vn.tripfinity.backend.controller;

import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

import com.vn.tripfinity.backend.dto.RestaurantDTO;
import com.vn.tripfinity.backend.dto.RestaurantRatingSummaryDTO;
import com.vn.tripfinity.backend.dto.RestaurantReviewDTO;
import com.vn.tripfinity.backend.dto.RestaurantReviewReplyDTO;
import com.vn.tripfinity.backend.service.RestaurantService;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@RestController
@RequestMapping("/api/restaurants")
@RequiredArgsConstructor
@Slf4j
@CrossOrigin(origins = "*")
public class RestaurantController {

    private final RestaurantService restaurantService;

    private void requireBearer(String authorization) {
        if (authorization == null || !authorization.startsWith("Bearer ") || authorization.length() <= 7) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Missing or invalid Authorization header");
        }
    }

    @GetMapping
    public ResponseEntity<List<RestaurantDTO>> getAllRestaurants(@RequestHeader("Authorization") String authorization) {
        requireBearer(authorization);
        return ResponseEntity.ok(restaurantService.getAllRestaurants());
    }

    @GetMapping("/{id}")
    public ResponseEntity<RestaurantDTO> getRestaurantById(@RequestHeader("Authorization") String authorization,
            @PathVariable Integer id) {
        requireBearer(authorization);
        return ResponseEntity.ok(restaurantService.getRestaurantById(id));
    }

    @GetMapping("/provider/{providerId}")
    public ResponseEntity<List<RestaurantDTO>> getRestaurantsByProvider(
            @RequestHeader("Authorization") String authorization,
            @PathVariable Integer providerId) {
        requireBearer(authorization);
        return ResponseEntity.ok(restaurantService.getRestaurantsByProviderId(providerId));
    }

    @PostMapping
    public ResponseEntity<RestaurantDTO> createRestaurant(@RequestHeader("Authorization") String authorization,
            @Valid @RequestBody RestaurantDTO dto) {
        requireBearer(authorization);
        RestaurantDTO created = restaurantService.createRestaurant(dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @PutMapping("/{id}")
    public ResponseEntity<RestaurantDTO> updateRestaurant(@RequestHeader("Authorization") String authorization,
            @PathVariable Integer id,
            @Valid @RequestBody RestaurantDTO dto) {
        requireBearer(authorization);
        return ResponseEntity.ok(restaurantService.updateRestaurant(id, dto));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteRestaurant(@RequestHeader("Authorization") String authorization,
            @PathVariable Integer id) {
        requireBearer(authorization);
        restaurantService.deleteRestaurant(id);
        return ResponseEntity.noContent().build();
    }

    // ========= Reviews =========
    @PostMapping("/{id}/reviews")
    public ResponseEntity<RestaurantReviewDTO> createRestaurantReview(
            @RequestHeader("Authorization") String authorization,
            @PathVariable("id") Integer id,
            @Valid @RequestBody RestaurantReviewDTO dto) {
        requireBearer(authorization);
        dto.setRestaurantId(id);
        RestaurantReviewDTO created = restaurantService.createRestaurantReview(dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @GetMapping("/{id}/reviews")
    public ResponseEntity<List<RestaurantReviewDTO>> getRestaurantReviews(
            @RequestHeader("Authorization") String authorization,
            @PathVariable("id") Integer id,
            @RequestParam(value = "status", required = false) String status) {
        requireBearer(authorization);
        return ResponseEntity.ok(restaurantService.getRestaurantReviews(id, status));
    }

    // ===== Review Replies =====
    @PostMapping("/reviews/{reviewId}/replies")
    public ResponseEntity<RestaurantReviewReplyDTO> createRestaurantReviewReply(
            @RequestHeader("Authorization") String authorization,
            @PathVariable("reviewId") Integer reviewId,
            @Valid @RequestBody RestaurantReviewReplyDTO dto) {
        requireBearer(authorization);
        RestaurantReviewReplyDTO created = restaurantService.createRestaurantReviewReply(reviewId, dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @GetMapping("/reviews/{reviewId}/replies")
    public ResponseEntity<List<RestaurantReviewReplyDTO>> getRestaurantReviewReplies(
            @RequestHeader("Authorization") String authorization,
            @PathVariable("reviewId") Integer reviewId) {
        requireBearer(authorization);
        return ResponseEntity.ok(restaurantService.getRestaurantReviewReplies(reviewId));
    }

    // ==================== RATING SUMMARY ENDPOINT ====================
    @GetMapping("/{restaurantId}/rating-summary")
    public ResponseEntity<RestaurantRatingSummaryDTO> getRatingSummary(
            @RequestHeader("Authorization") String authorization,
            @PathVariable Integer restaurantId) {
        requireBearer(authorization);
        log.info("GET /api/restaurants/{}/rating-summary - Getting rating summary", restaurantId);
        RestaurantRatingSummaryDTO summary = restaurantService.calculateRatingSummary(restaurantId);
        return ResponseEntity.ok(summary);
    }
}
