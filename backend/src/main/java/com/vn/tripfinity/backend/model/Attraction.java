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
@Table(name = "attractions")
public class Attraction {

    public enum AttractionStatus {
        published, archived, disabled
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

    // Specific fields
    @Column(name = "address", length = 255)
    private String address;

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
    }
}
