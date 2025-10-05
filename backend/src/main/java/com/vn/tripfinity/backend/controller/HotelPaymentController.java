package com.vn.tripfinity.backend.controller;

import com.vn.tripfinity.backend.dto.HotelPaymentDTO;
import com.vn.tripfinity.backend.service.HotelPaymentService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/hotel-payments")
@RequiredArgsConstructor
@Slf4j
@CrossOrigin(origins = "*")
public class HotelPaymentController {

    private final HotelPaymentService paymentService;

    @GetMapping
    public ResponseEntity<List<HotelPaymentDTO>> getAllPayments() {
        log.info("GET /api/hotel-payments - Lấy toàn bộ payments");
        List<HotelPaymentDTO> payments = paymentService.getAllPayments();
        return ResponseEntity.ok(payments);
    }

    @GetMapping("/{id}")
    public ResponseEntity<HotelPaymentDTO> getPaymentById(@PathVariable Integer id) {
        log.info("GET /api/hotel-payments/{} - Lấy payment theo ID", id);
        HotelPaymentDTO payment = paymentService.getPaymentById(id);
        return ResponseEntity.ok(payment);
    }

    @GetMapping("/booking/{bookingId}")
    public ResponseEntity<HotelPaymentDTO> getPaymentByBookingId(@PathVariable Integer bookingId) {
        log.info("GET /api/hotel-payments/booking/{} - Lấy payment theo booking ID", bookingId);
        HotelPaymentDTO payment = paymentService.getPaymentByBookingId(bookingId);
        return ResponseEntity.ok(payment);
    }

    @GetMapping("/transaction/{transactionId}")
    public ResponseEntity<HotelPaymentDTO> getPaymentByTransactionId(@PathVariable String transactionId) {
        log.info("GET /api/hotel-payments/transaction/{} - Lấy payment theo transaction ID", transactionId);
        HotelPaymentDTO payment = paymentService.getPaymentByTransactionId(transactionId);
        return ResponseEntity.ok(payment);
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<List<HotelPaymentDTO>> getPaymentsByUser(@PathVariable Integer userId) {
        log.info("GET /api/hotel-payments/user/{} - Lấy payments của user", userId);
        List<HotelPaymentDTO> payments = paymentService.getPaymentsByUser(userId);
        return ResponseEntity.ok(payments);
    }

    @GetMapping("/user/{userId}/status/{status}")
    public ResponseEntity<List<HotelPaymentDTO>> getPaymentsByUserAndStatus(
            @PathVariable Integer userId,
            @PathVariable String status) {
        log.info("GET /api/hotel-payments/user/{}/status/{} - Lấy payments theo user và status", userId, status);
        List<HotelPaymentDTO> payments = paymentService.getPaymentsByUserAndStatus(userId, status);
        return ResponseEntity.ok(payments);
    }

    @PostMapping
    public ResponseEntity<HotelPaymentDTO> createPayment(@Valid @RequestBody HotelPaymentDTO dto) {
        log.info("POST /api/hotel-payments - Tạo payment mới");
        HotelPaymentDTO createdPayment = paymentService.createPayment(dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(createdPayment);
    }

    @PutMapping("/{id}")
    public ResponseEntity<HotelPaymentDTO> updatePayment(
            @PathVariable Integer id,
            @Valid @RequestBody HotelPaymentDTO dto) {
        log.info("PUT /api/hotel-payments/{} - Cập nhật payment", id);
        HotelPaymentDTO updatedPayment = paymentService.updatePayment(id, dto);
        return ResponseEntity.ok(updatedPayment);
    }

    @PatchMapping("/{id}/status/{status}")
    public ResponseEntity<HotelPaymentDTO> updatePaymentStatus(
            @PathVariable Integer id,
            @PathVariable String status) {
        log.info("PATCH /api/hotel-payments/{}/status/{} - Cập nhật payment status", id, status);
        HotelPaymentDTO updatedPayment = paymentService.updatePaymentStatus(id, status);
        return ResponseEntity.ok(updatedPayment);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deletePayment(@PathVariable Integer id) {
        log.info("DELETE /api/hotel-payments/{} - Xóa payment", id);
        paymentService.deletePayment(id);
        return ResponseEntity.noContent().build();
    }
}