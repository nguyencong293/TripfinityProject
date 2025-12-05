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
@Table(name = "attractions")
public class Attraction {

    public enum AttractionStatus {
        published, archived, disabled
    }

    public enum Visibility {
        private_, public_
    }

    public enum AttractionType {
        cultural_site, entertainment, historical_site, landmark, museum,
        natural_attraction, other, park, temple, theme_park
    }

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "attraction_id")
    private Integer attractionId;

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
    private String imageUrls;

    @Column(name = "rating_average", precision = 3, scale = 2)
    private BigDecimal ratingAverage;

    @Column(name = "badges", length = 255)
    private String badges;

    @Enumerated(EnumType.STRING)
    @Column(name = "attraction_status", nullable = false, length = 32)
    private AttractionStatus attractionStatus;

    @Enumerated(EnumType.STRING)
    @Column(name = "visibility", nullable = false, length = 16)
    private Visibility visibility;

    @Column(name = "is_featured", nullable = false)
    private Boolean isFeatured;

    @Enumerated(EnumType.STRING)
    @Column(name = "attraction_type", length = 32)
    private AttractionType attractionType;

    @Column(name = "coordinates", length = 100)
    private String coordinates;

    @Column(name = "average_visit_minutes")
    private Integer averageVisitMinutes;

    @Column(name = "visit_types_json", columnDefinition = "JSON")
    private String visitTypesJson;

    @Column(name = "available_times_json", columnDefinition = "JSON")
    private String availableTimesJson;

    @Column(name = "suitable_for_json", columnDefinition = "JSON")
    private String suitableForJson;

    @Column(name = "features_json", columnDefinition = "JSON")
    private String featuresJson;

    @Column(name = "opening_hours_json", columnDefinition = "JSON")
    private String openingHoursJson;

    @Column(name = "highlights_json", columnDefinition = "JSON")
    private String highlightsJson;

    @Column(name = "tips_text", columnDefinition = "TEXT")
    private String tipsText;

    @Column(name = "policies_text", columnDefinition = "TEXT")
    private String policiesText;

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
        if (attractionStatus == null)
            attractionStatus = AttractionStatus.published;
        if (visibility == null)
            visibility = Visibility.public_;
        if (isFeatured == null)
            isFeatured = false;
        if (currencyCode == null || currencyCode.isEmpty())
            currencyCode = "VND";
    }
}
