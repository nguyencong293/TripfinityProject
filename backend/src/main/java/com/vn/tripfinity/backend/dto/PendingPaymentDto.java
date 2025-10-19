package com.vn.tripfinity.backend.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PendingPaymentDto {
    private String appTransId; // ZaloPay transaction ID
    private Integer userId;
    private Integer hotelId;
    private LocalDate startDate;
    private LocalDate endDate;
    private Integer numAdults;
    private Integer numChildren;
    private BigDecimal totalPrice;
    private String currencyCode;
    private String providerNotes; // Contains rooms, beds, special requests
    private LocalDateTime createdAt;
    private LocalDateTime expiresAt; // Payment expires after 15 minutes
}
