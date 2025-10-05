package com.vn.tripfinity.backend.model;

import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Entity
@Table(name = "hotel_rating_summaries")
public class HotelRatingSummary {

    @Id
    @Column(name = "hotel_id")
    private Integer hotelId;

    @OneToOne(fetch = FetchType.LAZY)
    @MapsId
    @JoinColumn(name = "hotel_id")
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private Hotel hotel;

    @Column(name = "avg_rating", nullable = false, precision = 3, scale = 2)
    private BigDecimal avgRating;

    @Column(name = "total_reviews", nullable = false)
    private Integer totalReviews;

    @Column(name = "count_1", nullable = false)
    private Integer count1;

    @Column(name = "count_2", nullable = false)
    private Integer count2;

    @Column(name = "count_3", nullable = false)
    private Integer count3;

    @Column(name = "count_4", nullable = false)
    private Integer count4;

    @Column(name = "count_5", nullable = false)
    private Integer count5;

    @Column(name = "avg_cleanliness", precision = 3, scale = 2)
    private BigDecimal avgCleanliness;

    @Column(name = "avg_service", precision = 3, scale = 2)
    private BigDecimal avgService;

    @Column(name = "avg_value_for_money", precision = 3, scale = 2)
    private BigDecimal avgValueForMoney;

    @Column(name = "avg_location", precision = 3, scale = 2)
    private BigDecimal avgLocation;

    @Column(name = "avg_facilities", precision = 3, scale = 2)
    private BigDecimal avgFacilities;

    @PrePersist
    public void prePersist() {
        if (avgRating == null)
            avgRating = new BigDecimal("0.00");
        if (totalReviews == null)
            totalReviews = 0;
        if (count1 == null)
            count1 = 0;
        if (count2 == null)
            count2 = 0;
        if (count3 == null)
            count3 = 0;
        if (count4 == null)
            count4 = 0;
        if (count5 == null)
            count5 = 0;
    }
}