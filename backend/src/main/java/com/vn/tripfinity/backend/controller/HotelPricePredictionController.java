package com.vn.tripfinity.backend.controller;

import com.vn.tripfinity.backend.dto.HotelPricePredictionDTO;
import com.vn.tripfinity.backend.service.HotelPricePredictionService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/api/hotel-price-predictions")
@RequiredArgsConstructor
@Slf4j
@CrossOrigin(origins = "*")
public class HotelPricePredictionController {

    private final HotelPricePredictionService predictionService;

    @GetMapping
    public ResponseEntity<List<HotelPricePredictionDTO>> getAllPredictions() {
        log.info("GET /api/hotel-price-predictions - Lấy toàn bộ price predictions");
        List<HotelPricePredictionDTO> predictions = predictionService.getAllPredictions();
        return ResponseEntity.ok(predictions);
    }

    @GetMapping("/{id}")
    public ResponseEntity<HotelPricePredictionDTO> getPredictionById(@PathVariable Integer id) {
        log.info("GET /api/hotel-price-predictions/{} - Lấy price prediction theo ID", id);
        HotelPricePredictionDTO prediction = predictionService.getPredictionById(id);
        return ResponseEntity.ok(prediction);
    }

    @GetMapping("/hotel/{hotelId}")
    public ResponseEntity<List<HotelPricePredictionDTO>> getPredictionsByHotel(@PathVariable Integer hotelId) {
        log.info("GET /api/hotel-price-predictions/hotel/{} - Lấy price predictions của hotel", hotelId);
        List<HotelPricePredictionDTO> predictions = predictionService.getPredictionsByHotel(hotelId);
        return ResponseEntity.ok(predictions);
    }

    @GetMapping("/hotel/{hotelId}/date/{date}")
    public ResponseEntity<HotelPricePredictionDTO> getPredictionByHotelAndDate(
            @PathVariable Integer hotelId,
            @PathVariable @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {
        log.info("GET /api/hotel-price-predictions/hotel/{}/date/{} - Lấy price prediction theo hotel và ngày", hotelId,
                date);
        HotelPricePredictionDTO prediction = predictionService.getPredictionByHotelAndDate(hotelId, date);
        return ResponseEntity.ok(prediction);
    }

    @GetMapping("/hotel/{hotelId}/range")
    public ResponseEntity<List<HotelPricePredictionDTO>> getPredictionsByHotelAndDateRange(
            @PathVariable Integer hotelId,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        log.info(
                "GET /api/hotel-price-predictions/hotel/{}/range?startDate={}&endDate={} - Lấy predictions theo khoảng ngày",
                hotelId, startDate, endDate);
        List<HotelPricePredictionDTO> predictions = predictionService.getPredictionsByHotelAndDateRange(hotelId,
                startDate, endDate);
        return ResponseEntity.ok(predictions);
    }

    @PostMapping
    public ResponseEntity<HotelPricePredictionDTO> createPrediction(@Valid @RequestBody HotelPricePredictionDTO dto) {
        log.info("POST /api/hotel-price-predictions - Tạo price prediction mới");
        HotelPricePredictionDTO createdPrediction = predictionService.createPrediction(dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(createdPrediction);
    }

    @PutMapping("/{id}")
    public ResponseEntity<HotelPricePredictionDTO> updatePrediction(
            @PathVariable Integer id,
            @Valid @RequestBody HotelPricePredictionDTO dto) {
        log.info("PUT /api/hotel-price-predictions/{} - Cập nhật price prediction", id);
        HotelPricePredictionDTO updatedPrediction = predictionService.updatePrediction(id, dto);
        return ResponseEntity.ok(updatedPrediction);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deletePrediction(@PathVariable Integer id) {
        log.info("DELETE /api/hotel-price-predictions/{} - Xóa price prediction", id);
        predictionService.deletePrediction(id);
        return ResponseEntity.noContent().build();
    }
}