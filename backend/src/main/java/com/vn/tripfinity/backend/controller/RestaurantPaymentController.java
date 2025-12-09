package com.vn.tripfinity.backend.controller;

import com.vn.tripfinity.backend.dto.RestaurantPaymentDTO;
import com.vn.tripfinity.backend.service.RestaurantPaymentService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/restaurant-payments")
@RequiredArgsConstructor
@Slf4j
@CrossOrigin(origins = "*")
public class RestaurantPaymentController {

    private final RestaurantPaymentService paymentService;

    @GetMapping
    public ResponseEntity<List<RestaurantPaymentDTO>> getAllPayments() {
        log.info("GET /api/restaurant-payments - Lấy toàn bộ payments");
        List<RestaurantPaymentDTO> payments = paymentService.getAllPayments();
        return ResponseEntity.ok(payments);
    }

    @GetMapping("/{id}")
    public ResponseEntity<RestaurantPaymentDTO> getPaymentById(@PathVariable Integer id) {
        log.info("GET /api/restaurant-payments/{} - Lấy payment theo ID", id);
        RestaurantPaymentDTO payment = paymentService.getPaymentById(id);
        return ResponseEntity.ok(payment);
    }

    @GetMapping("/booking/{bookingId}")
    public ResponseEntity<RestaurantPaymentDTO> getPaymentByBookingId(@PathVariable Integer bookingId) {
        log.info("GET /api/restaurant-payments/booking/{} - Lấy payment theo booking ID", bookingId);
        RestaurantPaymentDTO payment = paymentService.getPaymentByBookingId(bookingId);
        return ResponseEntity.ok(payment);
    }

    @GetMapping("/transaction/{transactionId}")
    public ResponseEntity<RestaurantPaymentDTO> getPaymentByTransactionId(@PathVariable String transactionId) {
        log.info("GET /api/restaurant-payments/transaction/{} - Lấy payment theo transaction ID", transactionId);
        RestaurantPaymentDTO payment = paymentService.getPaymentByTransactionId(transactionId);
        return ResponseEntity.ok(payment);
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<List<RestaurantPaymentDTO>> getPaymentsByUser(@PathVariable Integer userId) {
        log.info("GET /api/restaurant-payments/user/{} - Lấy payments của user", userId);
        List<RestaurantPaymentDTO> payments = paymentService.getPaymentsByUser(userId);
        return ResponseEntity.ok(payments);
    }

    @GetMapping("/user/{userId}/status/{status}")
    public ResponseEntity<List<RestaurantPaymentDTO>> getPaymentsByUserAndStatus(
            @PathVariable Integer userId,
            @PathVariable String status) {
        log.info("GET /api/restaurant-payments/user/{}/status/{} - Lấy payments theo user và status", userId, status);
        List<RestaurantPaymentDTO> payments = paymentService.getPaymentsByUserAndStatus(userId, status);
        return ResponseEntity.ok(payments);
    }

    @PostMapping
    public ResponseEntity<RestaurantPaymentDTO> createPayment(@Valid @RequestBody RestaurantPaymentDTO dto) {
        log.info("POST /api/restaurant-payments - Tạo payment mới");
        RestaurantPaymentDTO createdPayment = paymentService.createPayment(dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(createdPayment);
    }

    @PutMapping("/{id}")
    public ResponseEntity<RestaurantPaymentDTO> updatePayment(
            @PathVariable Integer id,
            @Valid @RequestBody RestaurantPaymentDTO dto) {
        log.info("PUT /api/restaurant-payments/{} - Cập nhật payment", id);
        RestaurantPaymentDTO updatedPayment = paymentService.updatePayment(id, dto);
        return ResponseEntity.ok(updatedPayment);
    }

    @PatchMapping("/{id}/status/{status}")
    public ResponseEntity<RestaurantPaymentDTO> updatePaymentStatus(
            @PathVariable Integer id,
            @PathVariable String status) {
        log.info("PATCH /api/restaurant-payments/{}/status/{} - Cập nhật payment status", id, status);
        RestaurantPaymentDTO updatedPayment = paymentService.updatePaymentStatus(id, status);
        return ResponseEntity.ok(updatedPayment);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deletePayment(@PathVariable Integer id) {
        log.info("DELETE /api/restaurant-payments/{} - Xóa payment", id);
        paymentService.deletePayment(id);
        return ResponseEntity.noContent().build();
    }
}
