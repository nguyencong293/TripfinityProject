package com.vn.tripfinity.backend.controller;

import com.vn.tripfinity.backend.dto.HotelDTO;
import com.vn.tripfinity.backend.service.HotelService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@RestController
@RequestMapping("/api/hotels")
@RequiredArgsConstructor
@Slf4j
@CrossOrigin(origins = "*")
public class HotelController {
    private final HotelService hotelService;

    @GetMapping
    public ResponseEntity<List<HotelDTO>> getAllHotels() {
        log.info("GET /api/hotels - Getting all hotels");
        List<HotelDTO> hotels = hotelService.getAllHotels();
        return ResponseEntity.ok(hotels);
    }

    @GetMapping("/{hotelId}")
    public ResponseEntity<HotelDTO> getHotelById(@PathVariable Integer hotelId) {
        log.info("GET /api/hotels/{} - Getting hotel by ID", hotelId);
        HotelDTO hotel = hotelService.getHotelById(hotelId);
        return ResponseEntity.ok(hotel);
    }

    @GetMapping("/provider/{providerId}")
    public ResponseEntity<List<HotelDTO>> getHotelsByProvider(@PathVariable Integer providerId) {
        log.info("GET /api/hotels/provider/{} - Getting hotels by provider", providerId);
        List<HotelDTO> hotels = hotelService.getHotelsByProvider(providerId);
        return ResponseEntity.ok(hotels);
    }

    @GetMapping("/provider/{providerId}/status/{status}")
    public ResponseEntity<List<HotelDTO>> getHotelsByProviderAndStatus(
            @PathVariable Integer providerId,
            @PathVariable String status) {
        log.info("GET /api/hotels/provider/{}/status/{} - Getting hotels by provider and status",
                providerId, status);
        List<HotelDTO> hotels = hotelService.getHotelsByProviderAndStatus(providerId, status);
        return ResponseEntity.ok(hotels);
    }

    @GetMapping("/area/{areaId}")
    public ResponseEntity<List<HotelDTO>> getHotelsByArea(@PathVariable Integer areaId) {
        log.info("GET /api/hotels/area/{} - Getting hotels by area", areaId);
        List<HotelDTO> hotels = hotelService.getHotelsByArea(areaId);
        return ResponseEntity.ok(hotels);
    }

    @GetMapping("/slug/{slug}")
    public ResponseEntity<HotelDTO> getHotelBySlug(@PathVariable String slug) {
        log.info("GET /api/hotels/slug/{} - Getting hotel by slug", slug);
        HotelDTO hotel = hotelService.getHotelBySlug(slug);
        return ResponseEntity.ok(hotel);
    }

    @PostMapping
    public ResponseEntity<HotelDTO> createHotel(@Valid @RequestBody HotelDTO hotelDTO) {
        log.info("POST /api/hotels - Creating hotel");
        HotelDTO createdHotel = hotelService.createHotel(hotelDTO);
        return ResponseEntity.status(HttpStatus.CREATED).body(createdHotel);
    }

    @PutMapping("/{hotelId}")
    public ResponseEntity<HotelDTO> updateHotel(
            @PathVariable Integer hotelId,
            @Valid @RequestBody HotelDTO hotelDTO) {
        log.info("PUT /api/hotels/{} - Updating hotel", hotelId);
        HotelDTO updatedHotel = hotelService.updateHotel(hotelId, hotelDTO);
        return ResponseEntity.ok(updatedHotel);
    }

    @DeleteMapping("/{hotelId}")
    public ResponseEntity<Void> deleteHotel(@PathVariable Integer hotelId) {
        log.info("DELETE /api/hotels/{} - Deleting hotel", hotelId);
        hotelService.deleteHotel(hotelId);
        return ResponseEntity.noContent().build();
    }

    // ==================== THUMBNAIL ENDPOINTS ====================

    @PostMapping("/{hotelId}/thumbnail")
    public ResponseEntity<HotelDTO> uploadThumbnail(
            @PathVariable Integer hotelId,
            @RequestParam("file") MultipartFile file) {
        log.info("POST /api/hotels/{}/thumbnail - Uploading thumbnail", hotelId);
        try {
            HotelDTO updatedHotel = hotelService.uploadThumbnail(hotelId, file);
            return ResponseEntity.ok(updatedHotel);
        } catch (Exception e) {
            log.error("Error uploading thumbnail for hotel {}: {}", hotelId, e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    @DeleteMapping("/{hotelId}/thumbnail")
    public ResponseEntity<HotelDTO> deleteThumbnail(@PathVariable Integer hotelId) {
        log.info("DELETE /api/hotels/{}/thumbnail - Deleting thumbnail", hotelId);
        try {
            HotelDTO updatedHotel = hotelService.deleteThumbnail(hotelId);
            return ResponseEntity.ok(updatedHotel);
        } catch (Exception e) {
            log.error("Error deleting thumbnail for hotel {}: {}", hotelId, e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    // ==================== IMAGES ENDPOINTS ====================

    @PostMapping("/{hotelId}/images")
    public ResponseEntity<HotelDTO> addImages(
            @PathVariable Integer hotelId,
            @RequestParam("files") List<MultipartFile> files) {
        log.info("POST /api/hotels/{}/images - Adding {} images", hotelId, files.size());
        try {
            HotelDTO updatedHotel = hotelService.addImages(hotelId, files);
            return ResponseEntity.ok(updatedHotel);
        } catch (Exception e) {
            log.error("Error adding images for hotel {}: {}", hotelId, e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    @DeleteMapping("/{hotelId}/images")
    public ResponseEntity<HotelDTO> deleteImage(
            @PathVariable Integer hotelId,
            @RequestParam("imageUrl") String imageUrl) {
        log.info("DELETE /api/hotels/{}/images - Deleting image: {}", hotelId, imageUrl);
        try {
            HotelDTO updatedHotel = hotelService.deleteImage(hotelId, imageUrl);
            return ResponseEntity.ok(updatedHotel);
        } catch (Exception e) {
            log.error("Error deleting image for hotel {}: {}", hotelId, e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    @DeleteMapping("/{hotelId}/images/all")
    public ResponseEntity<HotelDTO> deleteAllImages(@PathVariable Integer hotelId) {
        log.info("DELETE /api/hotels/{}/images/all - Deleting all images", hotelId);
        try {
            HotelDTO updatedHotel = hotelService.deleteAllImages(hotelId);
            return ResponseEntity.ok(updatedHotel);
        } catch (Exception e) {
            log.error("Error deleting all images for hotel {}: {}", hotelId, e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }
}