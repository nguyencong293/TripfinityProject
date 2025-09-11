package com.vn.tripfinity.backend.dto;

import jakarta.validation.constraints.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ServiceTripDTO {

    private Integer serviceId;

    @NotNull(message = "providerId không được để trống")
    private Integer providerId;

    @NotBlank(message = "serviceType không được để trống")
    @Size(max = 32)
    private String serviceType;

    @NotBlank(message = "title không được để trống")
    @Size(max = 255)
    private String title;

    private String serviceDescription;

    @Size(max = 255)
    private String location;

    private LocalDate startDate;
    private LocalDate endDate;

    @NotNull(message = "price không được để trống")
    @DecimalMin(value = "0.0", inclusive = true, message = "price phải >= 0")
    private BigDecimal price;

    @NotBlank(message = "currencyCode không được để trống")
    @Size(max = 3)
    private String currencyCode;

    private Integer capacity;
    private Integer minParticipants;
    private Integer maxParticipants;

    @Size(max = 512)
    private String thumbnailUrl;

    private String imageUrls;

    private BigDecimal ratingAverage;
    private String badges;
    private String serviceStatus;

    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}