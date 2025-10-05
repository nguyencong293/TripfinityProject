package com.vn.tripfinity.backend.controller;

import com.vn.tripfinity.backend.dto.HotelVirtualTourDTO;
import com.vn.tripfinity.backend.service.HotelVirtualTourService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;

@RestController
@RequestMapping("/api/hotel-virtual-tours")
@RequiredArgsConstructor
@Slf4j
@CrossOrigin(origins = "*")
public class HotelVirtualTourController {

    private final HotelVirtualTourService virtualTourService;

    @GetMapping
    public ResponseEntity<List<HotelVirtualTourDTO>> getAllVirtualTours() {
        log.info("GET /api/hotel-virtual-tours - Lấy toàn bộ virtual tours");
        List<HotelVirtualTourDTO> virtualTours = virtualTourService.getAllVirtualTours();
        return ResponseEntity.ok(virtualTours);
    }

    @GetMapping("/{id}")
    public ResponseEntity<HotelVirtualTourDTO> getVirtualTourById(@PathVariable Integer id) {
        log.info("GET /api/hotel-virtual-tours/{} - Lấy virtual tour theo ID", id);
        HotelVirtualTourDTO virtualTour = virtualTourService.getVirtualTourById(id);
        return ResponseEntity.ok(virtualTour);
    }

    @GetMapping("/hotel/{hotelId}")
    public ResponseEntity<List<HotelVirtualTourDTO>> getVirtualToursByHotel(@PathVariable Integer hotelId) {
        log.info("GET /api/hotel-virtual-tours/hotel/{} - Lấy virtual tours của hotel", hotelId);
        List<HotelVirtualTourDTO> virtualTours = virtualTourService.getVirtualToursByHotel(hotelId);
        return ResponseEntity.ok(virtualTours);
    }

    @GetMapping("/hotel/{hotelId}/type/{mediaType}")
    public ResponseEntity<List<HotelVirtualTourDTO>> getVirtualToursByHotelAndMediaType(
            @PathVariable Integer hotelId,
            @PathVariable String mediaType) {
        log.info("GET /api/hotel-virtual-tours/hotel/{}/type/{} - Lấy virtual tours theo media type", hotelId,
                mediaType);
        List<HotelVirtualTourDTO> virtualTours = virtualTourService.getVirtualToursByHotelAndMediaType(hotelId,
                mediaType);
        return ResponseEntity.ok(virtualTours);
    }

    @PostMapping
    public ResponseEntity<HotelVirtualTourDTO> createVirtualTour(@Valid @RequestBody HotelVirtualTourDTO dto) {
        log.info("POST /api/hotel-virtual-tours - Tạo virtual tour mới");
        HotelVirtualTourDTO createdVirtualTour = virtualTourService.createVirtualTour(dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(createdVirtualTour);
    }

    @PostMapping("/hotel/{hotelId}/upload")
    public ResponseEntity<HotelVirtualTourDTO> uploadVirtualTourMedia(
            @PathVariable Integer hotelId,
            @RequestParam String mediaType,
            @RequestParam("mediaFile") MultipartFile mediaFile,
            @RequestParam(value = "thumbnailFile", required = false) MultipartFile thumbnailFile) throws IOException {
        log.info("POST /api/hotel-virtual-tours/hotel/{}/upload - Upload virtual tour media", hotelId);
        HotelVirtualTourDTO createdVirtualTour = virtualTourService.uploadVirtualTourMedia(hotelId, mediaType,
                mediaFile, thumbnailFile);
        return ResponseEntity.status(HttpStatus.CREATED).body(createdVirtualTour);
    }

    @PutMapping("/{id}")
    public ResponseEntity<HotelVirtualTourDTO> updateVirtualTour(
            @PathVariable Integer id,
            @Valid @RequestBody HotelVirtualTourDTO dto) {
        log.info("PUT /api/hotel-virtual-tours/{} - Cập nhật virtual tour", id);
        HotelVirtualTourDTO updatedVirtualTour = virtualTourService.updateVirtualTour(id, dto);
        return ResponseEntity.ok(updatedVirtualTour);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteVirtualTour(@PathVariable Integer id) throws IOException {
        log.info("DELETE /api/hotel-virtual-tours/{} - Xóa virtual tour", id);
        virtualTourService.deleteVirtualTour(id);
        return ResponseEntity.noContent().build();
    }
}