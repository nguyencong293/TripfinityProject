package com.vn.tripfinity.backend.dto;

import com.fasterxml.jackson.annotation.JsonAlias;
import jakarta.validation.constraints.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class HotelDTO {

    private Integer hotelId;

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

    @JsonAlias("start_date")
    private LocalDate startDate;

    @JsonAlias("end_date")
    private LocalDate endDate;

    @NotNull(message = "price không được để trống")
    @DecimalMin(value = "0.00", message = "price phải >= 0")
    private BigDecimal price;

    @DecimalMin(value = "0.00", message = "pricePerNight phải >= 0")
    @JsonAlias("price_per_night")
    private BigDecimal pricePerNight;

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
    private List<String> imageUrls; // List of image URLs

    @DecimalMin(value = "0.00", message = "ratingAverage phải >= 0.00")
    @DecimalMax(value = "5.00", message = "ratingAverage phải <= 5.00")
    @JsonAlias("rating_average")
    private BigDecimal ratingAverage;

    private List<String> badges;

    @NotNull(message = "hotelStatus không được để trống")
    @JsonAlias("hotel_status")
    private String hotelStatus; // published, archived, disabled

    @Min(value = 1, message = "starRating phải từ 1-5")
    @Max(value = 5, message = "starRating phải từ 1-5")
    @JsonAlias("star_rating")
    private Integer starRating;

    @JsonAlias("property_type")
    private String propertyType; // hotel, resort, apartment, villa, hostel, guesthouse, homestay

    @Size(max = 255)
    private String address;

    @JsonAlias("checkin_time")
    private LocalTime checkinTime;

    @JsonAlias("checkout_time")
    private LocalTime checkoutTime;

    // Đổi tên field để khớp với database column name
    @JsonAlias("highlights_json")
    private List<Integer> highlightsJson; // JSON array of integers

    @JsonAlias("amenities_json")
    private List<Integer> amenitiesJson; // JSON array of integers

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

    @JsonAlias("is_featured")
    private Boolean isFeatured;

    @JsonAlias("booking_settings_json")
    private String bookingSettingsJson; // JSON string

    @JsonAlias("published_at")
    private LocalDateTime publishedAt;

    @NotNull(message = "visibility không được để trống")
    private String visibility; // public_, private_

    @JsonAlias("created_at")
    private LocalDateTime createdAt;

    @JsonAlias("updated_at")
    private LocalDateTime updatedAt;
}