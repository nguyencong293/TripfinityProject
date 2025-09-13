package com.vn.tripfinity.backend.dto;

import jakarta.validation.constraints.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class RestaurantDTO {

    private Integer restaurantId;

    @NotNull(message = "providerId không được để trống")
    private Integer providerId;

    @NotNull(message = "areaId không được để trống")
    private Integer areaId;

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

    // Cho phép gửi danh sách URL ảnh
    private List<@Size(max = 1024) String> imageUrls;

    @DecimalMin(value = "0.00", inclusive = true, message = "ratingAverage phải >= 0.00")
    @DecimalMax(value = "5.00", inclusive = true, message = "ratingAverage phải <= 5.00")
    private BigDecimal ratingAverage;

    // Cho phép gửi danh sách badges
    private List<@Size(max = 100) String> badges;

    // published/archived/disabled
    @Size(max = 32)
    private String restaurantStatus;

    // cheap/moderate/expensive/luxury
    @Size(max = 32)
    private String priceLevel;

    @Size(max = 20)
    private String phone;

    @Size(max = 255)
    private String website;

    @Size(max = 255)
    private String address;

    // Các trường dạng cấu trúc sẽ được service chuyển sang JSON string khi lưu DB
    private List<@Size(max = 100) String> cuisines;
    private List<@Size(max = 100) String> services;
    private List<@Size(max = 100) String> diets;
    private Map<String, List<Map<String, String>>> openingHours;

    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
