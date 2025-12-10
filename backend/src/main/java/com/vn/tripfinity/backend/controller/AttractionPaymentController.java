package com.vn.tripfinity.backend.controller;

import com.vn.tripfinity.backend.dto.AttractionPaymentDTO;
import com.vn.tripfinity.backend.service.AttractionPaymentService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/attraction-payments")
@RequiredArgsConstructor
@Slf4j
@CrossOrigin(origins = "*")
public class AttractionPaymentController {

    private final AttractionPaymentService paymentService;

    @GetMapping
    public ResponseEntity<List<AttractionPaymentDTO>> getAllPayments() {
        log.info("GET /api/attraction-payments - Lấy toàn bộ payments");
        List<AttractionPaymentDTO> payments = paymentService.getAllPayments();
        return ResponseEntity.ok(payments);
    }

    @GetMapping("/{id}")
    public ResponseEntity<AttractionPaymentDTO> getPaymentById(@PathVariable Integer id) {
        log.info("GET /api/attraction-payments/{} - Lấy payment theo ID", id);
        AttractionPaymentDTO payment = paymentService.getPaymentById(id);
        return ResponseEntity.ok(payment);
    }

    @GetMapping("/booking/{bookingId}")
    public ResponseEntity<AttractionPaymentDTO> getPaymentByBookingId(@PathVariable Integer bookingId) {
        log.info("GET /api/attraction-payments/booking/{} - Lấy payment theo booking ID", bookingId);
        AttractionPaymentDTO payment = paymentService.getPaymentByBookingId(bookingId);
        return ResponseEntity.ok(payment);
    }

    @GetMapping("/transaction/{transactionId}")
    public ResponseEntity<AttractionPaymentDTO> getPaymentByTransactionId(@PathVariable String transactionId) {
        log.info("GET /api/attraction-payments/transaction/{} - Lấy payment theo transaction ID", transactionId);
        AttractionPaymentDTO payment = paymentService.getPaymentByTransactionId(transactionId);
        return ResponseEntity.ok(payment);
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<List<AttractionPaymentDTO>> getPaymentsByUser(@PathVariable Integer userId) {
        log.info("GET /api/attraction-payments/user/{} - Lấy payments của user", userId);
        List<AttractionPaymentDTO> payments = paymentService.getPaymentsByUser(userId);
        return ResponseEntity.ok(payments);
    }

    @GetMapping("/user/{userId}/status/{status}")
    public ResponseEntity<List<AttractionPaymentDTO>> getPaymentsByUserAndStatus(
            @PathVariable Integer userId,
            @PathVariable String status) {
        log.info("GET /api/attraction-payments/user/{}/status/{} - Lấy payments theo user và status", userId, status);
        List<AttractionPaymentDTO> payments = paymentService.getPaymentsByUserAndStatus(userId, status);
        return ResponseEntity.ok(payments);
    }

    @PostMapping
    public ResponseEntity<AttractionPaymentDTO> createPayment(@Valid @RequestBody AttractionPaymentDTO dto) {
        log.info("POST /api/attraction-payments - Tạo payment mới");
        AttractionPaymentDTO createdPayment = paymentService.createPayment(dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(createdPayment);
    }

    @PutMapping("/{id}")
    public ResponseEntity<AttractionPaymentDTO> updatePayment(
            @PathVariable Integer id,
            @Valid @RequestBody AttractionPaymentDTO dto) {
        log.info("PUT /api/attraction-payments/{} - Cập nhật payment", id);
        AttractionPaymentDTO updatedPayment = paymentService.updatePayment(id, dto);
        return ResponseEntity.ok(updatedPayment);
    }

    @PatchMapping("/{id}/status/{status}")
    public ResponseEntity<AttractionPaymentDTO> updatePaymentStatus(
            @PathVariable Integer id,
            @PathVariable String status) {
        log.info("PATCH /api/attraction-payments/{}/status/{} - Cập nhật payment status", id, status);
        AttractionPaymentDTO updatedPayment = paymentService.updatePaymentStatus(id, status);
        return ResponseEntity.ok(updatedPayment);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deletePayment(@PathVariable Integer id) {
        log.info("DELETE /api/attraction-payments/{} - Xóa payment", id);
        paymentService.deletePayment(id);
        return ResponseEntity.noContent().build();
    }
}
