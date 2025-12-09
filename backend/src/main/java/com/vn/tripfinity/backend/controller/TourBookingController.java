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

import com.vn.tripfinity.backend.dto.TourBookingDTO;
import com.vn.tripfinity.backend.service.TourBookingService;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@RestController
@RequestMapping("/api/tour-bookings")
@RequiredArgsConstructor
@Slf4j
@CrossOrigin(origins = "*")
public class TourBookingController {

    private final TourBookingService bookingService;

    @GetMapping
    public ResponseEntity<List<TourBookingDTO>> getAllBookings() {
        log.info("GET /api/tour-bookings - Lấy toàn bộ tour bookings");
        List<TourBookingDTO> bookings = bookingService.getAllBookings();
        return ResponseEntity.ok(bookings);
    }

    @GetMapping("/{id}")
    public ResponseEntity<TourBookingDTO> getBookingById(@PathVariable Integer id) {
        log.info("GET /api/tour-bookings/{} - Lấy tour booking theo ID", id);
        TourBookingDTO booking = bookingService.getBookingById(id);
        return ResponseEntity.ok(booking);
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<List<TourBookingDTO>> getBookingsByUser(@PathVariable Integer userId) {
        log.info("GET /api/tour-bookings/user/{} - Lấy tour bookings của user", userId);
        List<TourBookingDTO> bookings = bookingService.getBookingsByUser(userId);
        return ResponseEntity.ok(bookings);
    }

    @GetMapping("/tour/{tourId}")
    public ResponseEntity<List<TourBookingDTO>> getBookingsByTour(@PathVariable Integer tourId) {
        log.info("GET /api/tour-bookings/tour/{} - Lấy bookings của tour", tourId);
        List<TourBookingDTO> bookings = bookingService.getBookingsByTour(tourId);
        return ResponseEntity.ok(bookings);
    }

    @GetMapping("/provider/{providerId}")
    public ResponseEntity<List<TourBookingDTO>> getBookingsByProvider(@PathVariable Integer providerId) {
        log.info("GET /api/tour-bookings/provider/{} - Lấy tour bookings của provider", providerId);
        List<TourBookingDTO> bookings = bookingService.getBookingsByProvider(providerId);
        return ResponseEntity.ok(bookings);
    }

    @GetMapping("/user/{userId}/status/{status}")
    public ResponseEntity<List<TourBookingDTO>> getBookingsByUserAndStatus(
            @PathVariable Integer userId,
            @PathVariable String status) {
        log.info("GET /api/tour-bookings/user/{}/status/{} - Lấy tour bookings theo user và status", userId, status);
        List<TourBookingDTO> bookings = bookingService.getBookingsByUserAndStatus(userId, status);
        return ResponseEntity.ok(bookings);
    }

    @GetMapping("/provider/{providerId}/status/{status}")
    public ResponseEntity<List<TourBookingDTO>> getBookingsByProviderAndStatus(
            @PathVariable Integer providerId,
            @PathVariable String status) {
        log.info("GET /api/tour-bookings/provider/{}/status/{} - Lấy tour bookings theo provider và status", providerId,
                status);
        List<TourBookingDTO> bookings = bookingService.getBookingsByProviderAndStatus(providerId, status);
        return ResponseEntity.ok(bookings);
    }

    @GetMapping("/provider/{providerId}/unseen")
    public ResponseEntity<List<TourBookingDTO>> getUnseenBookingsByProvider(@PathVariable Integer providerId) {
        log.info("GET /api/tour-bookings/provider/{}/unseen - Lấy tour bookings chưa xem của provider", providerId);
        List<TourBookingDTO> bookings = bookingService.getUnseenBookingsByProvider(providerId);
        return ResponseEntity.ok(bookings);
    }

    @PostMapping
    public ResponseEntity<TourBookingDTO> createBooking(@Valid @RequestBody TourBookingDTO dto) {
        log.info("POST /api/tour-bookings - Tạo tour booking mới");
        TourBookingDTO createdBooking = bookingService.createBooking(dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(createdBooking);
    }

    @PutMapping("/{id}")
    public ResponseEntity<TourBookingDTO> updateBooking(
            @PathVariable Integer id,
            @Valid @RequestBody TourBookingDTO dto) {
        log.info("PUT /api/tour-bookings/{} - Cập nhật tour booking", id);
        TourBookingDTO updatedBooking = bookingService.updateBooking(id, dto);
        return ResponseEntity.ok(updatedBooking);
    }

    @PatchMapping("/{id}/mark-seen")
    public ResponseEntity<TourBookingDTO> markAsSeenByProvider(@PathVariable Integer id) {
        log.info("PATCH /api/tour-bookings/{}/mark-seen - Đánh dấu đã xem", id);
        TourBookingDTO updatedBooking = bookingService.markAsSeenByProvider(id);
        return ResponseEntity.ok(updatedBooking);
    }

    @PatchMapping("/{id}/confirm")
    public ResponseEntity<TourBookingDTO> confirmBooking(@PathVariable Integer id) {
        log.info("PATCH /api/tour-bookings/{}/confirm - Xác nhận tour booking", id);
        TourBookingDTO confirmedBooking = bookingService.confirmBooking(id);
        return ResponseEntity.ok(confirmedBooking);
    }

    @PatchMapping("/{id}/cancel")
    public ResponseEntity<TourBookingDTO> cancelBooking(@PathVariable Integer id) {
        log.info("PATCH /api/tour-bookings/{}/cancel - Hủy tour booking", id);
        TourBookingDTO cancelledBooking = bookingService.cancelBooking(id);
        return ResponseEntity.ok(cancelledBooking);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteBooking(@PathVariable Integer id) {
        log.info("DELETE /api/tour-bookings/{} - Xóa tour booking", id);
        bookingService.deleteBooking(id);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/cancel-expired")
    public ResponseEntity<Void> cancelExpiredPendingBookings() {
        log.info("POST /api/tour-bookings/cancel-expired - Hủy tour bookings pending hết hạn");
        bookingService.cancelExpiredPendingBookings();
        return ResponseEntity.ok().build();
    }

    /**
     * FIX DATA: Update providerId for tour bookings that don't have it
     * This should be called once to fix existing data
     */
    @PostMapping("/fix-provider-ids")
    public ResponseEntity<String> fixProviderIds() {
        log.info("POST /api/tour-bookings/fix-provider-ids - Fix providerId cho tour bookings cũ");
        int updatedCount = bookingService.fixMissingProviderIds();
        return ResponseEntity.ok(String.format("Đã cập nhật %d tour bookings", updatedCount));
    }
}
