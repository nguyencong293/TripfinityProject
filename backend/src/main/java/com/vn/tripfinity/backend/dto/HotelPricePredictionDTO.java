package com.vn.tripfinity.backend.dto;

import com.fasterxml.jackson.annotation.JsonAlias;
import jakarta.validation.constraints.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class HotelPricePredictionDTO {

    private Integer predictionId;

    @NotNull(message = "hotelId không được để trống")
    @JsonAlias("hotel_id")
    private Integer hotelId;

    @NotNull(message = "predictedDate không được để trống")
    @JsonAlias("predicted_date")
    private LocalDate predictedDate;

    @NotNull(message = "predictedPrice không được để trống")
    @DecimalMin(value = "0.00", message = "predictedPrice phải >= 0")
    @JsonAlias("predicted_price")
    private BigDecimal predictedPrice;

    @Size(max = 3)
    @JsonAlias("currency_code")
    private String currencyCode;

    @Size(max = 100)
    @JsonAlias("model_name")
    private String modelName;

    private LocalDateTime createdAt;
}