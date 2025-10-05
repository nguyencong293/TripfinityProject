package com.vn.tripfinity.backend.controller;

import com.vn.tripfinity.backend.dto.HotelRatingSummaryDTO;
import com.vn.tripfinity.backend.service.HotelRatingSummaryService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/hotel-rating-summaries")
@RequiredArgsConstructor
@Slf4j
@CrossOrigin(origins = "*")
public class HotelRatingSummaryController {

    private final HotelRatingSummaryService summaryService;

    @GetMapping
    public ResponseEntity<List<HotelRatingSummaryDTO>> getAllSummaries() {
        log.info("GET /api/hotel-rating-summaries - Lấy toàn bộ rating summaries");
        List<HotelRatingSummaryDTO> summaries = summaryService.getAllSummaries();
        return ResponseEntity.ok(summaries);
    }

    @GetMapping("/hotel/{hotelId}")
    public ResponseEntity<HotelRatingSummaryDTO> getSummaryByHotelId(@PathVariable Integer hotelId) {
        log.info("GET /api/hotel-rating-summaries/hotel/{} - Lấy rating summary theo hotel ID", hotelId);
        HotelRatingSummaryDTO summary = summaryService.getSummaryByHotelId(hotelId);
        return ResponseEntity.ok(summary);
    }

    @PostMapping("/hotel/{hotelId}/calculate")
    public ResponseEntity<HotelRatingSummaryDTO> createOrUpdateSummary(@PathVariable Integer hotelId) {
        log.info("POST /api/hotel-rating-summaries/hotel/{}/calculate - Tính toán/cập nhật rating summary", hotelId);
        HotelRatingSummaryDTO summary = summaryService.createOrUpdateSummary(hotelId);
        return ResponseEntity.ok(summary);
    }

    @DeleteMapping("/hotel/{hotelId}")
    public ResponseEntity<Void> deleteSummary(@PathVariable Integer hotelId) {
        log.info("DELETE /api/hotel-rating-summaries/hotel/{} - Xóa rating summary", hotelId);
        summaryService.deleteSummary(hotelId);
        return ResponseEntity.noContent().build();
    }
    // ==================== MỚI: ENDPOINT CHO PROVIDER ====================

    /**
     * Lấy tất cả rating summaries của các hotels thuộc một provider
     * GET /api/hotel-rating-summaries/provider/{providerId}
     */
    @GetMapping("/provider/{providerId}")
    public ResponseEntity<List<HotelRatingSummaryDTO>> getSummariesByProvider(@PathVariable Integer providerId) {
        log.info("GET /api/hotel-rating-summaries/provider/{} - Lấy rating summaries của provider", providerId);
        List<HotelRatingSummaryDTO> summaries = summaryService.getSummariesByProvider(providerId);
        return ResponseEntity.ok(summaries);
    }

}