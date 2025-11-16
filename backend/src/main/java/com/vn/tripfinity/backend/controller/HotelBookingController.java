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

import com.vn.tripfinity.backend.dto.HotelBookingDTO;
import com.vn.tripfinity.backend.service.HotelBookingService;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@RestController
@RequestMapping("/api/hotel-bookings")
@RequiredArgsConstructor
@Slf4j
@CrossOrigin(origins = "*")
public class HotelBookingController {

    private final HotelBookingService bookingService;

    @GetMapping
    public ResponseEntity<List<HotelBookingDTO>> getAllBookings() {
        log.info("GET /api/hotel-bookings - Lấy toàn bộ bookings");
        List<HotelBookingDTO> bookings = bookingService.getAllBookings();
        return ResponseEntity.ok(bookings);
    }

    @GetMapping("/{id}")
    public ResponseEntity<HotelBookingDTO> getBookingById(@PathVariable Integer id) {
        log.info("GET /api/hotel-bookings/{} - Lấy booking theo ID", id);
        HotelBookingDTO booking = bookingService.getBookingById(id);
        return ResponseEntity.ok(booking);
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<List<HotelBookingDTO>> getBookingsByUser(@PathVariable Integer userId) {
        log.info("GET /api/hotel-bookings/user/{} - Lấy bookings của user", userId);
        List<HotelBookingDTO> bookings = bookingService.getBookingsByUser(userId);
        return ResponseEntity.ok(bookings);
    }

    @GetMapping("/hotel/{hotelId}")
    public ResponseEntity<List<HotelBookingDTO>> getBookingsByHotel(@PathVariable Integer hotelId) {
        log.info("GET /api/hotel-bookings/hotel/{} - Lấy bookings của hotel", hotelId);
        List<HotelBookingDTO> bookings = bookingService.getBookingsByHotel(hotelId);
        return ResponseEntity.ok(bookings);
    }

    @GetMapping("/provider/{providerId}")
    public ResponseEntity<List<HotelBookingDTO>> getBookingsByProvider(@PathVariable Integer providerId) {
        log.info("GET /api/hotel-bookings/provider/{} - Lấy bookings của provider", providerId);
        List<HotelBookingDTO> bookings = bookingService.getBookingsByProvider(providerId);
        return ResponseEntity.ok(bookings);
    }

    @GetMapping("/user/{userId}/status/{status}")
    public ResponseEntity<List<HotelBookingDTO>> getBookingsByUserAndStatus(
            @PathVariable Integer userId,
            @PathVariable String status) {
        log.info("GET /api/hotel-bookings/user/{}/status/{} - Lấy bookings theo user và status", userId, status);
        List<HotelBookingDTO> bookings = bookingService.getBookingsByUserAndStatus(userId, status);
        return ResponseEntity.ok(bookings);
    }

    @GetMapping("/provider/{providerId}/status/{status}")
    public ResponseEntity<List<HotelBookingDTO>> getBookingsByProviderAndStatus(
            @PathVariable Integer providerId,
            @PathVariable String status) {
        log.info("GET /api/hotel-bookings/provider/{}/status/{} - Lấy bookings theo provider và status", providerId,
                status);
        List<HotelBookingDTO> bookings = bookingService.getBookingsByProviderAndStatus(providerId, status);
        return ResponseEntity.ok(bookings);
    }

    @GetMapping("/provider/{providerId}/unseen")
    public ResponseEntity<List<HotelBookingDTO>> getUnseenBookingsByProvider(@PathVariable Integer providerId) {
        log.info("GET /api/hotel-bookings/provider/{}/unseen - Lấy bookings chưa xem của provider", providerId);
        List<HotelBookingDTO> bookings = bookingService.getUnseenBookingsByProvider(providerId);
        return ResponseEntity.ok(bookings);
    }

    @PostMapping
    public ResponseEntity<HotelBookingDTO> createBooking(@Valid @RequestBody HotelBookingDTO dto) {
        log.info("POST /api/hotel-bookings - Tạo booking mới");
        HotelBookingDTO createdBooking = bookingService.createBooking(dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(createdBooking);
    }

    @PutMapping("/{id}")
    public ResponseEntity<HotelBookingDTO> updateBooking(
            @PathVariable Integer id,
            @Valid @RequestBody HotelBookingDTO dto) {
        log.info("PUT /api/hotel-bookings/{} - Cập nhật booking", id);
        HotelBookingDTO updatedBooking = bookingService.updateBooking(id, dto);
        return ResponseEntity.ok(updatedBooking);
    }

    @PatchMapping("/{id}/mark-seen")
    public ResponseEntity<HotelBookingDTO> markAsSeenByProvider(@PathVariable Integer id) {
        log.info("PATCH /api/hotel-bookings/{}/mark-seen - Đánh dấu đã xem", id);
        HotelBookingDTO updatedBooking = bookingService.markAsSeenByProvider(id);
        return ResponseEntity.ok(updatedBooking);
    }

    @PatchMapping("/{id}/cancel")
    public ResponseEntity<HotelBookingDTO> cancelBooking(@PathVariable Integer id) {
        log.info("PATCH /api/hotel-bookings/{}/cancel - Hủy booking", id);
        HotelBookingDTO cancelledBooking = bookingService.cancelBooking(id);
        return ResponseEntity.ok(cancelledBooking);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteBooking(@PathVariable Integer id) {
        log.info("DELETE /api/hotel-bookings/{} - Xóa booking", id);
        bookingService.deleteBooking(id);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/cancel-expired")
    public ResponseEntity<Void> cancelExpiredPendingBookings() {
        log.info("POST /api/hotel-bookings/cancel-expired - Hủy bookings pending hết hạn");
        bookingService.cancelExpiredPendingBookings();
        return ResponseEntity.ok().build();
    }

    /**
     * FIX DATA: Update providerId for bookings that don't have it
     * This should be called once to fix existing data
     */
    @PostMapping("/fix-provider-ids")
    public ResponseEntity<String> fixProviderIds() {
        log.info("POST /api/hotel-bookings/fix-provider-ids - Fix providerId cho bookings cũ");
        int updatedCount = bookingService.fixMissingProviderIds();
        return ResponseEntity.ok(String.format("Đã cập nhật %d bookings", updatedCount));
    }
}