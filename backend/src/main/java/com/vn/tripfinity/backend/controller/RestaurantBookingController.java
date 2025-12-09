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

import com.vn.tripfinity.backend.dto.RestaurantBookingDTO;
import com.vn.tripfinity.backend.service.RestaurantBookingService;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@RestController
@RequestMapping("/api/restaurant-bookings")
@RequiredArgsConstructor
@Slf4j
@CrossOrigin(origins = "*")
public class RestaurantBookingController {

    private final RestaurantBookingService bookingService;

    @GetMapping
    public ResponseEntity<List<RestaurantBookingDTO>> getAllBookings() {
        log.info("GET /api/restaurant-bookings - Lấy toàn bộ bookings");
        List<RestaurantBookingDTO> bookings = bookingService.getAllBookings();
        return ResponseEntity.ok(bookings);
    }

    @GetMapping("/{id}")
    public ResponseEntity<RestaurantBookingDTO> getBookingById(@PathVariable Integer id) {
        log.info("GET /api/restaurant-bookings/{} - Lấy booking theo ID", id);
        RestaurantBookingDTO booking = bookingService.getBookingById(id);
        return ResponseEntity.ok(booking);
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<List<RestaurantBookingDTO>> getBookingsByUser(@PathVariable Integer userId) {
        log.info("GET /api/restaurant-bookings/user/{} - Lấy bookings của user", userId);
        List<RestaurantBookingDTO> bookings = bookingService.getBookingsByUser(userId);
        return ResponseEntity.ok(bookings);
    }

    @GetMapping("/restaurant/{restaurantId}")
    public ResponseEntity<List<RestaurantBookingDTO>> getBookingsByRestaurant(@PathVariable Integer restaurantId) {
        log.info("GET /api/restaurant-bookings/restaurant/{} - Lấy bookings của restaurant", restaurantId);
        List<RestaurantBookingDTO> bookings = bookingService.getBookingsByRestaurant(restaurantId);
        return ResponseEntity.ok(bookings);
    }

    @GetMapping("/provider/{providerId}")
    public ResponseEntity<List<RestaurantBookingDTO>> getBookingsByProvider(@PathVariable Integer providerId) {
        log.info("GET /api/restaurant-bookings/provider/{} - Lấy bookings của provider", providerId);
        List<RestaurantBookingDTO> bookings = bookingService.getBookingsByProvider(providerId);
        return ResponseEntity.ok(bookings);
    }

    @GetMapping("/user/{userId}/status/{status}")
    public ResponseEntity<List<RestaurantBookingDTO>> getBookingsByUserAndStatus(
            @PathVariable Integer userId,
            @PathVariable String status) {
        log.info("GET /api/restaurant-bookings/user/{}/status/{} - Lấy bookings theo user và status", userId, status);
        List<RestaurantBookingDTO> bookings = bookingService.getBookingsByUserAndStatus(userId, status);
        return ResponseEntity.ok(bookings);
    }

    @GetMapping("/provider/{providerId}/status/{status}")
    public ResponseEntity<List<RestaurantBookingDTO>> getBookingsByProviderAndStatus(
            @PathVariable Integer providerId,
            @PathVariable String status) {
        log.info("GET /api/restaurant-bookings/provider/{}/status/{} - Lấy bookings theo provider và status", providerId,
                status);
        List<RestaurantBookingDTO> bookings = bookingService.getBookingsByProviderAndStatus(providerId, status);
        return ResponseEntity.ok(bookings);
    }

    @GetMapping("/provider/{providerId}/unseen")
    public ResponseEntity<List<RestaurantBookingDTO>> getUnseenBookingsByProvider(@PathVariable Integer providerId) {
        log.info("GET /api/restaurant-bookings/provider/{}/unseen - Lấy bookings chưa xem của provider", providerId);
        List<RestaurantBookingDTO> bookings = bookingService.getUnseenBookingsByProvider(providerId);
        return ResponseEntity.ok(bookings);
    }

    @PostMapping
    public ResponseEntity<RestaurantBookingDTO> createBooking(@Valid @RequestBody RestaurantBookingDTO dto) {
        log.info("POST /api/restaurant-bookings - Tạo booking mới");
        RestaurantBookingDTO createdBooking = bookingService.createBooking(dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(createdBooking);
    }

    @PutMapping("/{id}")
    public ResponseEntity<RestaurantBookingDTO> updateBooking(
            @PathVariable Integer id,
            @Valid @RequestBody RestaurantBookingDTO dto) {
        log.info("PUT /api/restaurant-bookings/{} - Cập nhật booking", id);
        RestaurantBookingDTO updatedBooking = bookingService.updateBooking(id, dto);
        return ResponseEntity.ok(updatedBooking);
    }

    @PatchMapping("/{id}/mark-seen")
    public ResponseEntity<RestaurantBookingDTO> markAsSeen(@PathVariable Integer id) {
        log.info("PATCH /api/restaurant-bookings/{}/mark-seen - Đánh dấu đã xem", id);
        RestaurantBookingDTO updatedBooking = bookingService.markAsSeen(id);
        return ResponseEntity.ok(updatedBooking);
    }

    @PatchMapping("/{id}/status/{status}")
    public ResponseEntity<RestaurantBookingDTO> updateBookingStatus(
            @PathVariable Integer id,
            @PathVariable String status) {
        log.info("PATCH /api/restaurant-bookings/{}/status/{} - Cập nhật status", id, status);
        RestaurantBookingDTO updatedBooking = bookingService.updateBookingStatus(id, status);
        return ResponseEntity.ok(updatedBooking);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteBooking(@PathVariable Integer id) {
        log.info("DELETE /api/restaurant-bookings/{} - Xóa booking", id);
        bookingService.deleteBooking(id);
        return ResponseEntity.noContent().build();
    }
}
