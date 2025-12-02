package com.vn.tripfinity.backend.model;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;
import lombok.ToString;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Entity
@Table(name = "tours")
public class Tour {

    public enum TourStatus {
        published, archived, disabled
    }

    public enum DifficultyLevel {
        easy, moderate, hard
    }

    public enum Visibility {
        public_, private_
    }

    public enum TourType {
        group, private_, custom
    }

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "tour_id")
    private Integer tourId;

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

    @Column(name = "title", nullable = false, length = 255)
    private String title;

    @Column(name = "service_description", columnDefinition = "TEXT")
    private String serviceDescription;

    @Column(name = "location", length = 255)
    private String location;

    @Column(name = "address", length = 255)
    private String address;

    @Column(name = "latitude", precision = 10, scale = 8)
    private BigDecimal latitude;

    @Column(name = "longitude", precision = 11, scale = 8)
    private BigDecimal longitude;

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
    private String imageUrls; // JSON array string: ["url1", "url2", ...]

    @Column(name = "rating_average", precision = 3, scale = 2)
    private BigDecimal ratingAverage;

    @Column(name = "badges", length = 255)
    private String badges; // JSON array string

    @Enumerated(EnumType.STRING)
    @Column(name = "tour_status", nullable = false, length = 32)
    private TourStatus tourStatus;

    @Enumerated(EnumType.STRING)
    @Column(name = "visibility", nullable = false, length = 32)
    private Visibility visibility;

    @Column(name = "is_featured", nullable = false)
    private Boolean isFeatured;

    @Column(name = "duration_days")
    private Integer durationDays;

    @Enumerated(EnumType.STRING)
    @Column(name = "difficulty_level", length = 32)
    private DifficultyLevel difficultyLevel;

    @Column(name = "departure_location", length = 255)
    private String departureLocation;

    @Column(name = "meeting_point", length = 255)
    private String meetingPoint;

    @Column(name = "guide_language", length = 100)
    private String guideLanguage; // deprecated

    @Column(name = "guide_languages_json", columnDefinition = "JSON")
    private String guideLanguagesJson;

    @Column(name = "itinerary_overview", columnDefinition = "TEXT")
    private String itineraryOverview;

    @Column(name = "itinerary_details_json", columnDefinition = "JSON")
    private String itineraryDetailsJson;

    @Column(name = "inclusive_items", columnDefinition = "TEXT")
    private String inclusiveItems; // deprecated

    @Column(name = "exclusive_items", columnDefinition = "TEXT")
    private String exclusiveItems; // deprecated

    @Column(name = "included_json", columnDefinition = "JSON")
    private String includedJson;

    @Column(name = "excluded_json", columnDefinition = "JSON")
    private String excludedJson;

    @Column(name = "cancellation_policy", columnDefinition = "TEXT")
    private String cancellationPolicy;

    @Column(name = "policies_text", columnDefinition = "TEXT")
    private String policiesText;

    @Enumerated(EnumType.STRING)
    @Column(name = "tour_type", length = 32)
    private TourType tourType;

    @Column(name = "categories_json", columnDefinition = "JSON")
    private String categoriesJson;

    @Column(name = "services_json", columnDefinition = "JSON")
    private String servicesJson;

    @Column(name = "slug", length = 255, unique = true)
    private String slug;

    @Column(name = "seo_title", length = 255)
    private String seoTitle;

    @Column(name = "seo_description", length = 512)
    private String seoDescription;

    @Column(name = "booking_settings_json", columnDefinition = "JSON")
    private String bookingSettingsJson;

    @Column(name = "published_at")
    private LocalDateTime publishedAt;

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
        if (tourStatus == null)
            tourStatus = TourStatus.published;
        if (visibility == null)
            visibility = Visibility.public_;
        if (isFeatured == null)
            isFeatured = false;
        if (tourType == null)
            tourType = TourType.group;
        if (currencyCode == null)
            currencyCode = "VND";
    }
}
