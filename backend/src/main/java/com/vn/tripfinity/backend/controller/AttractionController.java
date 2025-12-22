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

import com.vn.tripfinity.backend.dto.AttractionDTO;
import com.vn.tripfinity.backend.dto.AttractionRatingSummaryDTO;
import com.vn.tripfinity.backend.service.AttractionService;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@RestController
@RequestMapping("/api/attractions")
@RequiredArgsConstructor
@Slf4j
@CrossOrigin(origins = "*")
public class AttractionController {

    private final AttractionService attractionService;

    private void requireBearer(String authorization) {
        if (authorization == null || !authorization.startsWith("Bearer ") || authorization.length() <= 7) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Missing or invalid Authorization header");
        }
    }

    @GetMapping
    public ResponseEntity<List<AttractionDTO>> getAll(@RequestHeader("Authorization") String authorization) {
        requireBearer(authorization);
        return ResponseEntity.ok(attractionService.getAll());
    }

    @GetMapping("/{id}")
    public ResponseEntity<AttractionDTO> getById(@RequestHeader("Authorization") String authorization,
            @PathVariable Integer id) {
        requireBearer(authorization);
        return ResponseEntity.ok(attractionService.getById(id));
    }

    @GetMapping("/provider/{providerId}")
    public ResponseEntity<List<AttractionDTO>> getByProvider(@RequestHeader("Authorization") String authorization,
            @PathVariable Integer providerId) {
        requireBearer(authorization);
        return ResponseEntity.ok(attractionService.getByProviderId(providerId));
    }

    @PostMapping
    public ResponseEntity<AttractionDTO> create(@RequestHeader("Authorization") String authorization,
            @Valid @RequestBody AttractionDTO dto) {
        requireBearer(authorization);
        AttractionDTO created = attractionService.create(dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @PutMapping("/{id}")
    public ResponseEntity<AttractionDTO> update(@RequestHeader("Authorization") String authorization,
            @PathVariable Integer id,
            @Valid @RequestBody AttractionDTO dto) {
        requireBearer(authorization);
        return ResponseEntity.ok(attractionService.update(id, dto));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@RequestHeader("Authorization") String authorization,
            @PathVariable Integer id) {
        requireBearer(authorization);
        attractionService.delete(id);
        return ResponseEntity.noContent().build();
    }

    // ==================== THUMBNAIL ENDPOINTS ====================

    @PostMapping("/{id}/thumbnail")
    public ResponseEntity<AttractionDTO> uploadThumbnail(
            @RequestHeader("Authorization") String authorization,
            @PathVariable Integer id,
            @RequestParam("file") MultipartFile file) {
        requireBearer(authorization);
        log.info("POST /api/attractions/{}/thumbnail - Uploading thumbnail", id);
        try {
            AttractionDTO updatedAttraction = attractionService.uploadThumbnail(id, file);
            return ResponseEntity.ok(updatedAttraction);
        } catch (IOException e) {
            log.error("Error uploading thumbnail for attraction {}: {}", id, e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    @DeleteMapping("/{id}/thumbnail")
    public ResponseEntity<AttractionDTO> deleteThumbnail(
            @RequestHeader("Authorization") String authorization,
            @PathVariable Integer id) {
        requireBearer(authorization);
        log.info("DELETE /api/attractions/{}/thumbnail - Deleting thumbnail", id);
        try {
            AttractionDTO updatedAttraction = attractionService.deleteThumbnail(id);
            return ResponseEntity.ok(updatedAttraction);
        } catch (IOException e) {
            log.error("Error deleting thumbnail for attraction {}: {}", id, e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    // ==================== IMAGE ENDPOINTS ====================

    @PostMapping("/{id}/images")
    public ResponseEntity<AttractionDTO> uploadImages(
            @RequestHeader("Authorization") String authorization,
            @PathVariable Integer id,
            @RequestParam("files") List<MultipartFile> files) {
        requireBearer(authorization);
        log.info("POST /api/attractions/{}/images - Uploading {} images", id, files.size());
        try {
            AttractionDTO updatedAttraction = attractionService.addImages(id, files);
            return ResponseEntity.ok(updatedAttraction);
        } catch (IOException e) {
            log.error("Error uploading images for attraction {}: {}", id, e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    @DeleteMapping("/{id}/images")
    public ResponseEntity<AttractionDTO> deleteImage(
            @RequestHeader("Authorization") String authorization,
            @PathVariable Integer id,
            @RequestParam("imageUrl") String imageUrl) {
        requireBearer(authorization);
        log.info("DELETE /api/attractions/{}/images?imageUrl={}", id, imageUrl);
        try {
            AttractionDTO updatedAttraction = attractionService.deleteImage(id, imageUrl);
            return ResponseEntity.ok(updatedAttraction);
        } catch (IOException e) {
            log.error("Error deleting image for attraction {}: {}", id, e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    // ==================== RATING SUMMARY ENDPOINT ====================
    
    @GetMapping("/{attractionId}/rating-summary")
    public ResponseEntity<AttractionRatingSummaryDTO> getRatingSummary(
            @RequestHeader("Authorization") String authorization,
            @PathVariable Integer attractionId) {
        requireBearer(authorization);
        log.info("GET /api/attractions/{}/rating-summary - Getting rating summary", attractionId);
        AttractionRatingSummaryDTO summary = attractionService.calculateRatingSummary(attractionId);
        return ResponseEntity.ok(summary);
    }
}
