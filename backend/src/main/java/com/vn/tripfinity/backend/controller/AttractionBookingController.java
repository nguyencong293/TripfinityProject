package com.vn.tripfinity.backend.controller;

import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.vn.tripfinity.backend.dto.AttractionBookingDTO;
import com.vn.tripfinity.backend.service.AttractionBookingService;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@RestController
@RequestMapping("/api/attraction-bookings")
@RequiredArgsConstructor
@Slf4j
@CrossOrigin(origins = "*")
public class AttractionBookingController {

    private final AttractionBookingService bookingService;

    @GetMapping
    public ResponseEntity<List<AttractionBookingDTO>> getAllBookings() {
        log.info("GET /api/attraction-bookings - Lấy toàn bộ bookings");
        List<AttractionBookingDTO> bookings = bookingService.getAllBookings();
        return ResponseEntity.ok(bookings);
    }

    @GetMapping("/{id}")
    public ResponseEntity<AttractionBookingDTO> getBookingById(@PathVariable Integer id) {
        log.info("GET /api/attraction-bookings/{} - Lấy booking theo ID", id);
        AttractionBookingDTO booking = bookingService.getBookingById(id);
        return ResponseEntity.ok(booking);
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<List<AttractionBookingDTO>> getBookingsByUser(@PathVariable Integer userId) {
        log.info("GET /api/attraction-bookings/user/{} - Lấy bookings của user", userId);
        List<AttractionBookingDTO> bookings = bookingService.getBookingsByUser(userId);
        return ResponseEntity.ok(bookings);
    }

    @GetMapping("/attraction/{attractionId}")
    public ResponseEntity<List<AttractionBookingDTO>> getBookingsByAttraction(@PathVariable Integer attractionId) {
        log.info("GET /api/attraction-bookings/attraction/{} - Lấy bookings của attraction", attractionId);
        List<AttractionBookingDTO> bookings = bookingService.getBookingsByAttraction(attractionId);
        return ResponseEntity.ok(bookings);
    }

    @GetMapping("/provider/{providerId}")
    public ResponseEntity<List<AttractionBookingDTO>> getBookingsByProvider(@PathVariable Integer providerId) {
        log.info("GET /api/attraction-bookings/provider/{} - Lấy bookings của provider", providerId);
        List<AttractionBookingDTO> bookings = bookingService.getBookingsByProvider(providerId);
        return ResponseEntity.ok(bookings);
    }

    @GetMapping("/user/{userId}/status/{status}")
    public ResponseEntity<List<AttractionBookingDTO>> getBookingsByUserAndStatus(
            @PathVariable Integer userId,
            @PathVariable String status) {
        log.info("GET /api/attraction-bookings/user/{}/status/{} - Lấy bookings theo user và status", userId, status);
        List<AttractionBookingDTO> bookings = bookingService.getBookingsByUserAndStatus(userId, status);
        return ResponseEntity.ok(bookings);
    }

    @GetMapping("/provider/{providerId}/status/{status}")
    public ResponseEntity<List<AttractionBookingDTO>> getBookingsByProviderAndStatus(
            @PathVariable Integer providerId,
            @PathVariable String status) {
        log.info("GET /api/attraction-bookings/provider/{}/status/{} - Lấy bookings theo provider và status",
                providerId, status);
        List<AttractionBookingDTO> bookings = bookingService.getBookingsByProviderAndStatus(providerId, status);
        return ResponseEntity.ok(bookings);
    }

    @GetMapping("/provider/{providerId}/unseen")
    public ResponseEntity<List<AttractionBookingDTO>> getUnseenBookingsByProvider(@PathVariable Integer providerId) {
        log.info("GET /api/attraction-bookings/provider/{}/unseen - Lấy bookings chưa xem của provider", providerId);
        List<AttractionBookingDTO> bookings = bookingService.getUnseenBookingsByProvider(providerId);
        return ResponseEntity.ok(bookings);
    }

    @PostMapping
    public ResponseEntity<AttractionBookingDTO> createBooking(@Valid @RequestBody AttractionBookingDTO dto) {
        log.info("POST /api/attraction-bookings - Tạo booking mới");
        AttractionBookingDTO createdBooking = bookingService.createBooking(dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(createdBooking);
    }

    @PutMapping("/{id}")
    public ResponseEntity<AttractionBookingDTO> updateBooking(
            @PathVariable Integer id,
            @Valid @RequestBody AttractionBookingDTO dto) {
        log.info("PUT /api/attraction-bookings/{} - Cập nhật booking", id);
        AttractionBookingDTO updatedBooking = bookingService.updateBooking(id, dto);
        return ResponseEntity.ok(updatedBooking);
    }

    @PatchMapping("/{id}/mark-seen")
    public ResponseEntity<AttractionBookingDTO> markAsSeenByProvider(@PathVariable Integer id) {
        log.info("PATCH /api/attraction-bookings/{}/mark-seen - Đánh dấu đã xem", id);
        AttractionBookingDTO updatedBooking = bookingService.markAsSeenByProvider(id);
        return ResponseEntity.ok(updatedBooking);
    }

    @PatchMapping("/{id}/confirm")
    public ResponseEntity<AttractionBookingDTO> confirmBooking(@PathVariable Integer id) {
        log.info("PATCH /api/attraction-bookings/{}/confirm - Xác nhận booking", id);
        AttractionBookingDTO confirmedBooking = bookingService.confirmBooking(id);
        return ResponseEntity.ok(confirmedBooking);
    }

    @PatchMapping("/{id}/cancel")
    public ResponseEntity<AttractionBookingDTO> cancelBooking(@PathVariable Integer id) {
        log.info("PATCH /api/attraction-bookings/{}/cancel - Hủy booking", id);
        AttractionBookingDTO cancelledBooking = bookingService.cancelBooking(id);
        return ResponseEntity.ok(cancelledBooking);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteBooking(@PathVariable Integer id) {
        log.info("DELETE /api/attraction-bookings/{} - Xóa booking", id);
        bookingService.deleteBooking(id);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/cancel-expired")
    public ResponseEntity<Void> cancelExpiredPendingBookings() {
        log.info("POST /api/attraction-bookings/cancel-expired - Hủy bookings pending hết hạn");
        bookingService.cancelExpiredPendingBookings();
        return ResponseEntity.ok().build();
    }

    /**
     * FIX DATA: Update providerId for bookings that don't have it
     * This should be called once to fix existing data
     */
    @PostMapping("/fix-provider-ids")
    public ResponseEntity<String> fixProviderIds() {
        log.info("POST /api/attraction-bookings/fix-provider-ids - Fix providerId cho bookings cũ");
        int updatedCount = bookingService.fixMissingProviderIds();
        return ResponseEntity.ok(String.format("Đã cập nhật %d bookings", updatedCount));
    }
}
