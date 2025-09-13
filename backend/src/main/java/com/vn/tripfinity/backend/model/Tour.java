package com.vn.tripfinity.backend.model;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

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
    private String imageUrls; // CSV

    @Column(name = "rating_average", precision = 3, scale = 2)
    private BigDecimal ratingAverage;

    @Column(name = "badges", length = 255)
    private String badges; // CSV

    @Enumerated(EnumType.STRING)
    @Column(name = "tour_status", nullable = false, length = 32)
    private TourStatus tourStatus;

    // Chi tiết tour
    @Column(name = "itinerary_overview", columnDefinition = "TEXT")
    private String itineraryOverview;

    @Column(name = "meeting_point", length = 255)
    private String meetingPoint;

    @Column(name = "guide_language", length = 100)
    private String guideLanguage;

    @Column(name = "inclusive_items", columnDefinition = "TEXT")
    private String inclusiveItems;

    @Column(name = "exclusive_items", columnDefinition = "TEXT")
    private String exclusiveItems;

    @Column(name = "cancellation_policy", columnDefinition = "TEXT")
    private String cancellationPolicy;

    @Enumerated(EnumType.STRING)
    @Column(name = "difficulty_level", length = 32)
    private DifficultyLevel difficultyLevel;

    @Column(name = "duration_days")
    private Integer durationDays;

    @Column(name = "departure_location", length = 255)
    private String departureLocation;

    @Column(name = "included_json", columnDefinition = "JSON")
    private String includedJson;

    @Column(name = "excluded_json", columnDefinition = "JSON")
    private String excludedJson;

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
    }
}
