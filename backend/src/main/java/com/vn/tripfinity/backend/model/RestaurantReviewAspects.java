package com.vn.tripfinity.backend.model;

import jakarta.persistence.*;
import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Entity
@Table(name = "restaurant_review_aspects")
public class RestaurantReviewAspects {

    @Id
    @Column(name = "review_id")
    private Integer reviewId;

    @OneToOne(fetch = FetchType.LAZY)
    @MapsId
    @JoinColumn(name = "review_id")
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private RestaurantReview review;

    @Column(name = "quality", nullable = false)
    private Integer quality;

    @Column(name = "service", nullable = false)
    private Integer service;

    @Column(name = "price", nullable = false)
    private Integer price;

    @Column(name = "location", nullable = false)
    private Integer location;

    @Column(name = "ambience", nullable = false)
    private Integer ambience;
}
