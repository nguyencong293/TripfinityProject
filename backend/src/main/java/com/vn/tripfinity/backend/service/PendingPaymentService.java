package com.vn.tripfinity.backend.service;

import com.vn.tripfinity.backend.dto.PendingPaymentDto;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Service
public class PendingPaymentService {

    // In-memory storage for pending payments
    // In production, use Redis or database table
    private final Map<String, PendingPaymentDto> pendingPayments = new ConcurrentHashMap<>();

    /**
     * Store pending payment information
     * 
     * @param appTransId ZaloPay transaction ID
     * @param payment    Payment details
     */
    public void storePendingPayment(String appTransId, PendingPaymentDto payment) {
        payment.setAppTransId(appTransId);
        payment.setCreatedAt(LocalDateTime.now());
        payment.setExpiresAt(LocalDateTime.now().plusMinutes(15)); // Expire after 15 minutes
        pendingPayments.put(appTransId, payment);
    }

    /**
     * Get pending payment by transaction ID
     * 
     * @param appTransId ZaloPay transaction ID
     * @return Payment details or null if not found/expired
     */
    public PendingPaymentDto getPendingPayment(String appTransId) {
        PendingPaymentDto payment = pendingPayments.get(appTransId);
        if (payment == null) {
            return null;
        }

        // Check if expired
        if (LocalDateTime.now().isAfter(payment.getExpiresAt())) {
            pendingPayments.remove(appTransId);
            return null;
        }

        return payment;
    }

    /**
     * Remove pending payment after successful booking creation
     * 
     * @param appTransId ZaloPay transaction ID
     */
    public void removePendingPayment(String appTransId) {
        pendingPayments.remove(appTransId);
    }

    /**
     * Clean up expired payments (should be called periodically)
     */
    public void cleanupExpiredPayments() {
        LocalDateTime now = LocalDateTime.now();
        pendingPayments.entrySet().removeIf(entry -> now.isAfter(entry.getValue().getExpiresAt()));
    }
}
