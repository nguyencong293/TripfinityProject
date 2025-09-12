package com.vn.tripfinity.backend.dto;

import jakarta.validation.constraints.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AttractionDTO {

    private Integer attractionId;

    @NotNull(message = "providerId không được để trống")
    private Integer providerId;

    @NotBlank
    @Size(max = 255)
    private String title;

    private String serviceDescription;

    @Size(max = 255)
    private String location;

    private LocalDate startDate;
    private LocalDate endDate;

    @NotNull
    @DecimalMin(value = "0.00")
    private BigDecimal price;

    @NotBlank
    @Size(min = 3, max = 3)
    private String currencyCode;

    private Integer capacity;
    private Integer minParticipants;
    private Integer maxParticipants;

    @Size(max = 512)
    private String thumbnailUrl;

    private List<@Size(max = 1024) String> imageUrls;

    @DecimalMin(value = "0.00")
    @DecimalMax(value = "5.00")
    private BigDecimal ratingAverage;

    private List<@Size(max = 100) String> badges;

    @Size(max = 32)
    private String attractionStatus;

    @Size(max = 255)
    private String address;

    @Size(max = 100)
    private String coordinates;

    private Integer averageVisitMinutes;

    // JSON arrays
    private List<@Size(max = 100) String> visitTypesJson;
    private List<@Size(max = 100) String> suitableForJson;
    private List<@Size(max = 100) String> featuresJson;
    private List<@Size(max = 200) String> highlightsJson;

    // opening hours and available times can be structured JSON; accept generic
    // map/list
    private Object availableTimesJson;
    private Object openingHoursJson;

    private String tipsText;

    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
