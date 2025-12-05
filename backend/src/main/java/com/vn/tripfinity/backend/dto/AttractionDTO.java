package com.vn.tripfinity.backend.dto;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

import com.fasterxml.jackson.annotation.JsonAlias;

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
public class AttractionDTO {

    @JsonAlias("attraction_id")
    private Integer attractionId;

    @NotNull(message = "providerId không được để trống")
    @JsonAlias("provider_id")
    private Integer providerId;

    @NotNull(message = "areaId không được để trống")
    @JsonAlias("area_id")
    private Integer areaId;

    @NotBlank(message = "title không được để trống")
    @Size(max = 255)
    private String title;

    @Size(max = 5000)
    @JsonAlias("service_description")
    private String serviceDescription;

    @Size(max = 255)
    private String location;

    @Size(max = 255)
    private String address;

    @DecimalMin(value = "-90.0", message = "latitude phải >= -90.0")
    @DecimalMax(value = "90.0", message = "latitude phải <= 90.0")
    private BigDecimal latitude;

    @DecimalMin(value = "-180.0", message = "longitude phải >= -180.0")
    @DecimalMax(value = "180.0", message = "longitude phải <= 180.0")
    private BigDecimal longitude;

    @JsonAlias("start_date")
    private LocalDate startDate;

    @JsonAlias("end_date")
    private LocalDate endDate;

    @NotNull(message = "price không được để trống")
    @DecimalMin(value = "0.00", message = "price phải >= 0")
    private BigDecimal price;

    @NotBlank(message = "currencyCode không được để trống")
    @Size(max = 3)
    @JsonAlias("currency_code")
    private String currencyCode;

    private Integer capacity;

    @JsonAlias("min_participants")
    private Integer minParticipants;

    @JsonAlias("max_participants")
    private Integer maxParticipants;

    @Size(max = 512)
    @JsonAlias("thumbnail_url")
    private String thumbnailUrl;

    @JsonAlias("image_urls")
    private List<String> imageUrls;

    @DecimalMin(value = "0.00", message = "ratingAverage phải >= 0.00")
    @DecimalMax(value = "5.00", message = "ratingAverage phải <= 5.00")
    @JsonAlias("rating_average")
    private BigDecimal ratingAverage;

    private List<String> badges;

    @NotNull(message = "attractionStatus không được để trống")
    @JsonAlias("attraction_status")
    private String attractionStatus; // published, archived, disabled

    @NotNull(message = "visibility không được để trống")
    private String visibility; // public_, private_

    @JsonAlias("is_featured")
    private Boolean isFeatured;

    @JsonAlias("attraction_type")
    private String attractionType; // cultural_site, entertainment, historical_site, etc.

    @Size(max = 100)
    private String coordinates;

    @JsonAlias("average_visit_minutes")
    private Integer averageVisitMinutes;

    // JSON arrays
    @JsonAlias("visit_types_json")
    private List<String> visitTypesJson; // ["guided_tour", "self_guided", "audio_guide", "virtual_tour"]

    @JsonAlias("available_times_json")
    private List<String> availableTimesJson; // Array of time slots

    @JsonAlias("suitable_for_json")
    private List<String> suitableForJson; // ["family", "kids", "elderly", "couples", "groups", "solo", "pets"]

    @JsonAlias("features_json")
    private List<Integer> featuresJson; // Array of feature IDs

    @JsonAlias("opening_hours_json")
    private Object openingHoursJson; // Object: {"monday":"08:00-17:00", "tuesday":"08:00-17:00",...}

    @JsonAlias("highlights_json")
    private List<Integer> highlightsJson; // Array of highlight IDs

    @JsonAlias("tips_text")
    private String tipsText;

    @JsonAlias("policies_text")
    private String policiesText;

    @Size(max = 255)
    private String slug;

    @Size(max = 255)
    @JsonAlias("seo_title")
    private String seoTitle;

    @Size(max = 512)
    @JsonAlias("seo_description")
    private String seoDescription;

    @JsonAlias("booking_settings_json")
    private Object bookingSettingsJson;

    @JsonAlias("published_at")
    private LocalDateTime publishedAt;

    @JsonAlias("created_at")
    private LocalDateTime createdAt;

    @JsonAlias("updated_at")
    private LocalDateTime updatedAt;
}
