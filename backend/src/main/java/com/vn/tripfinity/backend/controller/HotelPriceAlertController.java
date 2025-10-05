package com.vn.tripfinity.backend.controller;

import com.vn.tripfinity.backend.dto.HotelPriceAlertDTO;
import com.vn.tripfinity.backend.service.HotelPriceAlertService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.List;

@RestController
@RequestMapping("/api/hotel-price-alerts")
@RequiredArgsConstructor
@Slf4j
@CrossOrigin(origins = "*")
public class HotelPriceAlertController {

    private final HotelPriceAlertService alertService;

    @GetMapping
    public ResponseEntity<List<HotelPriceAlertDTO>> getAllAlerts() {
        log.info("GET /api/hotel-price-alerts - Lấy toàn bộ price alerts");
        List<HotelPriceAlertDTO> alerts = alertService.getAllAlerts();
        return ResponseEntity.ok(alerts);
    }

    @GetMapping("/{id}")
    public ResponseEntity<HotelPriceAlertDTO> getAlertById(@PathVariable Integer id) {
        log.info("GET /api/hotel-price-alerts/{} - Lấy price alert theo ID", id);
        HotelPriceAlertDTO alert = alertService.getAlertById(id);
        return ResponseEntity.ok(alert);
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<List<HotelPriceAlertDTO>> getAlertsByUser(@PathVariable Integer userId) {
        log.info("GET /api/hotel-price-alerts/user/{} - Lấy price alerts của user", userId);
        List<HotelPriceAlertDTO> alerts = alertService.getAlertsByUser(userId);
        return ResponseEntity.ok(alerts);
    }

    @GetMapping("/hotel/{hotelId}")
    public ResponseEntity<List<HotelPriceAlertDTO>> getAlertsByHotel(@PathVariable Integer hotelId) {
        log.info("GET /api/hotel-price-alerts/hotel/{} - Lấy price alerts của hotel", hotelId);
        List<HotelPriceAlertDTO> alerts = alertService.getAlertsByHotel(hotelId);
        return ResponseEntity.ok(alerts);
    }

    @GetMapping("/user/{userId}/active")
    public ResponseEntity<List<HotelPriceAlertDTO>> getActiveAlertsByUser(@PathVariable Integer userId) {
        log.info("GET /api/hotel-price-alerts/user/{}/active - Lấy active price alerts của user", userId);
        List<HotelPriceAlertDTO> alerts = alertService.getActiveAlertsByUser(userId);
        return ResponseEntity.ok(alerts);
    }

    @GetMapping("/hotel/{hotelId}/check")
    public ResponseEntity<List<HotelPriceAlertDTO>> checkTriggeredAlerts(
            @PathVariable Integer hotelId,
            @RequestParam BigDecimal currentPrice) {
        log.info("GET /api/hotel-price-alerts/hotel/{}/check?currentPrice={} - Kiểm tra alerts được kích hoạt", hotelId,
                currentPrice);
        List<HotelPriceAlertDTO> triggeredAlerts = alertService.checkAndGetTriggeredAlerts(hotelId, currentPrice);
        return ResponseEntity.ok(triggeredAlerts);
    }

    @PostMapping
    public ResponseEntity<HotelPriceAlertDTO> createAlert(@Valid @RequestBody HotelPriceAlertDTO dto) {
        log.info("POST /api/hotel-price-alerts - Tạo price alert mới");
        HotelPriceAlertDTO createdAlert = alertService.createAlert(dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(createdAlert);
    }

    @PutMapping("/{id}")
    public ResponseEntity<HotelPriceAlertDTO> updateAlert(
            @PathVariable Integer id,
            @Valid @RequestBody HotelPriceAlertDTO dto) {
        log.info("PUT /api/hotel-price-alerts/{} - Cập nhật price alert", id);
        HotelPriceAlertDTO updatedAlert = alertService.updateAlert(id, dto);
        return ResponseEntity.ok(updatedAlert);
    }

    @PatchMapping("/{id}/toggle")
    public ResponseEntity<HotelPriceAlertDTO> toggleAlertStatus(@PathVariable Integer id) {
        log.info("PATCH /api/hotel-price-alerts/{}/toggle - Toggle alert status", id);
        HotelPriceAlertDTO updatedAlert = alertService.toggleAlertStatus(id);
        return ResponseEntity.ok(updatedAlert);
    }

    @PatchMapping("/{id}/notified")
    public ResponseEntity<HotelPriceAlertDTO> markAsNotified(@PathVariable Integer id) {
        log.info("PATCH /api/hotel-price-alerts/{}/notified - Đánh dấu đã thông báo", id);
        HotelPriceAlertDTO updatedAlert = alertService.markAsNotified(id);
        return ResponseEntity.ok(updatedAlert);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteAlert(@PathVariable Integer id) {
        log.info("DELETE /api/hotel-price-alerts/{} - Xóa price alert", id);
        alertService.deleteAlert(id);
        return ResponseEntity.noContent().build();
    }

    /**
     * Lấy tất cả price alerts của các hotels thuộc một provider
     * GET /api/hotel-price-alerts/provider/{providerId}
     */
    @GetMapping("/provider/{providerId}")
    public ResponseEntity<List<HotelPriceAlertDTO>> getAlertsByProvider(@PathVariable Integer providerId) {
        log.info("GET /api/hotel-price-alerts/provider/{} - Lấy price alerts của provider", providerId);
        List<HotelPriceAlertDTO> alerts = alertService.getAlertsByProvider(providerId);
        return ResponseEntity.ok(alerts);
    }

    /**
     * Lấy active price alerts của các hotels thuộc một provider
     * GET /api/hotel-price-alerts/provider/{providerId}/active
     */
    @GetMapping("/provider/{providerId}/active")
    public ResponseEntity<List<HotelPriceAlertDTO>> getActiveAlertsByProvider(@PathVariable Integer providerId) {
        log.info("GET /api/hotel-price-alerts/provider/{}/active - Lấy active price alerts của provider", providerId);
        List<HotelPriceAlertDTO> alerts = alertService.getActiveAlertsByProvider(providerId);
        return ResponseEntity.ok(alerts);
    }
}