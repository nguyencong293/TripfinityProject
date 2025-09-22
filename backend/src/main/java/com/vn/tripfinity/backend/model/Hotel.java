package com.vn.tripfinity.backend.model;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Entity
@Table(name = "hotels")
public class Hotel {

    public enum HotelStatus {
        published, archived, disabled
    }

    public enum PropertyType {
        hotel, resort, apartment, villa, hostel, guesthouse, homestay
    }

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "hotel_id")
    private Integer hotelId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "provider_id", nullable = false)
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private Provider provider;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "area_id", nullable = false)
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private Area area;

    // Chung
    @Column(name = "title", nullable = false, length = 255)
    private String title;

    @Column(name = "service_description", columnDefinition = "TEXT")
    private String serviceDescription;

    @Column(name = "location", length = 255)
    private String location;

    @Column(name = "start_date")
    private LocalDate startDate;

    @Column(name = "end_date")
    private LocalDate endDate;

    @Column(name = "price", nullable = false, precision = 12, scale = 2)
    private BigDecimal price;

    @Column(name = "currency_code", nullable = false, length = 3)
    private String currencyCode;

    @Column(name = "capacity")
    private Integer capacity;

    @Column(name = "min_participants")
    private Integer minParticipants;

    @Column(name = "max_participants")
    private Integer maxParticipants;

    @Column(name = "thumbnail_url", length = 512)
    private String thumbnailUrl;

    @Column(name = "image_urls", columnDefinition = "TEXT")
    private String imageUrls;

    @Column(name = "rating_average", precision = 3, scale = 2)
    private BigDecimal ratingAverage;

    @Column(name = "badges", length = 255)
    private String badges;

    @Enumerated(EnumType.STRING)
    @Column(name = "hotel_status", nullable = false, length = 32)
    private HotelStatus hotelStatus;

    @Column(name = "star_rating")
    private Integer starRating; // 1..5

    @Enumerated(EnumType.STRING)
    @Column(name = "property_type", length = 32)
    private PropertyType propertyType;

    @Column(name = "address", length = 255)
    private String address;

    @Column(name = "checkin_time")
    private LocalTime checkinTime;

    @Column(name = "checkout_time")
    private LocalTime checkoutTime;

    @Column(name = "highlights_json", columnDefinition = "JSON")
    private String highlightsJson;

    @Column(name = "amenities_json", columnDefinition = "JSON")
    private String amenitiesJson;

    @Column(name = "policies_text", columnDefinition = "TEXT")
    private String policiesText;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false, columnDefinition = "DATETIME DEFAULT CURRENT_TIMESTAMP")
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false, columnDefinition = "DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP")
    private LocalDateTime updatedAt;

    @PrePersist
    public void prePersist() {
        if (ratingAverage == null)
            ratingAverage = new BigDecimal("0.00");
        if (hotelStatus == null)
            hotelStatus = HotelStatus.published;
        if (propertyType == null)
            propertyType = PropertyType.hotel;
    }
}