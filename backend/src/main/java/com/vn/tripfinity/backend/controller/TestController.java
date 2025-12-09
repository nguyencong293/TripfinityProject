package com.vn.tripfinity.backend.controller;

import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.vn.tripfinity.backend.dto.HotelBookingDTO;
import com.vn.tripfinity.backend.dto.RestaurantBookingDTO;
import com.vn.tripfinity.backend.dto.PendingPaymentDto;
import com.vn.tripfinity.backend.service.HotelBookingService;
import com.vn.tripfinity.backend.service.RestaurantBookingService;
import com.vn.tripfinity.backend.service.PendingPaymentService;

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

    @Autowired
    private RestaurantBookingService restaurantBookingService;

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

    @PostMapping("/create-restaurant-booking-from-pending")
    public Map<String, Object> createRestaurantBookingFromPending(@RequestParam String appTransId) {
        try {
            PendingPaymentDto pendingPayment = pendingPaymentService.getPendingPayment(appTransId);

            if (pendingPayment == null) {
                return Map.of("success", false, "message", "Pending payment not found: " + appTransId);
            }

            // Create restaurant booking
            RestaurantBookingDTO bookingDto = RestaurantBookingDTO.builder()
                    .userId(pendingPayment.getUserId())
                    .restaurantId(pendingPayment.getRestaurantId())
                    .startDate(pendingPayment.getStartDate())
                    .numAdults(pendingPayment.getNumAdults())
                    .totalPrice(pendingPayment.getTotalPrice())
                    .currencyCode(pendingPayment.getCurrencyCode())
                    .providerNotes(pendingPayment.getProviderNotes())
                    .bookingStatus("confirmed")
                    .paymentMethod("zalopay")
                    .channel("mobile_app")
                    .build();

            RestaurantBookingDTO createdBooking = restaurantBookingService.createBooking(bookingDto);

            // Remove pending payment
            pendingPaymentService.removePendingPayment(appTransId);

            return Map.of(
                    "success", true,
                    "message", "Restaurant booking created successfully",
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
