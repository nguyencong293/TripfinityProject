package com.vn.tripfinity.backend.controller;

import java.io.IOException;
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
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;

import com.vn.tripfinity.backend.dto.TourDTO;
import com.vn.tripfinity.backend.dto.TourRatingSummaryDTO;
import com.vn.tripfinity.backend.dto.TourReviewDTO;
import com.vn.tripfinity.backend.dto.TourReviewReplyDTO;
import com.vn.tripfinity.backend.exception.ResourceNotFoundException;
import com.vn.tripfinity.backend.service.TourService;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@RestController
@RequestMapping("/api/tours")
@RequiredArgsConstructor
@Slf4j
@CrossOrigin(origins = "*")
public class TourController {

    private final TourService tourService;

    private void requireBearer(String authorization) {
        if (authorization == null || !authorization.startsWith("Bearer ") || authorization.length() <= 7) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Missing or invalid Authorization header");
        }
    }

    @GetMapping
    public ResponseEntity<List<TourDTO>> getAllTours(@RequestHeader("Authorization") String authorization) {
        requireBearer(authorization);
        return ResponseEntity.ok(tourService.getAllTours());
    }

    @GetMapping("/{id}")
    public ResponseEntity<TourDTO> getTourById(@RequestHeader("Authorization") String authorization,
            @PathVariable Integer id) {
        requireBearer(authorization);
        return ResponseEntity.ok(tourService.getTourById(id));
    }

    @GetMapping("/provider/{providerId}")
    public ResponseEntity<List<TourDTO>> getToursByProvider(@RequestHeader("Authorization") String authorization,
            @PathVariable Integer providerId) {
        requireBearer(authorization);
        return ResponseEntity.ok(tourService.getToursByProviderId(providerId));
    }

    @PostMapping
    public ResponseEntity<TourDTO> createTour(@RequestHeader("Authorization") String authorization,
            @Valid @RequestBody TourDTO dto) {
        requireBearer(authorization);
        TourDTO created = tourService.createTour(dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @PutMapping("/{id}")
    public ResponseEntity<TourDTO> updateTour(@RequestHeader("Authorization") String authorization,
            @PathVariable Integer id,
            @Valid @RequestBody TourDTO dto) {
        requireBearer(authorization);
        return ResponseEntity.ok(tourService.updateTour(id, dto));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteTour(@RequestHeader("Authorization") String authorization,
            @PathVariable Integer id) {
        requireBearer(authorization);
        tourService.deleteTour(id);
        return ResponseEntity.noContent().build();
    }

    // ==================== THUMBNAIL ENDPOINTS ====================

    @PostMapping("/{id}/thumbnail")
    public ResponseEntity<TourDTO> uploadThumbnail(
            @RequestHeader("Authorization") String authorization,
            @PathVariable Integer id,
            @RequestParam("file") MultipartFile file) {
        requireBearer(authorization);
        log.info("POST /api/tours/{}/thumbnail - Uploading thumbnail", id);
        try {
            TourDTO updatedTour = tourService.uploadThumbnail(id, file);
            return ResponseEntity.ok(updatedTour);
        } catch (ResourceNotFoundException | IOException e) {
            log.error("Error uploading thumbnail for tour {}: {}", id, e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    @DeleteMapping("/{id}/thumbnail")
    public ResponseEntity<TourDTO> deleteThumbnail(
            @RequestHeader("Authorization") String authorization,
            @PathVariable Integer id) {
        requireBearer(authorization);
        log.info("DELETE /api/tours/{}/thumbnail - Deleting thumbnail", id);
        try {
            TourDTO updatedTour = tourService.deleteThumbnail(id);
            return ResponseEntity.ok(updatedTour);
        } catch (ResourceNotFoundException | IOException e) {
            log.error("Error deleting thumbnail for tour {}: {}", id, e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    // ==================== IMAGES ENDPOINTS ====================

    @PostMapping("/{id}/images")
    public ResponseEntity<TourDTO> addImages(
            @RequestHeader("Authorization") String authorization,
            @PathVariable Integer id,
            @RequestParam("files") List<MultipartFile> files) {
        requireBearer(authorization);
        log.info("POST /api/tours/{}/images - Adding {} images", id, files.size());
        try {
            TourDTO updatedTour = tourService.addImages(id, files);
            return ResponseEntity.ok(updatedTour);
        } catch (ResourceNotFoundException | IOException e) {
            log.error("Error adding images for tour {}: {}", id, e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    @DeleteMapping("/{id}/images")
    public ResponseEntity<TourDTO> deleteImage(
            @RequestHeader("Authorization") String authorization,
            @PathVariable Integer id,
            @RequestParam("imageUrl") String imageUrl) {
        requireBearer(authorization);
        log.info("DELETE /api/tours/{}/images - Deleting image: {}", id, imageUrl);
        try {
            TourDTO updatedTour = tourService.deleteImage(id, imageUrl);
            return ResponseEntity.ok(updatedTour);
        } catch (ResourceNotFoundException | IOException e) {
            log.error("Error deleting image for tour {}: {}", id, e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    @DeleteMapping("/{id}/images/all")
    public ResponseEntity<TourDTO> deleteAllImages(
            @RequestHeader("Authorization") String authorization,
            @PathVariable Integer id) {
        requireBearer(authorization);
        log.info("DELETE /api/tours/{}/images/all - Deleting all images", id);
        try {
            TourDTO updatedTour = tourService.deleteAllImages(id);
            return ResponseEntity.ok(updatedTour);
        } catch (ResourceNotFoundException | IOException e) {
            log.error("Error deleting all images for tour {}: {}", id, e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    // ========= Reviews =========
    @PostMapping("/{id}/reviews")
    public ResponseEntity<TourReviewDTO> createTourReview(
            @RequestHeader("Authorization") String authorization,
            @PathVariable("id") Integer id,
            @Valid @RequestBody TourReviewDTO dto) {
        requireBearer(authorization);
        dto.setTourId(id);
        TourReviewDTO created = tourService.createTourReview(dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @GetMapping("/{id}/reviews")
    public ResponseEntity<List<TourReviewDTO>> getTourReviews(
            @RequestHeader("Authorization") String authorization,
            @PathVariable("id") Integer id,
            @RequestParam(value = "status", required = false) String status) {
        requireBearer(authorization);
        return ResponseEntity.ok(tourService.getTourReviews(id, status));
    }

    // ===== Review Replies =====
    @PostMapping("/reviews/{reviewId}/replies")
    public ResponseEntity<TourReviewReplyDTO> createTourReviewReply(
            @RequestHeader("Authorization") String authorization,
            @PathVariable Integer reviewId,
            @Valid @RequestBody TourReviewReplyDTO dto) {
        requireBearer(authorization);
        TourReviewReplyDTO created = tourService.createTourReviewReply(reviewId, dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @GetMapping("/reviews/{reviewId}/replies")
    public ResponseEntity<List<TourReviewReplyDTO>> getTourReviewReplies(
            @RequestHeader("Authorization") String authorization,
            @PathVariable Integer reviewId) {
        requireBearer(authorization);
        return ResponseEntity.ok(tourService.getTourReviewReplies(reviewId));
    }

    // ==================== RATING SUMMARY ENDPOINT ====================
    @GetMapping("/{tourId}/rating-summary")
    public ResponseEntity<TourRatingSummaryDTO> getRatingSummary(
            @RequestHeader("Authorization") String authorization,
            @PathVariable Integer tourId) {
        requireBearer(authorization);
        log.info("GET /api/tours/{}/rating-summary - Getting rating summary", tourId);
        TourRatingSummaryDTO summary = tourService.calculateRatingSummary(tourId);
        return ResponseEntity.ok(summary);
    }
}
