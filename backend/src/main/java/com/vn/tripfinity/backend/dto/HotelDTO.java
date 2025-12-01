package com.vn.tripfinity.backend.dto;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;

import com.fasterxml.jackson.annotation.JsonAlias;

import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
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

    // Tổng số phòng của khách sạn
    @JsonAlias("total_rooms")
    private Integer totalRooms;

    // Số phòng còn lại (calculated field, not in database)
    @JsonAlias("available_rooms")
    private Integer availableRooms;

    // Sức chứa còn lại (calculated field, not in database)
    @JsonAlias("available_capacity")
    private Integer availableCapacity;

    // Số giường tối đa trên 1 phòng (>=1)
    @Min(value = 1, message = "maxBedsPerRoom phải >= 1")
    @JsonAlias("max_beds_per_room")
    private Integer maxBedsPerRoom;

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

    @DecimalMin(value = "-90.0", message = "latitude phải >= -90.0")
    @DecimalMax(value = "90.0", message = "latitude phải <= 90.0")
    private BigDecimal latitude;

    @DecimalMin(value = "-180.0", message = "longitude phải >= -180.0")
    @DecimalMax(value = "180.0", message = "longitude phải <= 180.0")
    private BigDecimal longitude;

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



    @JsonAlias("published_at")
    private LocalDateTime publishedAt;

    @NotNull(message = "visibility không được để trống")
    private String visibility; // public_, private_

    @JsonAlias("created_at")
    private LocalDateTime createdAt;

    @JsonAlias("updated_at")
    private LocalDateTime updatedAt;
}