package com.vn.tripfinity.backend.model;

import jakarta.persistence.*;
import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Entity
@Table(name = "tour_review_aspects")
public class TourReviewAspects {

    @Id
    @Column(name = "review_id")
    private Integer reviewId;

    @OneToOne(fetch = FetchType.LAZY)
    @MapsId
    @JoinColumn(name = "review_id")
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private TourReview review;

    @Column(name = "guide_quality", nullable = false)
    private Integer guideQuality;

    @Column(name = "itinerary_quality", nullable = false)
    private Integer itineraryQuality;

    @Column(name = "value_for_money", nullable = false)
    private Integer valueForMoney;

    @Column(name = "organization", nullable = false)
    private Integer organization;

    @Column(name = "safety", nullable = false)
    private Integer safety;
}
