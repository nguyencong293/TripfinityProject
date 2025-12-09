package com.vn.tripfinity.backend.dto;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

import com.fasterxml.jackson.annotation.JsonAlias;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class RestaurantBookingDTO {

    private Integer bookingId;

    @NotNull(message = "userId không được để trống")
    @JsonAlias("user_id")
    private Integer userId;

    @NotNull(message = "restaurantId không được để trống")
    @JsonAlias("restaurant_id")
    private Integer restaurantId;

    @JsonAlias("booking_date")
    private LocalDateTime bookingDate;

    @JsonAlias("reservation_date")
    private LocalDate reservationDate;

    @JsonAlias("reservation_time")
    private String reservationTime;

    @JsonAlias("start_date")
    private LocalDate startDate;

    @JsonAlias("end_date")
    private LocalDate endDate;

    @NotNull(message = "numAdults không được để trống")
    @Min(value = 1, message = "numAdults phải >= 1")
    @JsonAlias("num_adults")
    private Integer numAdults;

    @JsonAlias("special_requests")
    private String specialRequests;

    @NotNull(message = "totalPrice không được để trống")
    @DecimalMin(value = "0.00", message = "totalPrice phải >= 0")
    @JsonAlias("total_price")
    private BigDecimal totalPrice;

    @JsonAlias("deposit_amount")
    private BigDecimal depositAmount;

    @Size(max = 3)
    @JsonAlias("currency_code")
    private String currencyCode;

    @JsonAlias("booking_status")
    private String bookingStatus; // pending, confirmed, cancelled, completed, refunded

    @JsonAlias("payment_method")
    private String paymentMethod; // counter, zalopay, vnpay, etc.

    @Size(max = 512)
    @JsonAlias("e_ticket_url")
    private String eTicketUrl;

    @JsonAlias("qr_code_data")
    private String qrCodeData;

    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    @JsonAlias("provider_id")
    private Integer providerId;

    @Size(max = 100)
    private String channel;

    @JsonAlias("hold_until")
    private LocalDateTime holdUntil;

    @JsonAlias("provider_seen")
    private Boolean providerSeen;

    @JsonAlias("provider_notes")
    private String providerNotes;

    @JsonAlias("provider_confirmed")
    private Integer providerConfirmed; // 0=pending, 1=confirmed, 2=cancelled

    @JsonAlias("provider_confirmed_at")
    private LocalDateTime providerConfirmedAt;
}
