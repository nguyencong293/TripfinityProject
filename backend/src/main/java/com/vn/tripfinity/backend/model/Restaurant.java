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
@Table(name = "restaurants")
public class Restaurant {

    public enum RestaurantStatus {
        published, archived, disabled
    }

    public enum Visibility {
        private_, public_
    }

    public enum PriceLevel {
        cheap, moderate, expensive, luxury
    }

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "restaurant_id")
    private Integer restaurantId;

    // FK -> providers.provider_id
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

    @Column(name = "badges", length = 255)
    private String badges;

    @Enumerated(EnumType.STRING)
    @Column(name = "restaurant_status", nullable = false, length = 32)
    private RestaurantStatus restaurantStatus;

    @Enumerated(EnumType.STRING)
    @Column(name = "visibility", nullable = false, length = 16)
    private Visibility visibility;

    @Column(name = "is_featured", nullable = false)
    private Boolean isFeatured;

    @Enumerated(EnumType.STRING)
    @Column(name = "price_level", length = 32)
    private PriceLevel priceLevel;

    @Column(name = "phone", length = 20)
    private String phone;

    @Column(name = "website", length = 255)
    private String website;

    @Column(name = "address", length = 255)
    private String address;

    @Column(name = "latitude", precision = 10, scale = 8)
    private BigDecimal latitude;

    @Column(name = "longitude", precision = 11, scale = 8)
    private BigDecimal longitude;

    @Column(name = "cuisines_json", columnDefinition = "JSON")
    private String cuisinesJson;

    @Column(name = "services_json", columnDefinition = "JSON")
    private String servicesJson;

    @Column(name = "diets_json", columnDefinition = "JSON")
    private String dietsJson;

    @Column(name = "opening_hours_json", columnDefinition = "JSON")
    private String openingHoursJson;

    @Column(name = "menu_highlights_json", columnDefinition = "JSON")
    private String menuHighlightsJson;

    @Column(name = "ambiance_tags_json", columnDefinition = "JSON")
    private String ambianceTagsJson;

    @Column(name = "payment_methods_json", columnDefinition = "JSON")
    private String paymentMethodsJson;

    @Column(name = "policies_text", columnDefinition = "TEXT")
    private String policiesText;

    @Column(name = "slug", length = 255, unique = true)
    private String slug;

    @Column(name = "seo_title", length = 255)
    private String seoTitle;

    @Column(name = "seo_description", length = 512)
    private String seoDescription;

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
        if (restaurantStatus == null)
            restaurantStatus = RestaurantStatus.published;
        if (visibility == null)
            visibility = Visibility.public_;
        if (isFeatured == null)
            isFeatured = false;
        if (currencyCode == null || currencyCode.isEmpty())
            currencyCode = "VND";
    }
}
