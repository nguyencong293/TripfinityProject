package com.vn.tripfinity.backend.dto;

import com.fasterxml.jackson.annotation.JsonAlias;
import jakarta.validation.constraints.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class HotelPriceAlertDTO {

    private Integer alertId;

    @NotNull(message = "userId không được để trống")
    @JsonAlias("user_id")
    private Integer userId;

    @NotNull(message = "hotelId không được để trống")
    @JsonAlias("hotel_id")
    private Integer hotelId;

    @NotNull(message = "targetPrice không được để trống")
    @DecimalMin(value = "0.00", message = "targetPrice phải >= 0")
    @JsonAlias("target_price")
    private BigDecimal targetPrice;

    @Size(max = 3)
    @JsonAlias("currency_code")
    private String currencyCode;

    @JsonAlias("is_active")
    private Boolean isActive;

    @JsonAlias("last_notified_at")
    private LocalDateTime lastNotifiedAt;

    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}