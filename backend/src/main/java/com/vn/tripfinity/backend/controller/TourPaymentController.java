package com.vn.tripfinity.backend.controller;

import com.vn.tripfinity.backend.dto.TourPaymentDTO;
import com.vn.tripfinity.backend.service.TourPaymentService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/tour-payments")
@RequiredArgsConstructor
@Slf4j
@CrossOrigin(origins = "*")
public class TourPaymentController {

    private final TourPaymentService paymentService;

    @GetMapping
    public ResponseEntity<List<TourPaymentDTO>> getAllPayments() {
        log.info("GET /api/tour-payments - Lấy toàn bộ tour payments");
        List<TourPaymentDTO> payments = paymentService.getAllPayments();
        return ResponseEntity.ok(payments);
    }

    @GetMapping("/{id}")
    public ResponseEntity<TourPaymentDTO> getPaymentById(@PathVariable Integer id) {
        log.info("GET /api/tour-payments/{} - Lấy tour payment theo ID", id);
        TourPaymentDTO payment = paymentService.getPaymentById(id);
        return ResponseEntity.ok(payment);
    }

    @GetMapping("/booking/{bookingId}")
    public ResponseEntity<TourPaymentDTO> getPaymentByBookingId(@PathVariable Integer bookingId) {
        log.info("GET /api/tour-payments/booking/{} - Lấy tour payment theo booking ID", bookingId);
        TourPaymentDTO payment = paymentService.getPaymentByBookingId(bookingId);
        return ResponseEntity.ok(payment);
    }

    @GetMapping("/transaction/{transactionId}")
    public ResponseEntity<TourPaymentDTO> getPaymentByTransactionId(@PathVariable String transactionId) {
        log.info("GET /api/tour-payments/transaction/{} - Lấy tour payment theo transaction ID", transactionId);
        TourPaymentDTO payment = paymentService.getPaymentByTransactionId(transactionId);
        return ResponseEntity.ok(payment);
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<List<TourPaymentDTO>> getPaymentsByUser(@PathVariable Integer userId) {
        log.info("GET /api/tour-payments/user/{} - Lấy tour payments của user", userId);
        List<TourPaymentDTO> payments = paymentService.getPaymentsByUser(userId);
        return ResponseEntity.ok(payments);
    }

    @GetMapping("/user/{userId}/status/{status}")
    public ResponseEntity<List<TourPaymentDTO>> getPaymentsByUserAndStatus(
            @PathVariable Integer userId,
            @PathVariable String status) {
        log.info("GET /api/tour-payments/user/{}/status/{} - Lấy tour payments theo user và status", userId, status);
        List<TourPaymentDTO> payments = paymentService.getPaymentsByUserAndStatus(userId, status);
        return ResponseEntity.ok(payments);
    }

    @PostMapping
    public ResponseEntity<TourPaymentDTO> createPayment(@Valid @RequestBody TourPaymentDTO dto) {
        log.info("POST /api/tour-payments - Tạo tour payment mới");
        TourPaymentDTO createdPayment = paymentService.createPayment(dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(createdPayment);
    }

    @PutMapping("/{id}")
    public ResponseEntity<TourPaymentDTO> updatePayment(
            @PathVariable Integer id,
            @Valid @RequestBody TourPaymentDTO dto) {
        log.info("PUT /api/tour-payments/{} - Cập nhật tour payment", id);
        TourPaymentDTO updatedPayment = paymentService.updatePayment(id, dto);
        return ResponseEntity.ok(updatedPayment);
    }

    @PatchMapping("/{id}/status/{status}")
    public ResponseEntity<TourPaymentDTO> updatePaymentStatus(
            @PathVariable Integer id,
            @PathVariable String status) {
        log.info("PATCH /api/tour-payments/{}/status/{} - Cập nhật tour payment status", id, status);
        TourPaymentDTO updatedPayment = paymentService.updatePaymentStatus(id, status);
        return ResponseEntity.ok(updatedPayment);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deletePayment(@PathVariable Integer id) {
        log.info("DELETE /api/tour-payments/{} - Xóa tour payment", id);
        paymentService.deletePayment(id);
        return ResponseEntity.noContent().build();
    }
}
