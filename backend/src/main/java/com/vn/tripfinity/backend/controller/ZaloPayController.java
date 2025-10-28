package com.vn.tripfinity.backend.controller;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.vn.tripfinity.backend.dto.HotelBookingDTO;
import com.vn.tripfinity.backend.dto.PendingPaymentDto;
import com.vn.tripfinity.backend.service.HotelBookingService;
import com.vn.tripfinity.backend.service.PendingPaymentService;
import com.vn.tripfinity.backend.service.ZaloPayService;
import com.vn.tripfinity.backend.util.HmacUtil;
import com.vn.tripfinity.backend.config.ZaloPayProperties;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.Map;

@RestController
@RequestMapping("/api/zalopay")
@RequiredArgsConstructor
@Slf4j
@CrossOrigin(origins = "*")
public class ZaloPayController {

    private final ZaloPayService zaloPayService;
    private final PendingPaymentService pendingPaymentService;
    private final HotelBookingService hotelBookingService;
    private final ZaloPayProperties zaloPayProperties;
    private final ObjectMapper objectMapper;

    /**
     * Create ZaloPay order with pending payment info
     * This should be called BEFORE creating booking
     */
    @PostMapping("/create-order")
    public ResponseEntity<Map<String, Object>> createOrder(
            @RequestParam BigDecimal amount,
            @RequestParam Integer userId,
            @RequestParam Integer hotelId,
            @RequestParam LocalDate startDate,
            @RequestParam LocalDate endDate,
            @RequestParam Integer numAdults,
            @RequestParam Integer numChildren,
            @RequestParam(required = false) String providerNotes,
            @RequestParam(required = false) String description) {

        log.info("Creating ZaloPay order for user={}, hotel={}, amount={}", userId, hotelId, amount);

        // Create order in ZaloPay
        Map<String, Object> result = zaloPayService.createOrder(amount, userId.toString(), description);
        String appTransId = (String) result.get("apptransid");

        // Store pending payment info
        PendingPaymentDto pendingPayment = PendingPaymentDto.builder()
                .userId(userId)
                .hotelId(hotelId)
                .startDate(startDate)
                .endDate(endDate)
                .numAdults(numAdults)
                .numChildren(numChildren)
                .totalPrice(amount)
                .currencyCode("VND")
                .providerNotes(providerNotes)
                .build();

        pendingPaymentService.storePendingPayment(appTransId, pendingPayment);

        log.info("Stored pending payment for transaction: {}", appTransId);

        return ResponseEntity.ok(result);
    }

    /**
     * ZaloPay callback - called when payment is successful
     * This is where we create the actual booking and payment record
     */
    @PostMapping("/callback")
    public ResponseEntity<Map<String, Object>> callback(
            @RequestParam(required = false) String data,
            @RequestParam(required = false) String mac,
            @RequestBody(required = false) String jsonBody) {
        try {
            log.info("=== ZaloPay Callback Received ===");
            log.info("Form data param: {}", data);
            log.info("Form mac param: {}", mac);
            log.info("JSON body: {}", jsonBody);

            String dataStr;
            String reqMac;

            // ZaloPay can send either form-encoded or JSON
            if (data != null && mac != null) {
                // Form-encoded callback
                dataStr = data;
                reqMac = mac;
            } else if (jsonBody != null && !jsonBody.isEmpty()) {
                // JSON callback
                JsonNode callbackJson = objectMapper.readTree(jsonBody);
                dataStr = callbackJson.get("data").asText();
                reqMac = callbackJson.get("mac").asText();
            } else {
                log.error("No callback data received");
                return ResponseEntity.ok(Map.of("return_code", 0, "return_message", "no data"));
            }

            log.info("Processing callback data: {}", dataStr);

            log.info("Processing callback data: {}", dataStr);

            // Verify MAC
            String calculatedMac = HmacUtil.hmacSha256Hex(zaloPayProperties.getKey2(), dataStr);

            if (!reqMac.equals(calculatedMac)) {
                log.error("Invalid MAC signature. Expected: {}, Got: {}", calculatedMac, reqMac);
                return ResponseEntity.ok(Map.of("return_code", -1, "return_message", "mac not equal"));
            }

            log.info("MAC verified successfully");

            log.info("MAC verified successfully");

            // Parse data
            JsonNode dataJson = objectMapper.readTree(dataStr);
            String appTransId = dataJson.get("apptransid").asText();
            long amount = dataJson.get("amount").asLong();

            log.info("Payment successful for transaction: {}, amount: {}", appTransId, amount);

            // Get pending payment info
            PendingPaymentDto pendingPayment = pendingPaymentService.getPendingPayment(appTransId);

            if (pendingPayment == null) {
                log.error("Pending payment not found for transaction: {}", appTransId);
                return ResponseEntity.ok(Map.of("return_code", 0, "return_message", "payment not found but accepted"));
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
                    .providerNotes(pendingPayment.getProviderNotes()) // Include provider notes (rooms, beds, requests)
                    .bookingStatus("confirmed") // Immediately confirmed because payment is successful
                    .paymentMethod("zalopay")
                    .channel("mobile_app")
                    .build();

            HotelBookingDTO createdBooking = hotelBookingService.createBooking(bookingDto);

            log.info("Created booking #{} for transaction {}", createdBooking.getBookingId(), appTransId);

            // Remove pending payment
            pendingPaymentService.removePendingPayment(appTransId);

            // Return success to ZaloPay
            return ResponseEntity.ok(Map.of("return_code", 1, "return_message", "success"));

        } catch (Exception e) {
            log.error("Error processing ZaloPay callback", e);
            return ResponseEntity.ok(Map.of("return_code", 0, "return_message", "exception: " + e.getMessage()));
        }
    }
}
