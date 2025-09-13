package com.vn.tripfinity.backend.model;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Entity
@Table(name = "areas")
public class Area {

    public enum AreaType {
        province, city, district
    }

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "area_id")
    private Integer areaId;

    @Column(name = "name", nullable = false, length = 255)
    private String name;

    @Column(name = "slug", nullable = false, unique = true, length = 255)
    private String slug;

    @Enumerated(EnumType.STRING)
    @Column(name = "area_type", nullable = false, length = 32)
    private AreaType areaType;

    @Column(name = "short_description", length = 255)
    private String shortDescription;

    @Column(name = "cover_image_url", length = 512)
    private String coverImageUrl;

    @Column(name = "avg_rating", precision = 3, scale = 2)
    private BigDecimal avgRating;

    @Column(name = "ratings_count")
    private Integer ratingsCount;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    @PrePersist
    public void prePersist() {
        if (avgRating == null)
            avgRating = new BigDecimal("0.00");
        if (ratingsCount == null)
            ratingsCount = 0;
        if (areaType == null)
            areaType = AreaType.province;
    }
}
