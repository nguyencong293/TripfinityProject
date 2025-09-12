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
public class TourDTO {

    private Integer tourId;

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

    private List<@Size(max = 1024) String> imageUrls;

    @DecimalMin(value = "0.00", inclusive = true, message = "ratingAverage phải >= 0.00")
    @DecimalMax(value = "5.00", inclusive = true, message = "ratingAverage phải <= 5.00")
    private BigDecimal ratingAverage;

    private List<@Size(max = 100) String> badges;

    @Size(max = 32)
    private String tourStatus; // published/archived/disabled

    // Chi tiết tour
    private String itineraryOverview;
    @Size(max = 255)
    private String meetingPoint;
    // Cho phép truyền 1 hoặc nhiều ngôn ngữ hướng dẫn
    private List<@Size(max = 100) String> guideLanguage;

    // Cho phép truyền danh sách mục bao gồm/không bao gồm
    private List<@Size(max = 255) String> inclusiveItems;
    private List<@Size(max = 255) String> exclusiveItems;
    private String cancellationPolicy;

    @Size(max = 32)
    private String difficultyLevel; // easy/moderate/hard

    private Integer durationDays;
    @Size(max = 255)
    private String departureLocation;

    private List<@Size(max = 200) String> included; // JSON array stored
    private List<@Size(max = 200) String> excluded; // JSON array stored

    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
