package com.vn.tripfinity.backend.dto;

import jakarta.validation.constraints.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class HotelDTO {

    private Integer hotelId;

    @NotNull(message = "providerId không được để trống")
    private Integer providerId;

    @NotBlank(message = "title không được để trống")
    @Size(max = 255)
    private String title;

    private String serviceDescription;

    @Size(max = 255)
    private String location;

    private LocalDate startDate;
    private LocalDate endDate;

    @NotNull(message = "price không được để trống")
    @DecimalMin(value = "0.00", inclusive = true, message = "price phải >= 0.00")
    private BigDecimal price;

    @NotBlank(message = "currencyCode không được để trống")
    @Size(min = 3, max = 3, message = "currencyCode phải là 3 ký tự")
    private String currencyCode;

    private Integer capacity;
    private Integer minParticipants;
    private Integer maxParticipants;

    @Size(max = 512)
    private String thumbnailUrl;

    private String imageUrls;

    @DecimalMin(value = "0.00", inclusive = true, message = "ratingAverage phải >= 0.00")
    @DecimalMax(value = "5.00", inclusive = true, message = "ratingAverage phải <= 5.00")
    private BigDecimal ratingAverage;

    @Size(max = 255)
    private String badges;

    // published/archived/disabled
    @Size(max = 32)
    private String hotelStatus;

    @Min(value = 1, message = "starRating phải >= 1")
    @Max(value = 5, message = "starRating phải <= 5")
    private Integer starRating;

    // hotel, resort, apartment, villa, hostel, guesthouse, homestay
    @Size(max = 32)
    private String propertyType;

    @Size(max = 255)
    private String address;

    private LocalTime checkinTime;
    private LocalTime checkoutTime;

    private String highlightsJson;
    private String amenitiesJson;
    private String policiesText;

    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}