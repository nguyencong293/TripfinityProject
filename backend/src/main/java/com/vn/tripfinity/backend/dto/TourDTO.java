package com.vn.tripfinity.backend.dto;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
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
public class TourDTO {

    private Integer tourId;

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

    @Size(max = 255)
    private String address;

    @DecimalMin(value = "-90.00000000", message = "latitude phải >= -90")
    @DecimalMax(value = "90.00000000", message = "latitude phải <= 90")
    private BigDecimal latitude;

    @DecimalMin(value = "-180.00000000", message = "longitude phải >= -180")
    @DecimalMax(value = "180.00000000", message = "longitude phải <= 180")
    private BigDecimal longitude;

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
    private String tourStatus;

    @Size(max = 32)
    private String visibility; // public/private

    private Boolean isFeatured;

    private Integer durationDays;

    @Size(max = 32)
    private String difficultyLevel; // easy/moderate/hard

    @Size(max = 255)
    private String departureLocation;

    @Size(max = 255)
    private String meetingPoint;

    // Deprecated - use guideLanguagesJson instead
    private List<@Size(max = 100) String> guideLanguage;

    private List<@Size(max = 50) String> guideLanguagesJson; // ["vietnamese","english","chinese","japanese","korean"]

    private String itineraryOverview;

    // Itinerary details: [{"day":1,"title":"","activities":[]}]
    private String itineraryDetailsJson;

    // Deprecated - use includedJson/excludedJson
    private List<@Size(max = 255) String> inclusiveItems;
    private List<@Size(max = 255) String> exclusiveItems;

    // What's included: ["hotel","meals","transport","guide","insurance","entrance_fees"]
    private List<@Size(max = 200) String> includedJson;

    // What's excluded: ["flights","visa","tips","personal_expenses"]
    private List<@Size(max = 200) String> excludedJson;

    private String cancellationPolicy;

    private String policiesText;

    @Size(max = 32)
    private String tourType; // group/private/custom

    // Categories: ["culture","nature","adventure","food","beach","mountain","city","historical"]
    private List<@Size(max = 100) String> categoriesJson;

    // Services: ["pickup","airport_transfer","photography","bike_rental","special_meals"]
    private List<@Size(max = 100) String> servicesJson;

    @Size(max = 255)
    private String slug;

    @Size(max = 255)
    private String seoTitle;

    @Size(max = 512)
    private String seoDescription;

    private String bookingSettingsJson; // JSON string for booking configuration

    private LocalDateTime publishedAt;

    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
