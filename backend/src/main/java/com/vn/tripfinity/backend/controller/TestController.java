package com.vn.tripfinity.backend.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import com.vn.tripfinity.backend.dto.HotelBookingDTO;
import com.vn.tripfinity.backend.dto.PendingPaymentDto;
import com.vn.tripfinity.backend.service.HotelBookingService;
import com.vn.tripfinity.backend.service.PendingPaymentService;

import java.util.Map;

/**
 * Test endpoint to manually trigger booking creation from pending payment
 * Use this to test if callback logic works correctly
 */
@RestController
@RequestMapping("/api/test")
public class TestController {

    @Autowired
    private PendingPaymentService pendingPaymentService;

    @Autowired
    private HotelBookingService hotelBookingService;

    @PostMapping("/create-booking-from-pending")
    public Map<String, Object> createBookingFromPending(@RequestParam String appTransId) {
        try {
            PendingPaymentDto pendingPayment = pendingPaymentService.getPendingPayment(appTransId);

            if (pendingPayment == null) {
                return Map.of("success", false, "message", "Pending payment not found: " + appTransId);
            }

            // Create booking
            HotelBookingDTO bookingDto = HotelBookingDTO.builder()
                    .userId(pendingPayment.getUserId())
                    .hotelId(pendingPayment.getHotelId())
                    .startDate(pendingPayment.getStartDate())
                    .endDate(pendingPayment.getEndDate())
                    .numAdults(pendingPayment.getNumAdults())
                    .numChildren(pendingPayment.getNumChildren())
                    .totalPrice(pendingPayment.getTotalPrice())
                    .currencyCode(pendingPayment.getCurrencyCode())
                    .providerNotes(pendingPayment.getProviderNotes()) // Include provider notes
                    .bookingStatus("confirmed")
                    .paymentMethod("zalopay")
                    .channel("mobile_app")
                    .build();

            HotelBookingDTO createdBooking = hotelBookingService.createBooking(bookingDto);

            // Remove pending payment
            pendingPaymentService.removePendingPayment(appTransId);

            return Map.of(
                    "success", true,
                    "message", "Booking created successfully",
                    "bookingId", createdBooking.getBookingId(),
                    "transactionId", appTransId);

        } catch (Exception e) {
            return Map.of(
                    "success", false,
                    "message", "Error: " + e.getMessage(),
                    "error", e.getClass().getSimpleName());
        }
    }
}
